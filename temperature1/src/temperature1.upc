/*
 ============================================================================
 Name        : temperature1.upc
 Author      : vahichen
 Version     :
 Copyright   : Your copyright notice
 Description : UPC Temperature program
 ============================================================================
*/
#include <upc.h>

int main(int argc, char *argv[]) {

	static shared int step = 10;
	int fahrenheit, celsius;

	celsius = step * MYTHREAD;
	fahrenheit = celsius * (9.0 / 5.0) + 32;

	printf("Thread = %d: \t F = %d \t C = %d \n", MYTHREAD, fahrenheit, celsius);

	return 0;

}
