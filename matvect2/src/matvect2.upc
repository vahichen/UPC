/*
 ============================================================================
 Name        : matvect2.upc
 Author      : vahichen
 Version     :
 Copyright   : Your copyright notice
 Description : UPC Matrix Vector program
 ============================================================================
*/

#include <upc_relaxed.h>

shared [THREADS] int a[THREADS][THREADS];
shared int b[THREADS], c[THREADS];

int main(int argc, char *argv[]) {

	int i, j;

	upc_forall(i = 0; i < THREADS; i++; i) {
		for (j = 0; j < THREADS; j++) {
			a[j][i] = MYTHREAD + j * 10;
		}
		b[i] = MYTHREAD;
	}

	upc_barrier;

	upc_forall(i = 0, c[i] = 0; i < THREADS; i++; i) {
		for (j = 0; j < THREADS; j++) {
			c[i] += a[i][j] * b[j];
		}
	}

	upc_barrier;

	if (MYTHREAD == 0) {
		for (i = 0; i < THREADS; i++) {
			for (j = 0; j < THREADS; j++) {
				printf("%2d ", a[i][j]);
			}
			printf(" | %2d || %3d", b[i], c[i]);
			printf("\n");
		}
	}


	return 0;
}
