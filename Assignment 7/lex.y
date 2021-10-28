%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Size of HashTable
#define TABLE_SIZE 100

int yylex();
int yyerror(char* s);
int yylineno;
FILE* yyin;
int success=1;

// File to store the generated intermediate code
FILE* interm_file;

// Keeps track of the label number for lines of intermediate code
int interm_label=0;

// Used to create new unique temporary variable name for intermediate code
int new_temp_index=1;

// Stores intermediate code corresponding to a label
char* interm_code[100];

int temp_label=0, backpatch_label=0, temp=0;

// expr_var tracks last assigned var in expressions/assignment
// temp_var is useful for backpatching later
char expr_var[10], temp_var[10];

// Tracks scope during parsing
int scope=0;

// Stores datatype during parsing
int dtype;

/** SYMBOL TABLE DS BEGINS **/

// Structure for a symbol's entry in a symbol table
typedef struct Symbol
{
    char name[10]; // name of the identifier
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

// Initialize all pointers in the symbol table to NULL
void init()
{
    for(int i=0;i<TABLE_SIZE;i++)
    {
        table.entry[i]=NULL;
    }
}

// Function to add a new entry to symbol table
void add(char* symb)
{
    int hval=hash(symb);
    Symbol* head=table.entry[hval];
    if(head==NULL)
    { // No collision
        head=(Symbol*)malloc(sizeof(Symbol));
        strcpy(head->name,symb);
        head->dtype=dtype;
        head->scope=scope;
        head->next=NULL;
        table.entry[hval]=head;
        return;
    }
    // For collision, add this new symbol to the end of list
    while(head->next!=NULL)
    {
        head=head->next;
    }
    head->next=(Symbol*)malloc(sizeof(Symbol));
    strcpy(head->name,symb);
    head->dtype=dtype;
    head->scope=scope;
    head->next=NULL;
}

// Function to check if the variable is being redefined in same scope
// returns 1 for redeclaration, 2 for conflicting types, otherwise 0
int existsInSameScope(char* symb)
{
    int hval=hash(symb);
    Symbol* head=table.entry[hval];
    if(head==NULL)
    {
        return 0;
    }
    while(head!=NULL)
    {
        // If the symbol names match and
        //      the current scope==its scope
        // then it implies that this identifier is
        //      either being redeclared (if datatypes are same)
        //      or, conflicting types found (if datatypes differ)
        if(strcmp(head->name,symb)==0 && head->scope==scope)
        {
            if(dtype==head->dtype)
            { // redeclaration
                    return 1;
            }
            else
            { // conflicting types
                    return 2;
            }
        }
        head=head->next;
    }
    return 0;
}

// Function to check if hashtable contains a particular symbol
int contains(char* symb)
{
    int hval=hash(symb);
    Symbol* head=table.entry[hval];
    if(head==NULL)
    {
        return 0;
    }
    while(head!=NULL)
    {
        // If the symbol names match
        // then it implies that this identifier is already present
        if(strcmp(head->name,symb)==0)
        {
            return 1;
        }
        head=head->next;
    }
    return 0;
}

// Function to get the data type of a symbol present in symbol table
int getDtype(char* symb)
{
    int hval=hash(symb);
    Symbol* head=table.entry[hval];
    while(head!=NULL)
    {
        if(strcmp(head->name,symb)==0)
        {
            return head->dtype;
        }
        head=head->next;
    }
    // not needed since the symbol is known to exist in the table
    return 0;
}

// Function to delete symbols of a scope when coming out of that scope
void deleteSymbolsOfScope(int scope)
{
    for(int i=0;i<TABLE_SIZE;i++)
    {
        Symbol* head=table.entry[i];
        Symbol* temp;
        if(head==NULL)
        {
            continue;
        }
        // Delete "matching scope" symbols at the start of the list
        while(head!=NULL && head->scope==scope)
        {
            temp=head;
            head=head->next;
            free(temp);
            table.entry[i]=head;
        }
        // Look for the required symbols using the previous pointer
        while(head!=NULL && head->next!=NULL)
        {
            if(head->next->scope==scope)
            { // Delete the next symbol
                    temp=head->next;
                    head->next=temp->next;
                    free(temp);
            }
            else
            { // Move the pointer forward
                    head=head->next;
            }
        }
    }
}

// Helper function to print symbols in symbol table
void printSymbolTable()
{
    for(int i=0;i<TABLE_SIZE;i++)
    {
        if(table.entry[i]==NULL)
        {
            continue;
        }
        printf("\nPrinting at index %d\n",i);
        Symbol* head=table.entry[i];
        while(head!=NULL)
        {
            printf("%s %d %d\n",head->name,head->dtype,head->scope);
            head=head->next;
        }
    }
}

// Free all the DMA space of hashtable
void freeAll()
{
    for(int i=0;i<TABLE_SIZE;i++)
    {
        Symbol* head=table.entry[i];
        Symbol* temp;
        while(head!=NULL)
        {
            temp=head;
            head=head->next;
            free(temp);
        }
    }
}

/** SYMBOL TABLE DS ENDS **/

/** FUNCTIONS FOR INTERMEDIATE CODE GENERATION **/

// Function to return name of a new temporary variable
char* newTemp()
{
    static char t[3];
    sprintf(t,"t%d",new_temp_index);
    return t;
}

// Function to emit the quadruple to output array
void generate(int label,char* str)
{
    interm_code[label]=(char*)malloc((strlen(str)+1)*sizeof(char));
    strcpy(interm_code[label],str);
}

// Function to print the intermediate codes to output file
void writeIntermCode(){
    for(int i=0;i<100;i++)
    {
        if(interm_code[i]!=NULL)
        {
            fprintf(interm_file,"%d: %s",i,interm_code[i]);
            free(interm_code[i]);
        }
    }
}

%}

