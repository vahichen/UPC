/*
 ============================================================================
 Name        : matcompress.upc
 Author      : vahichen
 Version     :
 Copyright   : Your copyright notice
 Description : UPC Matrix Compress program
 ============================================================================
*/

#include <stdio.h>
#include <upc.h>

#define N 8
// N过大，输出字符串溢出

#ifndef NULL
#define NULL   ((void *) 0)
#endif

#define MEM_OK(var) {											\
    if( var == NULL ) {											\
        printf("TH%02d: ERROR: %s == NULL\n", MYTHREAD, #var );	\
        upc_global_exit(1);										\
    }}

void initialize(void);
void compress(void);
void printmat(void);

typedef struct sMat {
	int numNZ;
	shared[] int *colInd;
	shared[] int *rowPtr;
	shared[] double *values;
}tMat;

shared [N * N / THREADS] double matA[N][N];
shared tMat sparseDat[THREADS];

int main(int argc, char *argv[]) {

	initialize();
	upc_barrier;

	compress();
	upc_barrier;

	return 0;

}

void initialize(void) {

	int i, j;

	upc_forall(i = 0; i < N; i++; i * THREADS / N) {
		for (j = 0; j <= i / 2; j++) {
			matA[i][j] = (i - j + 1) / (N * 1.0);
		}
	}

}

void compress(void) {

	int i, j, ind, row, count;
	char outStr[600];

	// Step 1: calculate nonZeros
	upc_forall(i = 0, sparseDat[MYTHREAD].numNZ = 0; i < N; i++; i * THREADS / N) {
		for (j = 0; j < N; j++) {
			if (matA[i][j] > 1E-6) {
				sparseDat[MYTHREAD].numNZ++;
			}
		}
	}
	upc_barrier;

	// Step 2: allocate
	sparseDat[MYTHREAD].colInd = (shared [] int *)upc_alloc(
		sparseDat[MYTHREAD].numNZ * sizeof(int));
	MEM_OK(sparseDat[MYTHREAD].colInd);
	sparseDat[MYTHREAD].rowPtr = (shared [] int *)upc_alloc(
		(N / THREADS + 1) * sizeof(int));
	MEM_OK(sparseDat[MYTHREAD].rowPtr);
	sparseDat[MYTHREAD].values = (shared [] double *)upc_alloc(
		sparseDat[MYTHREAD].numNZ * sizeof(double));
	MEM_OK(sparseDat[MYTHREAD].values);
	upc_barrier;

	// Step 3: generate compressed format
	row = 0;
	sparseDat[MYTHREAD].rowPtr[0] = 0;
	upc_forall(i = 0, ind = 0; i < N; i++; i * THREADS / N) {
		for (j = 0; j < N; j++) {
			if (matA[i][j] > 1E-6) {
				sparseDat[MYTHREAD].colInd[ind] = j;
				sparseDat[MYTHREAD].values[ind] = matA[i][j];
				ind++;
			}
		}
		sparseDat[MYTHREAD].rowPtr[++row] = ind;

	}
	upc_barrier;

	// Step 4: print
	sprintf(outStr, "TH%2d:\n", MYTHREAD);
	sprintf(outStr, "%s  colind[%d] = [", outStr, sparseDat[MYTHREAD].numNZ);
	for (i = 0; i < sparseDat[MYTHREAD].numNZ; i++) {
		sprintf(outStr, "%s %5d", outStr, sparseDat[MYTHREAD].colInd[i]);
	}
	sprintf(outStr, "%s ]\n  values[%d] = [", outStr, sparseDat[MYTHREAD].numNZ);
	for (i = 0; i < sparseDat[MYTHREAD].numNZ; i++) {
		sprintf(outStr, "%s %.3f", outStr, sparseDat[MYTHREAD].values[i]);
	}
	sprintf(outStr, "%s ]\n  rowptr[%d] = [", outStr, sparseDat[MYTHREAD].numNZ);
	for (i = 0; i < N / THREADS + 1; i++) {
		sprintf(outStr, "%s %5d", outStr, sparseDat[MYTHREAD].rowPtr[i]);
	}
	sprintf(outStr, "%s ]\n", outStr);
	printf("%s", outStr);

	upc_free(sparseDat[MYTHREAD].colInd);
	upc_free(sparseDat[MYTHREAD].rowPtr);
	upc_free(sparseDat[MYTHREAD].values);

}

void printmat(void) {

	int i, j;

	for (i = 0; i < N; i++) {
		printf("i = %2d, aff = %2d | ", i, i * THREADS / N % THREADS);
		for (j = 0; j < N; j++) {
			printf("%.3f ", matA[i][j]);
		}
		printf("|\n");
	}

}
