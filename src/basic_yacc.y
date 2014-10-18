%{
	#include<stdio.h>
	#include<math.h>
	int yylex(void);
%}

%start Program
%union{int ival; double dval;}

/*Keywords*/
%token PRINT END

/*Data type tokens*/
%token <ival> INTEGER
%token <dval> DOUBLE

/*Grammar's Variable(Non-terminal) types*/
%type <dval> ArithmExpr

/*Operator Associativity and Precedence*/
%left	'-' '+'
%left	'*' '/'
%left	NEGATION
%right	'^'

%%

Program 
	: Line Program
	| Line

Line	
	: PRINT ArithmExpr {int x=$2; if(x==$2) printf("%d\n",x); else printf("%f\n",$2);}
	| END
		
ArithmExpr
	: ArithmExpr '^' ArithmExpr	{$$=pow($1,$3);}
	| ArithmExpr '*' ArithmExpr	{$$=$1*$3;}
	| ArithmExpr '/' ArithmExpr	{$$=$1/$3;}
	| ArithmExpr '+' ArithmExpr	{$$=$1+$3;}
	| ArithmExpr '-' ArithmExpr	{$$=$1-$3;}
	| '-' ArithmExpr %prec NEGATION	{$$=-1 * $2;}
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
