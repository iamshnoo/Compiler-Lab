/* A simple program to test the working of the lexical analyser.*/

#include "analyser_impl.hpp"
using namespace lexicalAnalysis;

/**
 * Main Function to test the working of the lexical analyser.
 *
 * @param argv[1] : The name of the C source file to be analysed.
 * @return The success/failure code of the program.
 */
int main(int argc, char *argv[])
{
	Analyser analyser;
	analyser.analyse(argc, argv);
	return 0;
}
