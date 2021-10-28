%{
// include all the token definitions.
#include "tokens.h"

// flag used to skip through multi-line comments.
int comment = 0;

// keep track of line number, for printing in case of invalid token.
int lineno = 1;

// print an error message if no command line args are passed.
void inputError( int );

// prints (token, token ID, token length) for all valid tokens defined in the
// header file above.
void tokenAction ( int );

// wrapper for tokenAction function above.
void action ( int );

// action for all tokens matching the 'invalid' name definition.
void invalidAction ( void );

// for handling statements startig with the symbol '#'.
void preprocessorAction ( void );

// ignore single line comments.
void singleCommentAction ( void );

// toggle comment flag to 1 to skip the comment.
void multilineBeginAction ( void );

// toggle comment flag back to 0.
void multilineEndAction ( void );

// increase the lineno by 1.
void newlineAction ( void );

// ignore whitespaces.
void whitespaceAction ( void );

// if the token does not match with any of the rules defined above this.
void unknownTokenAction ( void );
%}

identifier [a-zA-Z][a-zA-Z0-9_]*
character \'(\\.|.)\'
string  \"(\\.|[^"\\])*\"
integer [0-9]*
real [0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?
invalid ([0-9][0-9]*|[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)[a-dA-Df-zF-Z_][a-zA-Z0-9_]*
single_symbol [\.\,\!\#\$\%\^\&\*\(\)\-\_\+\=\{\}\[\]\\\|\~\:\;\"\'\/\?\>\<]
whitespace [ \t]*

%%

#.*             {preprocessorAction (        );}

{character}     {action ( CHARCONST_TOK      );}
{string}        {action ( STRCONST_TOK       );}

auto            {action ( AUTO_TOK           );}
break           {action ( BREAK_TOK          );}
case            {action ( CASE_TOK           );}
char            {action ( CHAR_TOK           );}
const           {action ( CONST_TOK          );}
continue        {action ( CONTINUE_TOK       );}
default         {action ( DEFAULT_TOK        );}
do              {action ( DO_TOK             );}
double          {action ( DOUBLE_TOK         );}
else            {action ( ELSE_TOK           );}
enum            {action ( ENUM_TOK           );}
extern          {action ( EXTERN_TOK         );}
float           {action ( FLOAT_TOK          );}
for             {action ( FOR_TOK            );}
goto            {action ( GOTO_TOK           );}
if              {action ( IF_TOK             );}
int             {action ( INT_TOK            );}
long            {action ( LONG_TOK           );}
register        {action ( REGISTER_TOK       );}
return          {action ( RETURN_TOK         );}
short           {action ( SHORT_TOK          );}
signed          {action ( SIGNED_TOK         );}
sizeof          {action ( SIZEOF_TOK         );}
static          {action ( STATIC_TOK         );}
struct          {action ( STRUCT_TOK         );}
switch          {action ( SWITCH_TOK         );}
typedef         {action ( TYPEDEF_TOK        );}
union           {action ( UNION_TOK          );}
unsigned        {action ( UNSIGNED_TOK       );}
void            {action ( VOID_TOK           );}
volatile        {action ( VOLATILE_TOK       );}
while           {action ( WHILE_TOK          );}

{identifier}    {action ( ID_TOK             );}
{invalid}       {invalidAction (             );}
{integer}       {action ( INTCONST_TOK       );}
{real}          {action ( REALCONST_TOK      );}

"//".*          {singleCommentAction (       );}
"/*"            {multilineBeginAction (      );}
"*/"            {multilineEndAction (        );}

"+="            {action ( PLUSEQ_TOK         );}
"-="            {action ( MINUSEQ_TOK        );}
"*="            {action ( TIMESEQ_TOK        );}
"/="            {action ( QUOTIENTEQ_TOK     );}
"&="            {action ( ANDEQ_TOK          );}
"|="            {action ( OREQ_TOK           );}
"^="            {action ( XOREQ_TOK          );}
"<<"            {action ( LSHIFT_TOK         );}
">>"            {action ( RSHIFT_TOK         );}
"<<="           {action ( LSHIFTEQ_TOK       );}
">>="           {action ( RSHIFTEQ_TOK       );}
"<="            {action ( LEQ_TOK            );}
">="            {action ( GEQ_TOK            );}
"=="            {action ( EQEQ_TOK           );}
"::"            {action ( SCOPERES_TOK       );}

{single_symbol} {action ( (int) yytext[0]    );}

"\n"            {newlineAction (             );}
{whitespace}    {whitespaceAction (          );}

.               {unknownTokenAction (        );}

%%

/**
 * @brief Produce output of lexical analysis on program passed as
 *        command line arg.
 *
 * @param argc : Number of command line arguments.
 * @param argv : Command line arguments.
 * @return : None
 */
int main ( int argc, char **argv )
{
  // If no input file is provided print error message and terminate.
  if (argc != 2)
    inputError(argc);

  yyin = fopen ( argv[1], "r" );
  yylex();
  return 0;
}

/**
 * @brief Inform user about how to run the program if command line arg
 *        is not passed correctly.
 *
 * @param argc : Number of command line arguments.
 * @return : None
 */
void inputError ( int argc )
{
  int nargs = argc - 1;
  printf( "\nMissing Arguments - required 1 , found %d \n", nargs);
  printf( "Syntax: \n" );
  printf( "-------\n");
  printf( "\t./analyser <source_filename>\n");
  printf( "Example:\n");
  printf( "--------\n");
  printf( "If analyser and source file to be analysed are in the same directory \n");
  printf( "\t./analyser <program_name>.c\n");
  printf( "Exiting ...\n\n");
  exit(0);
}

// Overloads the default yywrap() to print a message on reaching EOF.
int yywrap ()
{
  printf("EOF reached! Thanks for using my analyser.\n");
  return 1;
}

void tokenAction ( int tokenId )
{
  printf( "%s %d %lu\n", yytext, tokenId, yyleng);
}

void action ( int tokenId )
{
  if (!comment)
    tokenAction( tokenId );
}

void invalidAction ( void )
{
  if (!comment)
    printf("ERROR: Invalid Token %s in Line %d\n", yytext, lineno);
}

void preprocessorAction ( void )
{
  if (!comment)
    printf("PREPROCESSOR : Preprocessor Directive -> %s\n", yytext);
}

void singleCommentAction ( void )
{
  if (!comment)
    printf("COMMENT : Single Line Comment in line %d\n", lineno);
}

void multilineBeginAction ( void )
{
  printf("COMMENT : Multi Line Comment beginning in line %d\n", lineno);
  comment = 1;
}

void multilineEndAction ( void )
{
  printf("COMMENT : Multi Line Comment ending in line %d\n", lineno);
  comment = 0;
}

void newlineAction ( void )
{
  lineno++;
}

void whitespaceAction ( void )
{
  return;
}

void unknownTokenAction ( void )
{
  if (!comment)
    printf("ERROR: Unknown Token %s in line %d\n", yytext, lineno);
}
