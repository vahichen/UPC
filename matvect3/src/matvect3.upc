/*
 ============================================================================
 Name        : matvect3.upc
 Author      : vahichen
 Version     :
 Copyright   : Your copyright notice
 Description : UPC Matrix Vector program
 ============================================================================
*/

#include <upc_relaxed.h>

shared [THREADS] int a[THREADS * 10][THREADS];
shared int b[THREADS], c[THREADS * 10];

int main(int argc, char *argv[]) {

	int i, j, k;

	upc_forall(i = 0; i < THREADS; i++; i) {
		for (j = MYTHREAD; j < 10 * THREADS; j += THREADS) {
			for (k = 0; k < THREADS; k++) {
				a[j][k] = MYTHREAD + k * 10;
			}
		}
		b[i] = MYTHREAD;
	}

	upc_barrier;

	for (i = MYTHREAD; i < 10 * THREADS; i += THREADS) {
		for (j = 0, c[i] = 0; j < THREADS; j++) {
			c[i] += a[i][j] * b[j];
		}
	}

	upc_barrier;

	if (MYTHREAD == 0) {
		for (i = 0; i < 10 * THREADS; i++) {
			for (j = 0; j < THREADS; j++) {
				printf("%2d ", a[i][j]);
			}
			if (i < THREADS) {
				printf(" | %2d ", b[i]);
			} else {
				printf(" |    ");
			}
			printf(" || %3d \n", c[i]);
		}
	}


	return 0;
}
