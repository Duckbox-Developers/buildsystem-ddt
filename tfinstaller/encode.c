/***********************************************************
	encode.c -- sliding dictionary with percolating update
***********************************************************/
#include "ar.h"
#include <stdlib.h>
#include <string.h>  /* memmove() */
#include <netinet/in.h>

#define PERCOLATE  1
#define NIL        0
#define MAX_HASH_VAL (3 * DICSIZ + (DICSIZ / 512 + 1) * UCHAR_MAX)

static uchar *text, *childcount;
static node pos, matchpos, avail, *position, *parent, *prev, *next = NULL;
static int remainder, matchlen;

#if MAXMATCH <= (UCHAR_MAX + 1)
	static uchar *level;
#else
	static ushort *level;
#endif

static void allocate_memory(void)
{
	if (next != NULL)
	{
		return;
	}

	text       = (uchar *)malloc(DICSIZ * 2 + MAXMATCH);
	level      = (uchar *)malloc((DICSIZ + UCHAR_MAX + 1) * sizeof(*level));
	childcount = (uchar *)malloc((DICSIZ + UCHAR_MAX + 1) * sizeof(*childcount));
#if PERCOLATE
	position   = (node *)malloc((DICSIZ + UCHAR_MAX + 1) * sizeof(*position));
#else
	position   = (node *)malloc(DICSIZ * sizeof(*position));
#endif
	parent     = (node *)malloc(DICSIZ * 2 * sizeof(*parent));
	prev       = (node *)malloc(DICSIZ * 2 * sizeof(*prev));
	next       = (node *)malloc((MAX_HASH_VAL + 1) * sizeof(*next));
	if (next == NULL)
	{
		error("out of memory.");
	}
}

static void init_slide(void)
{
	node i;

	for (i = DICSIZ; i <= DICSIZ + UCHAR_MAX; i++)
	{
		level[i] = 1;
#if PERCOLATE
		position[i] = NIL;  /* sentinel */
#endif
	}

	for (i = DICSIZ; i < DICSIZ * 2; i++)
	{
		parent[i] = NIL;
	}
	avail = 1;

	for (i = 1; i < DICSIZ - 1; i++)
	{
		next[i] = i + 1;
	}
	next[DICSIZ - 1] = NIL;

	for (i = DICSIZ * 2; i <= MAX_HASH_VAL; i++)
	{
		next[i] = NIL;
	}
}

#define HASH(p, c) ((p) + ((c) << (DICBIT - 9)) + DICSIZ * 2)

static node child(node q, uchar c)
/* q's child for character c (NIL if not found) */
{
	node r;

	r = next[HASH(q, c)];
	parent[NIL] = q;  /* sentinel */

	while (parent[r] != q)
	{
		r = next[r];
	}
	return r;
}

static void makechild(node q, uchar c, node r)
/* Let r be q's child for character c. */
{
	node h, t;

	h = HASH(q, c);
	t = next[h];

	next[h] = r;
	next[r] = t;

	prev[t] = r;
	prev[r] = h;
	parent[r] = q;

	childcount[q]++;
}

void split(node old)
{
	node new, t;

	new = avail;
	avail = next[new];
	childcount[new] = 0;

	t = prev[old];
	prev[new] = t;
	next[t] = new;

	t = next[old];
	next[new] = t;
	prev[t] = new;
	parent[new] = parent[old];
	level[new] = matchlen;

	position[new] = pos;
	makechild(new, text[matchpos + matchlen], old);
	makechild(new, text[pos + matchlen], pos);
}

static void insert_node(void)
{
	node q, r, j, t;
	uchar c, *t1, *t2;

	if (matchlen >= 4)
	{
		matchlen--;
		r = (matchpos + 1) | DICSIZ;
		while ((q = parent[r]) == NIL)
		{
			r = next[r];
		}

		while (level[q] >= matchlen)
		{
			r = q;
			q = parent[q];
		}
#if PERCOLATE
		t = q;
		while (position[t] < 0)
		{
			position[t] = pos;
			t = parent[t];
		}
		if (t < DICSIZ)
		{
			position[t] = pos | PERC_FLAG;
		}
#else
		t = q;
		while (t < DICSIZ)
		{
			position[t] = pos;
			t = parent[t];
		}
#endif
	}
	else
	{
		q = text[pos] + DICSIZ;
		c = text[pos + 1];

		if ((r = child(q, c)) == NIL)
		{
			makechild(q, c, pos);
			matchlen = 1;
			return;
		}
		matchlen = 2;
	}

	for ( ; ; )
	{
		if (r >= DICSIZ)
		{
			j = MAXMATCH;
			matchpos = r;
		}
		else
		{
			j = level[r];
			matchpos = position[r] & ~PERC_FLAG;
		}
		if (matchpos >= pos)
		{
			matchpos -= DICSIZ;
		}
		t1 = &text[pos + matchlen];
		t2 = &text[matchpos + matchlen];

		while (matchlen < j)
		{
			if (*t1 != *t2)
			{
				split(r);
				return;
			}
			matchlen++;
			t1++;
			t2++;
		}

		if (matchlen >= MAXMATCH)
		{
			break;
		}
		position[r] = pos;
		q = r;
		if ((r = child(q, *t1)) == NIL)
		{
			makechild(q, *t1, pos);
			return;
		}
		matchlen++;
	}
	t = prev[r];
	prev[pos] = t;
	next[t] = pos;

	t = next[r];
	next[pos] = t;
	prev[t] = pos;

	parent[pos] = q;
	parent[r] = NIL;
	next[r] = pos;  /* special use of next[] */
}

