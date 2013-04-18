/*
 ============================================================================
 Name        : test.upc
 Author      : vahichen
 Version     :
 Copyright   : Your copyright notice
 Description : UPC Hello world program
 ============================================================================
*/

#include <upc.h>

shared int *a;
char *shared p1;

int main(int argc, char *argv[]) {

	a = (shared int *)upc_all_alloc(THREADS, THREADS * sizeof(double));

	if (MYTHREAD == 2) a += 9;

	printf("TH%2d: Threadof = %2d, Addrfield = %010Xh, Phaseof = %2d\n",
			MYTHREAD, upc_threadof(a), upc_addrfield(a), upc_phaseof(a));

	return 0;
}
