/*
 ============================================================================
 Name        : hist1.upc
 Author      : vahichen
 Version     :
 Copyright   : Your copyright notice
 Description : UPC Histogram1 program
 ============================================================================
*/

#define N		1024

#ifndef NULL
#define NULL	((void *) 0)
#endif

#define MEM_OK(var) {                                        	 \
    if( var == NULL )                                          	 \
    {                                                        	 \
        printf("TH%02d: ERROR: %s == NULL\n", MYTHREAD, #var );	 \
        upc_global_exit(1);                                    	 \
    } }

#include <upc.h>
#include <upc_relaxed.h>

shared [N * N / THREADS] unsigned char img[N][N];
shared int hist[256];
upc_lock_t *lock;


void initialize(void);

int main(int argc, char *argv[]) {

	int i, j;

	initialize();

	upc_barrier;

	upc_forall(i = 0; i < N; i++; i * THREADS / N) {
		for(j = 0; j < N; j++) {
			upc_lock(lock);
			hist[img[i][j]]++;
			upc_unlock(lock);
		}
	}

	upc_barrier;

	// print out the histogram
	if (MYTHREAD == 0) {
		//print_hist();
	}

	return 0;
}

void initialize(void) {

	lock = upc_all_lock_alloc();
	MEM_OK(lock);

	// initialize the image img[][]

}
