#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "../kernel/types.h"
#include "user.h"

int main(int argc, char *argv[]) {
  int x1 = getreadcount();
  // printf("XV6_TEST_OUTPUT: x1 %d\n", x1);
  int x2 = getreadcount();
  // printf("XV6_TEST_OUTPUT: x2 %d\n", x2);
  char buf[100];
  (void)read(4, buf, 1);
  int x3 = getreadcount();
  // printf("XV6_TEST_OUTPUT: x3 %d\n", x3);
  int i;
  for (i = 0; i < 1000; i++) {
    (void)read(4, buf, 1);
  }
  int x4 = getreadcount();
  // printf("XV6_TEST_OUTPUT: x4 %d\n", x4);
  printf("XV6_TEST_OUTPUT %d %d %d\n", x2 - x1, x3 - x2, x4 - x3);
  exit(0);
}