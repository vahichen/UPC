/*
 ============================================================================
 Name        : heat_conduction4.upc
 Author      : vahichen
 Version     :
 Copyright   : Your copyright notice
 Description : UPC Heat Conduction program
 ============================================================================
*/

#include <stdio.h>
#include <math.h>
#include <upc_relaxed.h>
#include "globals.h"

#ifndef NULL
#define NULL   ((void *) 0)
#endif

#define MEM_OK(var) {                                         \
    if( var == NULL )                                           \
    {                                                         \
        printf("TH%02d: ERROR: %s == NULL\n", MYTHREAD, #var ); \
        upc_global_exit(1);                                     \
    } }

shared [BLOCKS] double *shared sh_grids;
shared double dTmax_local[THREADS];

void initialize(shared [BLOCKS] double (*grids)[N][N][N]);
int heat_conduction(shared [BLOCKS] double (*grids)[N][N][N]);
void printgrid(shared [BLOCKS] double (*grids)[N][N][N], int iter);

int main(int argc, char *argv[]) {

	int iter;

	if (MYTHREAD == 0) {
		sh_grids = (shared [BLOCKS] double *shared)upc_global_alloc(
				2 * N * N * N / BLOCKS, BLOCKS * sizeof(double));
		MEM_OK(sh_grids);
	}
	upc_barrier;

	initialize((shared [BLOCKS] double (*)[N][N][N])sh_grids);
	upc_barrier;

	iter = heat_conduction((shared [BLOCKS] double (*)[N][N][N])sh_grids);
	upc_barrier;

	if (MYTHREAD == 0) {
		printgrid((shared [BLOCKS] double (*)[N][N][N])sh_grids, iter);
	}

	return 0;
}

void initialize(shared [BLOCKS] double (*grids)[N][N][N]) {

	int x, y;
	for (y = 1; y < N -1; y++) {
		upc_forall(x = 1; x < N - 1; x++; &grids[0][0][y][x]) {
			grids[0][0][y][x] = grids[1][0][y][x] = 1.0;
		}
	}
}

int heat_conduction(shared [BLOCKS] double (*grids)[N][N][N]) {

	int i, j, k;
	int x, y, z, iter = 0, finished = 0;
	int sg = 0, dg = 1;
	double T, dTmax, dT, epsilon = 0.0001;

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
		} else {
			dg = sg;
			sg = !sg;
		}
		upc_barrier;

	} while (!finished);

	return iter;
}

void printgrid(shared [BLOCKS] double (*grids)[N][N][N], int iter) {

	int i, j, k;

	for (i = 0; i < N; i++) {
		printf("******** z = %d ********\n", i);
		for (j = 0; j < N; j++) {
			for (k = 0; k < N; k++) {
				printf("%2f ", grids[iter % 2][i][j][k]);
			}
			printf("\n");
		}
	}
	printf("============ iter = %d =============\n", iter);
}
