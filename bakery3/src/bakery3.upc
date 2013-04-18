/*
 ============================================================================
 Name        : bakery3.upc
 Author      : vahichen
 Version     :
 Copyright   : Your copyright notice
 Description : UPC Bakery3 program
 ============================================================================
*/

#include <stdio.h>
#include <upc_relaxed.h>

typedef enum {FALSE, TRUE} bool_t;
shared bool_t choosing[THREADS];
shared int number[THREADS];
shared int counter;

int main(int argc, char *argv[]) {

	int i;

	if(MYTHREAD == 0) {
		counter = 0;
	}

	choosing[MYTHREAD] = TRUE;
	upc_barrier;

	number[MYTHREAD] = (++counter);		//	pick up a ticket number
	choosing[MYTHREAD] = FALSE;			//	announce that i got my ticket

	upc_fence;

	for(i = 0; i < THREADS; i++) {		//	check all other customers
		while(choosing[i] == TRUE)		//	wait for customer i to get his ticket number
			;
		//	is customer i still in shop AND will he be served before me?
		if((number[i] > 0) &&			//	customer i is in the shop
			((number[MYTHREAD]) > number[i] ||	// customer i is before me
					((number[MYTHREAD] == number[i]) && (MYTHREAD > i)))) {	//	customer i is younger than me
			while(number[i] > 0)		//	so i need to wait for him to leave
				;
		}
	}

	//	I got my turn, I have the lowest ticket or I am the youngest
	printf("Thread %02d exits with number = %d\n", MYTHREAD, number[MYTHREAD]);
	number[MYTHREAD]=0;

	upc_fence;

	return 0;

}
