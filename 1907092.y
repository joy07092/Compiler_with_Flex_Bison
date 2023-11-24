%{
    #include <stdio.h>
    #include <string.h>
    #include <math.h>
    #include <stdlib.h>

    int yylex();
    int yyerror(char* s);
  
    #define var_allowed 100
    int case_matched = 0;
    int VAR_CNT = 0, FUNC_CNT = 0;
    #define func_allowed 100
    int func_flag = 0, curr_function = 0, curr_parameter = 0, func_rejec = 0;

    typedef struct {
        char *name;
        int type;
        int length;
        int *ival;   //for the integer variable
        double *dval;  //for the double variable  
        char **sval;  //for string variable, pointer to pointer character array
    } info;    //storing the variable information
    info *varptr;  //the size is later given in the main function

    typedef struct {
        char *fname;
        info *fptr;
        int var_cnt;
    } stackfun;
    stackfun *funcptr;  //the size is later given in the main function

    int check_unique(char *name) {  //check for duplicate variable name
        for(int i = 0; i < VAR_CNT; ++i) {
            if(strcmp(varptr[i].name, name) == 0) {
                return -1;   //not unique
            }
        }
        return 1;  //unique
    } 

    int variable_index(char *name) {  //return the variable index
        for(int i = 0; i < VAR_CNT; ++i) {
            if(strcmp(varptr[i].name, name) == 0) {
                return i;
            }
        }
        return -1;    //when the variable is not declared
    }

    int function_index(char *name){
        for(int i = 0; i < FUNC_CNT; ++i) {
            if(strcmp(funcptr[i].fname, name) == 0) {
                return i;
            }
        }
        return -1;
    }

    void variable_info(char *n, int t, int l, int p, void *v) {  //store variable information
        varptr[p].name = n;
        varptr[p].type = t;
        varptr[p].length = l;
        if(t == 1) { //1 for integer
            int *value = (int *) v;
            varptr[p].ival = malloc(l * sizeof(int));
            for(int i = 0; i < l; ++i) {
                varptr[p].ival[i] = value[i];
            }
            printf("Variable initialized: %s is Integer, Value: %d\n", varptr[p].name, *varptr[p].ival);
        } else if(t == 2) { //2 for float
            double *value = (double *) v;
            varptr[p].dval = malloc(l * sizeof(double));
            for(int i = 0; i < l; ++i) {
                varptr[p].dval[i] = value[i];
            }
            printf("Variable initialized: %s is Flaoting Point Number, Value: %lf\n", varptr[p].name, *varptr[p].dval);
        } else if(t == 3) {  //3 for string
            char **s = ((char**) v);
            varptr[p].sval = malloc(l * sizeof(char**));
            for(int i = 0; i < l; ++i) {
                varptr[p].sval[i] = s[i];
            }
            printf("Variable initialized: %s is String, Value: %s\n", varptr[p].name, *varptr[p].sval);
        }
    }
    
    void read_value(char *name, int p) {
        int index = variable_index(name);
        if (index == -1) {
            printf("Variable \"%s\" doesn't exist.\n", name);
        } else {
            if(p >= varptr[index].length) {
                printf("Maximum Number of Variables Used.\n");
            } else {
                if (varptr[index].type == 2) { //2 for float
                    printf("Enter Input for float variable %s: \n", name);
                    scanf("%lf", &varptr[index].dval[p]);
                } else if (varptr[index].type == 1) { //1 for integer
                    printf("Enter Input for integer variable %s: \n", name);
                    scanf("%d", &varptr[index].ival[p]);
                } else if(varptr[index].type == 3) { //3 for string
                    printf("Enter Input for string variable %s: \n", name);
                    char str [1000];
                    //scanf("%s", str);
                    //varptr[index].sval[p] = str;
                }
            }
        }
    }
    void print_value(char *name) {
        int index = variable_index(name);
        if(index == -1) {
            printf("Variable \"%s\" doesn't exist.\n", name);
        } else {
             
                printf("Value of %s is: ", name);
                if(varptr[index].type == 1) { //1 for integer
                    printf("%d\n", varptr[index].ival[0]);
                } else if(varptr[index].type == 2) { //2 for float
                    printf("%lf\n", varptr[index].dval[0]);
                } else if(varptr[index].type == 3) { //3 for string
                    printf("%s\n", varptr[index].sval[0]);
                }
            
        }
    }
    
    
    
    
%}

