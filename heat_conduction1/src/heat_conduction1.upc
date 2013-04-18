/*
 ============================================================================
 Name        : heat_conduction1.upc
 Author      : vahichen
 Version     :
 Copyright   : Your copyright notice
 Description : UPC Heat Conduction program
 ============================================================================
*/

#include <math.h>
#include <upc_relaxed.h>
#include "globals.h"

shared [BLOCKS] double grids[2][N][N][N];
shared double dTmax_local[THREADS];

void initialize(void);
void printgrid(int dg, int iter);

int main(int argc, char *argv[]) {

	int i, j, k;
	int x, y, z, iter = 0, finished = 0;
	int sg = 0, dg = 1;
	double T, dTmax, dT, epsilon = 0.0001;

	initialize();
	upc_barrier;

	do {
		dTmax = 0.0;
		for (z = 1; z < N - 1; z++) {
			for (y = 1; y < N - 1; y++) {
				upc_forall(x = 1; x < N - 1; x++; &grids[sg][z][y][x]) {
					T = (grids[sg][z + 1][y][x] + grids[sg][z - 1][y][x] +
						grids[sg][z][y + 1][x] + grids[sg][z][y - 1][x] +
						grids[sg][z][y][x + 1] + grids[sg][z][y][x - 1]) / 6.0;
					dT = T - grids[sg][z][y][x];
					grids[dg][z][y][x] = T;
					if (dTmax < fabs(dT)) {
						dTmax = fabs(dT);
					}
				}
			}
		}
		dTmax_local[MYTHREAD] = dTmax;
		upc_barrier;

		dTmax = dTmax_local[0];
		for (i = 1; i < THREADS; i++) {
			if (dTmax < dTmax_local[i]) {
				dTmax = dTmax_local[i];
			}
		}
		upc_barrier;

		iter++;
		if (dTmax < epsilon) {
			finished = 1;
			if (MYTHREAD == 0) {
				printgrid(dg, iter);
			}
		} else {
			dg = sg;
			sg = !sg;
		}
		upc_barrier;

	} while (!finished);

	return 0;
}

void initialize(void) {

	int x, y;
	for (y = 1; y < N -1; y++) {
		upc_forall(x = 1; x < N - 1; x++; &grids[0][0][y][x]) {
			grids[0][0][y][x] = grids[1][0][y][x] = 1.0;
		}
	}
}

void printgrid(int dg, int iter) {

	int i, j, k;

	for (i = 0; i < N; i++) {
		printf("******** z = %d ********\n", i);
		for (j = 0; j < N; j++) {
			for (k = 0; k < N; k++) {
				printf("%2f ", grids[dg][i][j][k]);
			}
			printf("\n");
		}
	}
	printf("============ iter = %d =============\n", iter);
}
