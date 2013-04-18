/*
 ============================================================================
 Name        : pointer.c
 Author      : vahichen
 Version     :
 Copyright   : Your copyright notice
 Description : Hello World in C, Ansi-style
 ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>

void disp(int (*a)[3]) {
	   printf("%d",*(*(a+1)+1));
}

int main(void) {

    int a[2][3];
    a[0][0]=1;
    a[0][1]=2;
    a[0][2]=3;
    a[1][0]=4;
    a[1][1]=5;
    a[1][2]=6;
    disp(&a[0]);//也可以写作disp(a);

	puts("\nHello UPC World"); /* prints Hello UPC World */
	return EXIT_SUCCESS;
}
