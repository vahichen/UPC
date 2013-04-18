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
upc_lock_t *shared lock[256];


void initialize(void);

int main(int argc, char *argv[]) {

	int i, j;

	initialize();

	upc_barrier;

	upc_forall(i = 0; i < N; i++; i * THREADS / N) {
		for(j = 0; j < N; j++) {
			upc_lock(lock[img[i][j]]);
			hist[img[i][j]]++;
			upc_unlock(lock[img[i][j]]);
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

	int i;
	upc_forall(i = 0; i , 256; i++; i) {
		lock[i] = upc_global_lock_alloc();
		MEM_OK(lock[i]);
	}

	// initialize the image img[][]

}
