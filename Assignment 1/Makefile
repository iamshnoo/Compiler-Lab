CC = g++
CFLAGS = -std=c++11
BINARY = analyser
SOURCE = lexicalAnalyserTest.cpp
INPUT = sample_program.c
OUTPUT = analysis_output.txt

all:
	$(CC) $(SOURCE) -o $(BINARY) $(CFLAGS)

run:
	./$(BINARY) $(INPUT) > $(OUTPUT)

view:
	cat $(OUTPUT)

clean:
	rm -f $(BINARY) *~
	clear
