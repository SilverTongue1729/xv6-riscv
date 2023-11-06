#include "kernel/stat.h"
#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
  if (argc != 3) {
    printf("Usage: setpriority <priority> <pid>\n");
    exit(1);
  }
  int priority = atoi(argv[1]);
  int pid = atoi(argv[2]);

  setpriority(priority, pid);

  return 0;
}