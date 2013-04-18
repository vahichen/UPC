/*
 ============================================================================
 Name        : matsqr3.upc
 Author      : vahichen
 Version     :
 Copyright   : Your copyright notice
 Description : UPC Matrix Squaring program (single pointer)
 ============================================================================
*/

#include <upc.h>

shared int A[THREADS][THREADS], A_Sqr[THREADS][THREADS];

void mat_squaring(shared int (*dst)[THREADS], shared int (*src)[THREADS]) {

	int i, j, k;
	shared int *rowPtr;
	int *colPtr;

	upc_forall(i = 0; i < THREADS; i++; i) {
		for (j = 0; j < THREADS; j++) {
			src[j][i] = MYTHREAD + j * 5;
		}
	}

	rowPtr = &src[0][0];
	colPtr = (int *)&src[0][MYTHREAD];

	upc_barrier;

	for (i = 0; i < THREADS; i++, rowPtr += THREADS) {
		upc_forall(j = 0; j < THREADS; j++; j) {
			dst[i][j] = 0;
			for (k = 0; k < THREADS; k++) {
				dst[i][j] += *(rowPtr + k) * *(colPtr + k);
			}
		}
	}

	upc_barrier;

	if (MYTHREAD == 0) {
		for (i = 0; i < THREADS; i++) {
			for (j = 0; j < THREADS; j++) {
				printf("%2d ", src[i][j]);
			}
			printf("| ");
			for (j = 0; j < THREADS; j++) {
				printf("%2d ", src[i][j]);
			}
			printf("|| ");
			for (j = 0; j < THREADS; j++) {
				printf("%4d ", dst[i][j]);
			}
			printf("\n");
		}
	}
}

int main(int argc, char *argv[]) {

	mat_squaring(A_Sqr, A);

	return 0;
}
