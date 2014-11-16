%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>
	#include<ctype.h>
	#include"y.tab.h"
	void yyerror(char*);
	char* toLower( char *str);
	char* extractLabel(char *source);
	char* extractGoToLabel(char *source, char* label);
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
(if)						{return IF;}
(then)						{return THEN;}
(else)						{return ELSE;}
(and)						{return AND;}
(or)						{return OR;}
(not)						{return NOT;}
(for)						{return FOR;}
(next)						{return NEXT;}
(to)						{return TO;}


{letter}({letter}|{digit})*":" {char *lbl;lbl=extractLabel(yytext);strcpy(yylval.str,toLower(lbl));return LABEL;}
goto{whitespace}+{letter}({letter}|{digit})* {char *lbl;lbl=extractGoToLabel(yytext,lbl);strcpy(yylval.str,toLower(lbl));return GOTOLABEL;}
{letter}({letter}|{digit}|".")*[#&%]? {strcpy(yylval.str,toLower(yytext));return NUM_VAR;}
{letter}({letter}|{digit}|".")*"$"    {strcpy(yylval.str,toLower(yytext));return STR_VAR;}
.							;
%%	

char* toLower( char *str) {
/*Function to convert a string to lowercase*/
	int i;
	for(i=0;str[i]!='\0';i++) {
		str[i]=tolower(str[i]);
	}
	return str;
}

char* extractLabel(char *source) {
/*Function to remove : from the label pattern found*/
	int i=0;
	for(i=0;source[i]!=':';i++);
	source[i]='\0';
	return source;
}

char* extractGoToLabel(char *source, char* label) {
/*Function to extract label name from goto label*/
	int startIndex,endIndex;
	int i,length;
	/*ignore whitespaces and find the first character*/
	for(i=4;(source[i]==' ')||(source[i]=='\t');i++);
	startIndex=i;
	
	/*find the last character*/
	for(;(source[i]!=' ')&&(source[i]!='\t')&&(source[i]!='\0');i++);
	endIndex=i;
	
	length=endIndex-startIndex;
	label=(char *)malloc(sizeof(char)*(length+1));
	memcpy(label,source+startIndex,length);
	label[length]='\0';
	return label;
}
