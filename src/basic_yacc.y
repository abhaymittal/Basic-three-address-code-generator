%{
	#include<stdio.h>
	#include<string.h>
	#include<stdlib.h>
	int yylex(void);
	FILE *fPtr;
	int tempCounter=0;
	int labelCounter=0;
	char tVar[12];
	int labelIndex;
	int genTempIndex();
	int genLabelIndex();
	struct intStruct {
		int val;
		struct intStruct* next;
	};
	
	struct intStruct *labelIndexStack;
	
	void pushLabelIndex(int label);
	int popLabelIndex();
%}

%start Program
%union{int ival; double dval; char str[120]; struct {int trueIndex; int falseIndex;} bool; }

/*Keywords*/
%token PRINT END LET INPUT
%token DO LOOP WHILE
%token <str> LT LTE GT GTE EQ NEQ
%token IF THEN ELSE
%token AND OR NOT

/*Data type tokens*/
%token <ival> INTEGER
%token <dval> DOUBLE
%token <str> STRING_LITERAL
%token <str> VARIABLE
%token <str> NUM_VAR STR_VAR


/*Grammar's Variable(Non-terminal) types*/
%type <str> ArithmExpr
%type <str> RelOp
%type <bool> RelExpr
%type <bool> BoolEmpty
%type <bool> LogicExpr

/*Operator Associativity and Precedence*/
%left	'-' '+'
%left	'*' '/'
%left	NEGATION
%right	'^'
%left	NOT
%left	AND
%left	OR

%%

Program
	: Statements End {fprintf(fPtr,"exit\n");}
	
End
	: END
	| Empty

Statements
	: Statement Statements
	| Statement

Statement	
	: PRINT Output				{fprintf(fPtr,"PRINT \"\\n\"\n");}
	| LET Assignment
	| Assignment
	| INPUT NUM_VAR				{fprintf(fPtr,"SCAN %s\n",$2);}
	| INPUT STR_VAR				{fprintf(fPtr,"SCAN %s\n",$2);}
	| Loop
	| Decision
	



/*PRINTING SECTION BEGIN*/
Output
	: Output2 ArithmExpr		{fprintf(fPtr,"PRINT %s\n",$2);}
	| Output2 STRING_LITERAL	{fprintf(fPtr,"PRINT %s\n",$2);}
	| Output2 STR_VAR			{fprintf(fPtr,"PRINT %s\n",$2);}
	
Output2
	: Output ','				
	| Empty	
/*PRINTING SECTION END*/
	
/*VARIABLE SECTION BEGIN*/
Assignment
	: NUM_VAR EQ ArithmExpr		{fprintf(fPtr,"%s = %s\n",$1,$3);}
	| STR_VAR EQ STRING_LITERAL	{fprintf(fPtr,"%s = %s\n",$1,$3);}
/*VARIABLE SECTION BEGIN*/


/*ARITHMETIC SECTION BEGIN*/
ArithmExpr
	: ArithmExpr '^' ArithmExpr	{sprintf(tVar,"t%d",genTempIndex());strcpy($$,tVar);fprintf(fPtr,"%s=getNewTemp()\n",$$);fprintf(fPtr,"%s=%s^%s\n",$$,$1,$3);}
	| ArithmExpr '*' ArithmExpr	{sprintf(tVar,"t%d",genTempIndex());strcpy($$,tVar);fprintf(fPtr,"%s=getNewTemp()\n",$$);fprintf(fPtr,"%s=%s*%s\n",$$,$1,$3);}
	| ArithmExpr '/' ArithmExpr	{sprintf(tVar,"t%d",genTempIndex());strcpy($$,tVar);fprintf(fPtr,"%s=getNewTemp()\n",$$);fprintf(fPtr,"%s=%s/%s\n",$$,$1,$3);}
	| ArithmExpr '+' ArithmExpr	{sprintf(tVar,"t%d",genTempIndex());strcpy($$,tVar);fprintf(fPtr,"%s=getNewTemp()\n",$$);fprintf(fPtr,"%s=%s+%s\n",$$,$1,$3);}
	| ArithmExpr '-' ArithmExpr	{sprintf(tVar,"t%d",genTempIndex());strcpy($$,tVar);fprintf(fPtr,"%s=getNewTemp()\n",$$);fprintf(fPtr,"%s=%s-%s\n",$$,$1,$3);}
	| '-' ArithmExpr %prec NEGATION {sprintf(tVar,"t%d",genTempIndex());strcpy($$,tVar);fprintf(fPtr,"%s=getNewTemp()\n",$$);fprintf(fPtr,"%s=-1*%s\n",$$,$2);}
	| INTEGER					{sprintf($$,"%d",$1);}
	| NUM_VAR 				    {strcpy($$,$1);}
	| '(' ArithmExpr ')'		{strcpy($$,$2);}
