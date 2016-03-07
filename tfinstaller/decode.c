/***********************************************************
	decode.c
***********************************************************/
#include "ar.h"

static int j;  /* remaining bytes to copy */

void decode_start(void)
{
	huf_decode_start();
	j = 0;
}

void decode(uint count, uchar buffer[])
	/* The calling function must keep the number of
	   bytes to be processed.  This function decodes
	   either 'count' bytes or 'DICSIZ' bytes of infile,
	   whichever is smaller, into the array 'buffer[]'
	   of size 'DICSIZ' or more.
	   Call decode_start() once for each new file
	   before calling this function. */
{
	static uint i;
	uint r, c;

	r = 0;
	while (--j >= 0)
	{
		buffer[r] = buffer[i];
		i = (i + 1) & (DICSIZ - 1);
		if (++r == count)
		{
			return;
		}
	}
	for ( ; ; )
	{
		c = decode_c();
		if (c <= UCHAR_MAX)
		{
			buffer[r] = c;
			if (++r == count)
			{
				return;
			}
		}
		else
		{
			j = c - (UCHAR_MAX + 1 - THRESHOLD);
			i = (r - decode_p() - 1) & (DICSIZ - 1);
			while (--j >= 0)
			{
				buffer[r] = buffer[i];
				i = (i + 1) & (DICSIZ - 1);
				if (++r == count)
				{
					return;
				}
			}
		}
	}
}

static unsigned long get_from_header(int i, int n, unsigned char *header)
{
	unsigned long s;

	s = 0;
	while (--n >= 0)
	{
		s = (s << 8) + header[(i ++)];
	}
	return s;
}

void decodeFile(int fileSize, int binary)
{
	unsigned char header[10];
	unsigned char dbuf[MAX_BLOCK_SIZE + 16];
	int tfd;
	int block_CRC;
	int model_ID;
	int blockcount;
	int bcount;
	int btype; //block type
	static char *btypename[6] = {"Loader", "Firmware", "Settings", "EEPROM", "Defaults", "Background" };
	long datastart;
	unsigned int decread;
	int compr;  //flag: current block is compressed
	int doheader; //flag: process binary header
	int loadaddress;
	int entryaddress;

	verboseprintf("File length: %d bytes ", fileSize);

	//detect file type
	fread(header, 1, 2, infile); // get 1st word
	if (get_from_header(0, 2, header) == 0x0008)
	{
		fseek(infile, fileSize - 2, SEEK_SET);
		fread(header, 1, 2, infile);
		if (get_from_header(0, 2, header) != 0xfefe)
		{
			verboseprintf("(TFD format)\n");
			tfd = 1;
		}
	}
	else
	{
		verboseprintf("(flash format)\n");
		tfd = 0;
	}
	fseek(infile, 0L, SEEK_SET);

	if (tfd)
	{
		// read TFD file header
		fread(header, 1, sizeof(header), infile);
		block_CRC = get_from_header(2, 2, header);
		if (crc16(0, 6, (unsigned char*)(header + 4)) != block_CRC)
		{
			fclose(infile);
			fclose(outfile);
			remove(outfilen);
			error("header CRC wrong (expected 0x%04x, calculated 0x%04x)", block_CRC, crc16(0, 6, (unsigned char*)(header + 4)));
		}
		model_ID = get_from_header(4, 2, header);
		blockcount = get_from_header(8, 2, header);
	}
	else
	{
		blockcount = 0;

		while (1) //determine block count of flash file
		{
			fread(header, 1, 6, infile);
			origsize = (unsigned short)get_from_header(0, 2, header);
			if (origsize == 0xfefe)  //EOF marker
			{
				break;
			}
			blockcount++;
			datastart = ftell(infile);
			compsize = (unsigned short)get_from_header(2, 2, header);
			fseek(infile, datastart + compsize, SEEK_SET);
		}
		fseek(infile, 0L, SEEK_SET);
	}
	verboseprintf("# of blocks: %d\n", blockcount);

	printf("\nUnpacking");
	verboseprintf(" %s:\n", infilen);
	bcount = 0;
	doheader = 1;

	while (bcount < blockcount)
	{
		fread(header, 1, (tfd ? 8 : 6), infile);
		bcount++;
		datastart = ftell(infile);

		if (tfd)
		{
			compsize = get_from_header(0, 2, header) - 6;
			block_CRC = (int)get_from_header(2, 2, header);
			//check block CRC (over block type, origsize and datapart)
			fseek(infile, datastart - 4, SEEK_SET);
			fread(dbuf, 1, compsize + 4, infile);
			if (crc16(0, compsize + 4, (unsigned char*)dbuf) != block_CRC)
			{
				fclose(infile);
				fclose(outfile);
				remove(outfilen);
				error("block CRC 0x%04x in block %d wrong", block_CRC, bcount);
			}
			fseek(infile, datastart, SEEK_SET);
			btype = get_from_header(4, 2, header);
			origsize = get_from_header(6, 2, header);
			verboseprintf("Block %3d  Size=%04X/%04X  Type %d (%s) ", bcount, compsize, origsize, btype, btypename[btype]);
		}
		else
		{
			compsize = get_from_header(2, 2, header);
			block_CRC = (int)get_from_header(4, 2, header);
			//check block CRC (over data part)
			if (crc16(0, compsize, (unsigned char*)dbuf) != block_CRC)
			{
				fclose(infile);
				fclose(outfile);
				remove(outfilen);
				error("block CRC 0x%04x in block %d wrong", block_CRC, bcount);
			}
			origsize = get_from_header(0, 2, header);
			verboseprintf("Block %3d  Size=%04X/%04X ", bcount, compsize, origsize);
		}

		//decode infile block
		compr = 0;
		if (compsize < origsize)
		{
			compr = 1;
			decode_start();
		}

		while (origsize != 0)
		{
			decread = (unsigned int)((origsize > DICSIZ) ? DICSIZ : origsize);
			if (compr)
			{
				decode(decread, dbuf);  // huffman-LZ percolating & slide algorithm
				printf(".");
			}
			else
			{
				// copy input file to outfile
				if (fread(dbuf, 1, decread, infile) != decread)
				{
						error("cannot read input file\n");
				}
				printf("U");
			}

			if (bcount == 1 && doheader == 1) /* Process 1st block (contains binary header) */
			{
				loadaddress = (dbuf[3]<<24) + (dbuf[2]<<16) + (dbuf[1]<<8) + dbuf[0]; //!big endian!
				entryaddress = (dbuf[11]<<24) + (dbuf[10]<<16) + (dbuf[9]<<8) + dbuf[8];

				/* omit binary header from output if not writing asm format */
				if (binary == 1)
				{
					fwrite(dbuf + 16, 1, decread - 16, outfile);
				}
				else
				{
					fwrite(dbuf, 1, decread, outfile);
				}
				doheader = 0;
			}
			/* do not write EOD marker of last output block if not writing asm format */
			else if (bcount == blockcount && origsize == decread && binary == 1)
			{
				fwrite(dbuf, 1, decread - 4, outfile);
			}
			else
			{
				fwrite(dbuf, 1, decread, outfile);
			}
			origsize -= decread;
		}
		verboseprintf("\n");
	}

	printf("\nLoad address : 0x%08x\n", (unsigned int)loadaddress);
	printf("Entry address: 0x%08x\n", (unsigned int)entryaddress);
	printf("Model ID     : %d (0x%04X)\n", model_ID, model_ID);
	verboseprintf("Finished     : %d blocks unpacked\n", bcount);
}
