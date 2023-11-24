%{
    #include <stdio.h>
    #include <string.h>
    #include "1907092.tab.h"
%}

IDENTIFIER                [a-zA-Z][_a-zA-Z0-9]*
INTEGER                   [-+]?[0-9]*
FLOAT                    [-+]?[0-9]+[.][0-9]+
STRING                    \"(\\.|[^"\\])*\"

%%

"add_library"[ ]+{IDENTIFIER}[.][h][$] {
    return HEADER;
}

"int_j [mainjoy()]" {
    printf("Main function found!\n");
    return MAIN;
}

"$" {
    return EOL;
}
"int_j"[ ]+ {
    return NUMBER_TYPE;
}

"float_j"[ ]+ {
    return DECIMAL_TYPE;
}
"string_j"[ ]+ {
    return STRING_TYPE;
}

"jin" {
    return INPUT;
}
"jout" {
    return PRINT;
}
"in" {
    return IN;
}
"jwhile" {
    return WHILE;
}
"dfn" {
    return DEF;
}
"calling" {
    return CALL;
}
"++" {
    return INC;
}

"--" {
    return DEC;
}
"==" {
    return EQL;
}
"+++" {
    return ONLY_INC;
}	
"---" {
    return ONLY_DEC;
}									
"!=" {
    return NEQL;
}
"<" {
    return LT;
}
">" {
    return GT;
}
"<=" {
    return LEQL;
}
">=" {
    return GEQL;
}
"&&" {
    return AND;
}
"||" {
    return OR;
}
"^^" {
    return XOR;
}
"~~" {
    return NOT;
}
"**" {
    return POW;
}
"log10" {
    return LOG10;
}
"log2" {
    return LOG2;
}
"ln" {
    return LN;
}
"sqrt" {
    return SQRT;
}
"jif" {
    return IF;
}
"jelse_if" {
    return EL_IF;
}
"jelse" {
    return ELSE;
}
"sin" {
    return SIN;
}
"cos" {
    return COS;
}
"tan" {
    return TAN;
}
"jfor" {
    return FOR;
}

"display" {
    return DISPLAY;
}
"switch:" {
    return SWITCH;
}
"def:" {
    return DEFAULT;
}
"case:" {
    return CASE;
}
"start"[ ]*[:] {
    return START;
}

"finish"[ ]*[:] {
    return FINISH;
}

"by"[ ]*[:] {
    return BY;
}

"/>>"[ ]* {
    char comment[1000];
    int i = 0;
    while(1) {
        char c = input(); //read one character at a time from input
        if(c == '\n' || c == EOF) {
            comment[i] = '\0';
            break;
        }
        comment[i++] = c;
    }
    printf("SINGLELINE COMMENT\n", comment);
    return S_COMMENT;
}

"/*"[ ]* {
    char comment[1000];
    int i = 0;
    while(1) {
        char c = input();
        if(c == '*') {
            char d = input();
            if(d == '/') {
                comment[i++] = '\0';
                break;
            }
            comment[i++] = (c == '\n') ? ' ' : c;
            comment[i++] = (d == '\n') ? ' ' : c;
        } else {
            if(comment[i - 1] == '*' && c == '/') {
                comment[i - 1] = '\0';
                break;
            }
            comment[i++] = (c == '\n') ? ' ' : c;
        }
    }
    printf("MULTILINE COMMENT\n", comment);
    return M_COMMENT;
}

{IDENTIFIER} {
    yylval.string = strdup(yytext);
    return VARIABLE;
 }

{INTEGER} {
    yylval.integer = atoi(yytext);  //string to integer
    return NUMBER_VALUE;
}

{FLOAT} {
    yylval.floating_num = atof(yytext); //string to floating point
    return DECIMAL_VALUE;
}

{STRING} {
    char* tmp = strdup(yytext);//yytext string copied to tmp string
    int n = strlen(tmp);
    yylval.string = malloc(n * sizeof(char));
    memcpy(yylval.string, &tmp[1], n  - 2);
    yylval.string[n - 2]= '\0';   //last 3 lines, omit quote and store the rest of the string and added null terminator
    return STRING_VALUE;
}


[ \t\n] {
}

[-+/*<>=,();%^{}\[\]] {
    return yytext[0];
}
. {
    printf("Unknown Character. %s\n", yytext);
}


%%
int yywrap() { //returns 1 when there is no more input
    return 1;
}

int yyerror(char *s){ //report error that occur during lexical analysis
	printf("error: %s\n", s); //prints an error message to the standard error stream (stderr)
    return 1; //returns 1, signaling to the calling program (often the parser generated by Bison) that an error has occurred
}