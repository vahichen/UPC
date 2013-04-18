/*
 ============================================================================
 Name        : temperature2.upc
 Author      : vahichen
 Version     :
 Copyright   : Your copyright notice
 Description : UPC Temperature program
 ============================================================================
*/
#include <upc.h>
#define TBL_SZ 12

int main(int argc, char *argv[]) {

	static shared int step = 10;
	int fahrenheit, celsius, i;

	for (i = 0; i < TBL_SZ; i++) {
		if (MYTHREAD == i % THREADS) {
			celsius = step * i;
			fahrenheit = celsius * (9.0 / 5.0) + 32;
			printf("Thread = %d: \t F = %d \t C = %d \n",
					MYTHREAD, fahrenheit, celsius);
		}
	}

	return 0;

}