%error-verbose  //error: syntax error, further info of the error is printed by this
%union { //defines the types of tokens that the grammar can recognize
	int integer;
	double floating_num;
	char *string;
}

%token VARIABLE INPUT PRINT DISPLAY START FINISH BY MAIN
%token NUMBER_TYPE DECIMAL_TYPE STRING_TYPE
%token NUMBER_VALUE DECIMAL_VALUE STRING_VALUE
%token AND OR XOR NOT INC DEC LT GT EQL NEQL LEQL GEQL ONLY_INC ONLY_DEC
%token POW SIN COS TAN LOG10 LOG2 LN SQRT
%token DEF CALL
%token IF EL_IF ELSE
%token FOR IN WHILE SWITCH CASE DEFAULT
%token HEADER S_COMMENT M_COMMENT EOL

//establish the relationship between specific tokens in the grammar rules and the types defined in the %union block
%type <integer> NUMBER_VALUE if_blocks elif_block
%type <floating_num> DECIMAL_VALUE statements statement expr while_conditions POW SIN COS TAN LOG10 LOG2 LN SQRT
%type <string> VARIABLE NUMBER_TYPE DECIMAL_TYPE STRING_TYPE STRING_VALUE

%nonassoc EL_IF 
%nonassoc ELSE

%left INC DEC ONLY_INC ONLY_DEC
%left AND OR XOR NOT
%left LT GT EQL NEQL LEQL GEQL
%left '+' '-'
%left '*' '/' '%'

%%
starting_symbol:
    comments headers comments functions comments MAIN '{' statements '}' {
        printf("Compiled Successfully\n");
    }
;
headers:
    headers HEADER {
        printf("Header Found!\n");
    }
    | HEADER {
        printf("Header Found!\n");
    }
;
comments:
    comments comment
    | comment
;
comment:
    S_COMMENT
    |M_COMMENT
    |
statements:
    {}
    |statements statement
;

statement: 
    EOL
    |statement EOL statement
    |S_COMMENT
    |M_COMMENT
    |input EOL
    |print EOL
    |declarations EOL
    |if_blocks {
        printf("IF BLOCKS return: %d\n", $1);
    }
    |for_loop
    |switch_statement
    |while_loop
    |function_call EOL
    |display EOL
    |only_inc_dec EOL
;

display:
    DISPLAY '(' STRING_VALUE ')' {
        printf("%s\n", $3);
    }
;
print:
    PRINT '(' output_variable ')' {}
;
output_variable:
    output_variable ',' VARIABLE {
        print_value($3);
    }
    |VARIABLE {
        print_value($1);

    }
;

input:
    INPUT '(' input_variable ')' {
    }
;

input_variable:
    input_variable ',' VARIABLE {
        read_value($3, 0);
    }
    |VARIABLE {
        read_value($1, 0);
    }

functions:functions function_declare
        |function_declare
;

function_declare:
    return_types DEF function_name '(' function_variable ')' '{' statement '}' {
        if(func_flag){
         printf("Function successfully declared\n"); 
         func_flag=0;
    }
    else {
        printf("Error:Function creation failed\n");
    }
}
;
return_types:
    NUMBER_TYPE
    |DECIMAL_TYPE
    |STRING_TYPE
;

function_name:
    VARIABLE {
        int index = function_index($1);
        if (index != -1) {
            printf("Error: Function '%s' already declared.\n", $1);
        } else {
            func_flag =1 ;
            printf("Function declaration start: %s\n", $1);
            funcptr[FUNC_CNT].fname = malloc((strlen($1) + 1) * sizeof(char));
            strcpy(funcptr[FUNC_CNT].fname, $1);
            funcptr[FUNC_CNT].var_cnt = 0;
            funcptr[FUNC_CNT].fptr = malloc(4 * sizeof(stackfun));
            FUNC_CNT++;
        }
    }

function_variable:
    |function_variable ',' single_variable
    | single_variable
;

