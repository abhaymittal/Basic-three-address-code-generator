%{
	#include<stdio.h>
	#include"y.tab.h"
%}
digit [0-9]
letter [a-zA-Z]
whitespace [ \t]
%%
{whitespace}+ ;
{digit}+ printf("INTEGER FOUND");
{digit}+.{digit}+ printf("FLOATING POINT NUMBER FOUND");
(P|p)(R|r)(I|i)(N|n)(T|t) printf("print found");
(end) printf("End found");
. ;
%%	


