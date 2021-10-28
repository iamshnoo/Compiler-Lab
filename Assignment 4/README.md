# Assignment 4

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

The parser works for a subset of the C language, specifically,
the following programming language constructs:

- a) Main function
- b) Statements
  - i) Statements like local/global declarations.
  - ii) Assignment Statements.
  - iii) Conditional Statements.
  - iv) Iterative Statements
  - v) Function Call
- c) User defined functions
- d) A variable must be declared before it is used.

***Compile and run from scratch:***

  ```bash
  # compile
  yacc -v -d lexparser.y
  lex -o lexical_analyser.c lexrules.l
  gcc -o compiler y.tab.c lexical_analyser.c

  # run
  ./compiler <sample_program.c >output.txt

  # view output
  cat output.txt

  # remove binary
  rm output.txt lexical_analyser.c y.output y.tab.c y.tab.h compiler
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
