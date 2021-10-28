%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Maximum size of the symbol table.
#define TABLE_SIZE 100

int yylex();
void yyerror(char* s);

// Keeps track of the current line being parsed.
int yylineno;

// Tracks scope during parsing
int scope = 0;

// Stores datatype during parsing
int dtype;

// Structure for a symbol's entry in a symbol table
typedef struct Symbol
{
  char name[10]; // name of the identifier
  int dtype;     // 0 for int; 1 for float
  int scope;     // scope of this symbol
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

// Initialize all pointers in the symbol table to NULL
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

  // No collision
  if (head == NULL)
  {
    head = ( Symbol* )malloc(sizeof(Symbol));
    strcpy(head->name, symb);
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
    // the current scope is same as its scope.
    if (strcmp(head->name, symb) == 0 && head->scope == scope)
    {
      // redeclaration
      if (dtype == head->dtype)
        return 1;

      // conflicting types
      else
        return 2;

    }
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
    // If the symbol names match
    // then it implies that this identifier is already present
    if (strcmp(head->name, symb) == 0)
      return 1;
    head = head->next;
  }
  return 0;
}

// Function to get the data type of a symbol present in symbol table
int getSymbolDataType(char* symb)
{
  int hval = hash(symb);
  Symbol* head = table.entry[hval];
  while (head != NULL)
  {
    if (strcmp(head->name, symb) == 0)
      return head->dtype;

    head = head->next;
  }
  // not needed since the symbol is known to exist in the table
  return 0;
}

// Function to delete symbols of a scope when coming out of that scope
void deleteScopeSymbols(int scope)
{
  for (int i = 0; i < TABLE_SIZE; i++)
  {
    Symbol* head = table.entry[i];
    Symbol* temp;
    if (head == NULL)
      continue;

    // Delete "matching scope" symbols at the start of the list
    while (head != NULL && head->scope == scope)
    {
      temp = head;
      head = head->next;
      free(temp);
      table.entry[i] = head;
    }

    // Look for the required symbols using the previous pointer
    while (head != NULL && head->next != NULL)
    {
      // Delete the next symbol
      if (head->next->scope == scope)
      {
        temp = head->next;
        head->next = temp->next;
        free(temp);
      }

      // Move the pointer forward
      else
        head = head->next;

    }
  }
}

// Helper function to print symbols in symbol table
void printSymbolTable()
{
  for (int i = 0; i < TABLE_SIZE; i++)
  {
    if (table.entry[i] == NULL)
      continue;

    printf("\nPrinting at index %d\n",i);
    Symbol* head = table.entry[i];
    while (head != NULL)
    {
      printf("%s %d %d\n",head->name, head->dtype, head->scope);
      head = head->next;
    }
  }
}

// Free all the DMA space of hashtable
void __freeMemory__()
{
  for (int i = 0; i < TABLE_SIZE; i++)
  {
    Symbol* head = table.entry[i];
    Symbol* temp;
    while (head!=NULL)
    {
      temp = head;
      head = head->next;
      free(temp);
    }
  }
}

%}

%union
{
  int number;     // for integer constants
  float decimal;  // for floating point numbers
  char* string;   // for name of identifiers
  int dtype;      // for datatype of expressions
}

// Keywords
%token          AUTO_TOK
%token          BREAK_TOK
%token          CASE_TOK
%token          CHAR_TOK
%token          CONST_TOK
%token          CONTINUE_TOK
%token          DEFAULT_TOK
%token          DO_TOK
%token          DOUBLE_TOK
%token          ELSE_TOK
%token          ENUM_TOK
%token          EXTERN_TOK
%token          FLOAT_TOK
%token          FOR_TOK
%token          GOTO_TOK
%token          IF_TOK
%token          INT_TOK
%token          LONG_TOK
%token          REGISTER_TOK
%token          RETURN_TOK
%token          SHORT_TOK
%token          SIGNED_TOK
%token          SIZEOF_TOK
%token          STATIC_TOK
%token          STRUCT_TOK
%token          SWITCH_TOK
%token          TYPEDEF_TOK
%token          UNION_TOK
%token          UNSIGNED_TOK
%token          VOID_TOK
%token          VOLATILE_TOK
%token          WHILE_TOK

%token          HEADER_TOK

// Constants
%token          MAIN_TOK
%token          REALCONST_TOK
%token          STRCONST_TOK
%token          CHARCONST_TOK

// Multi-character Lexemes
%token          PLUSEQ_TOK
%token          MINUSEQ_TOK
%token          TIMESEQ_TOK
%token          QUOTIENTEQ_TOK
%token          GEQ_TOK
%token          LEQ_TOK
%token          NOTEQ_TOK
%token          ANDEQ_TOK
%token          OREQ_TOK
%token          XOREQ_TOK
%token          LSHIFT_TOK
%token          RSHIFT_TOK
%token          LSHIFTEQ_TOK
%token          RSHIFTEQ_TOK
%token          EQEQ_TOK
%token          AND_TOK
%token          OR_TOK
%token          SCOPERES_TOK

