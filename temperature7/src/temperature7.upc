/*
 ============================================================================
 Name        : temperature7.upc
 Author      : vahichen
 Version     :
 Copyright   : Your copyright notice
 Description : UPC Temperature program
 ============================================================================
*/

#include <upc.h>
#define TBL_SZ 12

int main(int argc, char *argv[]) {

	static shared int fahrenheit[TBL_SZ];
	shared int *fahrenheit_ptr;
	static shared int step = 10;
	int celsius, i;

	fahrenheit_ptr = fahrenheit + MYTHREAD;

	upc_forall(i = 0; i < TBL_SZ; i++; i) {
		celsius = step * i;
		*fahrenheit_ptr = celsius * (9.0 / 5.0) + 32;
		fahrenheit_ptr += THREADS;
	}

	upc_barrier;

	if (MYTHREAD == 0) {
		fahrenheit_ptr = fahrenheit;
		for (i = 0; i < TBL_SZ; i++, fahrenheit_ptr++) {
			celsius = step * i;
			printf("%d \t %d \n", *fahrenheit_ptr, celsius);
		}
	}

	return 0;

}
