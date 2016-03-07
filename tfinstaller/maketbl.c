/***********************************************************
	maketbl.c -- make table for decoding
***********************************************************/
#include "ar.h"

extern ushort left[], right[];

void make_table(int nchar, uchar bitlen[], int tablebits, ushort table[])
{
	ushort count[17];  /* count of bitlen */
	ushort weight[17]; /* 0x10000ul >> bitlen */
	ushort start[18];  /* first code of bitlen */
	ushort *p;
	uint i, k, len, ch, jutbits, avail, nextcode, mask;

/* initialize */
	for (i = 1; i <= 16; i++)
	{
		count[i] = 0;
	}

/* count */
	for (i = 0; i < nchar; i++)
	{
		count[bitlen[i]]++;
	}

/* calculate first code */
	start[1] = 0;

	for (i = 1; i <= 16; i++)
	{
		start[i + 1] = start[i] + (count[i] << (16 - i));
	}

	if (start[17] != (ushort)(1U << 16))
	{
		error("bad table");
	}

/* shift data for make table. */
	jutbits = 16 - tablebits;
	for (i = 1; i <= tablebits; i++)
	{
		start[i] >>= jutbits;
		weight[i] = 1U << (tablebits - i);
	}

	while (i <= 16)
	{
		weight[i] = 1U << (16 - i);
		i++;
	}

/* initialize */
	i = start[tablebits + 1] >> jutbits;

	if (i != (ushort)(1U << 16))
	{
		k = 1U << tablebits;
		while (i != k)
		{
			table[i++] = 0;
		}
	}

/* create table and tree */
	avail = nchar;
	mask = 1U << (15 - tablebits);

	for (ch = 0; ch < nchar; ch++)
	{
		if ((len = bitlen[ch]) == 0)
		{
			continue;
		}
		nextcode = start[len] + weight[len];
		if (len <= tablebits)
		{   /* code in table */
			for (i = start[len]; i < nextcode; i++)
			{
				table[i] = ch;
			}
		}
		else
		{   /* code not in table */
			k = start[len];
			p = &table[k >> jutbits];
			i = len - tablebits;

			/* make tree (length n) */
			while (i != 0)
			{
				if (*p == 0)
				{
					right[avail] = left[avail] = 0;
					*p = avail++;
				}
				if (k & mask)
				{
					p = &right[*p];
				}
				else
				{
					p = &left[*p];
				}
				k <<= 1;
				i--;
			}
			*p = ch;
		}
		start[len] = nextcode;
	}
}
