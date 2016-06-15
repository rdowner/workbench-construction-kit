/*
 * splitlzh - Split a LZH file into a multivolume archive suitable for
 *            processing by LhA.
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

  return fopen(work, "wb");
}

int main(argc, argv)
int argc;
char **argv;
{
  char buffer[1024];              /* Small I/O buffer */
  FILE *in, *out;
  long size, i, j = 1024, vol_no = 0;

  if (argc != 4) {
    printf("Usage: %s <arcsize in KB> <infile> <outname>\n", argv[0]);
    exit(EXIT_FAILURE);
  }

  size = atoi(argv[1]);

  if (in = fopen(argv[2], "rb")) {
    while (!feof(in)) {
      if (out = open_vol(argv[3], vol_no++)) {
        i = size;

        while((i--) && (j == 1024)) {
          j = fread(buffer, 1, 1024, in);
          fwrite(buffer, 1, j, out);
        }
        fclose(out);
      } else {
        fclose(in);
        printf("Error opening volume %d!\n\n", vol_no);
        exit(EXIT_FAILURE);
      }
    }
  } else {
    printf("Error opening source!!\n\n");
    exit(EXIT_FAILURE);
  }

  return 0;
}
