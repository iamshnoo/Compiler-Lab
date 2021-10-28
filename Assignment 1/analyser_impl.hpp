#ifndef LEXICAL_ANALYSER_IMPL_HPP
#define LEXICAL_ANALYSER_IMPL_HPP

// Include the definition file.
#include "analyser.hpp"

namespace lexicalAnalysis{

// Constructor
Analyser::Analyser()
{
  // Do nothing here.
}

/**
 * Checks if a character is a whitespace i.e. space or tab or newline.
 *
 * @param ch : The character to check.
 * @return : A bool denoting whether the character is a whitespace.
 */
bool Analyser::isWhiteSpace(char ch)
{
	if (ch == ' ' || ch == '\t' || ch == '\n')
		return true;
	return false;
}

/**
 * Checks if a token is a delimiter.
 *
 * @param token : The input token to check.
 * @return : A bool denoting whether the token is a delimiter.
 */
bool Analyser::isDelimiter(string token)
{
	// Checking if token is a delimiter
	for (string word : delimiters)
		if (!token.compare(word))
				return true;
	return false;
}

/**
 * Checks if a token is a valid operator.
 *
 * @param token : The input token to check.
 * @return : A bool denoting whether the token is an operator.
 */
bool Analyser::isOperator(string token)
{
	// Checking if token is a operator
	for (string word : operators)
		if (!token.compare(word))
				return true;
	return false;
}

/**
 * Checks if a token is a valid reserved word.
 *
 * @param token : The input token to check.
 * @return : A bool denoting whether the token is a reserved word.
 */
bool Analyser::isReservedWord(string token)
{
	// Checking if token is a reserved word
	for (string word : reservedWords)
		if (!token.compare(word))
			return true;
	return false;
}

/**
 * Checks if a token is a valid identifier.
 * Valid identifier consists of alphanumeric characters and '_' (underscore)
 * only. It also cannot start with a number.
 *
 * @param token : The input token to check.
 * @return : A bool denoting whether the token is a valid identifier.
 */
bool Analyser::isIdentifier(string token)
{
	int tokenLength = token.length();

	// Blank token is invalid.
	if (tokenLength == 0)
		return false;

	// Must start with alphabet or underscore.
	if (!isalpha(token[0]) && token[0] != '_')
		return false;

	// Remaining characters can be alphanumeric or underscore.
	for (int i = 1; i < tokenLength; i++)
		if (token[i] != '_' && !isalnum(token[i]))
			return false;

	return true;
}

/**
 * Checks if a token is valid integer constant.
 * Valid integer constants consist of only digit characters.
 *
 * @param token : The input token to check.
 * @return : A bool denoting whether the token is a valid integer constant.
 */
bool Analyser::isIntegerConstant(string token)
{
	int tokenLength = token.length();

	// blank token is invalid
	if (tokenLength == 0)
		return false;

	// all characters must be digits
	for (int i = 0; i < tokenLength; i++)
		if (!isdigit(token[i]))
			return false;
	return true;
}

/**
 * Sets the value of yytext and returns the ID of the input token.
 *
 * @param token : The input token to get ID.
 * @param type : The type of token.
 * @return : The token ID of the input token and -1 if error.
 */
int Analyser::getTokenID(string token, int type)
{
	// setting yytext as the current token
	yytext = (char *)malloc(sizeof(char) * token.length() + 1);
	strcpy(yytext, token.c_str());
	yylen = token.length();

	if (type == IDENTIFIER)
		return ID_TOK;

	if (type == INTEGER)
		return INTCONST_TOK;


	// For single character delimiters and operators the token ID is
	// the ASCII code of the character itself. If other token ID scheme
	// is used, then these will have to be added to the next section of
	// this function.

	if (type == DELIMITER || (type == OPERATOR && token.length() == 1))
		return token[0];


	// Determining the token ID of reserved words and multi-character
	// operators by direct comparison.

	if (!token.compare("while"))
			return WHILE_TOK;
	if (!token.compare("if"))
			return IF_TOK;
	if (!token.compare("int"))
			return INT_TOK;
	if (!token.compare("float"))
			return FLOAT_TOK;
	if (!token.compare("char"))
			return CHAR_TOK;
	if (!token.compare("double"))
			return DOUBLE_TOK;
	if (!token.compare("bool"))
			return BOOL_TOK;
	if (!token.compare("true"))
			return TRUE_TOK;
	if (!token.compare("false"))
			return FALSE_TOK;
	if (!token.compare("for"))
			return FOR_TOK;
	if (!token.compare("include"))
			return INCLUDE_TOK;
	if (!token.compare("return"))
			return RETURN_TOK;
	if (!token.compare("+="))
			return PLUSEQ_TOK;
	if (!token.compare("-="))
			return MINUSEQ_TOK;
	if (!token.compare("*="))
			return TIMESEQ_TOK;
	if (!token.compare("/="))
			return QUOTIENTEQ_TOK;
	if (!token.compare("&="))
			return ANDEQ_TOK;
	if (!token.compare("|="))
			return OREQ_TOK;
	if (!token.compare("^="))
			return XOREQ_TOK;
	if (!token.compare("<<"))
			return LSHIFT_TOK;
	if (!token.compare(">>"))
			return RSHIFT_TOK;
	if (!token.compare("<<="))
			return LSHIFTEQ_TOK;
	if (!token.compare(">>="))
			return RSHIFTEQ_TOK;
	if (!token.compare("<="))
			return LEQ_TOK;
	if (!token.compare(">="))
			return GEQ_TOK;
	if (!token.compare("=="))
			return EQEQ_TOK;

	return -1;
}

/**
 * Returns the Token ID of the next token in the file stored in yyin.
 *
 * @param : None
 * @return : The token ID of the next token in the file stored in yyin.
 */
int Analyser::yylex(void)
{
	string tokenBuffer = "";
	int tokenType = NONE;

	while (true)
	{
		char currentCharacter = fgetc(yyin);

		if (feof(yyin))
			break;

		string newToken = tokenBuffer + currentCharacter;

		switch (tokenType)
		{
			case NONE:
				if (isWhiteSpace(currentCharacter))
					break;

				if (isDelimiter(newToken))
				{
					tokenType = DELIMITER;
					return getTokenID(newToken, tokenType);
				}

				if (isReservedWord(newToken))
					tokenType = RESERVED;

				else if (isIdentifier(newToken))
					tokenType = IDENTIFIER;

				else if (isOperator(newToken))
					tokenType = OPERATOR;

				else if (isIntegerConstant(newToken))
					tokenType = INTEGER;

				else
					return getTokenID(newToken, tokenType);

				tokenBuffer = newToken;
				break;

			case RESERVED:
				if (!isIdentifier(newToken))
				{
					// move file pointer back by one character
					fseek(yyin, -1, SEEK_CUR);
					return getTokenID(tokenBuffer, tokenType);
				}
				if (!isReservedWord(newToken))
					tokenType = IDENTIFIER;
				tokenBuffer = newToken;
				break;

			case IDENTIFIER:
				if (!isIdentifier(newToken))
				{
					// move file pointer back by one character
					fseek(yyin, -1, SEEK_CUR);
					return getTokenID(tokenBuffer, tokenType);
				}
				if (isReservedWord(newToken))
					tokenType = RESERVED;
				tokenBuffer = newToken;
				break;

			case OPERATOR:
				if (!isOperator(newToken))
				{
					// move file pointer back by one character
					fseek(yyin, -1, SEEK_CUR);
					return getTokenID(tokenBuffer, tokenType);
				}
				tokenBuffer = newToken;
				break;

			case INTEGER:
				if (!isIntegerConstant(newToken))
				{
					// move file pointer back by one character
					fseek(yyin, -1, SEEK_CUR);
					return getTokenID(tokenBuffer, tokenType);
				}
				tokenBuffer = newToken;
				break;
		}
	}

	return getTokenID(tokenBuffer, tokenType);
}

/**
 * Inform user about how to run the program if command line arg is not passed.
 *
 * @param argc : Number of command line arguments.
 * @return : None
 */
void Analyser::inputError(int argc)
{
	cout << "Missing Arguments - required 1 , found" << argc << "\n" << endl;
	cout << "Syntax:" << endl;
	cout << "-------" << endl;
	cout << "\tanalyser <source_filename>\n" << endl;
	cout << "Example:" << endl;
	cout << "--------" << endl;
	cout << "(If analyser (executable) and program.c (source file to be"
				<< "analysed) ";
	cout << " are in the same directory)" << endl;
	cout << "\t./analyser program.c\n"
					<< endl;
	cout << "Exiting ..." << endl;
	exit(0);
}

/**
 * Produce output of lexical analysis on program passed as command line arg.
 *
 * @param argc : Number of command line arguments.
 * @param argv : Command line arguments.
 * @return : None
 */
void Analyser::analyse(int argc, char *argv[])
{
	// If no input file is provided print error message and terminate.
	if (argc != 2)
		this->inputError(argc);

	else
	{
		// Open the file to be analysed in read mode.
		this->yyin = fopen(argv[1], "r");

		// Find tokens and print Token IDs.
		while (!feof(this->yyin))
		{
			int token_id = this->yylex();

			// Ensure that -1 is not printed for EOF.
			if (feof(this->yyin))
					break;

			// Print the token.
			cout << this->yytext << " ";

			// Print the token ID.
			cout << token_id << " ";

			// Print the token length.
			cout << this->yylen << endl;
		}

		fclose(this->yyin);
	}
	return;
}

}

#endif
