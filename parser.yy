%skeleton "lalr1.cc"
%require "3.2"
%defines

%define api.token.constructor
%define api.value.type variant
%define parse.assert

%code requires 
{
    #include "constant.hh"
    #include "llvm/ADT/APFloat.h"
    #include "llvm/ADT/Optional.h"
    #include "llvm/ADT/STLExtras.h"
    #include "llvm/IR/BasicBlock.h"
    #include "llvm/IR/Constants.h"
    #include "llvm/IR/DerivedTypes.h"
    #include "llvm/IR/Function.h"
    #include "llvm/IR/Instructions.h"
    #include "llvm/IR/IRBuilder.h"
    #include "llvm/IR/LLVMContext.h"
    #include "llvm/IR/LegacyPassManager.h"
    #include "llvm/IR/Module.h"
    #include "llvm/IR/Type.h"
    #include "llvm/IR/Verifier.h"
    #include "llvm/Support/FileSystem.h"
    #include "llvm/Support/Host.h"
    #include "llvm/Support/raw_ostream.h"
    #include "llvm/Support/TargetRegistry.h"
    #include "llvm/Support/TargetSelect.h"
    #include "llvm/Target/TargetMachine.h"
    #include "llvm/Target/TargetOptions.h"
    #include "llvm/ADT/STLExtras.h"
    #include "llvm/Analysis/BasicAliasAnalysis.h"
    #include "llvm/Analysis/Passes.h"
    #include "llvm/IR/DIBuilder.h"
    #include "llvm/IR/IRBuilder.h"
    #include "llvm/IR/LLVMContext.h"
    #include "llvm/IR/LegacyPassManager.h"
    #include "llvm/IR/Module.h"
    #include "llvm/IR/Verifier.h"
    #include "llvm/Support/TargetSelect.h"
    #include "llvm/Transforms/Scalar.h"
    #include <algorithm>
    #include <cassert>
    #include <cctype>
    #include <cstdio>
    #include <cstdlib>
    #include <map>
    #include <memory>
    #include <string>
    #include <system_error>
    #include <utility>
    #include <vector>
    class driver;

    static llvm::LLVMContext TheContext;
    static llvm::IRBuilder<> Builder(TheContext);
    static std::unique_ptr<llvm::Module> TheModule;
    static std::map<std::string, llvm::AllocaInst *> NamedValues;
//    static std::map<std::string, std::unique_ptr<PrototypeAST>> FunctionProtos;


    llvm::Value *LogErrorV(const char *Str);
    static llvm::AllocaInst *CreateEntryBlockAlloca(llvm::Function *TheFunction, const std::string &VarName);

}

%param { driver& drv }

%locations

%define parse.trace
%define parse.error verbose
%code 
{
    #include "driver.hh"
}
%define api.token.prefix {TOK_}

%token <std::string>            IDENTIFIER              "identifier"
%token <std::string>            STRING_LITERAL          "string_literal"
%token                     SIZEOF                  "sizeof"
%token <I_Constant> I_CONSTANT
%token <F_Constant> F_CONSTANT
%token 
        SEMICOLON               ";"
        LEFT_CURLY_BRACE        "{"
        RIGHT_CURLY_BRACE       "}"
        COMMA                   ","
        COLON                   ":"
        EQ                      "="
        LEFT_PARENTHESIS        "("
        RIGHT_PARAENTHESIS      ")"
        LEFT_BRACKETS           "["
        RIGHT_BRACKETS          "]"
        DOT                     "."
        AND_BY_BIT              "&"
        NOT                     "!"
        REVERSE                 "~"
        MINUS                   "-"
        PLUS                    "+"
        STAR                    "*"
        DEVIDE                  "/"
        MODULO                  "%"
        LEFT_ANGLE_BRACKETS     "<"
        RIGHT_ANGLE_BRACKETS    ">"
        EXCLUSIVE_OR            "^"
        OR_BY_BIT               "|"
        QUESTION_MARK           "?"
        ELLIPSIS                "..."
        RIGHT_ASSIGN            ">>="
        LEFT_ASSIGN             "<<="
        ADD_ASSIGN              "+="
        SUB_ASSIGN              "-="
        MUL_ASSIGN              "*="
        DIV_ASSIGN              "/="
        MOD_ASSIGN              "%="
        AND_ASSIGN              "&="
        XOR_ASSIGN              "^="
        OR_ASSIGN               "|="
        RIGHT_OP                ">>"
        LEFT_OP                 "<<"
        INC_OP                  "++"
        DEC_OP                  "--"
        PTR_OP                  "->"
        AND_OP                  "&&"
        OR_OP                   "||"
        LE_OP                   "<="
        GE_OP                   ">="
        EQ_OP                   "=="
        NE_OP                   "!="
        ;

