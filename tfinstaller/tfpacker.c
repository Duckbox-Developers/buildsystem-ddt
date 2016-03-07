/***********************************************************
	tfpacker.c
***********************************************************/
#include "ar.h"
#include <stdlib.h>
#include <string.h>  /* memmove() */
#include <fcntl.h>
#include <unistd.h>

#define VERSION "2.0 (151105)"

void printUsage(char *pName)
{
	printf("Usage: %s [[-m <modelID>] [-l <laddr>] [-e <eaddr>] [-t]] | [-x] [[-v] [-b]] <infile> <outfile>\n", pName);
	printf(" - laddr is the load address (default = 0x84601000)\n");
	printf(" - eaddr is the entry address (default = laddr)\n");
	printf(" - modelID is the decimal model identifier (default = 39321 (0x9999))\n");
	printf(" - -v: verbose operation\n");
	printf(" - -b: extracted output is binary instead of .asm format\n");
	printf("Examples:\n");
	printf("\t%s <binary image> <binary flash file>\n", pName);
	printf("\t%s -t <binary image> <TFD file>\n", pName);
	printf("\t%s -l 0x85f0000 -t <binary image> <TFD file>\n", pName);
	printf("\t%s -x <TFD or binary flash file> <asm image>\n", pName);
	printf("\t%s -x -v -b <TFD or binary flash file> <binary image>\n", pName);
}

int main(int argc, char *argv[])
{
	int opt;
	int tfd = 0;
	int xtract = 0;
	int binary = 0;
	uint modelID = 0x9999;
	uint loadAddr = -1;
	uint entryAddr = -1;

	printf("%s version %s\n\n", argv[0], VERSION);
	verbose = 0;

	while ((opt = getopt(argc, argv, "m:l:e:txvb")) != -1)
	{
		switch (opt)
		{
			case 'x':
			{
				xtract = 1;
				break;
			}
			case 'v':
			{
				verbose = 1;
				break;
			}
			case 'b':
			{
				binary = 1;
				break;
			}
			case 'm':
			{
				modelID = (uint)strtod(optarg, NULL);
				break;
			}
			case 'l':
			{
				loadAddr = (uint)strtod(optarg, NULL);
				break;
			}
			case 'e':
			{
				entryAddr = (uint)strtod(optarg, NULL);
				break;
			}
			case 't':
			{
				tfd = 1;
				break;
			}
			default:
			{
				printf("Error: unrecognized option -%c\n\n", optopt);
				printUsage(argv[0]);
				return -1;
			}
		}
	}

	//check command line syntax
	if (xtract == 1)
	{
		if (tfd == 1)
		{
			printf("Error: -t cannot be used with -x\n\n");
			printUsage(argv[0]);
			return -1;
		}
	}
	else
	{
		if (modelID != 0x9999)
		{
			printf("Error: -m cannot be used with -x\n\n");
			printUsage(argv[0]);
			return -1;
		}
		if (binary == 1)
		{
			printf("Error: -b can only be used with -x\n\n");
			printUsage(argv[0]);
			return -1;
		}
		if (verbose == 1)
		{
			printf("Error: -v can only be used with -x\n\n");
			printUsage(argv[0]);
			return -1;
		}
		if (loadAddr != -1 || entryAddr != -1)
		{
			printf("Error: -l and/or -e cannot be used with -x\n\n");
			printUsage(argv[0]);
			return -1;
		}
	}
	// check the number of remaining arguments (exactly two are expected)
	if ((optind + 2) != argc)
	{
		printf("Error: exactly two file names must be specified\n\n");
		printUsage(argv[0]);
		return -1;
	}

	infilen = argv[optind];
	outfilen = argv[optind + 1];

	if (loadAddr == -1)
	{
		loadAddr = 0x84601000;
	}

	if (entryAddr == -1)
	{
		entryAddr = loadAddr;
	}

	if ((infile = fopen(infilen, "rb")) == NULL)
	{
		error("cannot open input file %s", infilen);
	}
	if ((outfile = fopen(outfilen, "wb")) == NULL)
	{
		error("cannot open output file %s", outfilen);
	}

	fseek(infile, 0, SEEK_END);
	opt = ftell(infile);
	fseek(infile, 0, SEEK_SET);

	make_crctable();

	if (xtract)
	{
		decodeFile(opt, binary);
	}
	else
	{
		printf("Load address : 0x%08x\n", loadAddr);
		printf("Entry address: 0x%08x\n", entryAddr);
		printf("Model ID     : %d\n\n", modelID);
		printf("Packing ");

		encodeFile(tfd, modelID, loadAddr, entryAddr, opt);
	}

	fclose(infile);
	fclose(outfile);

	return 0;
}
