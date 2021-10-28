#ifndef LEXICAL_ANALYSER_HPP
#define LEXICAL_ANALYSER_HPP

// Defining some global token types for simplicity.
#define NONE 0
#define DELIMITER 1
#define OPERATOR 2
#define RESERVED 3
#define IDENTIFIER 4
#define INTEGER 5

#include <bits/stdc++.h>
using namespace std;

namespace lexicalAnalysis{

  class Analyser
  {
   public:
      // Constructor
      Analyser();

      // The input file is opened and stored in yyin. Token IDs are printed
      // by calling the yylex() function till eof is reached.
      void analyse(int, char**);

   private:
      // Stores the input source file
      FILE *yyin;

      // Stores the current token that was read
      char *yytext;

      // Length of token in yytext
      int yylen;

      // Returns the Token ID of the next token in the file stored in yyin.
      int yylex(void);

      // Used to guide the user to run programs using the analyser.s
      void inputError(int);

      // Helper function declarations.
      bool isWhiteSpace(char);
      bool isDelimiter(string);
      bool isOperator(string);
      bool isReservedWord(string);
      bool isIdentifier(string);
      bool isIntegerConstant(string);
      int getTokenID(string, int);

      // Supported single character lexemes.
      const static char LPAREN_TOK = '(';
      const static char GT_TOK = '>';
      const static char RPAREN_TOK = ')';
      const static char EQ_TOK = '=';
      const static char PLUS_TOK = '+';
      const static char MINUS_TOK = '-';
      const static char TIMES_TOK = '*';
      const static char QUOTIENT_TOK = '/';
      const static char SEMICOLON_TOK = ';';
      const static char LBRACE_TOK = '{';
      const static char RBRACE_TOK = '}';
      const static char LBRACKET_TOK = '<';
      const static char RBRACKET_TOK = '>';
      const static char COMMA_TOK = ',';
      const static char DOT_TOK = '.';

      // Supported multi character lexemes.
      const static unsigned int PLUSEQ_TOK = 450;
      const static unsigned int MINUSEQ_TOK = 451;
      const static unsigned int TIMESEQ_TOK = 452;
      const static unsigned int QUOTIENTEQ_TOK = 453;
      const static unsigned int GEQ_TOK = 454;
      const static unsigned int LEQ_TOK = 455;
      const static unsigned int ANDEQ_TOK = 456;
      const static unsigned int OREQ_TOK = 457;
      const static unsigned int XOREQ_TOK = 458;
      const static unsigned int LSHIFT_TOK = 459;
      const static unsigned int RSHIFT_TOK = 460;
      const static unsigned int LSHIFTEQ_TOK = 461;
      const static unsigned int RSHIFTEQ_TOK = 462;
      const static unsigned int EQEQ_TOK = 463;

      // Supported reserved words.
      const static unsigned int WHILE_TOK = 256;
      const static unsigned int FOR_TOK = 257;
      const static unsigned int IF_TOK = 258;
      const static unsigned int INCLUDE_TOK = 259;
      const static unsigned int RETURN_TOK = 260;
      const static unsigned int INT_TOK = 261;
      const static unsigned int FLOAT_TOK = 262;
      const static unsigned int CHAR_TOK = 263;
      const static unsigned int DOUBLE_TOK = 264;
      const static unsigned int BOOL_TOK = 265;
      const static unsigned int TRUE_TOK = 266;
      const static unsigned int FALSE_TOK = 267;

      // Supported identifier and constants.
      const static unsigned int ID_TOK = 350;
      const static unsigned int INTCONST_TOK = 351;

      // Supported reserved words.
      const string reservedWords[12] = {"while", "for", "if", "return",
          "include", "int", "float", "char","double","bool","true","false"};

      // Supported operators.
      const string operators[31] = {"+", "-", "*", "/", "++", "--", "=", "==",
          "<", "<=", ">", ">=", "&", "|", "^", "&&", "||", "+=", "-=", "*=",
          "/=", "&=", "|=", "^=", "<<", ">>", "<<=",">>=",":", "%", "~"};

      // Supported delimiters.
      const string delimiters[10] = {";", "(", ")", "{", "}", "[", "]", ".",
          ",", "#"};

  }; // class Analyser
} //namespace lexicalAnalysis

#endif