static void delete_node(void)
{
#if PERCOLATE
	node q, r, s, t, u;
#else
	node r, s, t, u;
#endif

	if (parent[pos] == NIL)
	{
		return;
	}
	r = prev[pos];
	s = next[pos];

	next[r] = s;
	prev[s] = r;

	r = parent[pos];
	parent[pos] = NIL;

	if (r >= DICSIZ || --childcount[r] > 1)
	{
		return;
	}
#if PERCOLATE
	t = position[r] & ~PERC_FLAG;
#else
	t = position[r];
#endif
	if (t >= pos)
	{
		t -= DICSIZ;
	}
#if PERCOLATE
	s = t;
	q = parent[r];

	while ((u = position[q]) & PERC_FLAG)
	{
		u &= ~PERC_FLAG;
		if (u >= pos)
		{
			u -= DICSIZ;
		}
		if (u > s)
		{
			s = u;
		}

		position[q] = (s | DICSIZ);
		q = parent[q];
	}
	if (q < DICSIZ)
	{
		if (u >= pos)
		{
			u -= DICSIZ;
		}
		if (u > s)
		{
			s = u;
		}
		position[q] = s | DICSIZ | PERC_FLAG;
	}
#endif
	s = child(r, text[t + level[r]]);
	t = prev[s];
	u = next[s];

	next[t] = u;
	prev[u] = t;

	t = prev[r];
	next[t] = s;
	prev[s] = t;

	t = next[r];
	prev[t] = s;
	next[s] = t;

	parent[s] = parent[r];
	parent[r] = NIL;

	next[r] = avail;
	avail = r;
}

static int get_next_match(void)
{
	int n, endOfFile = 0;
	int tmpSize = DICSIZ;

	if (origsize >= MAX_BLOCK_SIZE)
	{
		tmpSize = 0;
		//printf("0\n");
	}
	else if ((origsize + tmpSize) > MAX_BLOCK_SIZE)
	{
		//printf("tmp = %d, orig = %d\n", tmpSize, origsize);
		tmpSize = MAX_BLOCK_SIZE - origsize;
	}

	remainder--;
	if (++pos == DICSIZ * 2)
	{
		memmove(&text[0], &text[DICSIZ], DICSIZ + MAXMATCH);
		n = fread_crc(&text[DICSIZ + MAXMATCH], tmpSize, infile);
		if (n < tmpSize)
		{
			endOfFile = 1;
			//printf("EOF\n");
		}
		remainder += n;
		pos = DICSIZ;
		printf(".");
	}
	delete_node();
	insert_node();
	return endOfFile;
}

// the original function has been updated to encode blocks with size
// of up to 0x7ffa.
// The parameter tfd indicates whether to encode the output in
// flash (0) or TFD (1) format.
void encodeFile(int tfd, uint modelID, uint loadAddr, uint entryAddr, int fileSize)
{
	int lastmatchlen;
	int endOfFile = 0;
	node lastmatchpos;
	ushort header[5];
	ushort blockCount = 0;

	if (tfd)
	{
		// prepare TFD file header
		header[0] = htons(8);
		header[2] = htons(modelID);
		header[3] = htons(1);
		fwrite(header, 1, sizeof(header), outfile);
	}

	allocate_memory();  

	// prepare binary header with offsets
	setBinaryHeader(loadAddr, entryAddr, fileSize);

	while (!endOfFile)
	{
		if (readInput(infile) < 1)
		{
			break;
		}
		compsize = 0;
		origsize = 0;
		unpackable = 0;

		init_slide(); 
		huf_encode_start();

		remainder = fread_crc(&text[DICSIZ], DICSIZ + MAXMATCH, infile);
		if (remainder < 1)
		{
			break;
		}
		matchlen = 0;
		pos = DICSIZ;
		insert_node();

		if (matchlen > remainder)
		{
			matchlen = remainder;
		}
		while (remainder > 0 && ! unpackable)
		{
			lastmatchlen = matchlen;
			lastmatchpos = matchpos;
			endOfFile = get_next_match();

			if (matchlen > remainder)
			{
				matchlen = remainder;
			}

			if (matchlen > lastmatchlen || lastmatchlen < THRESHOLD)
			{
				output(text[pos - 1], 0);
			}
			else
			{
				output(lastmatchlen + (UCHAR_MAX + 1 - THRESHOLD), (pos - lastmatchpos - 2) & (DICSIZ - 1));

				while (--lastmatchlen > 0)
				{
					endOfFile = get_next_match();
				}
				if (matchlen > remainder)
				{
					matchlen = remainder;
				}
			}
		}
		huf_encode_end();

		if (unpackable)
		{
			copyInput();
		}

		if (writeOutput(outfile, tfd) < 1)
		{
			printf("\nWarning: no output data written\n");
			break;
		}

		blockCount++;
	}

	printf("\n");

	if (tfd)
	{
		// update TFD file header with block count and CRC
		fseek(outfile, 0, SEEK_SET);
		header[4] = htons(blockCount);
		header[1] = htons(crc16(0, 6, (uchar*)(header + 2)));
		fwrite(header, 1, sizeof(header), outfile);
	}
	else
	{
		// append EOF signature to the flash file
		uchar eofMark[] = {0xfe, 0xfe};
		fwrite(eofMark, 1, sizeof(eofMark), outfile);
	}
}
