/***********************************************************
	ar.h
***********************************************************/
#include <stdio.h>
#include <limits.h>
typedef unsigned char  uchar;   /*  8 bits */
typedef unsigned short ushort;  /* 16 bits */
typedef unsigned int   uint;    /* 32 bits */
typedef unsigned long  ulong;   /* 64 bits */
typedef short          node;

int unpackable, verbose;
unsigned long origsize, compsize;
FILE *infile, *outfile;
const char *infilen, *outfilen;
unsigned int crc, bitbuf;

/* ar.c */

#define PERCOLATE 1
#define NIL 0
#define MAX_HASH_VAL (3 * DICSIZ + (DICSIZ / 512 + 1) * UCHAR_MAX)

/* io.c */

#define INIT_CRC  0  /* CCITT: 0xFFFF */
#define BITBUFSIZ (CHAR_BIT * sizeof bitbuf)
#define MAX_BLOCK_SIZE 0x7ffa

void error(char *fmt, ...);
void verboseprintf(char *fmt, ...);
void make_crctable(void);
void fillbuf(int n);
uint getbits(int n);
/* void putbit(int bit); */
void putbits(int n, uint x);
int fread_crc(uchar *p, int n, FILE *f);
void fwrite_crc(uchar *p, int n, FILE *f);
void init_getbits(void);
void init_putbits(void);

ushort crc16(ushort crc16, int len, uchar *buf);
int readInput(FILE *pFile);
int writeOutput(FILE *pFile, int tfd);
void copyInput();
void setBinaryHeader(uint loadAddr, uint entryAddr, int fileSize);

/* encode.c and decode.c */

#define DICBIT    13    /* 12(-lh4-) or 13(-lh5-) */
#define DICSIZ (1U << DICBIT)
#define MATCHBIT   8    /* bits for MAXMATCH - THRESHOLD */
#define MAXMATCH 256    /* formerly F (not more than UCHAR_MAX + 1) */
#define THRESHOLD  3    /* choose optimal value */
#define PERC_FLAG 0x8000U

int encode(void);
void decode_start(void);
void decode(uint count, uchar text[]);
void decodeFile(int fileSize, int binary);
void encodeFile(int tfd, unsigned int modelID, unsigned int loadAddr, unsigned int entryAddr, int fileSize);

/* huf.c */

#define NC (UCHAR_MAX + MAXMATCH + 2 - THRESHOLD)
/* alphabet = {0, 1, 2, ..., NC - 1} */
#define CBIT 9       /* $\lfloor \log_2 NC \rfloor + 1$ */
#define CODE_BIT 16  /* codeword length */

void huf_encode_start(void);
void huf_decode_start(void);
uint decode_c(void);
uint decode_p(void);
void output(uint c, uint p);
void huf_encode_end(void);

/* maketbl.c */

void make_table(int nchar, uchar bitlen[],
				int tablebits, ushort table[]);

/* maketree.c */

int make_tree(int nparm, ushort freqparm[],
				uchar lenparm[], ushort codeparm[]);