// yylval is now a union (instead of default int)
// which can hold different info.
%union
{
    int number;     // for integer constants
    float decimal;  // for floating point numbers
    char* string;   // for name of identifiers
    struct DtypeName
    {                   // for expressions
        int dtype;      // for datatype of expressions
        char* place;    // for "place" value of expression
    } DtypeName;
}

%token INT_CONST_TOK
%token FLOAT_CONST_TOK
%token INT_TOK
%token FLOAT_TOK
%token MAIN_TOK
%token LPAREN_TOK
%token RPAREN_TOK
%token LCURLY_TOK
%token RCURLY_TOK
%token LSQ_TOK
%token RSQ_TOK

%left  PLUS_TOK MINUS_TOK
%left  ASTERISK_TOK QUOTIENT_TOK MODULUS_TOK

%token ASSIGN_TOK
%token SEMICOLON_TOK
%token COMMA_TOK
%token IF_TOK
%token ELSE_TOK
%token WHILE_TOK
%token RETURN_TOK
%token IDENTIFIER_TOK

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE_TOK

%type<number> INT_CONST_TOK
%type<string> IDENTIFIER_TOK
%type<decimal> FLOAT_CONST_TOK
%type<DtypeName> EXPRESSION

%start S


%%
S:      MAIN_FN US_DEF_FNS
        ;
MAIN_FN:        DATATYPE MAIN_TOK LPAREN_TOK RPAREN_TOK BLK      {printf("\nSyntax of main function is correct");}
                ;
BLK:    BLK_START STMTS BLKS BLK_END
        ;
BLK_START:      LCURLY_TOK      {scope+=1;}
                ;
BLK_END:        RCURLY_TOK      {   deleteSymbolsOfScope(scope);
                                    scope-=1;
                                }
                ;
BLKS:   BLK STMTS BLKS
        |
        ;
STMTS:  STMTS STMT
        |
        ;
STMT:   RETURN_TOK EXPRESSION SEMICOLON_TOK     {printf("\nSyntax of return statement is correct");}
        |
        DECLARATION SEMICOLON_TOK       {printf("\nSyntax of declaration statement is correct");}
        |
        ASSIGN SEMICOLON_TOK            {printf("\nSyntax of assignment statement is correct");}
        |
        FN_CALL SEMICOLON_TOK           {printf("\nSyntax of function call is correct");}
        |
        ITER                            {printf("\nSyntax of iterative statement is correct");}
        |
        COND                            {printf("\nSyntax of conditional statement is correct");}
        ;
