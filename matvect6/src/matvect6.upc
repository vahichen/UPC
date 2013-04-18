/*
 ============================================================================
 Name        : matvect6.upc
 Author      : vahichen
 Version     :
 Copyright   : Your copyright notice
 Description : UPC Matrix Vector program
 ============================================================================
*/

#include <upc_relaxed.h>

shared [16 * THREADS] int a[4 *THREADS][4 * THREADS];
shared [4] int b[4 * THREADS], c[4 * THREADS];

int main(int argc, char *argv[]) {

	int i, j, k;

	upc_forall(i = 0; i < 4 * THREADS; i++; i / 4) {
		for (j = 0; j < 4 * THREADS; j++) {
			a[i][j] =  i / 4 * 10 + MYTHREAD;
		}
		b[i] = MYTHREAD;
	}

	upc_barrier;

	upc_forall(i = 0; i < 4 * THREADS; i++; i / 4) {
		for (c[i] = 0, j = 0; j < 4 * THREADS; j++) {
			c[i] += a[i][j] * b[j];
		}
	}

	upc_barrier;

	if (MYTHREAD == 0) {
		for (i = 0; i < 4 * THREADS; i++) {
			for (j = 0; j < 4 * THREADS; j++) {
				printf("%2d ", a[i][j]);
			}
			printf(" | %2d || %3d\n", b[i], c[i]);
		}
	}


	return 0;
}
