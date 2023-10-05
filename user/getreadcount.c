#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{

  if(argc != 1){
    fprintf(2, "Usage: getreadcount\n");
    exit(1);
  }
  
  int count = getreadcount();

  printf("Total read count: %d\n", count);

  exit(0);
}
