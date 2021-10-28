/**
 * @file code_generator.c
 * @author Anjishnu Mukherjee (511017020.anjishnu@students.iiests.ac.in)
 * @brief This file generates assembly language target code
 * from the intermediate code produced by a C compiler's(gcc) front-end.
 * It currently takes in an input a file "intermediate_code.txt" which contains
 * the intermediate code for "example.c".
 * As output, it will produce "assembly_code_8085.txt", because that is the only
 * assembly level language I am familiar with from a previous course in
 * microprocessors.
 *
 * --------------------------------------------------------
 * Instructions to execute :
 * --------------------------------------------------------
 * gcc code_generator.c -o codegen
 * ./codegen intermediate_code.txt assembly_code_8085.txt
 * --------------------------------------------------------
 *
 * @version 0.1
 * @date 2020-11-25
 *
 * @copyright Copyright (c) 2020
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

// Registor descriptor
typedef struct RegInfo
{
    // whether or not that register is occupied
    int isOccupied;

    // list of identifiers whose value is in that register
    char name[5][5];
} RegInfo;

// Registor Descriptor table (considering 4 registers: B, C, D, E)
RegInfo regDesc[4];

// A counter keeping track of count of labels for the utility function below
int labelNum = 0;

// Utility to return a new label name for assembly language code
char* getNewLabel ( )
{
    static char label[5];
    sprintf(label, "L%d", labelNum);
    labelNum += 1;
    return label;
}

/**
 * @brief Check if a variable is in register descriptor table
 *        Returns -1 if not present
 *        otherwise returns the register number.
 *
 */
int inRegDesc ( char* var )
{
    // boolean flag
    int found = 0;

    int regNum = -1;
    for (int i = 0; i < 4; i++)
    {
        if (found)
            break;

        if (regDesc[i].isOccupied)
        {
            for (int j = 0; j < 5; j++)
            {
                if (strlen(regDesc[i].name[j]) == 0)
                    break;

                if (strcmp(regDesc[i].name[j], var) == 0)
                {
                    found = 1;
                    regNum = i;
                    break;
                }
            }
        }
    }
    return regNum;
}

/**
 * @brief Produce output of lexical analysis on program passed as
 *        command line arg.
 *
 * @param argc : Number of command line arguments.
 * @param argv : Command line arguments. (executable, input, output)
 * @return : None
 */
