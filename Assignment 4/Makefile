all:
	@yacc -v -d lexparser.y
	@lex -o lexical_analyser.c lexrules.l
	@gcc -o compiler y.tab.c lexical_analyser.c

run:
	@./compiler <sample_program.c >output.txt

view:
	@echo "--------------------------------"
	@echo "--------INPUT PROGRAM ----------"
	@echo "--------------------------------"
	@cat sample_program.c
	@echo "--------------------------------"
	@echo "--------- OUTPUT ---------------"
	@echo "--------------------------------"
	@cat output.txt
	@echo "--------------------------------"

clean:
	@rm lexical_analyser.c y.output y.tab.c y.tab.h compiler
	@clear