single_variable:
    NUMBER_TYPE VARIABLE {
        if (FUNC_CNT > 0) {
            int index = funcptr[FUNC_CNT - 1].var_cnt;
            int value = 0;
            variable_info($2, 1, 1, VAR_CNT, &value);
            funcptr[FUNC_CNT - 1].fptr[index] = varptr[VAR_CNT];
            VAR_CNT++;
            funcptr[FUNC_CNT - 1].var_cnt++;
        }
    }
    | DECIMAL_TYPE VARIABLE {
        if (FUNC_CNT > 0) {
            int index = funcptr[FUNC_CNT - 1].var_cnt;
            double value = 0;
            variable_info($2, 2, 1, VAR_CNT, &value);
            funcptr[FUNC_CNT - 1].fptr[index] = varptr[VAR_CNT];
            VAR_CNT++;
        funcptr[FUNC_CNT - 1].var_cnt++;
        }
    }
;

function_call:
    CALL user_function_name '(' parameters ')' {
        if(func_rejec) {
            printf("Function Not Declared.\n");
        } else {
            printf("Function Successfully Called.\n");
        }
    }
;

user_function_name:
    VARIABLE {
        int index = function_index($1);
        if(index == -1) {
            printf("Function Doesn't Exist.\n");
        } else {
            curr_function = index;
            curr_parameter = 0;
            func_rejec = 0;
        }
    }
;

parameters:
    parameters ',' single_parameter
    |single_parameter
;

single_parameter: 
    VARIABLE {
        int index = variable_index($1);
        if(curr_parameter >= funcptr[curr_function].var_cnt) {
            printf("Way too many arguments.\n");
            func_rejec = 1;
        } else if(funcptr[curr_function].fptr[curr_parameter].type != varptr[index].type) {
            printf("Data Types Don't Match.\n");
            func_rejec = 1;
        } else {
            curr_parameter++;
        }
    }
    | 
;

for_loop:
    FOR '(' VARIABLE IN '[' START expr ',' FINISH expr ',' BY expr ']' ')' '{' statement '}' {
        printf("For Loop Block\n");
        int from = $7;
        int end = $10;
        int by = $13;
        int dif = end - from;
        if(dif * by < 0) {
            printf("For Loop Condition wasn't satisfied\n");
        } else {
            int c = 1;
            for(int i = from; i <= end; i += by) {
                printf("For Loop Iteration: %d\n", c);
                c++;
            }
        }
    }
;
switch_statement:
    SWITCH '{' cases '}' {
        printf("Switch statement ended\n");
    }
;
cases:
    cases case
    | case
;
case:
    CASE '(' expr ')' '{' statement '}' {
        int condition = (fabs($3) > 1e-9);   
        if(condition) {
            case_matched = 1;
            printf("Case Matched.\n");
        } else {
            //printf("Condition Didn't match in IF Block.\n");
        }
    }
    | DEFAULT '{' statement '}' {
        if(!case_matched) {
            printf("Default matched\n");
        }
    }
while_loop:
    WHILE '(' while_conditions ')' '{' statement '}' {
        printf("WHILE BLOCK\n");
        int whilecheckbool = 0;
        for(int i = 1; i < $3; ++i) {
            whilecheckbool = 1;
            printf("WHILE Loop Iteration: %d\n", i);
        }
        if(!whilecheckbool) {
            printf("While Loop Condition wasn't satisfied\n");
        }
    }
