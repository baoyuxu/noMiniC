%{
# include <cerrno>
# include <climits>
# include <cstdlib>
# include <string>
# include "constant.hh"
# include "driver.hh"
# include "parser.hh"
extern void yyerror(const char *);  /* prints grammar violation message */
extern int sym_type(const char *);  /* returns type from symbol table */
#define sym_type(identifier) IDENTIFIER /* with no symbol table, fake it */
static void comment(void);
static yy::parser::symbol_type check_type(const yy::parser::location_type &loc );
static yy::parser::symbol_type checkIConstant( const yy::parser::location_type &loc );
# define YY_USER_ACTION  loc.columns (yyleng);
%}

%option nounput noinput batch debug

%e  1019
%p  2807
%n  371
%k  284
%a  1213
%o  1117

O   [0-7]
D   [0-9]
NZ  [1-9]
L   [a-zA-Z_]
A   [a-zA-Z_0-9]
H   [a-fA-F0-9]
HP  (0[xX])
E   ([Ee][+-]?{D}+)
P   ([Pp][+-]?{D}+)
FS  (f|F|l|L)
IS  (((u|U)(l|L|ll|LL)?)|((l|L|ll|LL)(u|U)?))
CP  (u|U|L)
SP  (u8|u|U|L)
ES  (\\(['"\?\\abfnrtv]|[0-7]{1,3}|x[a-fA-F0-9]+))
WS  [ \t\v\n\f]

%%

%{
  // A handy shortcut to the location held by the driver.
  yy::location& loc = drv.location;
  // Code run each time yylex is called.
  loc.step ();
%}
"/*"                                    { comment(); }
"//".*                                    { /* consume //-comment */ }

"auto"					{ return yy::parser::make_AUTO(loc); }
"break"					{ return yy::parser::make_BREAK(loc); }
"case"					{ return yy::parser::make_CASE(loc); }
"char"					{ return yy::parser::make_CHAR(loc); }
"const"					{ return yy::parser::make_CONST(loc); }
"continue"				{ return yy::parser::make_CONTINUE(loc); }
"default"				{ return yy::parser::make_DEFAULT(loc);}
"do"					{ return yy::parser::make_DO(loc); }
"double"				{ return yy::parser::make_DOUBLE(loc); }
"else"					{ return yy::parser::make_ELSE(loc); }
"enum"					{ return yy::parser::make_ENUM(loc); }
"extern"				{ return yy::parser::make_EXTERN(loc); }
"float"					{ return yy::parser::make_FLOAT(loc); }
"for"					{ return yy::parser::make_FOR(loc); }
"goto"					{ return yy::parser::make_GOTO(loc); }
"if"					{ return yy::parser::make_IF(loc); }
"inline"				{ return yy::parser::make_INLINE(loc); }
"int"					{ return yy::parser::make_INT(loc); }
"long"					{ return yy::parser::make_LONG(loc); }
"register"				{ return yy::parser::make_REGISTER(loc); }
"restrict"				{ return yy::parser::make_RESTRICT(loc); }
"return"				{ return yy::parser::make_RETURN(loc); }
"short"					{ return yy::parser::make_SHORT(loc); }
"signed"				{ return yy::parser::make_SIGNED(loc); }
"sizeof"				{ return yy::parser::make_SIZEOF(loc); }
"static"				{ return yy::parser::make_STATIC(loc); }
"struct"				{ return yy::parser::make_STRUCT(loc); }
"switch"				{ return yy::parser::make_SWITCH(loc); }
"typedef"				{ return yy::parser::make_TYPEDEF(loc); }
"union"					{ return yy::parser::make_UNION(loc); }
"unsigned"				{ return yy::parser::make_UNSIGNED(loc); }
"void"					{ return yy::parser::make_VOID(loc); }
"volatile"				{ return yy::parser::make_VOLATILE(loc); }
"while"					{ return yy::parser::make_WHILE(loc); }
"_Alignas"                              { return  yy::parser::make_ALIGNAS(loc); }
"_Alignof"                              { return  yy::parser::make_ALIGNOF(loc); }
"_Atomic"                               { return  yy::parser::make_ATOMIC(loc); }
"_Bool"                                 { return  yy::parser::make_BOOL(loc); }
"_Complex"                              { return  yy::parser::make_COMPLEX(loc); }
"_Generic"                              { return  yy::parser::make_GENERIC(loc); }
"_Imaginary"                            { return  yy::parser::make_IMAGINARY(loc); }
"_Noreturn"                             { return  yy::parser::make_NORETURN(loc); }
"_Static_assert"                        { return  yy::parser::make_STATIC_ASSERT(loc); }
"_Thread_local"                         { return  yy::parser::make_THREAD_LOCAL(loc); }
"__func__"                              { return  yy::parser::make_FUNC_NAME(loc); }

{L}{A}*					{ return check_type(loc); }

{HP}{H}+{IS}?   { /*return  yy::parser::make_ICONSTANT( atio(yytext),ICONSTANT::iType(), loc);*/ return checkIConstant(loc); }
{NZ}{D}*{IS}?				{ /*return  yy::parser::make_ICONSTANT(loc);*/ return checkIConstant(loc); }
"0"{O}*{IS}?				{ /*return  yy::parser::make_ICONSTANT(loc);*/ return checkIConstant(loc); }

{CP}?"'"([^'\\\n]|{ES})+"'"		{ /*return  yy::parser::make_ICONSTANT(loc);*/ return checkIConstant(loc); }

{D}+{E}{FS}?				{ return  yy::parser::make_F_CONSTANT(loc); }
{D}*"."{D}+{E}?{FS}?			{ return  yy::parser::make_F_CONSTANT(loc); }
{D}+"."{E}?{FS}?			{ return  yy::parser::make_F_CONSTANT(loc); }
{HP}{H}+{P}{FS}?			{ return  yy::parser::make_F_CONSTANT(loc); }
{HP}{H}*"."{H}+{P}{FS}?			{ return  yy::parser::make_F_CONSTANT(loc); }
{HP}{H}+"."{P}{FS}?			{ return  yy::parser::make_F_CONSTANT(loc); }

({SP}?\"([^"\\\n]|{ES})*\"{WS}*)+	{ return  yy::parser::make_STRING_LITERAL( yytext,loc); }

"..."					{ return yy::parser::make_ELLIPSIS(loc); }
">>="					{ return yy::parser::make_RIGHT_ASSIGN(loc); }
"<<="					{ return yy::parser::make_LEFT_ASSIGN(loc); }
"+="					{ return yy::parser::make_ADD_ASSIGN(loc); }
"-="					{ return yy::parser::make_SUB_ASSIGN(loc); }
"*="					{ return yy::parser::make_MUL_ASSIGN(loc); }
"/="					{ return yy::parser::make_DIV_ASSIGN(loc); }
"%="					{ return yy::parser::make_MOD_ASSIGN(loc); }
"&="					{ return yy::parser::make_AND_ASSIGN(loc); }
"^="					{ return yy::parser::make_XOR_ASSIGN(loc); }
"|="					{ return yy::parser::make_OR_ASSIGN(loc); }
">>"					{ return yy::parser::make_RIGHT_OP(loc); }
"<<"					{ return yy::parser::make_LEFT_OP(loc); }
"++"					{ return yy::parser::make_INC_OP(loc); }
"--"					{ return yy::parser::make_DEC_OP(loc); }
"->"					{ return yy::parser::make_PTR_OP(loc); }
"&&"					{ return yy::parser::make_AND_OP(loc); }
"||"					{ return yy::parser::make_OR_OP(loc); }
"<="					{ return yy::parser::make_LE_OP(loc); }
">="					{ return yy::parser::make_GE_OP(loc); }
"=="					{ return yy::parser::make_EQ_OP(loc); }
"!="					{ return yy::parser::make_NE_OP(loc); }
";"					{ }
("{"|"<%")				{ }
("}"|"%>")				{ }
","					{ }
":"					{ }
"="					{ }
"("					{ }
")"					{ }
("["|"<:")				{ }
("]"|":>")				{ }
"."					{ }
"&"					{ }
"!"					{ }
"~"					{ }
"-"					{ }
"+"					{ }
"*"					{ }
"/"					{ }
"%"					{ }
"<"					{ }
">"					{ }
"^"					{ }
"|"					{ }
"?"					{ }

{WS}+					{ /* whitespace separates tokens */ }
.					{ /* discard bad characters */ }
<<EOF>>    return yy::parser::make_END (loc);
%%

int yywrap(void)        /* called at end of input */
{
    return 1;           /* terminate now */
}

static void comment(void)
{
    /*int c;

    while ((c = input()) != 0)
        if (c == '*')
        {
            while ((c = input()) == '*')
                ;

            if (c == '/')
                return;

            if (c == 0)
                break;
        }
    yyerror("unterminated comment");
    */
}

static yy::parser::symbol_type check_type(const yy::parser::location_type &loc )
{
    /*switch (sym_type(yytext))
    {
    case TYPEDEF_NAME:                
        return TYPEDEF_NAME;
    case ENUMERATION_CONSTANT:        
        return ENUMERATION_CONSTANT;
    default:                          
        return IDENTIFIER;
    }*/
    return yy::parser::make_IDENTIFIER(yytext, loc);
}

void driver::scan_begin ()
{
  yy_flex_debug = trace_scanning;
  if (file.empty () || file == "-")
    yyin = stdin;
  else if (!(yyin = fopen (file.c_str (), "r")))
    {
      std::cerr << "cannot open " << file << ": " << strerror(errno) << '\n';
      exit (EXIT_FAILURE);
    }
}

void driver::scan_end ()
{
  fclose (yyin);
}

static yy::parser::symbol_type checkIConstant( const yy::parser::location_type &loc )
{
    return yy::parser::make_ICONSTANT( IConstant(atoi(yytext), IConstant::iType()),loc);
}

