%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>
	#include"y.tab.h"
	void yyerror(char*);
%}

digit [0-9]
letter [a-zA-Z]
whitespace [ \t]

%%
{whitespace}+ ;
{digit}+ 					{yylval.ival = atoi(yytext);return INTEGER;}
{digit}+"."{digit}+ 		{yylval.dval=atof(yytext);return DOUBLE;}
\"([^\n\"]|\"\")*\"			{strcpy(yylval.str,yytext);return STRING_LITERAL;}
(P|p)(R|r)(I|i)(N|n)(T|t) 	{return PRINT;}
[-+*^,()=/]					{return *yytext;}	
\n							;
(end) 						{return END;}
(let)						{return LET;}
(input)						{return INPUT;}
{letter}({letter}|{digit}|".")*[#&%]? {strcpy(yylval.str,yytext);return NUM_VAR;}
{letter}({letter}|{digit}|".")*"$"    {strcpy(yylval.str,yytext);return STR_VAR;}
.							;
%%	