while_conditions:
    VARIABLE INC LT expr {
        int index = variable_index($1);
        if(index == -1) {
            printf("Variable \"%s\" doesn't exist.\n", $1);
        } else if(varptr[index].type != 1) { //1 for integer
            printf("Variable should be NUMBER Type.\n");
        } else {
            int value = varptr[index].ival[0];
            if(value > $4) {
                $$ = -1;
            } else {
                $$ = (int) $4 - value;
            }
        }
    }
    |VARIABLE INC LEQL expr {
        int index = variable_index($1);
        if(index == -1) {
            printf("Variable \"%s\" doesn't exist.\n", $1);
        } else if(varptr[index].type != 1) { //1 for integer
            printf("Variable should be NUMBER Type.\n");
        } else {
            int value = varptr[index].ival[0];
            if(value > $4) {
                $$ = -1;
            } else {
                $$ = (int) $4 - value + 1;
            }
        }
    }
    |VARIABLE INC NEQL expr {
        int index = variable_index($1);
        if(index == -1) {
            printf("Variable \"%s\" doesn't exist.\n", $1);
        } else if(varptr[index].type != 1) { //1 for integer
            printf("Variable should be NUMBER Type.\n");
        } else {
            int value = varptr[index].ival[0];
            if(value > $4) {
                $$ = -1;
            } else {
                $$ = (int) $4 - value;
            }
        }
    }
    |VARIABLE DEC GT expr {
        int index = variable_index($1);
        if(index == -1) {
            printf("Variable \"%s\" doesn't exist.\n", $1);
        } else if(varptr[index].type != 1) { //1 for integer
            printf("Variable should be NUMBER Type.\n");
        } else {
            int value = varptr[index].ival[0];
            if(value < $4) {
                $$ = -1;
            } else {
                $$ = value - (int) $4;
            }
        }
    }
    |VARIABLE DEC GEQL expr {
        int index = variable_index($1);
        if(index == -1) {
            printf("Variable \"%s\" doesn't exist.\n", $1);
        } else if(varptr[index].type != 1) { //1 for integer
            printf("Variable should be NUMBER Type.\n");
        } else {
            int value = varptr[index].ival[0];
            if(value < $4) {
                $$ = -1;
            } else {
                $$ = value - (int) $4 + 1;
            }
        }
    }
    |VARIABLE DEC NEQL expr {
        int index = variable_index($1);
        if(index == -1) {
            printf("Variable \"%s\" doesn't exist.\n", $1);
        } else if(varptr[index].type != 1) { //1 for integer
            printf("Variable should be NUMBER Type.\n");
        } else {
            int value = varptr[index].ival[0];
            if(value < $4) {
                $$ = -1;
            } else {
                $$ = value - (int) $4;
            }
        }
    }
;

if_blocks:
    IF '(' expr ')' '{' if_blocks '}' elif_block {
        if ($3) {
            $$ = $6; 
        } else {
            $$ = $8; 
        }
    }
    | IF '(' expr ')' '{' if_blocks '}' {
        if ($3) {
            $$ = $6;
        }
    }
    | expr {  //expr %prec LOWER_THAN_ELSE
        $$ = $1;
    }
    ;

elif_block:
    EL_IF '(' expr ')' '{' if_blocks '}' elif_block {
          if ($3) {
            $$ = $6; 
        } else {
            $$ = $8; 
        }
    }
    | ELSE '{' if_blocks '}' {
        $$ = $3;
    }
    | EL_IF '(' expr ')' '{' if_blocks '}' {
        if ($3) {
            $$ = $6;
        }
    }
;
declarations:
    NUMBER_TYPE num_vars
    |DECIMAL_TYPE dec_vars
    |STRING_TYPE str_vars
;

str_vars:
    str_vars ',' str_var
    |str_var
;
str_var:
    VARIABLE '=' STRING_VALUE {
        int exists = check_unique($1);
        if(exists == -1) {
            printf("Variable \"%s\" already exists.\n", $1);
        } else {
            char *value = $3;
            variable_info($1, 3, 1, VAR_CNT, &value);
            VAR_CNT++;
        }
    }
    |VARIABLE {
        //char *value = "";
        //variable_info($1, 3, 1, VAR_CNT, &value);
        //VAR_CNT++; 
        printf("Error: String declaration without initialization\n");
    }
dec_vars:
    dec_vars ',' dec_var
    |dec_var
;
dec_var:
    VARIABLE '=' expr {
        if(check_unique($1) == -1) {
            printf("Variable \"%s\" already exists.\n", $1);
        } else {
            double value = $3;
            variable_info($1, 2, 1, VAR_CNT, &value);
            VAR_CNT++;
        }
    }
    |VARIABLE {
        printf("Error: Float declaration without initialization\n");
        // double value = 0.0;
        //variable_info($1, 2, 1, VAR_CNT, &value);
        //VAR_CNT++; 
    }

num_vars: 
    num_vars ',' num_var
    |num_var
;

num_var: 
    VARIABLE '=' expr {
        if(check_unique($1) == 1) {
            int value = $3;
            variable_info($1, 1, 1, VAR_CNT, &value);
            VAR_CNT++;
        } else {
            printf("Variable \"%s\" already exists.\n", $1);
        }
    }
    |VARIABLE {  
        printf("Error: Integer declaration without initialization\n");
    }
;