%token	FUNC_NAME 
%token	TYPEDEF_NAME ENUMERATION_CONSTANT

%token	TYPEDEF EXTERN STATIC AUTO REGISTER INLINE
%token	CONST RESTRICT VOLATILE
%token	BOOL CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE VOID
%token	COMPLEX IMAGINARY 
%token	STRUCT UNION ENUM 

%token	CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%token	ALIGNAS ALIGNOF ATOMIC GENERIC NORETURN STATIC_ASSERT THREAD_LOCAL

%token END  0 "end of file"

%type<llvm::Constant*> constant


//%type<std::string> Xexp
%start translation_unit
//%start unit
%%

/*unit
    : Xexp {drv.result = $1;}

Xexp
    : STRING_LITERAL {$$ = $1; std::cerr << "Int : " << $1 <<std::endl;}
    | Xexp PLUS Xexp {$$ = $1+$3; std::cerr << $$ << '=' << $1 <<'+' <<$3 <<std::endl;}
    ;
*/
primary_expression
	: IDENTIFIER
	| constant
	| string
	| '(' expression ')'
	| generic_selection
	;

constant
	: I_CONSTANT
    {
        if($1.type == I_Constant::Type::UINT)
            $$ = llvm::ConstantInt::get(llvm::Type::getInt32Ty(TheContext), llvm::APInt(32, $1.uiVal));
    }
	| F_CONSTANT
    {
        if($1.type == F_Constant::Type::FLOAT)
            $$ = llvm::ConstantFP::get(llvm::Type::getFloatTy(TheContext), llvm::APFloat($1.fVal));
    }
    ;
	/*| ENUMERATION_CONSTANT*/
	;

enumeration_constant		/* before it has been defined as such */
	: IDENTIFIER
	;

string
	: STRING_LITERAL
	| FUNC_NAME
	;

generic_selection
	: GENERIC '(' assignment_expression ',' generic_assoc_list ')'
	;

generic_assoc_list
	: generic_association
	| generic_assoc_list ',' generic_association
	;

generic_association
	: type_name ':' assignment_expression
	| DEFAULT ':' assignment_expression
	;

postfix_expression
	: primary_expression
	| postfix_expression '[' expression ']'
	| postfix_expression '(' ')'
	| postfix_expression '(' argument_expression_list ')'
	| postfix_expression '.' IDENTIFIER
	| postfix_expression PTR_OP IDENTIFIER
	| postfix_expression INC_OP
	| postfix_expression DEC_OP
	| '(' type_name ')' '{' initializer_list '}'
	| '(' type_name ')' '{' initializer_list ',' '}'
	;

argument_expression_list
	: assignment_expression
	| argument_expression_list ',' assignment_expression
	;

unary_expression
	: postfix_expression
	| INC_OP unary_expression
	| DEC_OP unary_expression
	| unary_operator cast_expression
	| SIZEOF unary_expression
	| SIZEOF '(' type_name ')'
	| ALIGNOF '(' type_name ')'
	;

unary_operator
	: '&'
	| '*'
	| '+'
	| '-'
	| '~'
	| '!'
	;

cast_expression
	: unary_expression
	| '(' type_name ')' cast_expression
	;

multiplicative_expression
	: cast_expression
	| multiplicative_expression '*' cast_expression
	| multiplicative_expression '/' cast_expression
	| multiplicative_expression '%' cast_expression
	;

additive_expression
	: multiplicative_expression
	| additive_expression '+' multiplicative_expression
	| additive_expression '-' multiplicative_expression
	;

shift_expression
	: additive_expression
	| shift_expression LEFT_OP additive_expression
	| shift_expression RIGHT_OP additive_expression
	;

relational_expression
	: shift_expression
	| relational_expression '<' shift_expression
	| relational_expression '>' shift_expression
	| relational_expression LE_OP shift_expression
	| relational_expression GE_OP shift_expression
	;

equality_expression
	: relational_expression
	| equality_expression EQ_OP relational_expression
	| equality_expression NE_OP relational_expression
	;

and_expression
	: equality_expression
	| and_expression '&' equality_expression
	;

exclusive_or_expression
	: and_expression
	| exclusive_or_expression '^' and_expression
	;

inclusive_or_expression
	: exclusive_or_expression
	| inclusive_or_expression '|' exclusive_or_expression
	;

logical_and_expression
	: inclusive_or_expression
	| logical_and_expression AND_OP inclusive_or_expression
	;

logical_or_expression
	: logical_and_expression
	| logical_or_expression OR_OP logical_and_expression
	;

conditional_expression
	: logical_or_expression
	| logical_or_expression '?' expression ':' conditional_expression
	;

