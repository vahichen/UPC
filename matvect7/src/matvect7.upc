/*
 ============================================================================
 Name        : matvect7.upc
 Author      : vahichen
 Version     :
 Copyright   : Your copyright notice
 Description : UPC Matrix Vector program
 ============================================================================
*/

#include <upc_relaxed.h>

#ifndef NULL
#define NULL   ((void *) 0)
#endif

#define MEM_OK(var) {											\
    if( var == NULL ) {											\
        printf("TH%02d: ERROR: %s == NULL\n", MYTHREAD, #var );	\
        upc_global_exit(1);										\
    } }

shared [THREADS] int *a;
shared int *shared b[THREADS], *shared c[THREADS];

int main(int argc, char *argv[]) {

	int i, j, row;

	shared [THREADS] int (*mat_a) [THREADS];

	a = (shared [THREADS] int *) upc_all_alloc(THREADS, THREADS * sizeof(int));
	MEM_OK(a);
	mat_a = (shared [THREADS] int (*)[THREADS])a;
	b[MYTHREAD] = (shared int *shared)upc_global_alloc(THREADS, sizeof(int));
	MEM_OK(b[MYTHREAD]);
	c[MYTHREAD] = (shared int *shared)upc_global_alloc(THREADS, sizeof(int));
	MEM_OK(c[MYTHREAD]);
	upc_barrier;

	upc_forall(i = 0; i < THREADS; i++; i) {
		for (j = 0; j < THREADS; j++) {
			mat_a[i][j] = MYTHREAD + j;
			b[i][j] = i * j;
			c[i][j] = 0;
		}
	}
	upc_barrier;

	for (row = 0; row < THREADS; row++) {
		upc_forall(i = 0; i < THREADS; i++; i) {
			for (j = 0; j < THREADS; j++) {
				c[row][i] += mat_a[i][j] * b[row][j];
			}
		}
	}
	upc_barrier;

	if (MYTHREAD == 0) {
		for (i = 0; i < THREADS; i++) {
			for (j = 0; j < THREADS; j++) {
				printf("%2d ", *(*(mat_a + i) + j));
			}
			printf("\n");
		}
		for (i = 0; i < THREADS; i++) {
			for (j = 0; j < THREADS; j++) {
				printf("<%d, %d> ", upc_threadof(*(mat_a + i) + j),
						upc_phaseof(*(mat_a + i) + j));
			}
			printf("\n");
		}
		for (i = 0; i < THREADS; i++) {
			for (j = 0; j < THREADS; j++) {
				printf("%2d ", *(*(b + i) + j));
			}
			printf("\n");
		}
		for (i = 0; i < THREADS; i++) {
			for (j = 0; j < THREADS; j++) {
				printf("<%d, %d> ", upc_threadof(*(b + i) + j),
						upc_phaseof(*(b + i) + j));
			}
			printf("\n");
		}
		for (i = 0; i < THREADS; i++) {
			for (j = 0; j < THREADS; j++) {
				printf("%2d ", *(*(c + i) + j));
			}
			printf("\n");
		}
		for (i = 0; i < THREADS; i++) {
			for (j = 0; j < THREADS; j++) {
				printf("<%d, %d> ", upc_threadof(*(c + i) + j),
						upc_phaseof(*(c + i) + j));
			}
			printf("\n");
		}
	}

	return 0;
}
