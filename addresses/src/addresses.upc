/*
 ============================================================================
 Name        : addresses.upc
 Author      : vahichen
 Version     :
 Copyright   : Your copyright notice
 Description : UPC Address program
 ============================================================================
*/

#include <upc.h>
#include <upc_relaxed.h>

#define BLOCKS 3
#define SIZE BLOCKS * THREADS

shared [BLOCKS] int buffer[SIZE];

int main(int argc, char *argv[]) {

	int i;
	shared [BLOCKS] int *buffer_ptr;
	shared [BLOCKS] int *buffer_ptr2;

	for (i = 0; i < BLOCKS; i++) {
		buffer[MYTHREAD * BLOCKS + i] = MYTHREAD * 10 + i;
	}

	if (MYTHREAD == 0) {
		buffer_ptr = buffer + 5;
		for (i = 0; i < THREADS; i++, buffer_ptr++) {
			printf("&buf[%d]: ", i);
			printf("THREAD: %02d\t", upc_threadof(buffer_ptr));
			printf("ADDRESS: %010Xh\t", upc_addrfield(buffer_ptr));
			printf("PHASE: %02d\t", upc_phaseof(buffer_ptr));
			printf("VALUE: %2d\n", *buffer_ptr);
		}
	}

	upc_barrier;
	if (MYTHREAD == 1) {
		buffer_ptr2 = buffer;
		for (i = 0; i < SIZE; i++, buffer_ptr2++) {
			printf("&buf[%d]: ", i);
			printf("THREAD: %02d\t", upc_threadof(buffer_ptr2));
			printf("ADDRESS: %010Xh\t", upc_addrfield(buffer_ptr2));
			printf("PHASE: %02d\t", upc_phaseof(buffer_ptr2));
			printf("VALUE: %2d\n", *buffer_ptr2);
		}
	}

	return 0;
}
