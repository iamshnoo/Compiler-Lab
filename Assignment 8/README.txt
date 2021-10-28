# Assignment 8

---

***Student Details:***

- Name : Anjishnu Mukherjee
- Registration Number : B05-511017020
- Class Roll Number : CS Gy-70
- Exam Roll Number : 510517086
- Email : 511017020.anjishnu@students.iiests.ac.in

---

The intermediate code for a demo program in "example.c" is present in
"intermediate_code.txt" and is provided as input to the "code_generator.c" file.
The code_generator also takes in the filename for the output file as a command
line argument. Here, it outputs to "assembly_code_8085.txt". The code generator
itself is written using C in the file "code_generator.c".

***Compile and run from scratch:***

  ```bash
  gcc code_generator.c -o codegen
  ./codegen intermediate_code.txt assembly_code_8085.txt
  ```

***Notes:***

- The variable names mentioned in the assembly code denote
  the memory address where that variable is located.

- Intel-8085's "Processor Programming Model" and "Instruction Set"
  have been considered.

- All variables are assumed to be present in the memory, i.e. the values
  of any identifier present in a register can be modified whenever required.

- For arithmetic expressions, only '+' and '-' are considered.

- For lines where assignment is done,
   a. the lhs variable's info needs to be put in the register descriptor table properly
   b. the register (R(x)) for storing this is chosen randomly (if all are filled),
      otherwise a free one is chosen

- Following are the different possible cases for assignment and also GOTO statements:

---------------------------------------------
Case - 0: t1 = 4 + 3

MVI A,4
ADI 3
MOV R(x),A

---------------------------------------------
Case - 1: t1 = b + 3

if b not in a register,
    LHLD b
    MOV A,M
else (b in R(x)),
    MOV A,R(x)
ADI 3
MOV R(x),A

---------------------------------------------
Case - 2: t5 = 3 + a

if a not in a register,
    LHLD a
    MOV A,M
else (a in R(x)),
    MOV A,R(x)
ADI 3
MOV R(x),A

---------------------------------------------
Case - 3: t4 = t1 + t3

if t1 not in a register,
    LHLD t1
    MOV A,M
else (t1 in R(x)),
    MOV A,R(x)
if t3 not in a register,
    LHLD t3
    ADD M
else (t3 in R(x)),
    ADD R(x)
MOV R(x),A

---------------------------------------------
Case - 4: a = t4

LHLD t4
if t4 is in a reg_desc, insert 'a' there as well
else,
    MOV R(x),M

---------------------------------------------
Case - 5: t2 = - s

LHLD s
MOV A,0
SUB M
MOV R(x),A

---------------------------------------------
Case - 6: t10 = not s

LHLD s
MOV A,M
ADI 0
JZ L1
MVI A,0
JMP L2
L1: MVI A,1
L2: NOP
MOV R(x),A

---------------------------------------------
Case - 7: if t10 goto 34

LHLD t10
MOV A,M
ADI 0
JNZ 34

---------------------------------------------
Case - 8: goto 33

JMP 33

---------------------------------------------
