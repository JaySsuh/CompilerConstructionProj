
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

%}

%option noyywrap yylineno

newline         \n
whitespace      [ \t\r]+
integer         [0-9]+
integerlead0    0[0-9]+      /* added definition so scanner recognizes the invalid integer */
character       \'[^\'\n]\'  /* match anything that isnt a single quote or newline */

 /* String can contain any characters between the double quotes */
 /* other than a newline or unescaped doublequotes */

string       \"([^\n\"\\]|\\.)*\" 


 /* If the end quote is not found in the same line the string is unterminated */
untermstring \"([^\n\"\\]|\\.)*\n

comment         \/\/[^\n]*
multlncomment   \/\*([^*]|\*+[^*/])*\*+\/
untermcomment   \/\*([^*]|\*+[^*/])*

identifier      [a-zA-Z][a-zA-Z0-9]*
illidentifier   [0-9]+[a-zA-Z][a-zA-Z0-9]*

%%

 /* rules */

 /* Keywords */
"if"            {updateCol(); return KWD_IF;}
"else"          {updateCol(); return KWD_ELSE;}
"while"         {updateCol(); return KWD_WHILE;}
"int"           {updateCol(); return KWD_INT;}
"string"        {updateCol(); return KWD_STRING;}
"char"          {updateCol(); return KWD_CHAR;}
"return"        {updateCol(); return KWD_RETURN;}
"void"          {updateCol(); return KWD_VOID;}


 /* Operators */
"++"            {updateCol(); return OPER_INC;}
"--"            {updateCol(); return OPER_DEC;}
"&&"            {updateCol(); return OPER_AND;}
"||"            {updateCol(); return OPER_OR;}
">="            {updateCol(); return OPER_GTE;}
"<="            {updateCol(); return OPER_LTE;}              
"=="            {updateCol(); return OPER_EQ;}
"!="            {updateCol(); return OPER_NEQ;}
"+"             {updateCol(); return OPER_ADD;}
"-"             {updateCol(); return OPER_SUB;}
"*"             {updateCol(); return OPER_MUL;}
"/"             {updateCol(); return OPER_DIV;}
"<"             {updateCol(); return OPER_LT;}
">"             {updateCol(); return OPER_GT;}
"="             {updateCol(); return OPER_ASGN;}
"@"             {updateCol(); return OPER_AT;}
"!"             {updateCol(); return OPER_NOT;}
"%"             {updateCol(); return OPER_MOD;}

 /* Brackets & Parens */
 "["            {updateCol(); return LSQ_BRKT;}
 "]"            {updateCol(); return RSQ_BRKT;}
 "{"            {updateCol(); return LCRLY_BRKT;}
 "}"            {updateCol(); return RCRLY_BRKT;}
 "("            {updateCol(); return LPAREN;}
 ")"            {updateCol(); return RPAREN;}

 /* Punctuation */
 ","            {updateCol(); return COMMA;}
 ";"            {updateCol(); return SEMICLN;}

 /* Identifiers */
{identifier}    {updateCol(); return ID;}
{illidentifier} {updateCol(); return ILLEGAL_TOK;}

 /* Constants */
{integerlead0}  {updateCol(); yyerror = "Integers may not have leading zeros"; return ERROR;}
{integer}       {updateCol(); return INTCONST;}
{character}     {updateCol(); return CHARCONST;}
{string}        {updateCol(); return processString();}
{untermstring}  {yycol = scancol; scancol = 1; yyerror = "Unterminated string constant"; return ERROR;}

 /* Comments */
{comment}       {updateCol();}
{multlncomment} {countLines();}
{untermcomment} {yycol = scancol; yyerror = "Unterminated comment"; return ERROR;}

 /* Other */
{newline}       {scancol = 1;}
{whitespace}    {scancol += yyleng;}
.               {return ILLEGAL_TOK;}

%%

/* user routines */
/*
Implement this function to keep track of column numbers
*/
void updateCol(){
    scancol += yyleng;
    yycol = scancol;
}
/*
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

/*
Implement this function to
check for illegal escape sequences in string literals
and
convert valid escape sequences into escaped characters
(string[0] == '\\' and string[1] == 'n', then string[0] should be '\n')
*/

int processString(){
    int len = yyleng;
    
    if(len < 2 || yytext[0] != '"' || yytext[len-1] != '"') {
        yyerror = "Unterminated string constant";
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
                yyerror = "Unrecognized escape character in String";
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
                default:
                    free(buf);
                    yyerror = "Unrecognized escape character in string";
                    return ERROR; 
            }
            src += 2;
        } else if(c == '\n') {
            free(buf);
            yyerror = "String spans multiple lines";
            return ERROR;
        } else {
            buf[dst++] = c;
            src++;
        }
    }
    buf[dst] = '\0';

    return STRING;
}
