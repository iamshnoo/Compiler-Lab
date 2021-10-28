LEX = lex
LEXRULES = lexrules.l
CC = gcc
CFLAGS = -ll
SOURCE = lexicalAnalyser.c
TARGET = lexicalAnalyser
EXAMPLE = sample_program.c
OUTPUT = analysis_output.txt

all: $(TARGET)

$(TARGET): $(OBJFILES)
	$(LEX) -o $(SOURCE) $(LEXRULES)
	$(CC) $(CFLAGS) $(SOURCE) -o $(TARGET)

run:
	./$(TARGET) $(EXAMPLE) > $(OUTPUT)

view:
	cat $(OUTPUT)

clean:
	rm -f $(TARGET) *~
	clear
