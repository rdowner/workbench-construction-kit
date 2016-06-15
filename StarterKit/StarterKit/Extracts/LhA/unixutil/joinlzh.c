/*
 * joinlzh - Join several parts of a LhA multivolume archive to one single
 *           LZH archive.
 *
 * This is freely distributable. Do with it whatever you desire.
 *
 * Written by Stefan Boberg, 1992
 *
 */

#include <stdio.h>
#include <string.h>

#define EXIT_FAILURE 1

FILE *open_vol(name, no)
char *name;
long no;
{
  char work[1024];

  if (no)
    sprintf(work, "%s.l%02d", name, no);
  else
    sprintf(work, "%s.lzh", name);

  return fopen(work, "rb");
}

int main(argc, argv)
int argc;
char **argv;
{
  char buffer[1024];              /* Small I/O buffer */
  FILE *in, *out;
  long j, vol_no = 0;

  if (argc != 3) {
    printf("Usage: %s <infilebase> <outname>\n", argv[0]);
    exit(EXIT_FAILURE);
  }

  if (out = fopen(argv[2], "wb")) {
    while (in = open_vol(argv[1], vol_no++)) {
      while(!feof(in)) {
        j = fread(buffer, 1, 1024, in);
        fwrite(buffer, 1, j, out);
      }
      fclose(in);
    }
  } else {
    printf("Error opening destination!!\n\n");
    exit(EXIT_FAILURE);
  }

  return 0;
}
