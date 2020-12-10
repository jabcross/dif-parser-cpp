/* Parser for DIF language

Grammar reference: http://dspcad.umd.edu/dif/difgrammar.html

*/


%{
#include <stdio.h>
#include "parser.h"
int yylex();

int yyerror(char *s);

int fileno(FILE *);

%}

%define api.value.type union

%token TOK_L_BKT
%token TOK_R_BKT
%token TOK_L_PAR
%token TOK_R_PAR
%token TOK_L_SQR
%token TOK_R_SQR
%token TOK_SEMICOLON
%token TOK_COLON
%token TOK_COMMA
%token TOK_S_QTE
%token TOK_PLUS
%token TOK_EQUAL
%token TOK_DOT
%token TOK_GRAPH
%token TOK_ATTRIBUTE
%token TOK_BASEDON
%token TOK_INTERFACE
%token TOK_PARAMETER
%token TOK_REFINEMENT
%token TOK_TOPOLOGY
%token TOK_ACTOR
%token TOK_INPUTS
%token TOK_OUTPUTS
%token TOK_NODES
%token TOK_EDGES
%token TOK_TRUE
%token TOK_FALSE
%token <std::string> TOK_STRING
%token <std::string> TOK_STRING_TAIL
%token TOK_INTEGER
%token TOK_DOUBLE
%token <std::string> TOK_IDENTIFIER
%token <std::string> TOK_STRING_IDENTIFIER


%%

graph_list
    : %empty
    | graph_list graph_block
    ;

graph_block
    : TOK_IDENTIFIER {start_graph(); set_graph_type($1);} name {set_graph_name(yytext);} TOK_L_BKT block_star TOK_R_BKT {end_graph();}
    ;

block_star
    : %empty
    | block_star block
    ;

block
    : TOK_BASEDON basedon_body {current_graph->set_basedon(yytext);}
    | TOK_TOPOLOGY topology_body
    | TOK_INTERFACE interface_body
    | TOK_PARAMETER parameter_body
    | TOK_REFINEMENT refinement_body
    | TOK_IDENTIFIER attribute_body
    | TOK_ATTRIBUTE name attribute_body
    | TOK_ACTOR name actor_body
    ;

name
    : TOK_IDENTIFIER
    | TOK_STRING_IDENTIFIER
    ;

basedon_body
    : TOK_L_BKT basedon_expression TOK_R_BKT
    ;

basedon_expression
    : name TOK_SEMICOLON
    ;

topology_body
    : TOK_L_BKT topology_list_star TOK_R_BKT
    ;

topology_list_star
    : %empty
    | topology_list_star topology_list
    ;

topology_list
    : TOK_NODES TOK_EQUAL name {add_topology_node(yytext);}node_identifier_tail_star TOK_SEMICOLON
    | TOK_EDGES TOK_EQUAL edge_definition edge_definition_tail_star TOK_SEMICOLON
    ;

node_identifier_tail_star
    : %empty
    | node_identifier_tail_star node_identifier_tail
    ;

node_identifier_tail
    : TOK_COMMA name {add_topology_node(yytext);}
    ;

edge_definition
    : name TOK_L_PAR name TOK_COMMA name TOK_R_PAR
    ;

edge_definition_tail_star
    : %empty
    | edge_definition_tail_star edge_definition_tail
    ;

edge_definition_tail
    : TOK_COMMA edge_definition
    ;

interface_body
    : TOK_L_BKT interface_expression_star TOK_R_BKT
    ;

interface_expression_star
    : %empty
    | interface_expression_star interface_expression
    ;

interface_expression
    : TOK_INPUTS TOK_EQUAL port_definition port_definition_tail_star TOK_SEMICOLON
    | TOK_OUTPUTS TOK_EQUAL port_definition port_definition_tail_star TOK_SEMICOLON
    ;

port_definition_tail_star
    : %empty
    | port_definition_tail_star port_definition_tail
    ;


port_definition
    : name
    | name TOK_COLON name
    ;

port_definition_tail
    : TOK_COMMA port_definition
    ;

parameter_body
    :TOK_L_BKT parameter_expression_star TOK_R_BKT
    ;

parameter_expression_star
    : %empty
    | parameter_expression_star parameter_expression
    ;

parameter_expression
    : name param_type_opt TOK_EQUAL value TOK_SEMICOLON
    | name param_type_opt TOK_COLON range_block TOK_SEMICOLON
    | name param_type_opt TOK_SEMICOLON
    ;

param_type_opt
    : %empty
    | param_type
    ;

