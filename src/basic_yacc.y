%{
	#include<stdio.h>
	#include<string.h>
	#include<stdlib.h>
	void yyerror (char const *s);
	FILE *fPtr;
	int tempCounter=0;
	int labelCounter=0;
	char tVar[12];
	
	int labelIndex;
	int genTempIndex();
	int genLabelIndex();
	
	/*Structure to create stack of temporary labels*/
	struct intStruct {
		int val;
		struct intStruct* next;
	};
	
	struct intStruct *labelIndexStack;		
	void pushLabelIndex(int label);
	int popLabelIndex();
		
	/*Structure to create list of all labels and goto to check goto maps to labels*/
	struct stringStruct {
		char label[12];
		struct stringStruct *next;
	};

	struct stringStruct *labelList=NULL;
	struct stringStruct *gotoList=NULL;
	
	struct stringStruct* insert(struct stringStruct* head, char *str); /*Function to insert in list*/
	struct stringStruct* find(struct stringStruct* head, char *str); /*Function to find in list*/
	
	void checkLabelValidity();
	void freeMem(); /*Function to clear memory allocated in labelList and gotoList while ending the program*/
%}

%start Program /*The start symbol of the grammar*/
%union{int ival; double dval; char str[120]; struct {int trueIndex; int falseIndex;} bool; }/*The list of supported data types*/

/*Keywords*/
%token PRINT END LET INPUT 
%token DO LOOP WHILE FOR NEXT TO /*Tokens for Loops*/
%token <str> LT LTE GT GTE EQ NEQ /*Tokens for Relational Operators*/
%token IF THEN ELSE /*Tokens for Decision Statements*/
%token AND OR NOT /*Tokens Logical Operators*/
%token <str> LABEL GOTOLABEL /*Tokens for Labels*/

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
%type <bool> RelExpr2

/*Operator Associativity and Precedence*/
%left	OR
%left	AND
%left	NOT


%left	'-' '+'
%left	'*' '/'
%left	NEGATION
%right	'^'


%%

/*Label for the complete program*/
Program
	: Statements End {fprintf(fPtr,"end\n"); checkLabelValidity();freeMem();}
	;

/*End statement is optional in the program*/
End
	: END
	| Empty
	;

Statements
	: Statement Statements
	| Statement
	;

/*Supported statement types
Note: Assignment can be done without let also. Therefore there is a separate LET Assignment
*/
Statement	
	: PRINT Output				{fprintf(fPtr,"PRINT \"\\n\"\n");}
	| LET Assignment
	| Assignment
	| INPUT NUM_VAR				{fprintf(fPtr,"SCAN %s\n",$2);}
	| INPUT STR_VAR				{fprintf(fPtr,"SCAN %s\n",$2);}
	| Loop
	| Decision
	| LABEL						{fprintf(fPtr,"%s: ",$1);labelList=insert(labelList,$1);}
	| GOTOLABEL					{fprintf(fPtr,"goto %s\n",$1);gotoList=insert(gotoList,$1);}
	;
	



/*PRINTING SECTION BEGIN*/
/*Output and Output2 are used with Print command. Multiple things can be printed in basic by separating each element with a comma*/
Output
	: Output2 ArithmExpr		{fprintf(fPtr,"PRINT %s\n",$2);}
	| Output2 STRING_LITERAL	{fprintf(fPtr,"PRINT %s\n",$2);}
	| Output2 STR_VAR			{fprintf(fPtr,"PRINT %s\n",$2);}
	;
	
Output2
	: Output ','				
	| Empty
	;	
/*PRINTING SECTION END*/
	
/*VARIABLE SECTION BEGIN*/
/*This section is for assigning values to variables*/
Assignment
	: NumAssignment
	| STR_VAR EQ STRING_LITERAL	{fprintf(fPtr,"%s = %s\n",$1,$3);}
	;
	
NumAssignment
	: NUM_VAR EQ ArithmExpr		{fprintf(fPtr,"%s = %s\n",$1,$3);}
	;
/*VARIABLE SECTION BEGIN*/


