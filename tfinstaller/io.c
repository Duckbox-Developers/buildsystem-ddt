/***********************************************************
	io.c -- input/output
***********************************************************/
#include "ar.h"
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <netinet/in.h>

#define CRCPOLY  0xA001  /* ANSI CRC-16 */
                         /* CCITT: 0x8408 */
#define UPDATE_CRC(c) \
	crc = crctable[(crc ^ (c)) & 0xFF] ^ (crc >> CHAR_BIT)

static ushort crctable[UCHAR_MAX + 1];
static uint subbitbuf;
static int bitcount;

//-----------------------------------------------------------------
// added by Phantomias
uint available;
uint inputIndex;
uint inputCount;
uchar inBuf[MAX_BLOCK_SIZE + 16];
uchar outBuf[MAX_BLOCK_SIZE + 10];

static int headerSet = 0;
static int eofFound = 0;

//------------------------------------------------------------------
// CRC-16 calculation algorithm
ushort crc16(ushort crc16, int len, uchar *buf)
{
	int i;

	for (i = 0; i < len; i++)
	{
		crc16 = ((crc16 >> 8) & 0xff) ^ crctable[(crc16 ^ *buf++) & 0xff];
	}
	return crc16;
}

void setBinaryHeader(uint loadAddr, uint entryAddr, int fileSize)
{
	uint *pBuf = (uint*)inBuf;

	pBuf[0] = loadAddr;
	pBuf[1] = fileSize + 16;
	pBuf[2] = entryAddr;
	pBuf[3] = loadAddr + fileSize + 32;
	headerSet = 1;
}

int readInput(FILE *pFile)
{
	uchar *pBuf = inBuf;
	int size = MAX_BLOCK_SIZE;
	int offset = 0;

	crc = INIT_CRC;
	if (headerSet)
	{
		offset = 16;
		pBuf += offset;
		size = MAX_BLOCK_SIZE - 16;
		headerSet = 0;
	}
	inputCount = fread(pBuf, 1, size, pFile);

	if ((inputCount < size) && !eofFound)
	{
		// no more data, append 0x01 0x00 0x00 0x00
		pBuf[inputCount + 0] = 0x01;
		pBuf[inputCount + 1] = 0x00;
		pBuf[inputCount + 2] = 0x00;
		pBuf[inputCount + 3] = 0x00;
		inputCount += 4;
		eofFound = 1;
	}

	inputCount += offset;

	available = inputCount;
	inputIndex = 0;
	return available;
}

void copyInput()
{
	memcpy(outBuf, inBuf, inputCount);
	compsize = inputCount;
}

int writeOutput(FILE *pFile, int tfd)
{
	int count = 0;
	ushort header[4];

	if (compsize > 0)
	{
		if (tfd)
		{
			// fill TFD block header
			header[0] = htons((ushort)compsize + 6);
			header[2] = htons(1);
			header[3] = htons((ushort)origsize);
			// compute header CRC
			count = crc16(0, 4, (uchar*)&header[2]);
			// update with data CRC
			count = crc16(count, compsize, outBuf);
			header[1] = htons(count);
		}
		else
		{
			// fill flash block header
			header[0] = htons((ushort)origsize);
			header[1] = htons((ushort)compsize);
			count = crc16(0, compsize, outBuf);
			header[2] = htons(count);
		}

		fwrite(header, 1, tfd ? 8 : 6, pFile);
		count = fwrite(outBuf, 1, compsize, pFile);
	}

	return count;
}

int getData(uchar *pData, int n)
{
	if (n >= available)
	{
		n = available;
	}

	memcpy(pData, &inBuf[inputIndex], n);
	inputIndex += n;
	available -= n;

	return n;
}
//------------------------------------------------------

void error(char *fmt, ...)
{
	va_list args;

	va_start(args, fmt);
	fprintf(stderr,"\nError: ");
	vfprintf(stderr, fmt, args);
	putc('\n', stderr);
	va_end(args);
	exit(EXIT_FAILURE);
}

void verboseprintf(char *fmt, ...)
{
	va_list args;

	if (verbose)
	{
		va_start(args, fmt);
		vprintf(fmt, args);
		va_end(args);
	}
}

void make_crctable(void)
{
	uint i, j, r;

	for (i = 0; i <= UCHAR_MAX; i++)
	{
		r = i;
		for (j = 0; j < CHAR_BIT; j++)
		{
			if (r & 1)
			{
				r = (r >> 1) ^ CRCPOLY;
			}
			else
			{
				r >>= 1;
			}
		}
		crctable[i] = r;
	}
}

void fillbuf(int n)  /* Shift bitbuf n bits left, read n bits */
{
	bitbuf <<= n;
	while (n > bitcount)
	{
		bitbuf |= subbitbuf << (n -= bitcount);
		if (compsize != 0)
		{
			compsize--;
			subbitbuf = (uchar)getc(infile);
		}
		else
		{
			subbitbuf = 0;
		}
		bitcount = CHAR_BIT;
	}
	bitbuf |= subbitbuf >> (bitcount -= n);
}

uint getbits(int n)
{
	uint x;
	if (n == 0)
	{
		return 0;
	}
	/* The above line added 2003-03-02.
	   unsigned bitbuf used to be 16 bits, but now it's 32 bits,
	   and (bitbuf >> 32) is equivalent to (bitbuf >> 0) (at least for ix86 and SPARC).
	   Thanks: CheMaRy.
	*/

	x = bitbuf >> (BITBUFSIZ - n);
	fillbuf(n);
	return x;
}

void putbits(int n, uint x)  /* Write rightmost n bits of x */
{
	if (n < bitcount)
	{
		subbitbuf |= x << (bitcount -= n);
	}
	else
	{
		if (compsize < origsize)
		{
			// modified by Phantomias to write to buffer
			outBuf[compsize] = subbitbuf | (x >> (n -= bitcount));
			compsize++;
		}
		else
		{
			unpackable = 1;
		}
		if (n < CHAR_BIT)
		{
			subbitbuf = x << (bitcount = CHAR_BIT - n);
		}
		else
		{
			if (compsize < origsize)
			{
				// modified by Phantomias to write to buffer
				outBuf[compsize] = x >> (n - CHAR_BIT);
				compsize++;
			}
			else
			{
				unpackable = 1;
			}
			subbitbuf = x << (bitcount = 2 * CHAR_BIT - n);
		}
	}
}

int fread_crc(uchar *p, int n, FILE *f)
{
	int i;

	// modified by Phantomias to read from buffer
	i = getData(p, n);
	n = i;
	origsize += n;

	while (--i >= 0)
	{
		UPDATE_CRC(*p++);
	}
	return n;
}

void fwrite_crc(uchar *p, int n, FILE *f)
{
	if (fwrite(p, 1, n, f) < n)
	{
		error("Unable to write");
	}
	while (--n >= 0)
	{
		UPDATE_CRC(*p++);
	}
}

void init_getbits(void)
{
	bitbuf = 0;
	subbitbuf = 0;
	bitcount = 0;

	fillbuf(BITBUFSIZ);
}

void init_putbits(void)
{
	bitcount = CHAR_BIT;
	subbitbuf = 0;
}
