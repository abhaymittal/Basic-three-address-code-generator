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
[-+*^,()/]					{return *yytext;}	
\n							;


(<)							{strcpy(yylval.str,yytext);return LT;}
(<=)						{strcpy(yylval.str,yytext);return LTE;}
(>)							{strcpy(yylval.str,yytext);return GT;}
(>=)						{strcpy(yylval.str,yytext);return GTE;}
(=)							{strcpy(yylval.str,yytext);return EQ;}
(<>)						{strcpy(yylval.str,yytext);return NEQ;}


(print)					 	{return PRINT;}
(end) 						{return END;}
(let)						{return LET;}
(input)						{return INPUT;}
(do)						{return DO;}
(loop)						{return LOOP;}
(while)						{return WHILE;}


{letter}({letter}|{digit}|".")*[#&%]? {strcpy(yylval.str,yytext);return NUM_VAR;}
{letter}({letter}|{digit}|".")*"$"    {strcpy(yylval.str,yytext);return STR_VAR;}
.							;
%%	


