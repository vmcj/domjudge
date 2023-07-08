#include <sys/types.h>
#include <sys/shm.h>
#include <string.h>

#define SHMSZ (512*1024*1024) /*Ubuntu rejects shared allocations larger than about 3MiB*/

int main() {
    int shmid;
    key_t key = 0xF111; /* Lets use `Fill' as our first ID.*/
    char *shm;

    while(1) { /* Like malloc, but using shared memory */
        if ((shmid = shmget(key, SHMSZ, IPC_CREAT|0666)) < 0){return 1;}/*Get shared memory*/
        if ((shm = shmat(shmid, NULL, 0)) == (void *) -1) { return 2; } /*Attach it        */
        memset(shm,0,SHMSZ);                                            /*Fill it up       */
        key++;                                                          /*On to the next ID*/
    }
    return 0;
}