%token          INT_CONST_TOK
%token          NOT_EQ_TOK

%token          ID_TOK

%nonassoc       LOWER_THAN_ELSE
%nonassoc       ELSE_TOK

// %type tells bison which member of the yylval union is used by which expression
%type<number>   INT_CONST_TOK
%type<string>   ID_TOK
%type<decimal>  REALCONST_TOK
%type<dtype>    EXPRESSION

%left           '+' '-'
%left           '*' '/' '%'

%start S

%%

S:              MAIN_FN US_DEF_FNS
                ;
MAIN_FN:        DATATYPE MAIN_TOK '(' ')' BLK {printf("\nSyntax of main function is correct");}
                ;
BLK:            BLK_START STMTS BLKS BLK_END
                ;
BLK_START:      '{'                           { scope += 1; }
                ;
BLK_END:        '}'                           { deleteScopeSymbols(scope); scope -= 1; }
                ;
BLKS:           BLK STMTS BLKS
                |
                ;
STMTS:          STMTS STMT
                |
                ;
STMT:           RETURN_TOK EXPRESSION ';'     {printf("\nSyntax of return statement is correct");}
                |
                DECLARATION ';'               {printf("\nSyntax of declaration statement is correct");}
                |
                ASSIGN ';'                    {printf("\nSyntax of assignment statement is correct");}
                |
                FN_CALL ';'                   {printf("\nSyntax of function call is correct");}
                |
                ITER                          {printf("\nSyntax of iterative statement is correct");}
                |
                COND                          {printf("\nSyntax of conditional statement is correct");}
                ;
DECLARATION:    DATATYPE VARS
                ;
DATATYPE:       INT_TOK                       { dtype = 0;
                                                printf("\n Integer declared in line %d.\n", yylineno);
                                              }
                |
                FLOAT_TOK                     { dtype = 1;
                                                printf("\n Float declared in line %d\n", yylineno);
                                              }
                ;
VARS:           ID_TOK ARRAY_OPTN             { int type = existsInSameScope($1);
                                                if (type == 1)
                                                {
                                                  char buff[50];
                                                  sprintf(buff,": Multiple definitions of the identifier %s",$1);
                                                  yyerror(buff);
                                                }
                                                else if (type == 2)
                                                {
                                                  char buff[50];
                                                  sprintf(buff,": Conflicting types for the identifier %s",$1);
                                                  yyerror(buff);
                                                }
                                                else
                                                {
                                                  add($1);
                                                }
                                              }
                |
                ID_TOK ARRAY_OPTN ',' VARS    { int type = existsInSameScope($1);
                                                if (type == 1)
                                                {
                                                  char buff[50];
                                                  sprintf(buff,": Multiple definitions of the identifier %s",$1);
                                                  yyerror(buff);
                                                }
                                                else if (type == 2)
                                                {
                                                  char buff[50];
                                                  sprintf(buff,": Conflicting types for the identifier %s",$1);
                                                  yyerror(buff);
                                                }
                                                else
                                                {
                                                  add($1);
                                                }
                                              }
                ;
ARRAY_OPTN:     '[' INT_CONST_TOK ']'
                |
                '[' REALCONST_TOK ']'         { char buff[40];
                                                sprintf(buff,": Incorrect Array Declaration");
                                                yyerror(buff);
                                              }
                |
                ;
ASSIGN:         ID_TOK '=' EXPRESSION         { if (!contains($1))
                                                {
                                                  char buff[40];
                                                  sprintf(buff,": Undefined identifier %s",$1);
                                                  yyerror(buff);
                                                }
                                                else
                                                {
                                                  if (getSymbolDataType($1)!=$3)
                                                  {
                                                    char buff[50];
                                                    sprintf(buff,": Illegal assignment (Type Error) detected");
                                                    yyerror(buff);
                                                  }
                                                }
                                            }
                ;
EXPRESSION:     '(' EXPRESSION ')'          { $$ = $2; }
                |
                EXPRESSION '+' EXPRESSION   { if ($1 != $3)
                                              {
                                                char buff[40];
                                                sprintf(buff,": Type error in expression");
                                                yyerror(buff);
                                              }
                                              $$ = $1;
                                            }
                |
                EXPRESSION '-' EXPRESSION   { if ($1 != $3)
                                              {
                                                char buff[40];
                                                sprintf(buff,": Type error in expression");
                                                yyerror(buff);
                                              }
                                              $$ = $1;
                                            }
                |
                EXPRESSION '*' EXPRESSION   { if ($1 != $3)
                                              {
                                                char buff[40];
                                                sprintf(buff,": Type error in expression");
                                                yyerror(buff);
                                              }
                                              $$ = $1;
                                            }
                |
                EXPRESSION '/' EXPRESSION   { if ($1 != $3)
                                              {
                                                char buff[40];
                                                sprintf(buff,": Type error in expression");
                                                yyerror(buff);
                                              }
                                              $$ = $1;
                                            }
                |
                EXPRESSION '%' EXPRESSION   { if ($1 != $3)
                                              {
                                                char buff[40];
                                                sprintf(buff,": Type error in expression");
                                                yyerror(buff);
                                              }
                                              $$ = $1;
                                            }
                |
                INT_CONST_TOK               { $$ = 0; }
                |
                REALCONST_TOK               { $$ = 1; }
                |
                ID_TOK                      { if (!contains($1))
                                              {
                                                char buff[40];
                                                sprintf(buff,": Undefined identifier %s",$1);
                                                yyerror(buff);
                                              }
                                              else
                                              {
                                                $$ = getSymbolDataType($1);
                                              }
                                            }

