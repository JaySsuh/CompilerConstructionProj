
/* definitions */

%{
#include <stdio.h>
#include <stdlib.h>
#include "tokendef.h"

 /* integers to track line and column numbers */
int scancol = 1;
int yycol = 1;
int scanlineno = 1;

 /* char pointer to pass error messages to driver.c */
char *yyerror;

 /* TODO: functions to update line and column numbers */
void updateCol();
void countLines();

 /* TODO: function to process a string literal */
int processString();

newline         //TODO
whitespace      //TODO
integer         //TODO
character       //TODO

 /* String can contain any characters between the double quotes */
 /* other than a newline or unescaped doublequotes */
*/
string       //TODO


 /* If the end quote is not found in the same line the string is unterminated */
untermstring //TODO

comment         //TODO
multlncomment   //TODO
untermcomment   //TODO

identifier      //TODO
illidentifier   //TODO: regular expression for an illegal identifier

yylineno = 1;

%%

 /* rules */

 /* Keywords */
 /* TODO: Support all keywords in mC */

 /* Operators */
 /* TODO: Support all operators in mC */

 /* Identifiers */;
{identifier}    //TODO
{illidentifier} {updateCol(); yyerror = "Illegal identifier"; return ERROR;}

 /* Constants */;
{integer}       //TODO
{integerlead0}  {updateCol(); yyerror = "Integers may no thave leading zeros"; return ERROR;}
{character}     //TODO
{string}        {updateCol(); return processString();}
{untermstring}  {updateCol(); yyerror = "Unterminated string"; return ERROR;}

 /* Comments */
{comment}       {updateCol();}
{untermcomment} {updateCol();}
{multlncomment} {updateCol(); yyerror = "Unterminated string"; return ERROR;}

 /* Other */
{newline}       {countLines(); /*no token */}
{whitespace}    {updateCol(); /* no token */}
.               {return ILLEGAL_TOK;}

%%

/* user routines */

/* TODO:
Implement this function to keep track of column numbers
*/
void updateCol(){
    scancol += yyleng;
    yycol = scancol;
}

/* TODO:
Implement this function to keep track of line numbers
*/
void countLines(){
        for(int i = 0; i < yyleng; i++) {
        if(yytext[i] == '\n') {
            scanlineno++;
            scancol = 1;
        } else {
            scancol++;
        }
    }
    yycol = scancol;
}


/* TODO:
Implement this function to
check for illegal escape sequences in string literals
and
convert valid escape sequences into escaped characters
(string[0] == '\\' and string[1] == 'n', then string[0] should be '\n')
*/
int processString(){
        int len = yyleng;
    
    if(len < 2 || yytext[0] != '"' || yytext[len-1] != '"') {
        yyerror = "Unterminated string";
        return ERROR;
    }

    char *buf = (char *) malloc(len -1);
    if(!buf) {
        yyerror = "Out of memory in string literal";
        return ERROR;
    }

    int src = 1; 
    int dst = 0;

    while(src < len - 1) {
        char c = yytext[src];
        if(c == '\\') {
            if(src + 1 >= len - 1) {
                free(buf);
                yyerror = "Illegal escape sequence in string."
                return ERROR;
            }
            char next = yytext[src + 1];

            switch(next) {
                case 'n': 
                    buf[dst++] = '\n';
                    break;
                case 't':
                    buf[dst++] = '\t';
                    break;
                case 'r':
                    buf[dst++] = '\r';
                    break;
                case '\\':
                    buf[dst++] = '\\';
                    break;
                case '"':
                    buf[dst++] = '"';
                    break;
                case '0':
                    buf[dst++] = '0';
                    break;
                default:
                    free(buf);
                    yyerror = "Illegal escape sequence in string";
                    return ERROR; 
            }
            src += 2;
        } else {
            buf[dst++] = c;
            src++;
        }
    }
    buf[dst] = '\0';

    return STRING;
}
