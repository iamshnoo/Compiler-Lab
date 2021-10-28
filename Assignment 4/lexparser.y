%{
#include <stdio.h>
#include <string.h>

int yylex ( );

int yylineno;

void yyerror ( char * );

char sym_table[255][255], tmp[255];

int sym_table_index = 0;

int sem_err = 0;

void updateSymTable ( int );
%}

%union
{
	char* str;
}

// Keywords
%token AUTO_TOK
%token BREAK_TOK
%token CASE_TOK
%token CHAR_TOK
%token CONST_TOK
%token CONTINUE_TOK
%token DEFAULT_TOK
%token DO_TOK
%token DOUBLE_TOK
%token ELSE_TOK
%token ENUM_TOK
%token EXTERN_TOK
%token FLOAT_TOK
%token FOR_TOK
%token GOTO_TOK
%token IF_TOK
%token INT_TOK
%token LONG_TOK
%token REGISTER_TOK
%token RETURN_TOK
%token SHORT_TOK
%token SIGNED_TOK
%token SIZEOF_TOK
%token STATIC_TOK
%token STRUCT_TOK
%token SWITCH_TOK
%token TYPEDEF_TOK
%token UNION_TOK
%token UNSIGNED_TOK
%token VOID_TOK
%token VOLATILE_TOK
%token WHILE_TOK

%token HEADER_TOK

// Constants
%token MAIN_TOK
%token <str> ID_TOK
%token INTCONST_TOK
%token REALCONST_TOK
%token STRCONST_TOK
%token CHARCONST_TOK

// Multi-character Lexemes
%token PLUSEQ_TOK
%token MINUSEQ_TOK
%token TIMESEQ_TOK
%token QUOTIENTEQ_TOK
%token GEQ_TOK
%token LEQ_TOK
%token NOTEQ_TOK
%token ANDEQ_TOK
%token OREQ_TOK
%token XOREQ_TOK
%token LSHIFT_TOK
%token RSHIFT_TOK
%token LSHIFTEQ_TOK
%token RSHIFTEQ_TOK
%token EQEQ_TOK
%token AND_TOK
%token OR_TOK
%token SCOPERES_TOK

%left '+' '-'
%left '*' '/' '%'

%start S

%%

S   : MAIN
    | USER_FUNCTION
    | DECLARE_ASSIGN
    | HEADER_TOK
    | HEADER_TOK S
    | S USER_FUNCTION
    | S MAIN
    | S DECLARE_ASSIGN
    ;

MAIN  : INT_TOK MAIN_TOK '(' ')' '{' BLOCK RETURN_TOK INTCONST_TOK ';' '}'           {printf("Main function is syntactically correct.\n");}
      ;

USER_FUNCTION : VOID_TOK ID_TOK '(' ')' '{' BLOCK RETURN_TOK ';' '}'                 {printf("User Defined function is syntactically correct.\n");}
              | INT_TOK ID_TOK '(' ')' '{' BLOCK RETURN_TOK INTCONST_TOK ';' '}'     {printf("User Defined function is syntactically correct.\n");}
              | FLOAT_TOK ID_TOK '(' ')' '{' BLOCK RETURN_TOK REALCONST_TOK ';' '}'  {printf("User Defined function is syntactically correct.\n");}
              | DOUBLE_TOK ID_TOK '(' ')' '{' BLOCK RETURN_TOK REALCONST_TOK ';' '}' {printf("User Defined function is syntactically correct.\n");}
              | CHAR_TOK ID_TOK '(' ')' '{' BLOCK RETURN_TOK CHARCONST_TOK ';' '}'   {printf("User Defined function is syntactically correct.\n");}

BLOCK   : STATEMENTS
        ;

STATEMENTS  : STATEMENT STATEMENTS
            |
            ;

STATEMENT   : DECLARE_ASSIGN
            | EXPRESSION_ASSIGN
            | CONDITIONAL                                                            {printf("Syntactically correct conditional block ended at Line %d\n", yylineno);}
            | ITERATIVE                                                              {printf("Syntactically correct iterative block ended at Line %d\n", yylineno);}
            | FUNC_CALL                                                              {printf("Function call at Line %d\n", yylineno);}
            ;

COMPARISON  : '>'
            | '<'
            | GEQ_TOK
            | LEQ_TOK
            | NOTEQ_TOK
            | EQEQ_TOK
            | AND_TOK
            | OR_TOK


DECLARE_ASSIGN  : INT_TOK INT_VARLIST ';'
                | FLOAT_TOK FLOAT_VARLIST ';'
                | CHAR_TOK CHAR_VARLIST ';'
                ;

INT_VARLIST : ID_TOK
            | ID_TOK ',' INT_VARLIST
            | ID_TOK '=' INTCONST_TOK   {strcpy(tmp, $1); updateSymTable(1);}
            ;