LOGIC_OP:       AND_TOK
                |
                OR_TOK
                ;
RELAT_OP:       LEQ_TOK
                |
                '<'
                |
                GEQ_TOK
                |
                '>'
                |
                EQEQ_TOK
                |
                NOT_EQ_TOK
                ;
COND:           IF_TOK '(' COND_PART ')' INNER_BODY %prec LOWER_THAN_ELSE
                |
                IF_TOK '(' COND_PART ')' INNER_BODY ELSE_PART
                ;
ELSE_PART:      ELSE_TOK INNER_BODY
                ;
ITER:           FOR_TOK '(' INIT_PART ';' COND_PART ';' CHANGE_PART ')' INNER_BODY
                |
                WHILE_TOK '(' COND_PART ')' INNER_BODY
                |
                DO_TOK INNER_BODY WHILE_TOK '(' COND_PART ')' ';'
                ;
INNER_BODY:     BODY_START STMT              { deleteScopeSymbols(scope); scope -= 1; }
                |
                BLK
                ;
BODY_START:     {scope+=1;}
                ;
INIT_PART:      ASSIGN
                |
                ;
CHANGE_PART:    ID_TOK '+' '+'                {if (!contains($1))
                                                {
                                                  char buff[40];
                                                  sprintf(buff,": Undefined identifier %s",$1);
                                                  yyerror(buff);
                                                }
                                              }
                |
                ID_TOK '-' '-'                {if (!contains($1))
                                                {
                                                  char buff[40];
                                                  sprintf(buff,": Undefined identifier %s",$1);
                                                  yyerror(buff);
                                                }
                                              }
                |
                ;
COND_PART:      CONDITIONS
                |
                ;
CONDITIONS:     CONDITION
                |
                CONDITION LOGIC_OP CONDITIONS
                ;
CONDITION:      EXPRESSION RELAT_OP EXPRESSION  { if ($1 != $3)
                                                  {
                                                    char buff[40];
                                                    sprintf(buff,": Type mismatch in operands");
                                                    yyerror(buff);
                                                  }
                                                }
                ;
FN_CALL:        ID_TOK '=' FN_SIGN              {if (!contains($1))
                                                  {
                                                    char buff[40];
                                                    sprintf(buff,": Undefined identifier %s",$1);
                                                    yyerror(buff);
                                                  }
                                                }
                |
                FN_SIGN
                ;
FN_SIGN:        ID_TOK '(' OPTIONS ')'
                ;
OPTIONS:        PARAMS
                |
                ;
PARAMS:         PARAM
                |
                PARAM ',' PARAMS
                ;
PARAM:          ID_TOK                           {if (!contains($1))
                                                    { char buff[40];
                                                      sprintf(buff,": Undefined identifier %s",$1);
                                                      yyerror(buff);
                                                    }
                                                  }
                |
                INT_CONST_TOK
                |
                REALCONST_TOK
                ;
US_DEF_FNS:     US_DEF_FN US_DEF_FNS
                |
                ;
US_DEF_FN:      DATATYPE FN_NAME '(' OPTIONS_FORMAL ')' BLK    {printf("\nSyntax of user defined function is correct");}
                ;
FN_NAME:        ID_TOK
                ;
OPTIONS_FORMAL: PARAMS_FORMAL
                |
                ;
PARAMS_FORMAL:  PARAM_FORMAL
                |
                PARAM_FORMAL ',' PARAMS_FORMAL
                ;
PARAM_FORMAL:   DATATYPE ID_TOK { int type = existsInSameScope($2);
                                  if(type == 1)
                                  {
                                    char buff[50];
                                    sprintf(buff,": Multiple definitions of the identifier %s",$2);
                                    yyerror(buff);
                                  }
                                  else if(type == 2)
                                  {
                                    char buff[50];
                                    sprintf(buff,": Conflicting types for the identifier %s",$2);
                                    yyerror(buff);
                                  }
                                  else
                                  {
                                    add($2);
                                  }
                                }
%%

int main()
{
    __init__();
    if (yyparse() == 0)
      printf("\nParse Complete.\n");
    __freeMemory__();
    return 0;
}

void yyerror(char* msg)
{
  printf("\nParsing failed at line %d %s\n", yylineno, msg);
}