range_block
    :range range_tail_star
    ;

range_tail_star
    : %empty
    | range_tail
    ;

range
    : TOK_L_SQR number TOK_COMMA number TOK_R_SQR
    | TOK_L_PAR number TOK_COMMA number TOK_R_SQR
    | TOK_L_SQR number TOK_COMMA number TOK_R_PAR
    | TOK_L_PAR number TOK_COMMA number TOK_R_PAR
    | TOK_L_BKT number discrete_range_number_tail_star TOK_R_BKT
    ;

discrete_range_number_tail_star
    : %empty
    | discrete_range_number_tail_star discrete_range_number_tail
    ;

discrete_range_number_tail
    :TOK_COMMA number
    ;

range_tail
    : TOK_PLUS range
    ;

number
    : TOK_DOUBLE
    | TOK_INTEGER
    ;

param_type
    :TOK_COLON TOK_STRING
    ;

refinement_body
    :TOK_L_BKT refinement_definition refinement_expression_star TOK_R_BKT
    ;

refinement_expression_star
    : %empty
    | refinement_expression_star refinement_expression
    ;

refinement_definition
    :name TOK_EQUAL name TOK_SEMICOLON
    ;

refinement_expression
    : name TOK_COLON name TOK_SEMICOLON
    | name TOK_EQUAL name TOK_SEMICOLON
    ;

attribute_body
    :TOK_L_BKT attribute_expression_star TOK_R_BKT
    ;

attribute_expression_star
    : %empty
    | attribute_expression_star attribute_expression
    ;

attribute_expression
    : name_opt TOK_EQUAL value TOK_SEMICOLON
    | name_opt TOK_EQUAL name TOK_SEMICOLON
    | name TOK_DOT name TOK_EQUAL name TOK_DOT name TOK_SEMICOLON
    | name_opt TOK_EQUAL id_list TOK_SEMICOLON
    ;

name_opt
    : %empty
    | name
    ;

id_list
    : name ref_id_tail_plus
    ;

ref_id_tail_plus
    : ref_id_tail
    | ref_id_tail_plus ref_id_tail
    ;

ref_id_tail
    :TOK_COMMA name
    ;

actor_body
    :TOK_L_BKT actor_expression_star TOK_R_BKT
    ;

actor_expression_star
    : %empty
    | actor_expression_star actor_expression
    ;

actor_expression
    : name type_opt TOK_EQUAL value TOK_SEMICOLON
    | name type_opt TOK_EQUAL name TOK_SEMICOLON
    | name type_opt TOK_EQUAL id_list TOK_SEMICOLON
    ;

type_opt
    : %empty
    | type
    ;

type
    : TOK_COLON TOK_IDENTIFIER
    | TOK_COLON TOK_COLON TOK_STRING
    | TOK_COLON TOK_IDENTIFIER TOK_COLON TOK_STRING
    ;

complex
    :TOK_L_PAR number TOK_COMMA number TOK_R_PAR
    ;

value
    : TOK_INTEGER
    | TOK_DOUBLE
    | complex
    | TOK_L_SQR numeric_row numeric_row_tail_star TOK_R_SQR
    | TOK_L_SQR complex_row complex_row_tail_star TOK_R_SQR
    | concatenated_string_value
    | boolean_value
    | TOK_L_BKT value value_tail_star TOK_R_BKT
    ;

numeric_row_tail_star
    : %empty
    | numeric_row_tail_star numeric_row_tail
    ;

complex_row_tail_star
    : %empty
    | complex_row_tail_star complex_row_tail
    ;

value_tail_star
    : %empty
    | value_tail_star value_tail
    ;

numeric_row
    :number numeric_tail_star
    ;

numeric_tail_star
    : %empty
    | numeric_tail_star numeric_tail
    ;

numeric_tail
    :TOK_COMMA number
    ;

numeric_row_tail
    :TOK_SEMICOLON numeric_row
    ;

complex_row
    :complex complex_tail_star
    ;

complex_tail_star
    : %empty
    | complex_tail_star complex_tail
    ;

complex_tail
    : TOK_COMMA complex
    ;

complex_row_tail
    : TOK_SEMICOLON complex_row
    ;

concatenated_string_value
    : TOK_STRING string_tail_star
    ;

string_tail_star
    : %empty
    | string_tail_star TOK_STRING_TAIL
    ;

boolean_value
    : TOK_TRUE
    | TOK_FALSE
    ;

value_tail
    :TOK_COMMA value
    ;

%%