/*ARITHMETIC SECTION END*/

/*RELATIONAL SECTION BEGIN*/
RelExpr
	: NUM_VAR RelOp ArithmExpr	{fprintf(fPtr, "If %s %s %s goto l%d\n",$1,$2,$3); fprintf(fPtr,"goto l%d\n");}
	
RelOp
 	: LT						{strcpy($$,$1);}
 	| LTE						{strcpy($$,$1);}
 	| GT						{strcpy($$,$1);}
 	| GTE						{strcpy($$,$1);}
 	| EQ						{strcpy($$,$1);}
 	| NEQ						{strcpy($$,$1);}
/*RELATIONAL SECTION END*/


/*LOGICAL SECTION BEGIN*/
LogicExpr
	: RelExpr
	/*| BoolEmpty{$1.trueIndex=genLabelIndex();$1.falseIndex=$$.falseIndex;} LogicExpr AND {fprintf(fPtr,"l%d: ",$1.trueIndex);} BoolEmpty{$4.trueIndex=$$.trueIndex;$4.falseIndex=$$.falseIndex;} LogicExpr
	| BoolEmpty{$1.trueIndex=$0.trueIndex;$1.falseIndex=$0.trueIndex;} LogicExpr OR LogicExpr
	| NOT BoolEmpty{$1.trueIndex=$0.trueIndex;$1.falseIndex=$0.trueIndex;} LogicExpr*/
	
/*LOGICAL SECTION END*/


/*LOOP CONSTRUCTS BEGIN */
Loop
	: DO{labelIndex=genLabelIndex();pushLabelIndex(labelIndex);fprintf(fPtr,"l%d: ",labelIndex);}Statements LOOP	{labelIndex=popLabelIndex();fprintf(fPtr,"goto l%d\n",labelIndex);}
	/*| DO{labelIndex=genLabelIndex();pushLabelIndex(labelIndex);fprintf(fPtr,"l%d: ",labelIndex);} WHILE{fprintf(fPtr,"ifFalse ");} RelExpr {labelIndex=genLabelIndex();pushLabelIndex(labelIndex);fprintf(fPtr,"goto l%d\n",labelIndex);}Statements LOOP {int lblIndexF=popLabelIndex();fprintf(fPtr,"goto l%d\n",popLabelIndex());fprintf(fPtr,"l%d: ",lblIndexF);}*/
/*LOOP CONSTRUCTS END*/

/*IF ELSE SECTION BEGIN*/
Decision
	: IF LogicExpr THEN Statements Else END IF 
	
Else
	: {labelIndex=genLabelIndex();fprintf(fPtr,"goto l%d\n",labelIndex);pushLabelIndex(labelIndex);}ELSE {fprintf(fPtr,"l%d: ",$<bool>-1.falseIndex);} Statements 
	| Empty {pushLabelIndex($<bool>-1.falseIndex);}
/*IF ELSE SECTION END*/

Empty:	{}/*EPSILON*/
BoolEmpty:	{}	
%%
int genTempIndex() {
	tempCounter++;
	return tempCounter;
}

int genLabelIndex() {
	labelCounter++;
	return labelCounter;
}

void pushLabelIndex(int label) {
	struct intStruct* temp;
	temp=(struct intStruct*)malloc(sizeof(struct intStruct));
	temp->val=label;
	temp->next=labelIndexStack;
	labelIndexStack=temp;
}

int popLabelIndex() {
	struct intStruct* temp;
	int label;
	temp=labelIndexStack;
	labelIndexStack=labelIndexStack->next;
	label=temp->val;
	free(temp);
	return label;
}
void yyerror (char const *s) {
	fprintf (stderr, "%s\n", s);
}

int main() {
	fPtr=stdout;
	yyparse();
	return 0;
}
