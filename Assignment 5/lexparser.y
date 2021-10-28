%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Size of symbol table
#define TABLE_SIZE 100

int yylex();
void yyerror(char* s);
int yylineno;
FILE* yyin;

// If there is no error in parsing a line, success remains 1, else changed to 0.
int success = 1;

// Tracks scope during parsing
int scope = 0;

// Stores datatype during parsing
int dtype;

// Stores current function name during parsing
char fname[10] = "main";

// Structure for a symbol's entry in a symbol table
typedef struct Symbol
{
  char name[10];
  char fname[10];
  int dtype; // 0 for int; 1 for float
  int scope; // scope of this symbol
  struct Symbol* next;
} Symbol;

// Symbol table structure
typedef struct Symtable
{
  Symbol* entry[TABLE_SIZE];
} Symtable;

/*
  http://www.cse.yorku.ca/~oz/hash.html -> djb2 algorithm

  this algorithm (k=33) was first reported by dan bernstein many years ago in
  comp.lang.c. another version of this algorithm (now favored by bernstein)
  uses xor: hash(i) = hash(i - 1) * 33 ^ str[i]; the magic of number 33 (why
  it works better than many other constants, prime or not) has never
  been adequately explained.
*/
int hash(char *str)
{
  int hash = 5381;
  int c;

  while ((c = *str++))
    hash = ((hash << 5) + hash) + c; // hash * 33 + c

  return hash % TABLE_SIZE;
}

// Global variable for symbol table
Symtable table;

void __init__()
{
  for (int i = 0; i < TABLE_SIZE; i++)
    table.entry[i] = NULL;
}

// Function to add a new entry to symbol table
void add(char* symb)
{
  int hval = hash(symb);
  Symbol* head = table.entry[hval];
  if (head == NULL)
  {
    // No collision
    head = ( Symbol* )malloc(sizeof(Symbol));
    strcpy(head->name, symb);
    strcpy(head->fname, fname);
    head->dtype = dtype;
    head->scope = scope;
    head->next = NULL;
    table.entry[hval] = head;
    return;
  }

  // For collision, add this new symbol to the end of list
  while(head->next != NULL)
    head = head->next;

  head->next = ( Symbol* )malloc(sizeof(Symbol));
  strcpy(head->name, symb);
  head->dtype = dtype;
  head->scope = scope;
  head->next = NULL;
}

// Function to check if the variable is being redefined within a function in same scope
int existsInSameScope(char* symb)
{
  int hval = hash(symb);
  Symbol* head = table.entry[hval];
  if (head == NULL)
    return 0;

  while (head != NULL)
  {
    // If the symbol names match and
    // the current scope is same as its scope and
    // they are within same function and
    // their datatypes are same
    // then it implies that this identifier is being redeclared.
    if (strcmp(head->name,symb)==0 && head->scope==scope &&
        strcmp(head->fname,fname)==0 && dtype==head->dtype)
      return 1;

    head = head->next;
  }
  return 0;
}

// Function to check if hashtable contains a particular symbol.
int contains(char* symb)
{
  int hval = hash(symb);
  Symbol* head = table.entry[hval];
  if (head == NULL)
    return 0;

  while (head != NULL)
  {
    // If the symbol names match and
    // either the var is global or
    // the current scope>=its scope and they are within same function
    // then it implies that this identifier is already present.
    if ((strcmp(head->name,symb)==0) &&
        ((head->scope==0) || (head->scope<=scope && strcmp(head->fname,fname)==0)))
      return 1;

    head = head->next;
  }
  return 0;
}

// Free all the DMA space of hashtable
void __freeMemory__()
{
  for (int i = 0; i < TABLE_SIZE; i++)
  {
    Symbol* head = table.entry[i];
    Symbol* temp = head;
    while (head != NULL)
    {
      head = head->next;
      free(temp);
    }
  }
}
%}

