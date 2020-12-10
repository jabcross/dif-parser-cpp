/* Token scanner for DIF language

Grammar reference: http://dspcad.umd.edu/dif/difgrammar.html

*/

%{
#include "parser.h"
#include "test_parser.h"
int lexerror = 0;

%}

digit [0-9]
non_digit ([a-z]|[A-Z]|"_")
double [+-]?{digit}*"."{digit}+([eE][+-]?{digit}+)?
integer [+-]?{digit}+
eol ("\r\n"|"\r"|"\n")
escape_sequence "\\"(["\\bfnrt]|[0-7]{1,3}|"x"[a-fA-F]+)
s_char_sequence ([^"$\\\r\n]|{escape_sequence})*
string ["]{s_char_sequence}*["]
%%

    /* short_comment */
\/\/[^\n]*\n {}

    /* long_comment */
"/*"[^*]*[*]+([^*/][^*]*[*]+)*+"/" {}

    /* symbols */
"{" {return TOK_L_BKT;}
"}" {return TOK_R_BKT;}
"(" {return TOK_L_PAR;}
")" {return TOK_R_PAR;}
"[" {return TOK_L_SQR;}
"]" {return TOK_R_SQR;}
";" {return TOK_SEMICOLON;}
":" {return TOK_COLON;}
"," {return TOK_COMMA;}
"'" {return TOK_S_QTE;}
"+" {return TOK_PLUS;}
"=" {return TOK_EQUAL;}
"." {return TOK_DOT;}

    /* keywords */
"graph" {return TOK_GRAPH;}
"attribute" {return TOK_ATTRIBUTE;}
"basedon" {return TOK_BASEDON;}
"interface" {return TOK_INTERFACE;}
"parameter" {return TOK_PARAMETER;}
"refinement" {return TOK_REFINEMENT;}
"topology" {return TOK_TOPOLOGY;}
"actor" {return TOK_ACTOR;}
"inputs" {return TOK_INPUTS;}
"outputs" {return TOK_OUTPUTS;}
"nodes" {return TOK_NODES;}
"edges" {return TOK_EDGES;}
"true" {return TOK_TRUE;}
"false" {return TOK_FALSE;}

    /* complex tokens */
{string} {return TOK_STRING;}
[+]([ \t]|{eol})*["]{s_char_sequence}["] {yylvalreturn TOK_STRING_TAIL;}
{integer} {return TOK_INTEGER;}
{double} {return TOK_DOUBLE;}
    /*identifier*/
{non_digit}({digit}|{non_digit})* {return TOK_IDENTIFIER;}
[$]{s_char_sequence}[$] {return TOK_STRING_IDENTIFIER;}

    /* whitespace */
[ \t]+


<<EOF>> {return END_OF_FILE;}

. {lexerror = 1; return LEXICAL_ERROR;}

%%

int yywrap(){
    return 1;

}