FLOAT_VARLIST   : FLOAT_TOK
                | FLOAT_TOK ',' FLOAT_VARLIST
                | FLOAT_TOK '=' REALCONST_TOK
                | FLOAT_TOK '=' REALCONST_TOK ',' FLOAT_VARLIST
                ;

CHAR_VARLIST    : CHAR_TOK
                | CHAR_TOK ',' CHAR_VARLIST
                | CHAR_TOK '=' CHARCONST_TOK
                | CHAR_TOK '=' CHARCONST_TOK ',' CHAR_VARLIST
                ;


EXPRESSION_ASSIGN   : INT_TOK ID_TOK '=' EXPRESSION ';'
                    | FLOAT_TOK ID_TOK '=' EXPRESSION ';'
                    | ID_TOK '=' EXPRESSION ';' {strcpy(tmp, $1); updateSymTable(0);}

EXPRESSION  : ID_TOK
            | INTCONST_TOK
            | REALCONST_TOK
            | '(' EXPRESSION ')'
            | EXPRESSION '+' EXPRESSION
            | EXPRESSION '-' EXPRESSION
            | EXPRESSION '*' EXPRESSION
            | EXPRESSION '/' EXPRESSION
            | EXPRESSION '%' EXPRESSION
            ;

CONDITIONAL : IF_TOK '(' CONDITIONAL_EXPRESSION ')' '{' BLOCK '}'
            | IF_TOK '(' CONDITIONAL_EXPRESSION ')' '{' BLOCK '}' ELSE_TOK '{' BLOCK '}'
            | IF_TOK '(' CONDITIONAL_EXPRESSION ')' '{' BLOCK '}' ELSE_TOK CONDITIONAL
            ;

CONDITIONAL_EXPRESSION  : EXPRESSION
                        | EXPRESSION COMPARISON EXPRESSION
                        ;

ITERATIVE   : WHILE_TOK '(' CONDITIONAL_EXPRESSION ')' '{' BLOCK '}'
            | DO_TOK '{' BLOCK '}' WHILE_TOK '(' CONDITIONAL_EXPRESSION ')' ';'
            | FOR_TOK '(' DECLARE_ASSIGN CONDITIONAL_EXPRESSION ';' FOR_UPDATE ')' '{' BLOCK '}'
            | FOR_TOK '(' FOR_INIT ';' CONDITIONAL_EXPRESSION ';' FOR_UPDATE ')' '{' BLOCK '}'
            ;

FOR_INIT  : INT_TOK ID_TOK '=' EXPRESSION
          | FLOAT_TOK ID_TOK '=' EXPRESSION
          | ID_TOK '=' EXPRESSION

FOR_UPDATE  : ID_TOK '=' EXPRESSION
            | ID_TOK '+' '+'
            ;


FUNC_CALL   : INT_TOK ID_TOK '=' ID_TOK '(' ARGs ')' ';'
            | FLOAT_TOK ID_TOK '=' ID_TOK '(' ARGs ')' ';'
            | CHAR_TOK ID_TOK '=' ID_TOK '(' ARGs ')' ';'
            | ID_TOK '=' ID_TOK '(' ARGs ')' ';'
            | ID_TOK '(' ARGs ')' ';'
            ;

ARGs    : ARG
        |
        ;

ARG : ID_TOK
    | ID_TOK ',' ARG
    | INTCONST_TOK
    | INTCONST_TOK ',' ARG
    | REALCONST_TOK
    | REALCONST_TOK ',' ARG
    | CHARCONST_TOK
    | CHARCONST_TOK ',' ARG
    | STRCONST_TOK
    | STRCONST_TOK ',' ARG
    ;

%%

int main()
{
  if ( yyparse() == 0 )
  {
    printf("\nNo Syntax Error\n");
    printf("%d Semantic Error(s) present\n", sem_err);
  }
  else
  {
    printf("\nSyntax Error\n");
  }
  return 0;
}

void yyerror ( char *s )
{
  printf("Error: %s at Line %d\n", s, yylineno);
}

void updateSymTable ( int isDeclaration )
{
  for(int i = 0; i < sym_table_index; i++)
  {
    if(strcmp(tmp, sym_table[i]) == 0)
    {
      if (isDeclaration)
      {
        sem_err++;
        printf("Variable %s : ", tmp);
        yyerror("Variable redeclaration");
      }
      return;
    }
  }

  if ( !isDeclaration )
  {
    sem_err++;
    printf("Variable %s : ", tmp);
    yyerror("Variable not declared");
    return;
  }

  printf("Variable %s : ", tmp);
  printf("Valid variable declaration\n");
  strcpy(sym_table[sym_table_index++], tmp);
}
