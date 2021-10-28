#include <stdio.h>

int d = 0;

void foo()
{
	printf("User function.\n");
	return;
}

int main()
{
	int a = 1;

	if (a == 1)
	{
		printf("Value of a is 1.\n");
		foo();
	}

	while (a < 100)
	{
		a = a * 2;
	}

	printf("Program Done!");

	return 0;
}
