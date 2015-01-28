#!/bin/sh
# tests for CVE-2015-0235 (GHOST)
# http://www.openwall.com/lists/oss-security/2015/01/27/9
# exploit code taken from: https://gist.github.com/koelling/ef9b2b9d0be6d6dbab63

cd /tmp

#curl -O https://github.office.opendns.com/security/scripts/raw/master/ghosttest.c -k &>/dev/null
cat > ghosttest.c <<EOF
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#define CANARY "in_the_coal_mine"

struct {
  char buffer[1024];
  char canary[sizeof(CANARY)];
} temp = { "buffer", CANARY };

int main(void) {
  struct hostent resbuf;
  struct hostent *result;
  int herrno;
  int retval;

  /*** strlen (name) = size_needed - sizeof (*host_addr) - sizeof (*h_addr_ptrs) - 1; ***/
  size_t len = sizeof(temp.buffer) - 16*sizeof(unsigned char) - 2*sizeof(char *) - 1;
  char name[sizeof(temp.buffer)];
  memset(name, '0', len);
  name[len] = '\0';

  retval = gethostbyname_r(name, &resbuf, temp.buffer, sizeof(temp.buffer), &result, &herrno);

  if (strcmp(temp.canary, CANARY) != 0) {
    puts("vulnerable");
    exit(EXIT_SUCCESS);
  }
  if (retval == ERANGE) {
    puts("not vulnerable");
    exit(EXIT_SUCCESS);
  }
  puts("should not happen");
  exit(EXIT_FAILURE);
}
/* from http://www.openwall.com/lists/oss-security/2015/01/27/9 */
EOF

gcc ghosttest.c -o ghosttest
chmod +x ghosttest
./ghosttest
rm ghosttest.c ghosttest
