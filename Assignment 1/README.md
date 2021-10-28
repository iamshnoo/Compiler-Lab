# Lexical Analyser

---

***Student Details:***

- Name : Anjishnu Mukherjee
- Registration Number : B05-511017020
- Class Roll Number : CS Gy-70
- Exam Roll Number : 510517086
- Email : 511017020.anjishnu@students.iiests.ac.in

---

```lexicalAnalyserTest.cpp``` is the main program that demonstrates the
working of the lexical analyser using ```sample_program.c``` as input and
```analysis_output.txt``` as output. The format of each line of output is
```(token_name <space> token_id <space> token_length)```.

The lexical analyser itself is provided via a header-only implementation in the
files ```analyser.hpp``` and ```analyser_impl.hpp```.

The implementations use some helpful C++11 features like in-class initialization
of non-static data members and range-based for loops amongst other things which
have greatly helped in simplifying working with strings and so
compiling with at least that version of c++ is a necessity.

- ***Compile and run from scratch:***

  ```bash
  # compile
  g++ lexicalAnalyserTest.cpp -o analyser -std=c++11

  # run
  ./analyser sample_program.c > analysis_output.txt

  # view output
  cat analysis_output.txt

  # remove binary
  rm -f analyser
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
