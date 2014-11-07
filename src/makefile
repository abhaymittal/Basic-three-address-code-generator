all: lex yacc y.tab.h
	gcc y.tab.c lex.yy.c -o comp -lfl -lm

lex: basic_lex.lex
	lex -i basic_lex.lex

yacc: basic_yacc.y
	yacc -d basic_yacc.y

clean:
	rm comp lex.yy.c y.tab.c y.tab.h *~ *\#