// yylval is an union, instead of the default int
// and can hold both strings and integers.
%union
{
  int number;
  char* string;
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
%token NOT_EQ_TOK

%token INT_CONST_TOK
%token ID_TOK

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE_TOK

// %type tells bison which member of the yylval union is used by which expression
%type<number> INT_CONST_TOK
%type<string> ID_TOK

%left  '+' '-'
%left  '*' '/' '%'

%start S

%%
S:              MAIN_FN US_DEF_FNS
                ;
MAIN_FN:        DATATYPE MAIN_TOK '(' ')' BLK      {printf("\nSyntax of main function is correct");}
                ;
BLK:            BLK_START STMTS BLKS BLK_END
                ;
BLK_START:      '{'      {scope+=1;}
                ;
BLK_END:        '}'      {scope-=1;}
                ;
BLKS:           BLK STMTS BLKS
                |
                ;
STMTS:          STMTS STMT
                |
                ;
STMT:           RETURN_TOK EXPRESSION ';'  {printf("\nSyntax of return statement is correct");}
                | DECLARATION ';'          {printf("\nSyntax of declaration statement is correct");}
                | ASSIGN ';'               {printf("\nSyntax of assignment statement is correct");}
                | FN_CALL ';'              {printf("\nSyntax of function call is correct");}
                | ITER                     {printf("\nSyntax of iterative statement is correct");}
                | COND                     {printf("\nSyntax of conditional statement is correct");}
                ;
DECLARATION:    DATATYPE VARS
                ;
DATATYPE:       INT_TOK       {dtype = 0; printf("\n Integer declared in line %d.\n", yylineno);}
                | FLOAT_TOK   {dtype = 1; printf("\n Float declared in line %d\n", yylineno);}
                ;
VARS:           ID_TOK  { if(existsInSameScope($1))
                          {
                            char buff[50];
                            sprintf(buff,": Multiple definitions of the identifier %s",$1);
                            yyerror(buff);
                          }
                          else
                          {
                            add($1);
                          }
                        }
                | ID_TOK ',' VARS   { if(existsInSameScope($1))
                                      {
                                        char buff[50];
                                        sprintf(buff,": Multiple definitions of the identifier %s",$1);
                                        yyerror(buff);
                                      }
                                      else
                                      {
                                        add($1);
                                      }
                                    }
                ;
ASSIGN:         ID_TOK '=' EXPRESSION   {if(!contains($1)) { char buff[40]; sprintf(buff,": Undefined identifier %s",$1); yyerror(buff); } }
                ;
EXPRESSION:     '(' EXPRESSION ')'
                | EXPRESSION '+' EXPRESSION
                | EXPRESSION '-' EXPRESSION
                | EXPRESSION '*' EXPRESSION
                | EXPRESSION '/' EXPRESSION
                | EXPRESSION '%' EXPRESSION
                | INT_CONST_TOK
                | ID_TOK      {if(!contains($1)) { char buff[40]; sprintf(buff,": Undefined identifier %s",$1); yyerror(buff); } }
                ;

LOGIC_OP:       AND_TOK
                | OR_TOK
                ;
RELAT_OP:       LEQ_TOK
                | '<'
                | GEQ_TOK
                | '>'
                | EQEQ_TOK
                | NOT_EQ_TOK
                ;

COND:           IF_TOK '(' COND_PART ')' INNER_BODY %prec LOWER_THAN_ELSE
                | IF_TOK '(' COND_PART ')' INNER_BODY ELSE_PART
                ;
ELSE_PART:      ELSE_TOK INNER_BODY
                ;

ITER:           FOR_TOK '(' INIT_PART ';' COND_PART ';' CHANGE_PART ')' INNER_BODY
                | WHILE_TOK '(' COND_PART ')' INNER_BODY
                | DO_TOK INNER_BODY WHILE_TOK '(' COND_PART ')' ';'
                ;
INNER_BODY:       BODY_START STMT {scope-=1;}
                | BLK
                ;
BODY_START:     {scope+=1;}
                ;

INIT_PART:      ASSIGN
                |
                ;
CHANGE_PART:      ID_TOK '+' '+'      {if(!contains($1)) { char buff[40]; sprintf(buff,": Undefined identifier %s",$1); yyerror(buff); } }
                | ID_TOK '-' '-'      {if(!contains($1)) { char buff[40]; sprintf(buff,": Undefined identifier %s",$1); yyerror(buff); } }
                |
                ;
COND_PART:      CONDITIONS
                |
                ;
CONDITIONS:       CONDITION
                | CONDITION LOGIC_OP CONDITIONS
                ;
CONDITION:      EXPRESSION RELAT_OP EXPRESSION
                ;

FN_CALL:        ID_TOK '=' FN_SIGN   {if(!contains($1)) { char buff[40]; sprintf(buff,": Undefined identifier %s",$1); yyerror(buff); } }
                | FN_SIGN
                ;
FN_SIGN:        ID_TOK '(' OPTIONS ')'
                ;
OPTIONS:        PARAMS
                |
                ;
PARAMS:         PARAM
                | PARAM ',' PARAMS
                ;
PARAM:          ID_TOK  {if(!contains($1)) { char buff[40]; sprintf(buff,": Undefined identifier %s",$1); yyerror(buff); } }
                | INT_CONST_TOK
                ;

US_DEF_FNS:     US_DEF_FN US_DEF_FNS
                |
                ;
US_DEF_FN:      DATATYPE FN_NAME '(' OPTIONS_FORMAL ')' BLK  {printf("\nSyntax of user defined function is correct");}
                ;
FN_NAME:        ID_TOK  {strcpy(fname,$1);}
                ;
OPTIONS_FORMAL: PARAMS_FORMAL
                |
                ;
PARAMS_FORMAL:    PARAM_FORMAL
                | PARAM_FORMAL ',' PARAMS_FORMAL
                ;
PARAM_FORMAL:   DATATYPE ID_TOK { if(existsInSameScope($2))
                                  {
                                    char buff[50];
                                    sprintf(buff,": Multiple definitions of the identifier %s",$2);
                                    yyerror(buff);
                                  }
                                  else
                                  {
                                    add($2);
                                  }
                                }
%%

int main(int argc, char *argv[])
{
  yyin = fopen(argv[1],"r");
  __init__();
  if (yyparse() == 0)
      printf("\nParsed successfully.\n");

  fclose(yyin);
  __freeMemory__();
  return 0;
}

void yyerror(char* msg)
{
  printf("\nParsing failed in line %d %s\n", yylineno, msg);
  success = 0;
}
