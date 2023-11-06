#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"

#define NFORK 10

#ifdef FCFS
#define IO 5
#else
#define IO 5
#endif


int main()
{
  int n, pid;
  int wtime, rtime;
  int twtime = 0, trtime = 0;
  for (n = 0; n < NFORK; n++)
  // for (n = NFORK-1; n > -1; n--)
  {
    
    // sleep for 1 tick
    sleep(1); // for FCFS??

    pid = fork();
    if (pid < 0)
      break;
    if (pid == 0)
    {
      if (n < IO)
      {
        sleep(200); // IO bound processes
      }
      else
      {
        for (volatile int i = 0; i < 1000000000; i++)
        {
        } // CPU bound process
      }
      // printf("Process %d finished\n", n);  // Remove this for MLFQ Graph
      printf("%d\n", n);  // Remove this for MLFQ Graph
      exit(0);
    }
    else {
#ifdef PBS
      setpriority(50 - IO + n, pid); // Will only matter for PBS, set lower priority for IO bound processes
#endif
    }
  }
  for (; n > 0; n--)
  // for (; n < NFORK-1; n++)
  {
    if (waitx(0, &wtime, &rtime) >= 0)
    {
      trtime += rtime;
      twtime += wtime;
    }
  }
  printf("Average rtime %d,  wtime %d\n", trtime / NFORK, twtime / NFORK);
  exit(0);
}