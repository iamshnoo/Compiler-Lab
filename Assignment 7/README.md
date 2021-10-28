# Assignment 7

---

***Student Details:***

- Name : Anjishnu Mukherjee
- Registration Number : B05-511017020
- Class Roll Number : CS Gy-70
- Exam Roll Number : 510517086
- Email : 511017020.anjishnu@students.iiests.ac.in

---

Rules for a lexical analyser for C is written in ```lex.l``` and the
corresponding grammar for a syntax analyser is written in ```lex.y```,
and they can be compiled using lex and yacc respectively to produce C files for
a lexical analyser and a parser. Compiling those 2 files together using gcc, we
get a binary for a compiler, that can be used to check both syntax and semantics
of a C program.

The parser works for a subset of the C language.

***Notes:***

- %token does not set the precedence / priority of a token
it declares the token to exist with NO precedence.
To declare a precedence for the token,
we use %left, %right or %nonassoc
all of which both declare the token AND set its precedence.

- A symbol table is maintained using hashing (with chaining)
  to keep track of identifiers and their scopes.
- Each entry of this table is a pointer to a list of "Symbols"
- A "Symbol" is a structure which stores name, datatype, scope.
- Scope is zero initially (global). On entry in a block, it is made +1
  and -1 on exit
- When coming out of a block, all symbols declared in that scope are deleted
  from the symbol table
- A simple hash function takes var name as input
   and returns an index into the hashtable
- For the obtained index, that symbol is "chained" to the corresponding list

Following semantic actions have been considered:

- A variable must be declared before usage
- Multiple declarations within same scope not allowed
- All sub-expressions must be of the same data type
- Type mismatch in assignment and conditional statements not allowed
- Incorrect array declarations (non-integer size) detected

Some assumptions made about the structure of source code:

- User defined functions come only 'after' main function
- Declaration of variables is done before assignment

Illustrations for assignment expressions, while, if and if-else:

Assignment expressions

-> S->id=E => generate quad.
-> E->-E => get new temp var for E.place and generate quad.
-> E->E1 op E2 => get new temp var for E.place and generate quad.
-> E->(E1) => assign E1.place to E.place
-> E->id => assign id.name to E.place

while(c=a*b)
    c=x*y+z;

L1: t0=a*b
c=t0
t1=not c
if t1 goto END // Backpatching
t2=x*y
t3=t2+z
c=t3
goto L1
END:


if(c=a*b)
    c=x*y+z

L1: t0=a*b
c=t0
t1=not c
if t1 goto END // Backpatching
t2=x*y
t3=t2+z
c=t3
END:


if(c=a*b)
    c=x*y+z
else
    c=a

L1: t0=a*b
c=t0
t1=not c
if t1 goto ELSE // Backpatching
t2=x*y
t3=t2+z
c=t3
goto END
ELSE: c=a
END:

---

***Compile and run from scratch:***

  ```bash
  lex lex.l
  yacc -dv lex.y
  gcc -Wall -o lex y.tab.c lex.yy.c
  ./lex
  ```
