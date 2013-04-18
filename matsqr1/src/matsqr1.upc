/*
 ============================================================================
 Name        : matsqr1.upc
 Author      : vahichen
 Version     :
 Copyright   : Your copyright notice
 Description : UPC Matrix Squaring program
 ============================================================================
*/

#include <upc.h>

shared int A[THREADS][THREADS], A_Sqr[THREADS][THREADS];

int main(int argc, char *argv[]) {

	int i, j, k;
	int d;
	shared int *rowPtr[THREADS];
	int *colPtr;

	upc_forall(i = 0; i < THREADS; i++; i) {
		for (j = 0; j < THREADS; j++) {
			A[j][i] = MYTHREAD + j * 10;
		}
	}

	for (i = 0; i < THREADS; i++) {
		rowPtr[i] = &A[i][0];
	}
	colPtr = (int *)&A[0][MYTHREAD];

	upc_barrier;

	for (i = 0; i < THREADS; i++) {
		upc_forall(j = 0; j < THREADS; j++; j) {
			A_Sqr[i][j] = 0;
			for (k = 0; k < THREADS; k++) {
				A_Sqr[i][j] += *(rowPtr[i] + k) * *(colPtr + k);
			}
		}
	}

	upc_barrier;

	if (MYTHREAD == 0) {
		for (i = 0; i < THREADS; i++) {
			for (j = 0; j < THREADS; j++) {
				printf("%2d ", A[i][j]);
			}
			printf("| ");
			for (j = 0; j < THREADS; j++) {
				printf("%2d ", A[i][j]);
			}
			printf("|| ");
			for (j = 0; j < THREADS; j++) {
				printf("%4d ", A_Sqr[i][j]);
			}
			printf("\n");
		}
	}

	return 0;
}