/*ARITHMETIC SECTION BEGIN*/
ArithmExpr
	: ArithmExpr '^' ArithmExpr	{sprintf(tVar,"t%d",genTempIndex());strcpy($$,tVar);fprintf(fPtr,"%s=getNewTemp()\n",$$);fprintf(fPtr,"%s=%s^%s\n",$$,$1,$3);}
	| ArithmExpr '*' ArithmExpr	{sprintf(tVar,"t%d",genTempIndex());strcpy($$,tVar);fprintf(fPtr,"%s=getNewTemp()\n",$$);fprintf(fPtr,"%s=%s*%s\n",$$,$1,$3);}
	| ArithmExpr '/' ArithmExpr	{sprintf(tVar,"t%d",genTempIndex());strcpy($$,tVar);fprintf(fPtr,"%s=getNewTemp()\n",$$);fprintf(fPtr,"%s=%s/%s\n",$$,$1,$3);}
	| ArithmExpr '+' ArithmExpr	{sprintf(tVar,"t%d",genTempIndex());strcpy($$,tVar);fprintf(fPtr,"%s=getNewTemp()\n",$$);fprintf(fPtr,"%s=%s+%s\n",$$,$1,$3);}
	| ArithmExpr '-' ArithmExpr	{sprintf(tVar,"t%d",genTempIndex());strcpy($$,tVar);fprintf(fPtr,"%s=getNewTemp()\n",$$);fprintf(fPtr,"%s=%s-%s\n",$$,$1,$3);}
	| '-' ArithmExpr %prec NEGATION {sprintf(tVar,"t%d",genTempIndex());strcpy($$,tVar);fprintf(fPtr,"%s=getNewTemp()\n",$$);fprintf(fPtr,"%s=-1*%s\n",$$,$2);} /*This rule is for the negated numbers*/
	| INTEGER					{sprintf($$,"%d",$1);}
	| NUM_VAR 				    {strcpy($$,$1);}
	| '(' ArithmExpr ')'		{strcpy($$,$2);}
	;
/*ARITHMETIC SECTION END*/

/*RELATIONAL SECTION BEGIN*/

/*RelExpr uses Inherited attirbutes. for generating the if else clause*/
RelExpr
	: NUM_VAR RelOp ArithmExpr	{fprintf(fPtr, "If %s %s %s goto l%d\n",$1,$2,$3,$<bool>-1.trueIndex); fprintf(fPtr,"goto l%d\n",$<bool>-1.falseIndex);}
	;
	
/*RelExpr2 creates new labels for the if else clause*/
RelExpr2
	: NUM_VAR RelOp ArithmExpr	{$$.trueIndex=genLabelIndex();$$.falseIndex=genLabelIndex();fprintf(fPtr, "If %s %s %s goto l%d\n",$1,$2,$3,$$.trueIndex); fprintf(fPtr,"goto l%d\n",$$.falseIndex);}
	;
	
/*Relational operators*/
RelOp
 	: LT						{strcpy($$,$1);}
 	| LTE						{strcpy($$,$1);}
 	| GT						{strcpy($$,$1);}
 	| GTE						{strcpy($$,$1);}
 	| EQ						{strcpy($$,$1);}
 	| NEQ						{strcpy($$,$1);}
 	;
/*RELATIONAL SECTION END*/


/*LOGICAL SECTION BEGIN*/
/*Section for logical Expressions.*/
LogicExpr
	: RelExpr2  {$$.trueIndex=$1.trueIndex;$$.falseIndex=$1.falseIndex;}
	| LogicExpr AND {fprintf(fPtr,"l%d: ",$1.trueIndex);}  BoolEmpty  {$4.trueIndex=genLabelIndex();$4.falseIndex=$1.falseIndex;} RelExpr {$$.trueIndex=$4.trueIndex;$$.falseIndex=$4.falseIndex;}
	| LogicExpr OR  {fprintf(fPtr,"l%d: ",$1.falseIndex);}  BoolEmpty  {$4.trueIndex=$1.trueIndex;$4.falseIndex=genLabelIndex();} RelExpr {$$.trueIndex=$4.trueIndex;$$.falseIndex=$4.falseIndex;} 
	| NOT LogicExpr {$$.trueIndex=$2.falseIndex;$$.falseIndex=$2.trueIndex;}
	;
	
	
/*LOGICAL SECTION END*/


/*LOOP CONSTRUCTS BEGIN */
Loop
	: DO {labelIndex=genLabelIndex();pushLabelIndex(labelIndex);fprintf(fPtr,"l%d: ",labelIndex);} Statements LOOP	{labelIndex=popLabelIndex();fprintf(fPtr,"goto l%d\n",labelIndex);} /*DO LOOP Construct*/
	| DO {labelIndex=genLabelIndex();pushLabelIndex(labelIndex);fprintf(fPtr,"l%d: ",labelIndex);} WHILE LogicExpr {fprintf(fPtr,"l%d: ",$4.trueIndex);} Statements LOOP {fprintf(fPtr,"goto l%d\n",popLabelIndex());fprintf(fPtr,"l%d: ",$4.falseIndex);} /*DO WHILE LOOP Construct*/
	| FOR NUM_VAR EQ ArithmExpr TO ArithmExpr {fprintf(fPtr,"%s = %s\n",$2,$4);labelIndex=genLabelIndex();fprintf(fPtr,"l%d: ",labelIndex); pushLabelIndex(labelIndex); int beginLabel=genLabelIndex();fprintf(fPtr,"if %s <= %s goto l%d\n",$2,$6,beginLabel);labelIndex=genLabelIndex();fprintf(fPtr,"goto l%d\n",labelIndex);pushLabelIndex(labelIndex);fprintf(fPtr,"l%d: ",beginLabel);} Statements  NEXT NUM_VAR 
	{if(strcmp($2,$10)!=0){yyerror("Counter variable not used in NEXT");exit(2);}fprintf(fPtr,"%s=%s+1\n",$10,$10);int falseLabel=popLabelIndex();fprintf(fPtr,"goto l%d\n",popLabelIndex());fprintf(fPtr,"l%d: ",falseLabel);} /*FOR LOOP Construct for step size one*/
	;
	
