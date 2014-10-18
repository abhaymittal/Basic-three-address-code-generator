%{
	#include<stdio.h>
	int yylex(void);
%}

%start Program
%union{int ival; double dval;}

%token PRINT END

%token <ival> INTEGER
%token <dval> DOUBLE
%type <ival> ArithmExpr

%left	'-' '+'
%left	'*' '/'
%right	'^'

%%

Program 
	: Line Program
	| Line

Line	
	: PRINT ArithmExpr {printf("%d\n",$2);}
	| END
		
ArithmExpr
	: ArithmExpr '^' ArithmExpr	
	| ArithmExpr '*' ArithmExpr	{$$=$1*$3;}
	| ArithmExpr '/' ArithmExpr	{$$=$1/$3;}
	| ArithmExpr '+' ArithmExpr	{$$=$1+$3;}
	| ArithmExpr '-' ArithmExpr	{$$=$1-$3;}
	| INTEGER					{$$=$1;}
	| DOUBLE					{$$=$1;}
	

%%

void yyerror (char const *s) {
	fprintf (stderr, "%s\n", s);
}

int main() {
	yyparse();
	return 0;
}
