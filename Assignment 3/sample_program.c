#include<stdio.h>

int main() {
	int a, 1b, 2a, c, ints, int_, in, i, breaks;
	float floats, floa, f = 1.2a;

	char c = '\'', d = 'f', g = ' ';

	/*
	 * A
	 * Multiline\n\n
	 * Comment
	 */

	// A single line comment
	a = 1;
	while (a < 100) {
		a = a*2;
	}

	a <<= 2;
	a /= 2;

	if (d != 'd') {
		printf("It is not d\n");
	}

	if (d == 'd') {
		printf("It is \"d\"\n");
	}

	// Another single line comment
	switch (d) {
		case 'a': printf("It is a\n");
							break;
		case 'f': printf("It is f\n");
							break;
		default : printf("It is neither\n");
	}

	printf("Program Done!");

	return 0;
}
