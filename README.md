# Compiler_with_Flex_Bison Wiki!

This a compiler developing project where a custom compiler was developed with the use of Flex and Bison to tokenize and parse input from user and make sure the input was according to the syntax of the custom language.

Here, the <.l> file represents the Flex file and <.y> file represent the Bison file.
And, the <input.txt> is the one from which the input of user is read and the output of that read is being write on <output.txt>

The commands that are needed to run the project have to be given in the "Command Prompt" in the folder these files are stored.
The commands are given below, they are total 4 in numbers:

bison -d name_of_the_bison_file.y
flex name_of_the_flex_file.y
gcc name_of_the_bison_file.tab.c lex.yy.c -o any_name
any_name