int main ( int argc, char **argv )
{
    // intermediate_code.txt
    FILE *intermediateFile = fopen(argv[1],"r");

    // assembly_code_8085.txt
    FILE *assemblyFile = fopen(argv[2],"w");

    const int BUFFER_SIZE = 50;
    char lineInFile[BUFFER_SIZE];
    size_t len = 0;
    srand(time(0));

    // Error in reading the file
    if (intermediateFile == NULL)
        exit(1);


    // Initialize register descriptor table
    for (int i = 0; i < 4; i++)
    {
        regDesc[i].isOccupied = 0;
        for (int j = 0; j < 5; j++)
            memset(regDesc[i].name[j], 0, 5);
    }

    // To store tokens of a line
    char *tokens[6];
    for (int i = 0; i < 6; i++)
        tokens[i] = NULL;


    while ( fgets(lineInFile, BUFFER_SIZE, intermediateFile) )
    {
        // Remove '\n' from "lineInFile"
        lineInFile[strlen(lineInFile)-1] = '\0';

        // Split the line into tokens
        char *token = strtok(lineInFile," ");
        int i = 0;
        while (token != NULL)
        {
            tokens[i] = (char*) malloc( 5 * sizeof(char));
            strcpy(tokens[i], token);
            token = strtok(NULL," ");
            i += 1;
        }

        // If it is an assignment expression
        if (strcmp(tokens[2], "=")==0)
        {
            // logical "not"
            if (strcmp(tokens[3], "not")==0)
            {
                char *l1 = getNewLabel();
                char *l2 = getNewLabel();
                fprintf(assemblyFile, "LHLD %s\n", tokens[4]);
                fprintf(assemblyFile, "MOV A,M\n");
                fprintf(assemblyFile, "ADI 0\n");
                fprintf(assemblyFile, "JZ %s\n", l1);
                fprintf(assemblyFile, "MVI A,0\n");
                fprintf(assemblyFile, "JMP %s\n", l2);
                fprintf(assemblyFile, "%s: MVI A,1\n", l1);
                fprintf(assemblyFile, "%s: NOP\n", l2);

                int done = 0;
                int regNum = 0;
                for (int i = 0; i < 4; i++)
                {
                    if (!regDesc[i].isOccupied)
                    {
                        regNum = i;
                        done = 1;
                        break;
                    }
                }
                if (!done)
                    regNum = rand() % 4;

                regDesc[regNum].isOccupied = 1;
                strcpy(regDesc[regNum].name[0], tokens[1]);

                fprintf(assemblyFile, "MOV R%d,A\n", regNum);
            }

            // negation
            else if (strcmp(tokens[3], "-")==0)
            {
                fprintf(assemblyFile, "LHLD %s\n", tokens[4]);
                fprintf(assemblyFile, "MOV A,0\n");
                fprintf(assemblyFile, "SUB M\n");

                int done = 0;
                int regNum = 0;
                for (int i = 0; i < 4; i++)
                {
                    if (!regDesc[i].isOccupied)
                    {
                        regNum = i;
                        done = 1;
                        break;
                    }
                }
                if (!done)
                    regNum = rand() % 4;

                regDesc[regNum].isOccupied = 1;
                strcpy(regDesc[regNum].name[0], tokens[1]);

                fprintf(assemblyFile, "MOV R%d,A\n", regNum);
            }

            // simple assignment
            else if (tokens[4]==NULL)
            {
                fprintf (assemblyFile, "LHLD %s\n", tokens[3]);

                int regNum = inRegDesc(tokens[3]);
                if (regNum != -1)
                {
                    for(int j = 0; j < 5; j++)
                        if (strlen(regDesc[regNum].name[j]) == 0)
                            strcpy(regDesc[regNum].name[j], tokens[1]);
                }

                else
                {
                    int done = 0;
                    int reg_num1 = 0;
                    for (int i = 0; i < 4; i++)
                    {
                        if (!regDesc[i].isOccupied)
                        {
                            reg_num1 = i;
                            done = 1;
                            break;
                        }
                    }
                    if (!done)
                        reg_num1 = rand() % 4;

                    regDesc[reg_num1].isOccupied = 1;
                    strcpy(regDesc[reg_num1].name[0], tokens[1]);

                    fprintf(assemblyFile, "MOV R%d,M\n", reg_num1);
                }
            }

            // type (number+something) or (number-something)
            else if (tokens[3][0]>='0' && tokens[3][0]<='9')
            {
                // type (number+number) or (number-number)
                if (tokens[5][0]>='0' && tokens[5][0]<='9')
                {
                    fprintf(assemblyFile, "MVI A,%s\n", tokens[3]);
                    if (strcmp(tokens[4], "+") == 0)
                        fprintf(assemblyFile, "ADI %s\n", tokens[5]);
                    else
                        fprintf(assemblyFile, "SUI %s\n", tokens[5]);

                    int done = 0;
                    int regNum = 0;
                    for (int i = 0; i < 4; i++)
                    {
                        if (!regDesc[i].isOccupied)
                        {
                            regNum = i;
                            done = 1;
                            break;
                        }
                    }
                    if (!done)
                        regNum = rand() % 4;

                    regDesc[regNum].isOccupied = 1;
                    strcpy(regDesc[regNum].name[0], tokens[1]);

                    fprintf(assemblyFile, "MOV R%d,A\n", regNum);
                }

                // type (number+id) or (number-id)
                else
                {
                    int regNum = inRegDesc(tokens[5]);
                    if (regNum == -1)
                    {
                        fprintf(assemblyFile, "LHLD %s\n", tokens[5]);
                        fprintf(assemblyFile, "MOV A,M\n");
                    }
                    else
                        fprintf(assemblyFile, "MOV A,R%d\n", regNum);

                    if (strcmp(tokens[4], "+") == 0)
                        fprintf(assemblyFile, "ADI %s\n", tokens[3]);
                    else
                        fprintf(assemblyFile, "SUI %s\n", tokens[3]);

                    int done = 0;
                    regNum = 0;
                    for (int i = 0; i < 4; i++)
                    {
                        if (!regDesc[i].isOccupied)
                        {
                            regNum = i;
                            done = 1;
                            break;
                        }
                    }
                    if (!done)
                        regNum = rand() % 4;

                    regDesc[regNum].isOccupied = 1;
                    strcpy(regDesc[regNum].name[0], tokens[1]);

                    fprintf(assemblyFile, "MOV R%d,A\n", regNum);
                }
            }

            // type (id+number) or (id-number)
            else if (tokens[5][0]>='0' && tokens[5][0]<='9')
            {
                int regNum = inRegDesc(tokens[3]);
                if (regNum == -1)
                {
                    fprintf(assemblyFile, "LHLD %s\n", tokens[3]);
                    fprintf(assemblyFile, "MOV A,M\n");
                }
                else
                    fprintf(assemblyFile, "MOV A,R%d\n", regNum);

                if (strcmp(tokens[4], "+")==0)
                    fprintf(assemblyFile, "ADI %s\n", tokens[5]);
                else
                    fprintf(assemblyFile, "SUI %s\n", tokens[5]);


                int done = 0;
                regNum = 0;
                for (int i = 0; i < 4; i++)
                {
                    if (!regDesc[i].isOccupied)
                    {
                        regNum = i;
                        done = 1;
                        break;
                    }
                }
                if (!done)
                    regNum = rand() % 4;

                regDesc[regNum].isOccupied = 1;
                strcpy(regDesc[regNum].name[0], tokens[1]);

                fprintf(assemblyFile, "MOV R%d,A\n", regNum);
            }

            // type (id+id) or (id-id)
            else
            {
                int regNum = inRegDesc(tokens[3]);
                if (regNum == -1)
                {
                    fprintf(assemblyFile, "LHLD %s\n", tokens[3]);
                    fprintf(assemblyFile, "MOV A,M\n");
                }
                else
                    fprintf(assemblyFile, "MOV A,R%d\n", regNum);

                regNum = inRegDesc(tokens[5]);
                if (regNum == -1)
                {
                    fprintf(assemblyFile, "LHLD %s\n", tokens[5]);
                    if (strcmp(tokens[4], "+") == 0)
                        fprintf(assemblyFile,"ADD M\n");
                    else
                        fprintf(assemblyFile,"SUB M\n");
                }
                else
                {
                    if (strcmp(tokens[4], "+") == 0)
                        fprintf(assemblyFile, "ADD R%d\n", regNum);
                    else
                        fprintf(assemblyFile, "SUB R%d\n", regNum);

                }

                int done = 0;
                regNum = 0;
                for (int i = 0; i < 4; i++)
                {
                    if (!regDesc[i].isOccupied)
                    {
                        regNum = i;
                        done = 1;
                        break;
                    }
                }
                if (!done)
                    regNum = rand() % 4;

                regDesc[regNum].isOccupied = 1;
                strcpy(regDesc[regNum].name[0], tokens[1]);

                fprintf(assemblyFile,"MOV R%d,A\n",regNum);
            }
        }

        // For Jump statements
        else
        {
            // Unconditional jump
            if (strcmp(tokens[1], "goto") == 0)
                fprintf(assemblyFile, "JMP %s\n", tokens[2]);

            // conditional jump
            else
            {
                fprintf(assemblyFile, "LHLD %s\n", tokens[2]);
                fprintf(assemblyFile, "MOV A,M\n");
                fprintf(assemblyFile, "ADI 0\n");
                fprintf(assemblyFile, "JNZ %s\n", tokens[4]);
            }
        }

        // Free allocated space
        for (int i = 0; i < 6; i++)
        {
            free(tokens[i]);
            tokens[i] = NULL;
        }
    }

    fclose(intermediateFile);
    fclose(assemblyFile);
}