DECLARATION:    DATATYPE VARS
                ;
DATATYPE:   INT_TOK     {dtype=0;}
            |
            FLOAT_TOK   {dtype=1;}
            ;
VARS:   IDENTIFIER_TOK ARRAY_OPTN       { int type = existsInSameScope($1);
                                            if(type==1){
                                                char buff[50];
                                                sprintf(buff,": Multiple definitions of the identifier %s",$1);
                                                yyerror(buff);
                                            } else if(type==2){
                                                char buff[50];
                                                sprintf(buff,": Conflicting types for the identifier %s",$1);
                                                yyerror(buff);
                                            } else{
                                                add($1);
                                        } }
        |
        IDENTIFIER_TOK ARRAY_OPTN COMMA_TOK VARS        { int type = existsInSameScope($1);
                                                            if(type==1){
                                                                char buff[50];
                                                                sprintf(buff,": Multiple definitions of the identifier %s",$1);
                                                                yyerror(buff);
                                                            } else if(type==2){
                                                                char buff[50];
                                                                sprintf(buff,": Conflicting types for the identifier %s",$1);
                                                                yyerror(buff);
                                                            } else{
                                                                add($1);
                                                        } }
        ;
ARRAY_OPTN:     LSQ_TOK INT_CONST_TOK RSQ_TOK
                |
                LSQ_TOK FLOAT_CONST_TOK RSQ_TOK { char buff[40];
                                                    sprintf(buff,": Incorrect Array Declaration");
                                                    yyerror(buff);
                                                }
                |
                ;
ASSIGN: IDENTIFIER_TOK ASSIGN_TOK EXPRESSION    { if(!contains($1)){
                                                        char buff[40];
                                                        sprintf(buff,": Undefined identifier %s",$1);
                                                        yyerror(buff);
                                                    } else{
                                                        if(getDtype($1)!=$3.dtype){
                                                                char buff[50];
                                                                sprintf(buff,": Illegal assignment (Type Error) detected");
                                                                yyerror(buff);
                                                        } else{ // no issues; let us generate the intermediate code
                                                                char buff[40];
                                                                sprintf(buff,"%s = %s\n",$1,$3.place);
                                                                generate(interm_label,buff);
                                                                strcpy(expr_var,$1);
                                                                interm_label+=1;
                                                        }
                                                } }
        ;