expr:
    NUMBER_VALUE {
        $$ = $1;
    }
    |DECIMAL_VALUE {
        $$ = $1;
    }
    |VARIABLE {
        int i = variable_index($1);
        if(i == -1) {
            printf("Variable \"%s\" doesn't exist.\n", $1);
            $$ = 0;
        } else if(varptr[i].type == 1) { //1 for integer
            $$ = varptr[i].ival[0];
        } else if(varptr[i].type == 2) { //2 for float
            $$ = varptr[i].dval[0];
        }
    }
    |'+' expr {
        $$ = $2;
    }
    |'-' expr {
        $$ = -$2;
    }
    |INC expr {
        $$ = $2;
    }
    |DEC expr {
        $$ = $2;
    }
    |expr '+' expr {
        $$ = $1 + $3;
    }
    |expr '-' expr {
        $$ = $1 - $3;
    }
    |expr '*' expr {
        $$ = $1 * $3;
    } 
    |expr '/' expr {
        $$ = $1 / $3;
    }
    |expr '%' expr {

        $$ = (int)$1 % (int)$3;
    }
    |expr POW expr {

        $$ = pow($1, $3);
    }
    |expr EQL expr         
    {
        $$ = ($1 == $3);
    }
    |expr NEQL expr        
    {
        $$ = ($1 != $3);
    }
    |expr LT expr {
        $$ = ($1 < $3);
    }
    |expr GT expr {
        $$ = ($1 > $3);
    }
    |expr LEQL expr {
        $$ = ($1 <= $3);
    }
    |expr GEQL expr        
    {
        $$ = ($1 >= $3);
    }
    |expr AND expr         
    {
        $$ = ( $1 && $3);
    }
    |expr OR expr          
    {
        $$ = ($1 || $3);
    }
    |expr XOR expr         
    {
        $$ = ((int)$1 ^ (int)$3);
    }
    |NOT expr              
    {
        $$ = !$2;
    }
    |VARIABLE INC
    {
        int index = variable_index($1);
        if(index == -1) {
            printf("Variable \"%s\" doesn't exist.\n", $1);
        } else if(varptr[index].type != 1) { //1 for integer
            printf("Can't Increment Incompatible Types.\n");
        } else {
            $$ = varptr[index].ival[0] + 1;
        }
    }
    |VARIABLE DEC       
    {
        int index = variable_index($1);
        if(index == -1) {
            printf("Variable \"%s\" doesn't exist.\n", $1);
        } else if(varptr[index].type != 1) { //1 for integer
            printf("Can't Increment Incompatible Types.\n");
        } else {
            $$ = varptr[index].ival[0] - 1;
        }
    }
    |'(' expr ')' {
        $$ = $2;
    }
    |SIN '(' expr ')' {
        $$ = sin($3);
    }
    |COS '(' expr ')' {
        $$ = cos($3);
    }
    |TAN '(' expr ')' {
        $$ = tan($3);
    }
    |LOG10 '(' expr ')' {
        $$ = log10($3);
    }
    |LOG2 '(' expr ')' {
        $$ = log2($3);
    }
    |LN '(' expr ')' {
        $$ = log($3);
    }
    |SQRT '(' expr ')' {
        $$ = sqrt($3);
    }

only_inc_dec:
    VARIABLE ONLY_INC {
        int index = variable_index($1);
        if(index == -1) {
            printf("Variable \"%s\" doesn't exist.\n", $1);
        } else if(varptr[index].type != 1) { //1 for integer
            printf("Can't Increment Incompatible Types.\n");
        } else {
            varptr[index].ival[0]++;
        }
    }
    |VARIABLE ONLY_DEC {
        int index = variable_index($1);
        if(index == -1) {
            printf("Variable \"%s\" doesn't exist.\n", $1);
        } else if(varptr[index].type != 1) { //1 for integer
            printf("Can't Increment Incompatible Types.\n");
        } else {
            varptr[index].ival[0]--;
        }
    }

; 

%%
int main() {
    FILE *yyin = freopen("input.txt", "r", stdin);
    FILE *yyout = freopen("output.txt", "w", stdout);
    varptr = malloc(var_allowed * sizeof(info));
    funcptr = malloc(func_allowed * sizeof(stackfun));
    yyparse();
    free(varptr);
    free(funcptr);
    fclose(yyin);
    fclose(yyout);
    return 0;
}