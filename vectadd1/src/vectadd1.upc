/*
 ============================================================================
 Name        : vectadd1.upc
 Author      : vahichen
 Version     :
 Copyright   : Your copyright notice
 Description : UPC Vector Add program
 ============================================================================
*/

#include <upc_relaxed.h>
#define N 4 * THREADS

shared int v1[N], v2[N], v1plusv2[N];

int main(int argc, char *argv[]) {

	int i;

	upc_forall(i = 0; i < N; i++; i) {
		v1[i] = MYTHREAD;
		v2[i] = 2 * MYTHREAD;
		v1plusv2[i] = v1[i] + v2[i];
	}

	upc_barrier;

	if (MYTHREAD == 0) {
		for (i = 0; i < N; i++) {
			printf("%d ", v1[i]);
			if ((i + 1) % THREADS == 0) {
				printf("\n");
			}
		}
		printf("============\n");
		for (i = 0; i < N; i++) {
			printf("%d ", v2[i]);
			if ((i + 1) % THREADS == 0) {
				printf("\n");
			}
		}
		printf("============\n");
		for (i = 0; i < N; i++) {
			printf("%d ", v1plusv2[i]);
			if ((i + 1) % THREADS == 0) {
				printf("\n");
			}
		}
	}


	return 0;
}
