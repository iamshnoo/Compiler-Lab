all:
	@lex lexrules.l
	@yacc -dv lexparser.y
	@gcc -Wall -o compiler y.tab.c lex.yy.c

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
	@rm compiler lex.yy.c y.tab.c y.tab.h y.output
	@clear