EXPRESSION: LPAREN_TOK EXPRESSION RPAREN_TOK    { $$.dtype=$2.dtype;
                                                    $$.place=strdup($2.place);
                                                }
            |
            EXPRESSION PLUS_TOK EXPRESSION      { if($1.dtype!=$3.dtype){
                                                        char buff[40];
                                                        sprintf(buff,": Type error in expression");
                                                        yyerror(buff);
                                                    } else{
                                                        $$.dtype=$1.dtype;
                                                        char* temp=newTemp();
                                                        new_temp_index+=1;
                                                        $$.place=strdup(temp);

                                                        char buff[40];
                                                        sprintf(buff,"%s = %s + %s\n",$$.place,$1.place,$3.place);
                                                        generate(interm_label,buff);
                                                        strcpy(expr_var,$$.place);
                                                        interm_label+=1;
                                                    }
                                                }
            |
            EXPRESSION MINUS_TOK EXPRESSION     { $$.dtype=$1.dtype;
                                                    if($1.dtype!=$3.dtype){
                                                        char buff[40];
                                                        sprintf(buff,": Type error in expression");
                                                        yyerror(buff);
                                                    } else{
                                                        char* temp=newTemp();
                                                        new_temp_index+=1;
                                                        $$.place=strdup(temp);

                                                        char buff[40];
                                                        sprintf(buff,"%s = %s - %s\n",$$.place,$1.place,$3.place);
                                                        generate(interm_label,buff);
                                                        strcpy(expr_var,$$.place);
                                                        interm_label+=1;
                                                    }
                                                }
            |
            EXPRESSION ASTERISK_TOK EXPRESSION  { $$.dtype=$1.dtype;
                                                    if($1.dtype!=$3.dtype){
                                                        char buff[40];
                                                        sprintf(buff,": Type error in expression");
                                                        yyerror(buff);
                                                    } else{
                                                        char* temp=newTemp();
                                                        new_temp_index+=1;
                                                        $$.place=strdup(temp);

                                                        char buff[40];
                                                        sprintf(buff,"%s = %s * %s\n",$$.place,$1.place,$3.place);
                                                        generate(interm_label,buff);
                                                        strcpy(expr_var,$$.place);
                                                        interm_label+=1;
                                                    }
                                                }
            |
            EXPRESSION QUOTIENT_TOK EXPRESSION  { $$.dtype=$1.dtype;
                                                    if($1.dtype!=$3.dtype){
                                                        char buff[40];
                                                        sprintf(buff,": Type error in expression");
                                                        yyerror(buff);
                                                    } else{
                                                        char* temp=newTemp();
                                                        new_temp_index+=1;
                                                        $$.place=strdup(temp);

                                                        char buff[40];
                                                        sprintf(buff,"%s = %s / %s\n",$$.place,$1.place,$3.place);
                                                        generate(interm_label,buff);
                                                        strcpy(expr_var,$$.place);
                                                        interm_label+=1;
                                                    }
                                                }
            |
            EXPRESSION MODULUS_TOK EXPRESSION   { $$.dtype=$1.dtype;
                                                    if($1.dtype!=$3.dtype){
                                                        char buff[40];
                                                        sprintf(buff,": Type error in expression");
                                                        yyerror(buff);
                                                    } else{
                                                        char* temp=newTemp();
                                                        new_temp_index+=1;
                                                        $$.place=strdup(temp);

                                                        char buff[40];
                                                        sprintf(buff,"%s = %s %% %s\n",$$.place,$1.place,$3.place);
                                                        generate(interm_label,buff);
                                                        strcpy(expr_var,$$.place);
                                                        interm_label+=1;
                                                    }
                                                }
            |
            MINUS_TOK EXPRESSION        { $$.dtype=$2.dtype;
                                            char* temp=newTemp();
                                            new_temp_index+=1;
                                            $$.place=strdup(temp);

                                            char buff[40];
                                            sprintf(buff,"%s = - %s\n",$$.place,$2.place);
                                            generate(interm_label,buff);
                                            strcpy(expr_var,$$.place);
                                            interm_label+=1;
                                        }
            |
            INT_CONST_TOK       { $$.dtype=0;
                                    char temp_place[10];
                                    sprintf(temp_place,"%d",$1);
                                    $$.place=strdup(temp_place);
                                }
            |
            FLOAT_CONST_TOK     { $$.dtype=1;
                                    char temp_place[10];
                                    sprintf(temp_place,"%.2f",$1);
                                    $$.place=strdup(temp_place);
                                }
            |
            IDENTIFIER_TOK      { if(!contains($1)){
                                        char buff[40];
                                        sprintf(buff,": Undefined identifier %s",$1);
                                        yyerror(buff);
                                    } else{
                                        $$.dtype=getDtype($1);
                                        $$.place=strdup($1);
                                }}
            ;

COND:   IF_TOK {temp_label=interm_label;}
        LPAREN_TOK COND_PART RPAREN_TOK {
                                                char* temp=newTemp();
                                                new_temp_index+=1;

                                                char buff[40];
                                                sprintf(buff,"%s = not %s\n",temp,expr_var);
                                                generate(interm_label,buff);
                                                interm_label+=1;
                                                backpatch_label=interm_label;
                                                strcpy(temp_var,temp);
                                                interm_label+=1;
                                        }
        INNER_BODY ELSE_OPTN
        ;
ELSE_OPTN:      %prec LOWER_THAN_ELSE   {
                                                // backpatching
                                                char buff[40];
                                                sprintf(buff,"if %s goto %d\n",temp_var,interm_label);
                                                generate(backpatch_label,buff);
                                        }
                |
                ELSE_PART
                ;
