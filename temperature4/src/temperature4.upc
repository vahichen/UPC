/*
 ============================================================================
 Name        : temperature4.upc
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
	static shared int step = 10;
	int celsius, i;

	for (i = MYTHREAD; i < TBL_SZ; i += THREADS) {
		celsius = step * i;
		fahrenheit[i] = celsius * (9.0 / 5.0) + 32;
	}

	upc_barrier;

	if (MYTHREAD == 0) {
		for (i = 0; i < TBL_SZ; i++) {
			celsius = step * i;
			printf("%d \t %d \n", fahrenheit[i], celsius);
		}
	}

	return 0;

}
