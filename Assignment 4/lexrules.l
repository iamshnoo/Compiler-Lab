%{
#include "y.tab.h"
%}

identifier [a-zA-Z][a-zA-Z0-9_]*
integer [0-9]*
string  \"(\\.|[^"\\])*\"
character \'(\\.|.)\'
invalid ([0-9][0-9]*|[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)[a-dA-Df-zF-Z_][a-zA-Z0-9_]*
real [0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?
single_symbol [\.\,\!\#\$\%\^\&\*\(\)\-\_\+\=\{\}\[\]\\\|\~\:\;\"\'\/\?\>\<]
whitespace [ \t]*

%%

#.*                 {return HEADER_TOK;    }

{string}            {return STRCONST_TOK;  }
{character}         {return CHARCONST_TOK; }

auto                {return AUTO_TOK;      }
break               {return BREAK_TOK;     }
case                {return CASE_TOK;      }
char                {return CHAR_TOK;      }
const               {return CONST_TOK;     }
continue            {return CONTINUE_TOK;  }
default             {return DEFAULT_TOK;   }
do                  {return DO_TOK;        }
double              {return DOUBLE_TOK;    }
else                {return ELSE_TOK;      }
enum                {return ENUM_TOK;      }
extern              {return EXTERN_TOK;    }
float               {return FLOAT_TOK;     }
for                 {return FOR_TOK;       }
goto                {return GOTO_TOK;      }
if                  {return IF_TOK;        }
int                 {return INT_TOK;       }
long                {return LONG_TOK;      }
register            {return REGISTER_TOK;  }
return              {return RETURN_TOK;    }
short               {return SHORT_TOK;     }
signed              {return SIGNED_TOK;    }
sizeof              {return SIZEOF_TOK;    }
static              {return STATIC_TOK;    }
struct              {return STRUCT_TOK;    }
switch              {return SWITCH_TOK;    }
typedef             {return TYPEDEF_TOK;   }
union               {return UNION_TOK;     }
unsigned            {return UNSIGNED_TOK;  }
void                {return VOID_TOK;      }
volatile            {return VOLATILE_TOK;  }
while               {return WHILE_TOK;     }

main                {return MAIN_TOK;      }

{identifier}        {yylval.str = strdup(yytext); return ID_TOK;}

{invalid}           {printf("SYNTAX ERROR : Known invalid token '%s' on Line Number %d\n", yytext, yylineno);}
{integer}           {return INTCONST_TOK;  }
{real}              {return REALCONST_TOK; }

"+="                {return PLUSEQ_TOK;    }
"-="                {return MINUSEQ_TOK;   }
"*="                {return TIMESEQ_TOK;   }
"/="                {return QUOTIENTEQ_TOK;}
"&="                {return ANDEQ_TOK;     }
"|="                {return OREQ_TOK;      }
"^="                {return XOREQ_TOK;     }
"<<"                {return LSHIFT_TOK;    }
">>"                {return RSHIFT_TOK;    }
"<<="               {return LSHIFTEQ_TOK;  }
">>="               {return RSHIFTEQ_TOK;  }
"<="                {return LEQ_TOK;       }
">="                {return GEQ_TOK;       }
"=="                {return EQEQ_TOK;      }
"::"                {return SCOPERES_TOK;  }

{single_symbol}     {return (int)yytext[0];}

"\n"                {yylineno++;           }
{whitespace}        {}

.                   {printf("ERROR : Unknown invalid token '%s' in Line Number %d\n", yytext, yylineno);}

%%

int yywrap()
{
  return 1;
}