/*LOOP CONSTRUCTS END*/

/*IF ELSE SECTION BEGIN*/
Decision
	: IF LogicExpr THEN {fprintf(fPtr,"l%d: ",$2.trueIndex);} Statements BoolEmpty {$6.trueIndex=$2.trueIndex;$6.falseIndex=$2.falseIndex;} Else END IF 
	;
	
Else /*Else can be present or it can be empty*/
	: {labelIndex=genLabelIndex();fprintf(fPtr,"goto l%d\n",labelIndex);pushLabelIndex(labelIndex);}ELSE {fprintf(fPtr,"l%d: ",$<bool>-1.falseIndex);} Statements {labelIndex=popLabelIndex();fprintf(fPtr,"l%d: ",labelIndex);}
	| Empty {fprintf(fPtr,"l%d: ",$<bool>-1.falseIndex);}
	;
/*IF ELSE SECTION END*/

Empty:	{};/*EPSILON*/
BoolEmpty:	{};	
%%

/*Function to generate a temporary variable index*/
int genTempIndex() {
	tempCounter++;
	return tempCounter;
}

/*Function to generate a label index*/
int genLabelIndex() {
	labelCounter++;
	return labelCounter;
}


/*Function to push a label in the label stack*/
void pushLabelIndex(int label) {
	struct intStruct* temp;
	temp=(struct intStruct*)malloc(sizeof(struct intStruct));
	temp->val=label;
	temp->next=labelIndexStack;
	labelIndexStack=temp;
}

/*Function to pop a label from the label stack*/
int popLabelIndex() {
	struct intStruct* temp;
	int label;
	temp=labelIndexStack;
	labelIndexStack=labelIndexStack->next;
	label=temp->val;
	free(temp);
	return label;
}

/*Function to insert a string(label) in the linked list used for Labels and Goto*/
struct stringStruct* insert(struct stringStruct* head, char *str) {
	struct stringStruct *temp;
	temp=(struct stringStruct*)malloc(sizeof(struct stringStruct));
	temp->next=NULL;
	strcpy(temp->label,str);
	temp->next=head;
	head=temp;
	return head;
}

/*Function to find a string(label) in the linked list used for Labels and Goto*/
struct stringStruct* find(struct stringStruct* head, char *str) {
	struct stringStruct *itr;	
	itr=head;
	while((strcmp(itr->label,str)!=0)&&(itr->next!=NULL)) {
		itr=itr->next;
	}
	
	if(strcmp(itr->label,str)==0)
		return itr;
	return NULL;
}


/*Function to check if all the gotos have corresponding labels to jump to*/
void checkLabelValidity() {
	struct stringStruct *labelPointer, *gotoPointer;
	
	gotoPointer=gotoList;
	/*For each label in the gotoList, check whether the corresponding label is present in the labelList*/
	while(gotoPointer!=NULL) {
		labelPointer=labelList;
		while(labelPointer!=NULL) {
			if(strcmp(gotoPointer->label,labelPointer->label)==0)
				break;
			labelPointer=labelPointer->next;
		}
		/*If corresponding label not found in the labelList*/
		if(labelPointer==NULL) {
		    char erStr[100];
		    sprintf(erStr,"No matching label found for statement: goto %s",gotoPointer->label);
			yyerror(erStr);
			exit(3);
		}
		gotoPointer=gotoPointer->next;
	}
}
 /*Function to clear memory allocated in labelList and gotoList while ending the program*/
void freeMem() {
	struct stringStruct *labelPointer, *gotoPointer;
	
	/*Clear gotoList*/
	gotoPointer=gotoList;
	while(gotoList!=NULL) {
		gotoList=gotoList->next;
		free(gotoPointer);
		gotoPointer=gotoList;
	}
	/*Clear labelList*/
	labelPointer=labelList;
	while(labelList!=NULL) {
		labelList=labelList->next;
		free(labelPointer);
		labelPointer=labelList;
	}
}

/*Yacc default functions */
void yyerror (char const *s) {
	fprintf(stderr, "===============================================================================\n");
	fprintf (stderr, "| Error => %-66s |\n",s);
	fprintf(stderr, "===============================================================================\n");
	if(fPtr!=stdout)
		system("rm out.txt");
}

int main(int argc, char *argv[]) {
	if(argc==2) {
		if(strcmp(argv[1],"out")==0)
			fPtr=stdout;
	}
	else
		fPtr=fopen("out.txt","w");
	yyparse();
	return 0;
}
