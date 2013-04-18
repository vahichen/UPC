/*
 ============================================================================
 Name        : philosophers.upc
 Author      : vahichen
 Version     :
 Copyright   : Your copyright notice
 Description : UPC Philosophers program
 ============================================================================
*/

#ifndef NULL
#define NULL	((void *) 0)
#endif

#define MEM_OK(var) {                                        	 \
    if( var == NULL )                                          	 \
    {                                                        	 \
        printf("TH%02d: ERROR: %s == NULL\n", MYTHREAD, #var );	 \
        upc_global_exit(1);                                    	 \
    } }

#include <stdio.h>
#include <upc_relaxed.h>

typedef enum {THINKING, STARVING, EATING} philosophers_status_t;
upc_lock_t *shared a_fork[THREADS];

void initialize(void);
void life_cycle(void);

int main(int argc, char *argv[]) {

	initialize();
	upc_barrier;

	life_cycle();
	upc_barrier;

	if (MYTHREAD == 0) {
		printf("*** --> all philosophers left the table <-- ***\n");
	}

	return 0;
}

void initialize(void) {

	a_fork[MYTHREAD] = upc_global_lock_alloc();
	MEM_OK(a_fork[MYTHREAD]);

}

void life_cycle(void) {

	philosophers_status_t state;

	int num_meals = 0;
	int delay_thinking = 1;		//	delay when thinking
	int delay_eating = 2;		//	delay when eating
	int left, right;
	int got_left, got_right;	//	get left, right lock

	left = MYTHREAD;
	right = (MYTHREAD + 1) % THREADS;
	state = THINKING;

	while(num_meals < 5) {
		if(state == THINKING) {
			printf("Philosopher %2d: --- I am thinking\n", MYTHREAD);
			sleep(delay_thinking);
			printf("Philosopher %2d: --- I finished thinking, "	\
					"now I am starving.\n", MYTHREAD);
			state = STARVING;
		}

		// trying to lock both forks
		got_left = upc_lock_attempt(a_fork[left]);
		got_right = upc_lock_attempt(a_fork[right]);

		if(got_left && got_right) {
			//	got both forks
			printf("Philosopher %2d: I have both forks --- "	\
					"I start eating.\n", MYTHREAD);
			state = EATING;
			sleep(delay_eating);
			num_meals++;

			printf("Philosopher %2d: I have both forks --- "	\
					"I finished eating %d meal(s).\n", MYTHREAD, num_meals);

			//	release both forks
			upc_unlock(a_fork[left]);
			upc_unlock(a_fork[right]);
			state = THINKING;

		} else {
			//	got one or none
			printf("Philosopher %2d: I can't get both forks --- "	\
					"I am starving\n", MYTHREAD);
			if(got_left) {
				upc_unlock(a_fork[left]);
			}
			if(got_right) {
				upc_unlock(a_fork[right]);
			}
		}
	}

	printf("Philosopher %2d: *** I ate too much, "	\
			"I am leaving! *** \n", MYTHREAD);

}
