#ifndef LEXICAL_ANALYSER_IMPL_HPP
#define LEXICAL_ANALYSER_IMPL_HPP

// Include the definition file.
#include "analyser.hpp"

namespace lexicalAnalysis{

/**
 * @brief Construct a new Analyser:: Analyser object
 *
 */
Analyser::Analyser()
{
// Do nothing here.
}

/**
 * @brief Checks if a character is a whitespace i.e. space or tab or newline.
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
 * @brief Checks if a token is a delimiter.
 *
 * @param token : The input token to check.
 * @return : A bool denoting whether the token is a delimiter.
 */
bool Analyser::isDelimiter(char ch)
{
  for (char delimiter : delimiters)
    if (ch == delimiter)
      return true;
  return false;
}

/**
 * @brief Checks if a token is a valid operator.
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
 * @brief Checks if a token is a valid reserved word.
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
 * @brief Checks if a token is a valid identifier.
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
 * @brief Checks if a token is valid integer constant.
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
 * @brief Sets the value of yytext and returns the ID of the input token.
 *
 * @param token : The input token to get ID.
 * @param state : The transition state of token.
 * @return : The token ID of the input token and -1 if error.
 */
int Analyser::getTokenID(string token, int state)
{
  // setting yytext as the current token
  yytext = (char *)malloc(sizeof(char) * token.length() + 1);
  strcpy(yytext, token.c_str());
  TokenLength() = token.length();

  if (state == Error())
    return Error();

  if (state == 17)
    return INTCONST_TOK;

  if (state == 19 || state == 22)
    return REALCONST_TOK;

  if (state == 15 || state == 16)
  {
    if (!isReservedWord(token))
      return ID_TOK;

    // Else
    // Determine the Token ID of reserved words by direct comparison

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
  }

  if (state == 23 || (state >= 1 && state <= 14))
  {

    // For single character delimiters and operators the Token ID is
    // the ASCII code of the character itself. If other Token ID scheme
    // is used, then these will have to be added to the next section of
    // this function.
    if (token.length() == 1)
        return token[0];


    // Determining the Token ID of multi-character operators by direct
    // comparision
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
  }
  return Error();
}

/**
 * @brief Return the next state from current state after reading
 *        the next character.
 *
 * @param state : The current state of the finite automata.
 * @param ch : The next character parsed.
 * @return int : The state which the automata transitions to using the above
 *              parameters as input.
 */
int Analyser::getNextState(int state, char ch)
{
  // first character of token
  if (state == 0)
  {
    // Operator
    if (ch == '%')
      return 1;
    if (ch == '/')
      return 2;
    if (ch == '*')
      return 3;
    if (ch == '-')
      return 4;
    if (ch == '+')
      return 5;
    if (ch == '=' || ch == '!')
      return 6;
    if (ch == '|')
      return 7;
    if (ch == '&')
      return 8;
    if (ch == '^')
      return 9;
    if (ch == '>')
      return 10;
    if (ch == '<')
      return 12;

    // Identifier / Reserved Word
    if (isalpha(ch) || ch == '_')
      return 15;

    // Number
    if (isdigit(ch))
      return 17;

    // Delimiter
    return 23;
  }

  // Now parse the second character of token, if any.

  // Handles all cases ending with '='
  if (state >= 1 && state <= 13)
    if (ch == '=')
      return 14;

  // Handle other specific cases below.

  // Handles '--'
  if (state == 4 )
    if (ch == '-')
      return 14;

  // Handles '++'
  if (state == 5 )
    if (ch == '+')
      return 14;

  // Handles '>>'
  if (state == 10 )
    if (ch == '>')
      return 11;

  // Handles '<<' and '<>'
  if (state == 12)
  {
    if (ch == '<')
      return 13;
    if (ch == '>')
      return 14;
  }

  // Handles '||'
  if (state == 7 )
    if (ch == '|')
      return 14;

  // Handles '&&'
  if (state == 8 )
    if (ch == '&')
      return 14;

  // Identifiers / Reserved Words
  if (state == 15 || state == 16)
    if (ch == '_' || isalpha(ch) || isdigit(ch))
      return 16;

  // Numbers

  // Integers
  if (state == 17)
  {
    if (isdigit(ch))
      return 17;
    if (ch == '.')
      return 18;
    if (ch == 'E' || ch == 'e')
      return 20;
    if (!isOperator(std::string(1, ch)) && !isDelimiter(ch))
      return Error();
  }

  // decimal point
  if (state == 18)
  {
    if (isdigit(ch))
      return 19;
    return Error();
  }

  // Decimal Number
  if (state == 19)
  {
    if (isdigit(ch))
      return 19;
    if (ch == 'E' || ch == 'e')
      return 20;
  }

  // exponent sign 'E' or 'e'
  if (state == 20)
  {
    if (isdigit(ch))
      return 22;
    if (ch == '+' || ch == '-')
      return 21;
    return Error();
  }

  // sign of exponent
  if (state == 21)
  {
    if (isdigit(ch))
      return 22;
    return Error();
  }

  // Scientific Form
  if (state == 22)
    if (isdigit(ch))
      return 22;

  return Accept();
}

/**
 * @brief Returns the Token ID of the next token in the file stored in yyin.
 *
 * @param : None
 * @return : The token ID of the next token in the file stored in yyin.
 */
int Analyser::yylex(void)
{
  string tokenBuffer = "";
  int currState = 0;

  while (true)
  {
    char currChar = fgetc(yyin);

    if (feof(yyin))
        break;

    if (currState == 0)
    {
      // Ignore blank lines.
      if (isWhiteSpace(currChar))
      {
        if (currChar == '\n')
          lineNumber++;
        continue;
      }

      // Ignore #include and #define statements
      else if (currChar == '#')
      {
        while (!feof(yyin) && currChar != '\n')
          currChar = fgetc(yyin);
        lineNumber++;
        continue;
      }
    }

    int newState = getNextState(currState, currChar);

    // invalid token found
    if (newState == Error())
    {
      tokenBuffer += currChar;
      while (!feof(yyin) && currChar != '\n')
        currChar = fgetc(yyin);
      lineNumber++;
      currState = newState;
      break;
    }

    // complete valid token found
    if (newState == Accept())
    {
      // move file pointer back by one character
      if (!isWhiteSpace(currChar))
        fseek(yyin, -1, SEEK_CUR);

      else if (currChar == '\n')
        lineNumber++;
      break;
    }
    tokenBuffer += currChar;
    currState = newState;
  }

  return getTokenID(tokenBuffer, currState);
}

/**
 * @brief Inform user about how to run the program if command line arg
 *        is not passed correctly.
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
 * @brief Produce output of lexical analysis on program passed as
 *        command line arg.
 *
 * @param argc : Number of command line arguments.
 * @param argv : Command line arguments.
 * @return : None
 */
void Analyser::analyse(int argc, char *argv[])
{
  // If no input file is provided print error message and terminate.
  if (argc != 2)
    inputError(argc);

  else
  {
    // Open the file to be analysed in read mode.
    yyin = fopen(argv[1], "r");
    lineNumber = 0;

    // Find tokens and print Token IDs.
    while (!feof(yyin))
    {
      int token_id = yylex();

      // Ensure that -1 is not printed for EOF.
      if (feof(yyin))
          break;

      // Print the token.
      cout << yytext << " ";

      if (token_id == Error())
      {
        cout << "ERROR: Invalid Token " << yytext <<" in Line "
            << lineNumber << endl;
        continue;
      }

      // Print the token ID.
      cout << token_id;

      // Print the length of the token.
      cout << " " << TokenLength();

      // Print next token on a new line.
      cout << endl;
    }

    fclose(yyin);
  }
  return;
}

}

#endif