assignment_expression
	: conditional_expression
	| unary_expression assignment_operator assignment_expression
	;

assignment_operator
	: '='
	| MUL_ASSIGN
	| DIV_ASSIGN
	| MOD_ASSIGN
	| ADD_ASSIGN
	| SUB_ASSIGN
	| LEFT_ASSIGN
	| RIGHT_ASSIGN
	| AND_ASSIGN
	| XOR_ASSIGN
	| OR_ASSIGN
	;

expression
	: assignment_expression
	| expression ',' assignment_expression
	;

constant_expression
	: conditional_expression	/* with constraints */
	;

declaration
	: declaration_specifiers ';'
	| declaration_specifiers init_declarator_list ';'
	| static_assert_declaration
	;

declaration_specifiers
	: storage_class_specifier declaration_specifiers
	| storage_class_specifier
	| type_specifier declaration_specifiers
	| type_specifier
	| type_qualifier declaration_specifiers
	| type_qualifier
	| function_specifier declaration_specifiers
	| function_specifier
	| alignment_specifier declaration_specifiers
	| alignment_specifier
	;

init_declarator_list
	: init_declarator
	| init_declarator_list ',' init_declarator
	;

init_declarator
	: declarator '=' initializer
	| declarator
	;

storage_class_specifier
	: TYPEDEF	/* identifiers must be flagged as TYPEDEF_NAME */
	| EXTERN
	| STATIC
	| THREAD_LOCAL
	| AUTO
	| REGISTER
	;

type_specifier
	: VOID
	| CHAR
	| SHORT
	| INT
	| LONG
	| FLOAT
	| DOUBLE
	| SIGNED
	| UNSIGNED
	| BOOL
	| COMPLEX
	| IMAGINARY	  	/* non-mandated extension */
	| atomic_type_specifier
	| struct_or_union_specifier
	| enum_specifier
	| TYPEDEF_NAME		/* after it has been defined as such */
	;

struct_or_union_specifier
	: struct_or_union '{' struct_declaration_list '}'
	| struct_or_union IDENTIFIER '{' struct_declaration_list '}'
	| struct_or_union IDENTIFIER
	;

struct_or_union
	: STRUCT
	| UNION
	;

struct_declaration_list
	: struct_declaration
	| struct_declaration_list struct_declaration
	;

struct_declaration
	: specifier_qualifier_list ';'	/* for anonymous struct/union */
	| specifier_qualifier_list struct_declarator_list ';'
	| static_assert_declaration
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list
	| type_specifier
	| type_qualifier specifier_qualifier_list
	| type_qualifier
	;

struct_declarator_list
	: struct_declarator
	| struct_declarator_list ',' struct_declarator
	;

struct_declarator
	: ':' constant_expression
	| declarator ':' constant_expression
	| declarator
	;

enum_specifier
	: ENUM '{' enumerator_list '}'
	| ENUM '{' enumerator_list ',' '}'
	| ENUM IDENTIFIER '{' enumerator_list '}'
	| ENUM IDENTIFIER '{' enumerator_list ',' '}'
	| ENUM IDENTIFIER
	;

enumerator_list
	: enumerator
	| enumerator_list ',' enumerator
	;

enumerator	/* identifiers must be flagged as ENUMERATION_CONSTANT */
	: enumeration_constant '=' constant_expression
	| enumeration_constant
	;

atomic_type_specifier
	: ATOMIC '(' type_name ')'
	;

type_qualifier
	: CONST
	| RESTRICT
	| VOLATILE
	| ATOMIC
	;

function_specifier
	: INLINE
	| NORETURN
	;

alignment_specifier
	: ALIGNAS '(' type_name ')'
	| ALIGNAS '(' constant_expression ')'
	;

declarator
	: pointer direct_declarator
	| direct_declarator
	;

direct_declarator
	: IDENTIFIER
	| '(' declarator ')'
	| direct_declarator '[' ']'
	| direct_declarator '[' '*' ']'
	| direct_declarator '[' STATIC type_qualifier_list assignment_expression ']'
	| direct_declarator '[' STATIC assignment_expression ']'
	| direct_declarator '[' type_qualifier_list '*' ']'
	| direct_declarator '[' type_qualifier_list STATIC assignment_expression ']'
	| direct_declarator '[' type_qualifier_list assignment_expression ']'
	| direct_declarator '[' type_qualifier_list ']'
	| direct_declarator '[' assignment_expression ']'
	| direct_declarator '(' parameter_type_list ')'
	| direct_declarator '(' ')'
	| direct_declarator '(' identifier_list ')'
	;

pointer
	: '*' type_qualifier_list pointer
	| '*' type_qualifier_list
	| '*' pointer
	| '*'
	;

