# Assignment 5

---

***Student Details:***

- Name : Anjishnu Mukherjee
- Registration Number : B05-511017020
- Class Roll Number : CS Gy-70
- Exam Roll Number : 510517086
- Email : 511017020.anjishnu@students.iiests.ac.in

---

Rules for a lexical analyser for C is written in ```lexrules.l``` and the
corresponding grammar for a syntax analyser is written in ```lexparser.y```,
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
- A "Symbol" is a structure which stores name, datatype, scope, function name
- Scope is zero initially (global). On entry in a block, it is made +1
  and -1 on exit
- A simple hash function takes var name as input
   and returns an index into the hashtable
- For the obtained index, that symbol is "chained" to the corresponding list

Following semantic actions have been considered:

- A variable must be declared before usage
- Multiple declarations within same scope not allowed

---

***Compile and run from scratch:***

  ```bash
  # compile
  lex lexrules.l
  yacc -dv lexparser.y
  gcc -Wall -o compiler y.tab.c lex.yy.c

  # run
  ./compiler <sample_program.c >output.txt

  # view output
  cat output.txt

  # remove binary
  rm compiler lex.yy.c y.tab.c y.tab.h y.output
  clear
  ```

***Compile and run using Makefile:***

  ```bash
  # compile
  make all

  # run
  make run

  # view output
  make view

  # remove binary
  make clean
  ```