ELSE_PART:  ELSE_TOK    {
                                // backpatching
                                char buff[40];
                                sprintf(buff,"if %s goto %d\n",temp_var,interm_label+1);
                                generate(backpatch_label,buff);
                                backpatch_label=interm_label;
                                interm_label+=1;
                        }
            INNER_BODY  {
                                // backpatching
                                char buff[40];
                                sprintf(buff,"goto %d\n",interm_label);
                                generate(backpatch_label,buff);
                        }
            ;

ITER:   WHILE_TOK {temp_label=interm_label;}
        LPAREN_TOK COND_PART RPAREN_TOK {
                                                char* temp=newTemp();
                                                new_temp_index+=1;

                                                char buff[40];
                                                sprintf(buff,"%s = not %s\n",temp,expr_var);
                                                generate(interm_label,buff);
                                                interm_label+=1;
                                                backpatch_label=interm_label;
                                                strcpy(temp_var,temp);
                                                interm_label+=1;
                                        }
        INNER_BODY {
                        char buff[40];
                        sprintf(buff,"goto %d\n",temp_label);
                        generate(interm_label,buff);
                        interm_label+=1;

                        // backpatching
                        sprintf(buff,"if %s goto %d\n",temp_var,interm_label);
                        generate(backpatch_label,buff);
                    }
        ;
INNER_BODY:     BODY_START STMT { deleteSymbolsOfScope(scope);
                                    scope-=1;}
                |
                BLK
                ;
BODY_START:             {scope+=1;}
                ;

COND_PART:  EXPRESSION
            |
            ASSIGN
            ;

FN_CALL:    IDENTIFIER_TOK ASSIGN_TOK FN_SIGN   { if(!contains($1)){
                                                        char buff[40];
                                                        sprintf(buff,": Undefined identifier %s",$1);
                                                        yyerror(buff);
                                                    } }
            |
            FN_SIGN
            ;
FN_SIGN:    IDENTIFIER_TOK LPAREN_TOK OPTIONS RPAREN_TOK
            ;
OPTIONS:    PARAMS
            |
            ;
PARAMS: PARAM
        |
        PARAM COMMA_TOK PARAMS
        ;
PARAM:  IDENTIFIER_TOK  { if(!contains($1)){
                                char buff[40];
                                sprintf(buff,": Undefined identifier %s",$1);
                                yyerror(buff);
                            } }
        |
        INT_CONST_TOK
        |
        FLOAT_CONST_TOK
        ;

US_DEF_FNS:     US_DEF_FN US_DEF_FNS
                |
                ;
US_DEF_FN:      DATATYPE FN_NAME LPAREN_TOK OPTIONS_FORMAL RPAREN_TOK BLK        {printf("\nSyntax of user defined function is correct");}
                ;
FN_NAME:        IDENTIFIER_TOK
                ;
OPTIONS_FORMAL: PARAMS_FORMAL
                |
                ;
PARAMS_FORMAL:  PARAM_FORMAL
                |
                PARAM_FORMAL COMMA_TOK PARAMS_FORMAL
                ;
PARAM_FORMAL:   DATATYPE IDENTIFIER_TOK { int type = existsInSameScope($2);
                                            if(type==1){
                                                char buff[50];
                                                sprintf(buff,": Multiple definitions of the identifier %s",$2);
                                                yyerror(buff);
                                            } else if(type==2){
                                                char buff[50];
                                                sprintf(buff,": Conflicting types for the identifier %s",$2);
                                                yyerror(buff);
                                            } else{
                                                add($2);
                                        } }
%%


int main(){
    yyin=fopen("sample.c","r");
    interm_file=fopen("intermediate_code.txt","w");
    init();
    if(yyparse()==0){
        writeIntermCode();
        printf("\nParsed successfully.\n");
    }
    fclose(yyin);
    fclose(interm_file);
    freeAll();
    return 0;
}

// Called to display error message along with the corresponding line number
int yyerror(char* msg){
    extern int yylineno;
    printf("\nParsing failed at line %d %s\n",yylineno,msg);
    success=0;
    return 0;
}