type_qualifier_list
	: type_qualifier
	| type_qualifier_list type_qualifier
	;


parameter_type_list
	: parameter_list ',' ELLIPSIS
	| parameter_list
	;

parameter_list
	: parameter_declaration
	| parameter_list ',' parameter_declaration
	;

parameter_declaration
	: declaration_specifiers declarator
	| declaration_specifiers abstract_declarator
	| declaration_specifiers
	;

identifier_list
	: IDENTIFIER
	| identifier_list ',' IDENTIFIER
	;

type_name
	: specifier_qualifier_list abstract_declarator
	| specifier_qualifier_list
	;

abstract_declarator
	: pointer direct_abstract_declarator
	| pointer
	| direct_abstract_declarator
	;

direct_abstract_declarator
	: '(' abstract_declarator ')'
	| '[' ']'
	| '[' '*' ']'
	| '[' STATIC type_qualifier_list assignment_expression ']'
	| '[' STATIC assignment_expression ']'
	| '[' type_qualifier_list STATIC assignment_expression ']'
	| '[' type_qualifier_list assignment_expression ']'
	| '[' type_qualifier_list ']'
	| '[' assignment_expression ']'
	| direct_abstract_declarator '[' ']'
	| direct_abstract_declarator '[' '*' ']'
	| direct_abstract_declarator '[' STATIC type_qualifier_list assignment_expression ']'
	| direct_abstract_declarator '[' STATIC assignment_expression ']'
	| direct_abstract_declarator '[' type_qualifier_list assignment_expression ']'
	| direct_abstract_declarator '[' type_qualifier_list STATIC assignment_expression ']'
	| direct_abstract_declarator '[' type_qualifier_list ']'
	| direct_abstract_declarator '[' assignment_expression ']'
	| '(' ')'
	| '(' parameter_type_list ')'
	| direct_abstract_declarator '(' ')'
	| direct_abstract_declarator '(' parameter_type_list ')'
	;

initializer
	: '{' initializer_list '}'
	| '{' initializer_list ',' '}'
	| assignment_expression
	;

initializer_list
	: designation initializer
	| initializer
	| initializer_list ',' designation initializer
	| initializer_list ',' initializer
	;

designation
	: designator_list '='
	;

designator_list
	: designator
	| designator_list designator
	;

designator
	: '[' constant_expression ']'
	| '.' IDENTIFIER
	;

static_assert_declaration
	: STATIC_ASSERT '(' constant_expression ',' STRING_LITERAL ')' ';'
	;

statement
	: labeled_statement
	| compound_statement
	| expression_statement
	| selection_statement
	| iteration_statement
	| jump_statement
	;

labeled_statement
	: IDENTIFIER ':' statement
	| CASE constant_expression ':' statement
	| DEFAULT ':' statement
	;

compound_statement
	: '{' '}'
	| '{'  block_item_list '}'
	;

block_item_list
	: block_item
	| block_item_list block_item
	;

block_item
	: declaration
	| statement
	;

expression_statement
	: ';'
	| expression ';'
	;

selection_statement
	: IF '(' expression ')' statement ELSE statement
	| IF '(' expression ')' statement
	| SWITCH '(' expression ')' statement
	;

iteration_statement
	: WHILE '(' expression ')' statement
	| DO statement WHILE '(' expression ')' ';'
	| FOR '(' expression_statement expression_statement ')' statement
	| FOR '(' expression_statement expression_statement expression ')' statement
	| FOR '(' declaration expression_statement ')' statement
	| FOR '(' declaration expression_statement expression ')' statement
	;

jump_statement
	: GOTO IDENTIFIER ';'
	| CONTINUE ';'
	| BREAK ';'
	| RETURN ';'
	| RETURN expression ';'
	;

translation_unit
	: external_declaration
	| translation_unit external_declaration
	;

external_declaration
	: function_definition
	| declaration
	;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement
	| declaration_specifiers declarator compound_statement
	;

declaration_list
	: declaration
	| declaration_list declaration
	;

%%
#include <stdio.h>

void yyerror(const char *s)
{
	fflush(stdout);
	fprintf(stderr, "*** %s\n", s);
}

void yy::parser::error (const location_type& l, const std::string& m)
{
   std::cerr << l << ": " << m << '\n';
}

static llvm::AllocaInst *CreateEntryBlockAlloca(llvm::Function *TheFunction, const std::string &VarName) 
{
  llvm::IRBuilder<> TmpB(&TheFunction->getEntryBlock(), TheFunction->getEntryBlock().begin());
  return TmpB.CreateAlloca(llvm::Type::getDoubleTy(TheContext), 0, VarName.c_str());
}

llvm::Value *LogErrorV(const char *Str) 
{
  yyerror(Str);
  return nullptr;
}


