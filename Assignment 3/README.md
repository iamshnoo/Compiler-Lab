# Lexical Analyser

---

***Student Details:***

- Name : Anjishnu Mukherjee
- Registration Number : B05-511017020
- Class Roll Number : CS Gy-70
- Exam Roll Number : 510517086
- Email : 511017020.anjishnu@students.iiests.ac.in

---

```lexrules.l``` is the lex input file that contains all pattern definitions and
rules and actions, along with the user program to run the analyser. It should be
first compiled to produce the C file ```lexicalAnalyser.c``` which can then be
compiled into an executable for the analyser. Using ```sample_program.c``` as
input, we get ```analysis_output.txt``` as output. The format of each line of
output is ```(token_name <space> token_id <space> token_length)``` or (for some
tokens, it only contains some remarks regarding the token).

Token definitions are provided in ```tokens.h```.

```lexrules.l``` and ```tokens.h``` give us a lexical analyser file written in
C, when compiled using flex. So, those 2 source files are the only independent
and necessary components for the analyser.

The ```sample_program.c``` actually contains a naive implementation of some
random program which tries to test for all the different rule definitions and
actions possible from the lexical analyser produced.

- ***Compile and run from scratch:***

  ```bash
  # compile
  lex -o lexicalAnalyser.c lexrules.l
  gcc lexicalAnalyser.c -o lexicalAnalyser

  # run
  ./lexicalAnalyser sample_program.c > analysis_output.txt

  # view output
  cat analysis_output.txt

  # remove binary
  rm -f lexicalAnalyser
  clear
  ```

- ***Compile and run using Makefile:***

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
