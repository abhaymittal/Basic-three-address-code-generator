%{
	#include<stdio.h>
	#include<math.h>
	int yylex(void);
%}

%start Program
%union{int ival; double dval; char str[120];}

/*Keywords*/
%token PRINT END

/*Data type tokens*/
%token <ival> INTEGER
%token <dval> DOUBLE
%token <str> STRING_LITERAL

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
	: PRINT Output				{printf("\n");}
	| END


/*PRINTING SECTION BEGIN*/
Output
	: Output2 ArithmExpr		{int x=$2; if(x==$2) printf("%d",x); else printf("%f",$2);}
	| Output2 STRING_LITERAL	{printf("%s",$2);}
	
Output2
	: Output ','
	| Empty	
/*PRINTING SECTION END*/


/*ARITHMETIC SECTION BEGIN*/
ArithmExpr
	: ArithmExpr '^' ArithmExpr	{$$=pow($1,$3);}
	| ArithmExpr '*' ArithmExpr	{$$=$1*$3;}
	| ArithmExpr '/' ArithmExpr	{$$=$1/$3;}
	| ArithmExpr '+' ArithmExpr	{$$=$1+$3;}
	| ArithmExpr '-' ArithmExpr	{$$=$1-$3;}
	| '-' ArithmExpr %prec NEGATION	{$$=-1 * $2;}
	| INTEGER					{$$=$1;}
	| DOUBLE					{$$=$1;}
/*ARITHMETIC SECTION END*/


Empty:	; /*EPSILON*/

%%


void yyerror (char const *s) {
	fprintf (stderr, "%s\n", s);
}

int main() {
	yyparse();
	return 0;
}
