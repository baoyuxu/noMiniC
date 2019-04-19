%skeleton "lalr1.cc"
%require "3.2"
%defines

%define api.token.constructor
%define api.value.type variant
%define parse.assert

%code requires 
{
    #include "common.hh"

    class driver;

    static llvm::LLVMContext TheContext;
    static llvm::IRBuilder<> Builder(TheContext);
    static std::unique_ptr<llvm::Module> TheModule;
    static std::map<std::string, llvm::AllocaInst *> NamedValues;
//    static std::map<std::string, std::unique_ptr<PrototypeAST>> FunctionProtos;
    static void InitializeModuleAndPassManager();
    llvm::Value *LogErrorV(const char *Str);
    static llvm::AllocaInst *CreateEntryBlockAlloca(llvm::Function *TheFunction, const std::string &VarName);

    void start_parser();
    void end_parser();

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

%type<llvm::Constant *> constant
%type<PrimaryExpression> primary_expression
%type<PostfixExpression> postfix_expression
%type<UnaryExpression> unary_expression
%type<CastExpression> cast_expression
%type<char> unary_operator
%type<MultiplicativeExpression> multiplicative_expression
%type<AdditiveExpression> additive_expression
%type<ShiftExpression> shift_expression
%type<RelationalExpression> relational_expression
%type<EqualityExpression> equality_expression
%type<AndExpression> and_expression
%type<ExclusiveOrExpression> exclusive_or_expression
%type<InclusiveOrExpression> inclusive_or_expression
%type<LogicalAndExpression> logical_and_expression
%type<LogicalOrExpression> logical_or_expression
%type<ConditionalExpression> conditional_expression
%type<AssignmentExpression> assignment_expression
%type<AssignmentOperator> assignment_operator
%type<Expression> expression

//%type<llvm::Value *> string

%start translation_unit

//%type<llvm::APInt> Xexp
//%start unit
%%

/*unit
    : Xexp 
    {
        llvm::Function *f = llvm::Function::Create(
            llvm::FunctionType::get(llvm::Type::getVoidTy(TheContext), std::vector<llvm::Type*>(), false),
            llvm::Function::ExternalLinkage,
            "test",
            TheModule.get()
            );
        llvm::BasicBlock *BB = llvm::BasicBlock::Create(TheContext, "entry", f);
        Builder.SetInsertPoint(BB);
        Builder.CreateRetVoid();
        llvm::verifyFunction(*f);
    }

Xexp
    : unary_expression
    { 
        if($1.type == UnaryExpression::Type::RVALUE) 
        {
            llvm::raw_os_ostream os(std::cout);
            $1.rval->print(os);
            os<<"\n";
        }
        else if($1.type == UnaryExpression::Type::IDENTIFIER )
            std::cerr<<"IDENTIFIER: "<<$1.IDENTIFIERVal<<std::endl;
    }
    | Xexp PLUS Xexp 
    ;*/


primary_expression
	: IDENTIFIER{$$.type = PrimaryExpression::Type::IDENTIFIER; $$.IDENTIFIERVal = $1;}
	| constant {$$.type = PrimaryExpression::Type::RVALUE; $$.rval = $1;}
	| "(" expression ")" 
    {
        $$.type = PrimaryExpression::Type::RVALUE; 
        if($2.type == Expression::Type::IDENTIFIER) 
            $$.rval = Builder.CreateLoad(NamedValues[$2.IDENTIFIERVal], $2.IDENTIFIERVal.c_str()); 
        else if($2.type == Expression::Type::RVALUE) 
            $$.rval = $2.rval; 
    }
    ;
	/*| generic_selection
	| string
	;*/

constant
	: I_CONSTANT
    {
        if( $1.type == I_Constant::Type::INT )
            $$ = llvm::ConstantInt::get(llvm::Type::getInt32Ty(TheContext), llvm::APInt(32, $1.iVal, true));
        else if( $1.type == I_Constant::Type::UINT )
            $$ = llvm::ConstantInt::get(llvm::Type::getInt32Ty(TheContext), llvm::APInt(32, $1.uiVal, false));
        else if( $1.type == I_Constant::Type::LONG )
            $$ = llvm::ConstantInt::get(llvm::Type::getInt64Ty(TheContext), llvm::APInt(64, $1.lVal, true));
        else if( $1.type == I_Constant::Type::ULONG )
            $$ = llvm::ConstantInt::get(llvm::Type::getInt64Ty(TheContext), llvm::APInt(64, $1.ulVal, false));
        else if( $1.type == I_Constant::Type::LONGLONG )
            $$ = llvm::ConstantInt::get(llvm::Type::getInt64Ty(TheContext), llvm::APInt(64, $1.llVal, true));
        else if( $1.type == I_Constant::Type::ULONGLONG )
            $$ = llvm::ConstantInt::get(llvm::Type::getInt64Ty(TheContext), llvm::APInt(64, $1.ullVal, false));
    }
	| F_CONSTANT
    {
        if($1.type == F_Constant::Type::FLOAT)
            $$ = llvm::ConstantFP::get(llvm::Type::getFloatTy(TheContext), llvm::APFloat($1.fVal));
        else if($1.type == F_Constant::Type::DOUBLE)
            $$ = llvm::ConstantFP::get(llvm::Type::getDoubleTy(TheContext), llvm::APFloat($1.dVal));
        //TODO: long double type
    }
    ;
	/*| ENUMERATION_CONSTANT*/
	;

enumeration_constant		/* before it has been defined as such */
	: IDENTIFIER
	;


/*
string
	: STRING_LITERAL
    | FUNC_NAME
	;

generic_selection
	: GENERIC "(" assignment_expression "," generic_assoc_list ")"
	;

generic_assoc_list
	: generic_association
	| generic_assoc_list "," generic_association
	;

generic_association
	: type_name ":" assignment_expression
	| DEFAULT ":" assignment_expression
	;
*/

postfix_expression
	: primary_expression 
    {
        $$ = static_cast<PostfixExpression>($1);
    }
	| postfix_expression "(" ")"                                                //TODO: finish. This and the next grammer are Funtion Call.
	| postfix_expression "(" argument_expression_list ")"
	| postfix_expression INC_OP
    {
        if($1.type == PostfixExpression::Type::IDENTIFIER)
            if(NamedValues.find($1.IDENTIFIERVal) != NamedValues.end())
            {
                llvm::Value *var = Builder.CreateLoad(NamedValues[$1.IDENTIFIERVal], $1.IDENTIFIERVal.c_str());
                llvm::Value *ans = nullptr;
                if( var->getType()->isIntegerTy() )
                    ans = Builder.CreateAdd(var, llvm::ConstantInt::get(llvm::Type::getInt32Ty(TheContext), llvm::APInt(32, 1, true)));
                else if( var->getType()->isDoubleTy() )
                    ans = Builder.CreateFAdd(var, llvm::ConstantFP::get(llvm::Type::getDoubleTy(TheContext), llvm::APFloat(1.0)));
                $$.type = PostfixExpression::Type::RVALUE;
                $$.rval = var;
                Builder.CreateStore(ans, NamedValues[$1.IDENTIFIERVal]);
            }
    }
	| postfix_expression DEC_OP
    {
        if($1.type == PostfixExpression::Type::IDENTIFIER)
            if(NamedValues.find($1.IDENTIFIERVal) != NamedValues.end())
            {
                llvm::Value *var = Builder.CreateLoad(NamedValues[$1.IDENTIFIERVal], $1.IDENTIFIERVal.c_str());
                llvm::Value *ans = nullptr;
                if( var->getType()->isIntegerTy() )
                    ans = Builder.CreateSub(var, llvm::ConstantInt::get(llvm::Type::getInt32Ty(TheContext), llvm::APInt(32, 1, true)));
                else if( var->getType()->isDoubleTy() )
                    ans = Builder.CreateFSub(var, llvm::ConstantFP::get(llvm::Type::getDoubleTy(TheContext), llvm::APFloat(1.0)));
                $$.type = PostfixExpression::Type::RVALUE;
                $$.rval = var;
                Builder.CreateStore(ans, NamedValues[$1.IDENTIFIERVal]);
            }
    }
    ;
	/*| postfix_expression "[" expression "]"
	| postfix_expression "." IDENTIFIER
	| postfix_expression PTR_OP IDENTIFIER
	| "(" type_name ")" "{" initializer_list "}"
	| "(" type_name ")" "{" initializer_list "," "}"
	;*/

argument_expression_list
	: assignment_expression
	| argument_expression_list "," assignment_expression
	;

unary_expression
	: postfix_expression
    {
        $$ = static_cast<UnaryExpression>($1); 
    }
	| INC_OP unary_expression
    {
        if($2.type == UnaryExpression::Type::IDENTIFIER)
            if(NamedValues.find($2.IDENTIFIERVal) != NamedValues.end())
            {
                llvm::Value *var = Builder.CreateLoad(NamedValues[$2.IDENTIFIERVal], $2.IDENTIFIERVal.c_str());
                llvm::Value *ans = nullptr;
                if( var->getType()->isIntegerTy() )
                    ans = Builder.CreateAdd(var, llvm::ConstantInt::get(llvm::Type::getInt32Ty(TheContext), llvm::APInt(32, 1, true)));
                else if( var->getType()->isDoubleTy() )
                    ans = Builder.CreateFAdd(var, llvm::ConstantFP::get(llvm::Type::getDoubleTy(TheContext), llvm::APFloat(1.0)));
                $$.type = UnaryExpression::Type::IDENTIFIER;
                $$.rval = Builder.CreateStore(ans, NamedValues[$2.IDENTIFIERVal]);
                
            }
    }
	| DEC_OP unary_expression
    {
        if($2.type == UnaryExpression::Type::IDENTIFIER)
            if(NamedValues.find($2.IDENTIFIERVal) != NamedValues.end())
            {
                llvm::Value *var = Builder.CreateLoad(NamedValues[$2.IDENTIFIERVal], $2.IDENTIFIERVal.c_str());
                llvm::Value *ans = nullptr;
                if( var->getType()->isIntegerTy() )
                    ans = Builder.CreateSub(var, llvm::ConstantInt::get(llvm::Type::getInt32Ty(TheContext), llvm::APInt(32, 1, true)));
                else if( var->getType()->isDoubleTy() )
                    ans = Builder.CreateFSub(var, llvm::ConstantFP::get(llvm::Type::getDoubleTy(TheContext), llvm::APFloat(1.0)));
                $$.type = UnaryExpression::Type::IDENTIFIER;
                $$.rval = Builder.CreateStore(ans, NamedValues[$2.IDENTIFIERVal]);
                
            }
    }
	| unary_operator cast_expression
    {
        llvm::Value *var;
        if($2.type == CastExpression::Type::IDENTIFIER)
            var = Builder.CreateLoad(NamedValues[$2.IDENTIFIERVal], $2.IDENTIFIERVal.c_str());
        else if($2.type == CastExpression::Type::RVALUE)
            var = $2.rval;
        $$.type = UnaryExpression::Type::RVALUE;

        switch($1)
        {
            case '-': // in LLVM Neg means SUB and Not means XOR
                if(var->getType()->isIntegerTy())
                    $$.rval = Builder.CreateNeg(var);
                else if(var->getType()->isDoubleTy())
                    $$.rval = Builder.CreateFNeg(var);
                break;
            case '+':
                $$.rval = var;
                break;
            case '!':
                if(var->getType()->isIntegerTy())
                    $$.rval = Builder.CreateICmpEQ(var, llvm::Constant::getNullValue(llvm::Type::getInt32Ty(TheContext)));
                break;
            case '~':
                if(var->getType()->isIntegerTy())
                    $$.rval = Builder.CreateNot(var);
                break;
        }
    }
    ;
	/*| SIZEOF unary_expression
	| SIZEOF "(" type_name ")"
	| ALIGNOF "(" type_name ")"
	;*/

unary_operator
    : "-" {$$ = '-';}
    | "+" {$$ = '+';}
    | "!" {$$ = '!';}
    | "~" {$$ = '~';}
    ;
	/*: "&"
	| "*"
	;*/

cast_expression
	: unary_expression
    {
        $$ = static_cast<CastExpression>($1);
    }
    ;
	/*| "(" type_name ")" cast_expression
	;*/

multiplicative_expression
	: cast_expression
    {
        $$ = static_cast<MultiplicativeExpression>($1);
        /*if( $1.type == CastExpression::Type::IDENTIFIER )
            $$.type = MultiplicativeExpression::Type::IDENTIFIER;
        else if( $1.type == CastExpression::Type::RVALUE )
            $$.type = MultiplicativeExpression::Type::RVALUE;
        $$.IDENTIFIERVal = $1.IDENTIFIERVal;
        $$.rval = $1.rval;*/
    }
	| multiplicative_expression "*" cast_expression
    {
        llvm::Value *var_multiplicative = nullptr;
        llvm::Value *var_cast = nullptr;
        if( $1.type == MultiplicativeExpression::Type::IDENTIFIER )
            var_multiplicative = Builder.CreateLoad(NamedValues[$1.IDENTIFIERVal], $1.IDENTIFIERVal.c_str());
        else if( $1.type == MultiplicativeExpression::Type::RVALUE )
            var_multiplicative = $1.rval;

        if( $3.type == CastExpression::Type::IDENTIFIER )
            var_cast = Builder.CreateLoad(NamedValues[$3.IDENTIFIERVal], $3.IDENTIFIERVal.c_str());
        else if( $3.type == CastExpression::Type::RVALUE )
            var_cast = $3.rval;

        $$.type = MultiplicativeExpression::Type::RVALUE;

        if( var_multiplicative->getType()->isDoubleTy() && var_cast->getType()->isIntegerTy())
        {
            var_cast = Builder.CreateSIToFP(var_cast, llvm::Type::getDoubleTy(TheContext));
        }
        else if( var_multiplicative->getType()->isIntegerTy() && var_cast->getType()->isDoubleTy() )
        {
            var_multiplicative = Builder.CreateSIToFP(var_multiplicative, llvm::Type::getDoubleTy(TheContext));
        }

        if( var_multiplicative->getType()->isDoubleTy() && var_cast->getType()->isDoubleTy() )
        {
            $$.rval = Builder.CreateFMul(var_multiplicative, var_cast);
        }
        else if(var_multiplicative->getType()->isIntegerTy() && var_cast->getType()->isIntegerTy())
        {
            $$.rval = Builder.CreateMul(var_multiplicative, var_cast);
        }

    }
	| multiplicative_expression "/" cast_expression
    {
        llvm::Value *var_multiplicative = nullptr;
        llvm::Value *var_cast = nullptr;
        if( $1.type == MultiplicativeExpression::Type::IDENTIFIER )
            var_multiplicative = Builder.CreateLoad(NamedValues[$1.IDENTIFIERVal], $1.IDENTIFIERVal.c_str());
        else if( $1.type == MultiplicativeExpression::Type::RVALUE )
            var_multiplicative = $1.rval;

        if( $3.type == CastExpression::Type::IDENTIFIER )
            var_cast = Builder.CreateLoad(NamedValues[$3.IDENTIFIERVal], $3.IDENTIFIERVal.c_str());
        else if( $3.type == CastExpression::Type::RVALUE )
            var_cast = $3.rval;

        $$.type = MultiplicativeExpression::Type::RVALUE;

        if( var_multiplicative->getType()->isDoubleTy() && var_cast->getType()->isIntegerTy())
        {
            var_cast = Builder.CreateSIToFP(var_cast, llvm::Type::getDoubleTy(TheContext));
        }
        else if( var_multiplicative->getType()->isIntegerTy() && var_cast->getType()->isDoubleTy() )
        {
            var_multiplicative = Builder.CreateSIToFP(var_multiplicative, llvm::Type::getDoubleTy(TheContext));
        }

        if( var_multiplicative->getType()->isDoubleTy() && var_cast->getType()->isDoubleTy() )
        {
            $$.rval = Builder.CreateFDiv(var_multiplicative, var_cast);
        }
        else if(var_multiplicative->getType()->isIntegerTy() && var_cast->getType()->isIntegerTy())
        {
            $$.rval = Builder.CreateSDiv(var_multiplicative, var_cast);
        }
    }
	| multiplicative_expression "%" cast_expression
    {
        llvm::Value *var_multiplicative = nullptr;
        llvm::Value *var_cast = nullptr;
        if( $1.type == MultiplicativeExpression::Type::IDENTIFIER )
            var_multiplicative = Builder.CreateLoad(NamedValues[$1.IDENTIFIERVal], $1.IDENTIFIERVal.c_str());
        else if( $1.type == MultiplicativeExpression::Type::RVALUE )
            var_multiplicative = $1.rval;

        if( $3.type == CastExpression::Type::IDENTIFIER )
            var_cast = Builder.CreateLoad(NamedValues[$3.IDENTIFIERVal], $3.IDENTIFIERVal.c_str());
        else if( $3.type == CastExpression::Type::RVALUE )
            var_cast = $3.rval;

        $$.type = MultiplicativeExpression::Type::RVALUE;

        if( var_multiplicative->getType()->isDoubleTy() && var_cast->getType()->isIntegerTy())
        {
            var_cast = Builder.CreateSIToFP(var_cast, llvm::Type::getDoubleTy(TheContext));
        }
        else if( var_multiplicative->getType()->isIntegerTy() && var_cast->getType()->isDoubleTy() )
        {
            var_multiplicative = Builder.CreateSIToFP(var_multiplicative, llvm::Type::getDoubleTy(TheContext));
        }

        if( var_multiplicative->getType()->isDoubleTy() && var_cast->getType()->isDoubleTy() )
        {
            $$.rval = Builder.CreateFRem(var_multiplicative, var_cast);
        }
        else if(var_multiplicative->getType()->isIntegerTy() && var_cast->getType()->isIntegerTy())
        {
            $$.rval = Builder.CreateSRem(var_multiplicative, var_cast);
        }
    }
	;

additive_expression
	: multiplicative_expression
    {
        $$ = static_cast<AdditiveExpression>($1);
    }
	| additive_expression "+" multiplicative_expression
    {
        llvm::Value *var_additive = nullptr;
        llvm::Value *var_multiplicative = nullptr;
        if( $1.type == AdditiveExpression::Type::IDENTIFIER )
            var_additive = Builder.CreateLoad(NamedValues[$1.IDENTIFIERVal], $1.IDENTIFIERVal.c_str());
        else if( $1.type == AdditiveExpression::Type::RVALUE )
            var_additive = $1.rval;

        if( $3.type == MultiplicativeExpression::Type::IDENTIFIER )
            var_multiplicative = Builder.CreateLoad(NamedValues[$3.IDENTIFIERVal], $3.IDENTIFIERVal.c_str());
        else if( $3.type == MultiplicativeExpression::Type::RVALUE )
            var_multiplicative = $3.rval;

        $$.type = AdditiveExpression::Type::RVALUE;

        if( var_multiplicative->getType()->isDoubleTy() && var_additive->getType()->isIntegerTy())
        {
            var_additive = Builder.CreateSIToFP(var_additive, llvm::Type::getDoubleTy(TheContext));
        }
        else if( var_multiplicative->getType()->isIntegerTy() && var_additive->getType()->isDoubleTy() )
        {
            var_multiplicative = Builder.CreateSIToFP(var_multiplicative, llvm::Type::getDoubleTy(TheContext));
        }

        if( var_multiplicative->getType()->isDoubleTy() && var_additive->getType()->isDoubleTy() )
        {
            $$.rval = Builder.CreateFAdd(var_multiplicative, var_additive);
        }
        else if(var_multiplicative->getType()->isIntegerTy() && var_additive->getType()->isIntegerTy())
        {
            $$.rval = Builder.CreateAdd(var_multiplicative, var_additive);
        }
    
    }
	| additive_expression "-" multiplicative_expression
    {
        llvm::Value *var_additive = nullptr;
        llvm::Value *var_multiplicative = nullptr;
        if( $1.type == AdditiveExpression::Type::IDENTIFIER )
            var_additive = Builder.CreateLoad(NamedValues[$1.IDENTIFIERVal], $1.IDENTIFIERVal.c_str());
        else if( $1.type == AdditiveExpression::Type::RVALUE )
            var_additive = $1.rval;

        if( $3.type == MultiplicativeExpression::Type::IDENTIFIER )
            var_multiplicative = Builder.CreateLoad(NamedValues[$3.IDENTIFIERVal], $3.IDENTIFIERVal.c_str());
        else if( $3.type == MultiplicativeExpression::Type::RVALUE )
            var_multiplicative = $3.rval;

        $$.type = AdditiveExpression::Type::RVALUE;

        if( var_multiplicative->getType()->isDoubleTy() && var_additive->getType()->isIntegerTy())
        {
            var_additive = Builder.CreateSIToFP(var_additive, llvm::Type::getDoubleTy(TheContext));
        }
        else if( var_multiplicative->getType()->isIntegerTy() && var_additive->getType()->isDoubleTy() )
        {
            var_multiplicative = Builder.CreateSIToFP(var_multiplicative, llvm::Type::getDoubleTy(TheContext));
        }

        if( var_multiplicative->getType()->isDoubleTy() && var_additive->getType()->isDoubleTy() )
        {
            $$.rval = Builder.CreateFSub( var_additive, var_multiplicative);
        }
        else if(var_multiplicative->getType()->isIntegerTy() && var_additive->getType()->isIntegerTy())
        {
            $$.rval = Builder.CreateSub(var_additive, var_multiplicative);
        }
        
    }
	;

shift_expression
	: additive_expression
    {
        $$ = static_cast<ShiftExpression>($1);
    }
	| shift_expression LEFT_OP additive_expression
    {
        llvm::Value *var_shift = nullptr;
        llvm::Value *var_additive = nullptr;
        if( $1.type == ShiftExpression::Type::IDENTIFIER )
            var_shift = Builder.CreateLoad(NamedValues[$1.IDENTIFIERVal], $1.IDENTIFIERVal.c_str());
        else if( $1.type == ShiftExpression::Type::RVALUE )
            var_shift = $1.rval;

        if( $3.type == AdditiveExpression::Type::IDENTIFIER )
            var_additive = Builder.CreateLoad(NamedValues[$3.IDENTIFIERVal], $3.IDENTIFIERVal.c_str());
        else if( $3.type == AdditiveExpression::Type::RVALUE )
            var_additive = $3.rval;

        $$.type = ShiftExpression::Type::RVALUE;

        if( var_shift->getType()->isIntegerTy() && var_additive->getType()->isIntegerTy() )
            $$.rval = Builder.CreateShl(var_shift, var_additive);
            
    }
	| shift_expression RIGHT_OP additive_expression
    {
        llvm::Value *var_shift = nullptr;
        llvm::Value *var_additive = nullptr;
        if($1.type == ShiftExpression::Type::IDENTIFIER )
            var_shift = Builder.CreateLoad(NamedValues[$1.IDENTIFIERVal], $1.IDENTIFIERVal.c_str());
        else if($1.type == ShiftExpression::Type::RVALUE)
            var_shift = $1.rval;

        if($3.type == AdditiveExpression::Type::IDENTIFIER)
            var_additive = Builder.CreateLoad(NamedValues[$3.IDENTIFIERVal], $3.IDENTIFIERVal.c_str());
        else if($3.type == AdditiveExpression::Type::RVALUE)
            var_additive = $3.rval;
        
        $$.type = ShiftExpression::Type::RVALUE;

        if(var_shift->getType()->isIntegerTy() && var_additive->getType()->isIntegerTy())
            $$.rval = Builder.CreateAShr(var_shift, var_additive);
    }
	;

relational_expression
	: shift_expression
    {
        if($1.type == ShiftExpression::Type::IDENTIFIER)
            $$.type = RelationalExpression::Type::IDENTIFIER;
        else if($1.type == ShiftExpression::Type::RVALUE)
            $$.type = RelationalExpression::Type::RVALUE;
        $$.IDENTIFIERVal = $1.IDENTIFIERVal;
        $$.rval = $1.rval;
    }
	| relational_expression "<" shift_expression
    {
        llvm::Value *var_relational = nullptr;
        llvm::Value *var_shift = nullptr;
        if($1.type == RelationalExpression::Type::IDENTIFIER )
            var_relational = Builder.CreateLoad(NamedValues[$1.IDENTIFIERVal], $1.IDENTIFIERVal.c_str());
        else if($1.type == RelationalExpression::Type::RVALUE)
            var_relational = $1.rval;

        if($3.type == ShiftExpression::Type::IDENTIFIER)
            var_shift = Builder.CreateLoad(NamedValues[$3.IDENTIFIERVal], $3.IDENTIFIERVal.c_str());
        else if($3.type == ShiftExpression::Type::RVALUE)
            var_shift = $3.rval;

        $$.type = RelationalExpression::Type::RVALUE;
        if( var_relational->getType()->isDoubleTy() && var_shift->getType()->isIntegerTy())
        {
            var_shift = Builder.CreateSIToFP(var_shift, llvm::Type::getDoubleTy(TheContext));
        }
        else if( var_relational->getType()->isIntegerTy() && var_shift->getType()->isDoubleTy() )
        {
            var_relational = Builder.CreateSIToFP(var_relational, llvm::Type::getDoubleTy(TheContext));
        }

        if( var_relational->getType()->isDoubleTy() && var_shift->getType()->isDoubleTy() )
        {
            $$.rval = Builder.CreateIntCast(
                Builder.CreateFCmpOLT( var_relational, var_shift),
                llvm::Type::getInt32Ty(TheContext), true);
        }
        else if(var_relational->getType()->isIntegerTy() && var_shift->getType()->isIntegerTy())
        {
            $$.rval = Builder.CreateIntCast(
                Builder.CreateICmpSLT( var_relational, var_shift),
                llvm::Type::getInt32Ty(TheContext), true);
        }

    }
	| relational_expression ">" shift_expression
    {
        llvm::Value *var_relational = nullptr;
        llvm::Value *var_shift = nullptr;
        if($1.type == RelationalExpression::Type::IDENTIFIER )
            var_relational = Builder.CreateLoad(NamedValues[$1.IDENTIFIERVal], $1.IDENTIFIERVal.c_str());
        else if($1.type == RelationalExpression::Type::RVALUE)
            var_relational = $1.rval;

        if($3.type == ShiftExpression::Type::IDENTIFIER)
            var_shift = Builder.CreateLoad(NamedValues[$3.IDENTIFIERVal], $3.IDENTIFIERVal.c_str());
        else if($3.type == ShiftExpression::Type::RVALUE)
            var_shift = $3.rval;

        $$.type = RelationalExpression::Type::RVALUE;
        if( var_relational->getType()->isDoubleTy() && var_shift->getType()->isIntegerTy())
        {
            var_shift = Builder.CreateSIToFP(var_shift, llvm::Type::getDoubleTy(TheContext));
        }
        else if( var_relational->getType()->isIntegerTy() && var_shift->getType()->isDoubleTy() )
        {
            var_relational = Builder.CreateSIToFP(var_relational, llvm::Type::getDoubleTy(TheContext));
        }

        if( var_relational->getType()->isDoubleTy() && var_shift->getType()->isDoubleTy() )
        {
            $$.rval = Builder.CreateIntCast(
                Builder.CreateFCmpOGT( var_relational, var_shift),
                llvm::Type::getInt32Ty(TheContext), true);
        }
        else if(var_relational->getType()->isIntegerTy() && var_shift->getType()->isIntegerTy())
        {
            $$.rval = Builder.CreateIntCast(
                Builder.CreateICmpSGT( var_relational, var_shift),
                llvm::Type::getInt32Ty(TheContext), true);
        }
    }
	| relational_expression LE_OP shift_expression
    {
        llvm::Value *var_relational = nullptr;
        llvm::Value *var_shift = nullptr;
        if($1.type == RelationalExpression::Type::IDENTIFIER )
            var_relational = Builder.CreateLoad(NamedValues[$1.IDENTIFIERVal], $1.IDENTIFIERVal.c_str());
        else if($1.type == RelationalExpression::Type::RVALUE)
            var_relational = $1.rval;

        if($3.type == ShiftExpression::Type::IDENTIFIER)
            var_shift = Builder.CreateLoad(NamedValues[$3.IDENTIFIERVal], $3.IDENTIFIERVal.c_str());
        else if($3.type == ShiftExpression::Type::RVALUE)
            var_shift = $3.rval;

        $$.type = RelationalExpression::Type::RVALUE;
        if( var_relational->getType()->isDoubleTy() && var_shift->getType()->isIntegerTy())
        {
            var_shift = Builder.CreateSIToFP(var_shift, llvm::Type::getDoubleTy(TheContext));
        }
        else if( var_relational->getType()->isIntegerTy() && var_shift->getType()->isDoubleTy() )
        {
            var_relational = Builder.CreateSIToFP(var_relational, llvm::Type::getDoubleTy(TheContext));
        }

        if( var_relational->getType()->isDoubleTy() && var_shift->getType()->isDoubleTy() )
        {
            $$.rval = Builder.CreateIntCast(
                Builder.CreateFCmpOLE( var_relational, var_shift),
                llvm::Type::getInt32Ty(TheContext), true);
        }
        else if(var_relational->getType()->isIntegerTy() && var_shift->getType()->isIntegerTy())
        {
            $$.rval = Builder.CreateIntCast(
                Builder.CreateICmpSLE( var_relational, var_shift),
                llvm::Type::getInt32Ty(TheContext), true);
        }
    }
	| relational_expression GE_OP shift_expression
    {
        llvm::Value *var_relational = nullptr;
        llvm::Value *var_shift = nullptr;
        if($1.type == RelationalExpression::Type::IDENTIFIER )
            var_relational = Builder.CreateLoad(NamedValues[$1.IDENTIFIERVal], $1.IDENTIFIERVal.c_str());
        else if($1.type == RelationalExpression::Type::RVALUE)
            var_relational = $1.rval;

        if($3.type == ShiftExpression::Type::IDENTIFIER)
            var_shift = Builder.CreateLoad(NamedValues[$3.IDENTIFIERVal], $3.IDENTIFIERVal.c_str());
        else if($3.type == ShiftExpression::Type::RVALUE)
            var_shift = $3.rval;

        $$.type = RelationalExpression::Type::RVALUE;
        if( var_relational->getType()->isDoubleTy() && var_shift->getType()->isIntegerTy())
        {
            var_shift = Builder.CreateSIToFP(var_shift, llvm::Type::getDoubleTy(TheContext));
        }
        else if( var_relational->getType()->isIntegerTy() && var_shift->getType()->isDoubleTy() )
        {
            var_relational = Builder.CreateSIToFP(var_relational, llvm::Type::getDoubleTy(TheContext));
        }

        if( var_relational->getType()->isDoubleTy() && var_shift->getType()->isDoubleTy() )
        {
            $$.rval = Builder.CreateIntCast(
                Builder.CreateFCmpOGE( var_relational, var_shift),
                llvm::Type::getInt32Ty(TheContext), true);
        }
        else if(var_relational->getType()->isIntegerTy() && var_shift->getType()->isIntegerTy())
        {
            $$.rval = Builder.CreateIntCast(
                Builder.CreateICmpSGE( var_relational, var_shift),
                llvm::Type::getInt32Ty(TheContext), true);
        }
    }
	;

equality_expression
	: relational_expression
    {
        if($1.type == RelationalExpression::Type::IDENTIFIER)
            $$.type = EqualityExpression::Type::IDENTIFIER;
        else if($1.type == RelationalExpression::Type::RVALUE)
            $$.type = EqualityExpression::Type::RVALUE;
        
        $$.IDENTIFIERVal = $1.IDENTIFIERVal;
        $$.rval = $1.rval;
    }
	| equality_expression EQ_OP relational_expression
    {
        llvm::Value *var_equality = nullptr;
        llvm::Value *var_relational = nullptr;
        if($1.type == EqualityExpression::Type::IDENTIFIER )
            var_equality = Builder.CreateLoad(NamedValues[$1.IDENTIFIERVal], $1.IDENTIFIERVal.c_str());
        else if($1.type == EqualityExpression::Type::RVALUE)
            var_equality = $1.rval;

        if($3.type == RelationalExpression::Type::IDENTIFIER)
            var_relational = Builder.CreateLoad(NamedValues[$3.IDENTIFIERVal], $3.IDENTIFIERVal.c_str());
        else if($3.type == RelationalExpression::Type::RVALUE)
            var_relational = $3.rval;

        $$.type = EqualityExpression::Type::RVALUE;
        if( var_equality->getType()->isDoubleTy() && var_relational->getType()->isIntegerTy())
        {
            var_relational = Builder.CreateSIToFP(var_relational, llvm::Type::getDoubleTy(TheContext));
        }
        else if( var_equality->getType()->isIntegerTy() && var_relational->getType()->isDoubleTy() )
        {
            var_equality = Builder.CreateSIToFP(var_equality, llvm::Type::getDoubleTy(TheContext));
        }

        if( var_equality->getType()->isDoubleTy() && var_relational->getType()->isDoubleTy() )
        {
            $$.rval = Builder.CreateIntCast(
                Builder.CreateFCmpOEQ( var_equality, var_relational),
                llvm::Type::getInt32Ty(TheContext), true);
        }
        else if(var_equality->getType()->isIntegerTy() && var_relational->getType()->isIntegerTy())
        {
            $$.rval = Builder.CreateIntCast(
                Builder.CreateICmpEQ( var_equality, var_relational),
                llvm::Type::getInt32Ty(TheContext), true);
        }
    }
	| equality_expression NE_OP relational_expression
    {
        llvm::Value *var_equality = nullptr;
        llvm::Value *var_relational = nullptr;
        if($1.type == EqualityExpression::Type::IDENTIFIER )
            var_equality = Builder.CreateLoad(NamedValues[$1.IDENTIFIERVal], $1.IDENTIFIERVal.c_str());
        else if($1.type == EqualityExpression::Type::RVALUE)
            var_equality = $1.rval;

        if($3.type == RelationalExpression::Type::IDENTIFIER)
            var_relational = Builder.CreateLoad(NamedValues[$3.IDENTIFIERVal], $3.IDENTIFIERVal.c_str());
        else if($3.type == RelationalExpression::Type::RVALUE)
            var_relational = $3.rval;

        $$.type = EqualityExpression::Type::RVALUE;
        if( var_equality->getType()->isDoubleTy() && var_relational->getType()->isIntegerTy())
        {
            var_relational = Builder.CreateSIToFP(var_relational, llvm::Type::getDoubleTy(TheContext));
        }
        else if( var_equality->getType()->isIntegerTy() && var_relational->getType()->isDoubleTy() )
        {
            var_equality = Builder.CreateSIToFP(var_equality, llvm::Type::getDoubleTy(TheContext));
        }

        if( var_equality->getType()->isDoubleTy() && var_relational->getType()->isDoubleTy() )
        {
            $$.rval = Builder.CreateIntCast(
                Builder.CreateFCmpONE( var_equality, var_relational),
                llvm::Type::getInt32Ty(TheContext), true);
        }
        else if(var_equality->getType()->isIntegerTy() && var_relational->getType()->isIntegerTy())
        {
            $$.rval = Builder.CreateIntCast(
                Builder.CreateICmpNE( var_equality, var_relational),
                llvm::Type::getInt32Ty(TheContext), true);
        }
    }
	;

and_expression
	: equality_expression
    {
        if($1.type == EqualityExpression::Type::IDENTIFIER)
            $$.type = AndExpression::Type::IDENTIFIER;
        else if($1.type == EqualityExpression::Type::RVALUE)
            $$.type = AndExpression::Type::RVALUE;

        $$.IDENTIFIERVal = $1.IDENTIFIERVal;
        $$.rval = $1.rval;
    }
	| and_expression "&" equality_expression
    {
        llvm::Value *var_and = nullptr;
        llvm::Value *var_equality = nullptr;
        if($1.type == AndExpression::Type::IDENTIFIER )
            var_and = Builder.CreateLoad(NamedValues[$1.IDENTIFIERVal], $1.IDENTIFIERVal.c_str());
        else if($1.type == AndExpression::Type::RVALUE)
            var_and = $1.rval;

        if($3.type == EqualityExpression::Type::IDENTIFIER)
            var_equality = Builder.CreateLoad(NamedValues[$3.IDENTIFIERVal], $3.IDENTIFIERVal.c_str());
        else if($3.type == EqualityExpression::Type::RVALUE)
            var_equality = $3.rval;
        
        $$.type = AndExpression::Type::RVALUE;

        if(var_and->getType()->isIntegerTy() && var_equality->getType()->isIntegerTy())
            $$.rval = Builder.CreateAnd(var_and, var_equality);
            
    }
	;

exclusive_or_expression
	: and_expression
    {
        if($1.type == AndExpression::Type::IDENTIFIER)
            $$.type = ExclusiveOrExpression::Type::IDENTIFIER;
        else if($1.type == AndExpression::Type::RVALUE)
            $$.type = ExclusiveOrExpression::Type::RVALUE;

        $$.IDENTIFIERVal = $1.IDENTIFIERVal;
        $$.rval = $1.rval;
    }
	| exclusive_or_expression "^" and_expression
    {
        llvm::Value *var_exclusive = nullptr;
        llvm::Value *var_and = nullptr;
        if($1.type == ExclusiveOrExpression::Type::IDENTIFIER )
            var_exclusive = Builder.CreateLoad(NamedValues[$1.IDENTIFIERVal], $1.IDENTIFIERVal.c_str());
        else if($1.type == ExclusiveOrExpression::Type::RVALUE)
            var_exclusive = $1.rval;

        if($3.type == AndExpression::Type::IDENTIFIER)
            var_and = Builder.CreateLoad(NamedValues[$3.IDENTIFIERVal], $3.IDENTIFIERVal.c_str());
        else if($3.type == AndExpression::Type::RVALUE)
            var_and = $3.rval;
        
        $$.type = ExclusiveOrExpression::Type::RVALUE;

        if(var_exclusive->getType()->isIntegerTy() && var_and->getType()->isIntegerTy())
            $$.rval = Builder.CreateXor(var_exclusive, var_and);
        
    }
	;

inclusive_or_expression
	: exclusive_or_expression
    {
        if($1.type == ExclusiveOrExpression::Type::IDENTIFIER)
            $$.type = InclusiveOrExpression::Type::IDENTIFIER;
        else if($1.type == ExclusiveOrExpression::Type::RVALUE)
            $$.type = InclusiveOrExpression::Type::RVALUE;
        $$.IDENTIFIERVal = $1.IDENTIFIERVal;
        $$.rval = $1.rval;
    }
	| inclusive_or_expression "|" exclusive_or_expression
    {
        llvm::Value *var_inclusive = nullptr;
        llvm::Value *var_exclusive = nullptr;
        if($1.type == InclusiveOrExpression::Type::IDENTIFIER )
            var_inclusive = Builder.CreateLoad(NamedValues[$1.IDENTIFIERVal], $1.IDENTIFIERVal.c_str());
        else if($1.type == InclusiveOrExpression::Type::RVALUE)
            var_inclusive = $1.rval;

        if($3.type == ExclusiveOrExpression::Type::IDENTIFIER)
            var_exclusive = Builder.CreateLoad(NamedValues[$3.IDENTIFIERVal], $3.IDENTIFIERVal.c_str());
        else if($3.type == ExclusiveOrExpression::Type::RVALUE)
            var_exclusive = $3.rval;
        
        $$.type = InclusiveOrExpression::Type::RVALUE;

        if(var_exclusive->getType()->isIntegerTy() && var_inclusive->getType()->isIntegerTy())
            $$.rval = Builder.CreateOr(var_inclusive, var_exclusive);

    }
	;

logical_and_expression
	: inclusive_or_expression
    {
        if($1.type == InclusiveOrExpression::Type::IDENTIFIER)
            $$.type = LogicalAndExpression::Type::IDENTIFIER;
        else if($1.type == InclusiveOrExpression::Type::RVALUE)
            $$.type = LogicalAndExpression::Type::RVALUE;
    }
	| logical_and_expression AND_OP inclusive_or_expression
    {
        llvm::Value *var_logical = nullptr;
        llvm::Value *var_inclusive = nullptr;
        if($1.type == LogicalAndExpression::Type::IDENTIFIER )
            var_logical = Builder.CreateLoad(NamedValues[$1.IDENTIFIERVal], $1.IDENTIFIERVal.c_str());
        else if($1.type == LogicalAndExpression::Type::RVALUE)
            var_logical = $1.rval;
        if($3.type == InclusiveOrExpression::Type::IDENTIFIER)
            var_inclusive = Builder.CreateLoad(NamedValues[$3.IDENTIFIERVal], $3.IDENTIFIERVal.c_str());
        else if($3.type == InclusiveOrExpression::Type::RVALUE)
            var_inclusive = $3.rval;
        
        $$.type = LogicalAndExpression::Type::RVALUE;
        
        $$.rval = Builder.CreateIntCast(
            Builder.CreateAnd(
                (var_logical->getType()->isIntegerTy()  ? Builder.CreateICmpNE(var_logical,llvm::ConstantInt::get(llvm::Type::getInt32Ty(TheContext), llvm::APInt(32, 0, true)))
                                                        : Builder.CreateFCmpONE(var_logical, llvm::ConstantFP::get(llvm::Type::getDoubleTy(TheContext), llvm::APFloat(0.0)))),
                (var_inclusive->getType()->isIntegerTy()?Builder.CreateICmpNE(var_inclusive, llvm::ConstantInt::get(llvm::Type::getInt32Ty(TheContext), llvm::APInt(32, 0, true)))
                                                        : Builder.CreateFCmpONE(var_inclusive,llvm::ConstantFP::get(llvm::Type::getDoubleTy(TheContext), llvm::APFloat(0.0))))),
           llvm::Type::getInt32Ty(TheContext),true);
    }
	;

logical_or_expression
	: logical_and_expression 
    {
        if($1.type == LogicalAndExpression::Type::IDENTIFIER)
            $$.type = LogicalOrExpression::Type::IDENTIFIER;
        else if($1.type == LogicalAndExpression::Type::RVALUE)
            $$.type = LogicalOrExpression::Type::RVALUE;
        $$.IDENTIFIERVal = $1.IDENTIFIERVal;
        $$.rval = $1.rval;
    }
	| logical_or_expression OR_OP logical_and_expression
    {
        llvm::Value *var_logical_or = nullptr;
        llvm::Value *var_logical_and = nullptr;
        if($1.type == LogicalOrExpression::Type::IDENTIFIER )
            var_logical_or = Builder.CreateLoad(NamedValues[$1.IDENTIFIERVal], $1.IDENTIFIERVal.c_str());
        else if($1.type == LogicalOrExpression::Type::RVALUE)
            var_logical_or = $1.rval;
        if($3.type == LogicalAndExpression::Type::IDENTIFIER)
            var_logical_and = Builder.CreateLoad(NamedValues[$3.IDENTIFIERVal], $3.IDENTIFIERVal.c_str());
        else if($3.type == LogicalAndExpression::Type::RVALUE)
            var_logical_and = $3.rval;
        
        $$.type = LogicalOrExpression::Type::RVALUE;
        
        $$.rval = Builder.CreateIntCast(
            Builder.CreateOr(
                (var_logical_or->getType()->isIntegerTy()   ? Builder.CreateICmpNE(var_logical_or,llvm::ConstantInt::get(llvm::Type::getInt32Ty(TheContext), llvm::APInt(32, 0, true)))
                                                            : Builder.CreateFCmpONE(var_logical_or, llvm::ConstantFP::get(llvm::Type::getDoubleTy(TheContext), llvm::APFloat(0.0)))),
                (var_logical_and->getType()->isIntegerTy()  ? Builder.CreateICmpNE(var_logical_and, llvm::ConstantInt::get(llvm::Type::getInt32Ty(TheContext), llvm::APInt(32, 0, true)))
                                                            : Builder.CreateFCmpONE(var_logical_and,llvm::ConstantFP::get(llvm::Type::getDoubleTy(TheContext), llvm::APFloat(0.0))))),
           llvm::Type::getInt32Ty(TheContext),true);

    }
	;

conditional_expression      
	: logical_or_expression
    {
        if($1.type == LogicalOrExpression::Type::IDENTIFIER)
            $$.type = ConditionalExpression::Type::IDENTIFIER;
        else if($1.type == LogicalOrExpression::Type::RVALUE)
            $$.type = ConditionalExpression::Type::RVALUE;
        $$.IDENTIFIERVal = $1.IDENTIFIERVal;
        $$.rval = $1.rval;
    };
	/*| logical_or_expression "?" expression ":" conditional_expression            TODO: NEED FINIASH Phi_node
    {
        llvm::Value *var_logical_or = nullptr;
        if($1.type == LogicalOrExpression::Type::IDENTIFIER )
            var_logical_or = Builder.CreateLoad(NamedValues[$1.IDENTIFIERVal], $1.IDENTIFIERVal.c_str());
        else if($1.type == LogicalOrExpression::Type::RVALUE)
            var_logical_or = $1.rval;
        if(var_logical_or->getType()->isIntegerTy()   ? Builder.CreateICmpNE(var_logical_or,llvm::ConstantInt::get(llvm::Type::getInt32Ty(TheContext), llvm::APInt(32, 0, true)))
                                                            : Builder.CreateFCmpONE(var_logical_or, llvm::ConstantFP::get(llvm::Type::getDoubleTy(TheContext), llvm::APFloat(0.0))))
    }
	;*/

assignment_expression
	: conditional_expression
    {
        if($1.type == ConditionalExpression::Type::IDENTIFIER)
            $$.type = AssignmentExpression::Type::IDENTIFIER;
        else if( $1.type == ConditionalExpression::Type::RVALUE)
            $$.type = AssignmentExpression::Type::RVALUE;
        $$.IDENTIFIERVal = $1.IDENTIFIERVal;
        $$.rval = $1.rval;
    }
	| unary_expression assignment_operator assignment_expression
    {
        llvm::Value *var_unary = nullptr;
        llvm::Value *var_assignment = nullptr;
        if($1.type == UnaryExpression::Type::IDENTIFIER )
            var_unary = Builder.CreateLoad(NamedValues[$1.IDENTIFIERVal], $1.IDENTIFIERVal.c_str());
        else
        {
            // TODO :throw error
        }
        
        if($3.type == AssignmentExpression::Type::IDENTIFIER)
            var_assignment = Builder.CreateLoad(NamedValues[$3.IDENTIFIERVal], $3.IDENTIFIERVal.c_str());
        else if($3.type == AssignmentExpression::Type::RVALUE)
            var_assignment = $3.rval;

        switch($2.assignType.underlying())
        {
            case AssignmentOperator::Type::ASSIGN :
            {
                Builder.CreateStore(var_assignment, NamedValues[$1.IDENTIFIERVal]);
                $$.type = AssignmentExpression::Type::RVALUE;
                $$.rval = var_assignment;
                break;
            }
            case AssignmentOperator::Type::MUL_ASSIGN :
            {    
                llvm::Value *var_new_unary = var_unary;
                llvm::Value *var_new_assignment = var_assignment;

                if( var_unary->getType()->isDoubleTy() && var_assignment->getType()->isIntegerTy())
                {
                    var_new_assignment = Builder.CreateSIToFP(var_assignment, llvm::Type::getDoubleTy(TheContext));
                }
                else if( var_unary->getType()->isIntegerTy() && var_assignment->getType()->isDoubleTy() )
                {
                    var_new_unary = Builder.CreateSIToFP(var_unary, llvm::Type::getDoubleTy(TheContext));
                }

                llvm::Value *ans = nullptr;
                if( var_new_unary->getType()->isDoubleTy() && var_new_assignment->getType()->isDoubleTy() )
                {
                    ans = Builder.CreateFMul(var_unary, var_assignment);
                }
                else if(var_new_unary->getType()->isIntegerTy() && var_new_assignment->getType()->isIntegerTy())
                {
                    ans = Builder.CreateMul(var_unary, var_assignment);
                }

                if(ans->getType()->isDoubleTy() && var_unary->getType()->isIntegerTy())
                    ans = Builder.CreateSIToFP(ans, llvm::Type::getDoubleTy(TheContext));
                else if(ans->getType()->isIntegerTy() && var_unary->getType()->isDoubleTy())
                    ans = Builder.CreateFPToSI(ans, llvm::Type::getInt32Ty(TheContext));

                Builder.CreateStore(ans, NamedValues[$1.IDENTIFIERVal]);

                $$.type = AssignmentExpression::Type::RVALUE;
                $$.rval = ans;

                break;
            }
            case AssignmentOperator::Type::DIV_ASSIGN :
            {
                llvm::Value *var_new_unary = var_unary;
                llvm::Value *var_new_assignment = var_assignment;

                if( var_unary->getType()->isDoubleTy() && var_assignment->getType()->isIntegerTy())
                {
                    var_new_assignment = Builder.CreateSIToFP(var_assignment, llvm::Type::getDoubleTy(TheContext));
                }
                else if( var_unary->getType()->isIntegerTy() && var_assignment->getType()->isDoubleTy() )
                {
                    var_new_unary = Builder.CreateSIToFP(var_unary, llvm::Type::getDoubleTy(TheContext));
                }

                llvm::Value *ans = nullptr;
                if( var_new_unary->getType()->isDoubleTy() && var_new_assignment->getType()->isDoubleTy() )
                {
                    ans = Builder.CreateFDiv(var_unary, var_assignment);
                }
                else if(var_new_unary->getType()->isIntegerTy() && var_new_assignment->getType()->isIntegerTy())
                {
                    ans = Builder.CreateSDiv(var_unary, var_assignment);
                }

                if(ans->getType()->isDoubleTy() && var_unary->getType()->isIntegerTy())
                    ans = Builder.CreateSIToFP(ans, llvm::Type::getDoubleTy(TheContext));
                else if(ans->getType()->isIntegerTy() && var_unary->getType()->isDoubleTy())
                    ans = Builder.CreateFPToSI(ans, llvm::Type::getInt32Ty(TheContext));

                Builder.CreateStore(ans, NamedValues[$1.IDENTIFIERVal]);

                $$.type = AssignmentExpression::Type::RVALUE;
                $$.rval = ans;

                break;
            }
            case AssignmentOperator::Type::MOD_ASSIGN :
            {
                llvm::Value *var_new_unary = var_unary;
                llvm::Value *var_new_assignment = var_assignment;

                llvm::Value *ans = nullptr;
                if(var_new_unary->getType()->isIntegerTy() && var_new_assignment->getType()->isIntegerTy())
                {
                    ans = Builder.CreateSRem(var_unary, var_assignment);
                }

                Builder.CreateStore(ans, NamedValues[$1.IDENTIFIERVal]);

                $$.type = AssignmentExpression::Type::RVALUE;
                $$.rval = ans;
                break;
            }
            case AssignmentOperator::Type::ADD_ASSIGN :
            {
                llvm::Value *var_new_unary = var_unary;
                llvm::Value *var_new_assignment = var_assignment;

                if( var_unary->getType()->isDoubleTy() && var_assignment->getType()->isIntegerTy())
                {
                    var_new_assignment = Builder.CreateSIToFP(var_assignment, llvm::Type::getDoubleTy(TheContext));
                }
                else if( var_unary->getType()->isIntegerTy() && var_assignment->getType()->isDoubleTy() )
                {
                    var_new_unary = Builder.CreateSIToFP(var_unary, llvm::Type::getDoubleTy(TheContext));
                }

                llvm::Value *ans = nullptr;
                if( var_new_unary->getType()->isDoubleTy() && var_new_assignment->getType()->isDoubleTy() )
                {
                    ans = Builder.CreateFAdd(var_unary, var_assignment);
                }
                else if(var_new_unary->getType()->isIntegerTy() && var_new_assignment->getType()->isIntegerTy())
                {
                    ans = Builder.CreateAdd(var_unary, var_assignment);
                }

                if(ans->getType()->isDoubleTy() && var_unary->getType()->isIntegerTy())
                    ans = Builder.CreateSIToFP(ans, llvm::Type::getDoubleTy(TheContext));
                else if(ans->getType()->isIntegerTy() && var_unary->getType()->isDoubleTy())
                    ans = Builder.CreateFPToSI(ans, llvm::Type::getInt32Ty(TheContext));

                Builder.CreateStore(ans, NamedValues[$1.IDENTIFIERVal]);

                $$.type = AssignmentExpression::Type::RVALUE;
                $$.rval = ans;
                break;
            }
            case AssignmentOperator::Type::SUB_ASSIGN :
            {
                llvm::Value *var_new_unary = var_unary;
                llvm::Value *var_new_assignment = var_assignment;

                if( var_unary->getType()->isDoubleTy() && var_assignment->getType()->isIntegerTy())
                {
                    var_new_assignment = Builder.CreateSIToFP(var_assignment, llvm::Type::getDoubleTy(TheContext));
                }
                else if( var_unary->getType()->isIntegerTy() && var_assignment->getType()->isDoubleTy() )
                {
                    var_new_unary = Builder.CreateSIToFP(var_unary, llvm::Type::getDoubleTy(TheContext));
                }

                llvm::Value *ans = nullptr;
                if( var_new_unary->getType()->isDoubleTy() && var_new_assignment->getType()->isDoubleTy() )
                {
                    ans = Builder.CreateFSub(var_unary, var_assignment);
                }
                else if(var_new_unary->getType()->isIntegerTy() && var_new_assignment->getType()->isIntegerTy())
                {
                    ans = Builder.CreateSub(var_unary, var_assignment);
                }

                if(ans->getType()->isDoubleTy() && var_unary->getType()->isIntegerTy())
                    ans = Builder.CreateSIToFP(ans, llvm::Type::getDoubleTy(TheContext));
                else if(ans->getType()->isIntegerTy() && var_unary->getType()->isDoubleTy())
                    ans = Builder.CreateFPToSI(ans, llvm::Type::getInt32Ty(TheContext));

                Builder.CreateStore(ans, NamedValues[$1.IDENTIFIERVal]);

                $$.type = AssignmentExpression::Type::RVALUE;
                $$.rval = ans;
                break;
            }
            case AssignmentOperator::Type::LEFT_ASSIGN :
            {
                llvm::Value *var_new_unary = var_unary;
                llvm::Value *var_new_assignment = var_assignment;

                llvm::Value *ans = nullptr;
                if(var_new_unary->getType()->isIntegerTy() && var_new_assignment->getType()->isIntegerTy())
                {
                    ans = Builder.CreateShl(var_unary, var_assignment);
                }

                Builder.CreateStore(ans, NamedValues[$1.IDENTIFIERVal]);

                $$.type = AssignmentExpression::Type::RVALUE;
                $$.rval = ans;
                break;
            }
            case AssignmentOperator::Type::RIGHT_ASSIGN :
            {
                llvm::Value *var_new_unary = var_unary;
                llvm::Value *var_new_assignment = var_assignment;

                llvm::Value *ans = nullptr;
                if(var_new_unary->getType()->isIntegerTy() && var_new_assignment->getType()->isIntegerTy())
                {
                    ans = Builder.CreateAShr(var_unary, var_assignment);
                }

                Builder.CreateStore(ans, NamedValues[$1.IDENTIFIERVal]);

                $$.type = AssignmentExpression::Type::RVALUE;
                $$.rval = ans;
                break;
            }
            case AssignmentOperator::Type::AND_ASSIGN :
            {
                llvm::Value *var_new_unary = var_unary;
                llvm::Value *var_new_assignment = var_assignment;

                llvm::Value *ans = nullptr;
                if(var_new_unary->getType()->isIntegerTy() && var_new_assignment->getType()->isIntegerTy())
                {
                    ans = Builder.CreateAnd(var_unary, var_assignment);
                }

                Builder.CreateStore(ans, NamedValues[$1.IDENTIFIERVal]);

                $$.type = AssignmentExpression::Type::RVALUE;
                $$.rval = ans;
                break;
            }
            case AssignmentOperator::Type::XOR_ASSIGN :
            {
                llvm::Value *var_new_unary = var_unary;
                llvm::Value *var_new_assignment = var_assignment;

                llvm::Value *ans = nullptr;
                if(var_new_unary->getType()->isIntegerTy() && var_new_assignment->getType()->isIntegerTy())
                {
                    ans = Builder.CreateXor(var_unary, var_assignment);
                }

                Builder.CreateStore(ans, NamedValues[$1.IDENTIFIERVal]);

                $$.type = AssignmentExpression::Type::RVALUE;
                $$.rval = ans;
                break;
            }
            case AssignmentOperator::Type::OR_ASSIGN :
            {
                llvm::Value *var_new_unary = var_unary;
                llvm::Value *var_new_assignment = var_assignment;

                llvm::Value *ans = nullptr;
                if(var_new_unary->getType()->isIntegerTy() && var_new_assignment->getType()->isIntegerTy())
                {
                    ans = Builder.CreateOr(var_unary, var_assignment);
                }

                Builder.CreateStore(ans, NamedValues[$1.IDENTIFIERVal]);

                $$.type = AssignmentExpression::Type::RVALUE;
                $$.rval = ans;
                break;
            }
        }
        
    }
	;

assignment_operator
	: "="           {$$.assignType = AssignmentOperator::Type::ASSIGN;}
	| MUL_ASSIGN    {$$.assignType = AssignmentOperator::Type::MUL_ASSIGN;}
	| DIV_ASSIGN    {$$.assignType = AssignmentOperator::Type::DIV_ASSIGN;}
	| MOD_ASSIGN    {$$.assignType = AssignmentOperator::Type::MOD_ASSIGN;}
	| ADD_ASSIGN    {$$.assignType = AssignmentOperator::Type::ADD_ASSIGN;}
	| SUB_ASSIGN    {$$.assignType = AssignmentOperator::Type::SUB_ASSIGN;}
	| LEFT_ASSIGN   {$$.assignType = AssignmentOperator::Type::LEFT_ASSIGN;}
	| RIGHT_ASSIGN  {$$.assignType = AssignmentOperator::Type::RIGHT_ASSIGN;}
	| AND_ASSIGN    {$$.assignType = AssignmentOperator::Type::AND_ASSIGN;}
	| XOR_ASSIGN    {$$.assignType = AssignmentOperator::Type::XOR_ASSIGN;}
	| OR_ASSIGN     {$$.assignType = AssignmentOperator::Type::OR_ASSIGN;}
	;

expression
	:assignment_expression 
    {
        if($1.type == AssignmentExpression::Type::IDENTIFIER)
            $$.type = Expression::Type::IDENTIFIER;
        else if($1.type == AssignmentExpression::Type::RVALUE)
            $$.type = Expression::Type::RVALUE;
        $$.IDENTIFIERVal = $1.IDENTIFIERVal;
        $$.rval = $1.rval;
    }
    ;
	/*| expression "," assignment_expression
	;*/

constant_expression
    :%empty
	/*: conditional_expression	 with constraints 
	;*/

declaration
	: declaration_specifiers ";"
	| declaration_specifiers init_declarator_list ";"
	/*| static_assert_declarationi*/
	;

declaration_specifiers
    : type_specifier declaration_specifiers 
    | type_specifier
    ;
	/*: storage_class_specifier declaration_specifiers
	| storage_class_specifier
	| type_specifier declaration_specifiers
	| type_specifier
	| type_qualifier declaration_specifiers
	| type_qualifier
	| function_specifier declaration_specifiers
	| function_specifier
	| alignment_specifier declaration_specifiers
	| alignment_specifier
	;*/

init_declarator_list
	: init_declarator
	| init_declarator_list "," init_declarator
	;

init_declarator
	: declarator "=" initializer
	| declarator
	;

/*storage_class_specifier
	: TYPEDEF	 identifiers must be flagged as TYPEDEF_NAME
	| EXTERN
	| STATIC
	| THREAD_LOCAL
	| AUTO
	| REGISTER
	;*/

type_specifier
    : INT
    | DOUBLE 
    ;
	/*: VOID
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
	| IMAGINARY	  	 non-mandated extension 
	| atomic_type_specifier
	| struct_or_union_specifier
	| enum_specifier
	| TYPEDEF_NAME		 after it has been defined as such 
	;

struct_or_union_specifier
	: struct_or_union "{" struct_declaration_list "}"
	| struct_or_union IDENTIFIER "{" struct_declaration_list "}"
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
	: specifier_qualifier_list ";"	 for anonymous struct/union 
	| specifier_qualifier_list struct_declarator_list ";"
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
	| struct_declarator_list "," struct_declarator
	;

struct_declarator
	: ":" constant_expression
	| declarator ":" constant_expression
	| declarator
	;

enum_specifier
	: ENUM "{" enumerator_list "}"
	| ENUM "{" enumerator_list "," "}"
	| ENUM IDENTIFIER "{" enumerator_list "}"
	| ENUM IDENTIFIER "{" enumerator_list "," "}"
	| ENUM IDENTIFIER
	;

enumerator_list
	: enumerator
	| enumerator_list "," enumerator
	;

enumerator	 
    identifiers must be flagged as ENUMERATION_CONSTANT 
	: enumeration_constant "=" constant_expression
	| enumeration_constant
	;

atomic_type_specifier
	: ATOMIC "(" type_name ")"
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
	: ALIGNAS "(" type_name ")"
	| ALIGNAS "(" constant_expression ")"
	;*/

declarator
    : direct_declarator
	/*: pointer direct_declarator
	| direct_declarator
	;*/

direct_declarator
	: IDENTIFIER
	/*| "(" declarator ")"
	| direct_declarator "[" "]"
	| direct_declarator "[" "*" "]"
	| direct_declarator "[" STATIC type_qualifier_list assignment_expression "]"
	| direct_declarator "[" STATIC assignment_expression "]"
	| direct_declarator "[" type_qualifier_list "*" "]"
	| direct_declarator "[" type_qualifier_list STATIC assignment_expression "]"
	| direct_declarator "[" type_qualifier_list assignment_expression "]"
	| direct_declarator "[" type_qualifier_list "]"
	| direct_declarator "[" assignment_expression "]"
    */
	| direct_declarator "(" parameter_type_list ")"
	| direct_declarator "(" ")"
	| direct_declarator "(" identifier_list ")"
	;


/*pointer
	: "*" type_qualifier_list pointer
	| "*" type_qualifier_list
	| "*" pointer
	| "*"
	;*/

/*type_qualifier_list
	: type_qualifier
	| type_qualifier_list type_qualifier
	;*/


parameter_type_list
	: parameter_list "," ELLIPSIS
	| parameter_list
	;

parameter_list
	: parameter_declaration
	| parameter_list "," parameter_declaration
	;

parameter_declaration
	: declaration_specifiers declarator
	| declaration_specifiers
    ;
	/*: declaration_specifiers declarator
	| declaration_specifiers abstract_declarator
	| declaration_specifiers
	;*/

identifier_list
	: IDENTIFIER
	| identifier_list "," IDENTIFIER
	;

/*type_name
	: specifier_qualifier_list
    ;
	: specifier_qualifier_list abstract_declarator
	| specifier_qualifier_list
	;*/

/*abstract_declarator
	: pointer direct_abstract_declarator
	| pointer
	| direct_abstract_declarator
	;

direct_abstract_declarator
	: "(" abstract_declarator ")"
	| "[" "]"
	| "[" "*" "]"
	| "[" STATIC type_qualifier_list assignment_expression "]"
	| "[" STATIC assignment_expression "]"
	| "[" type_qualifier_list STATIC assignment_expression "]"
	| "[" type_qualifier_list assignment_expression "]"
	| "[" type_qualifier_list "]"
	| "[" assignment_expression "]"
	| direct_abstract_declarator "[" "]"
	| direct_abstract_declarator "[" "*" "]"
	| direct_abstract_declarator "[" STATIC type_qualifier_list assignment_expression "]"
	| direct_abstract_declarator "[" STATIC assignment_expression "]"
	| direct_abstract_declarator "[" type_qualifier_list assignment_expression "]"
	| direct_abstract_declarator "[" type_qualifier_list STATIC assignment_expression "]"
	| direct_abstract_declarator "[" type_qualifier_list "]"
	| direct_abstract_declarator "[" assignment_expression "]"
	| "(" ")"
	| "(" parameter_type_list ")"
	| direct_abstract_declarator "(" ")"
	| direct_abstract_declarator "(" parameter_type_list ")"
	;*/

initializer
	: "{" initializer_list "}"
	| "{" initializer_list "," "}"
	| assignment_expression
	;

initializer_list
	/*: designation initializeri*/
	: initializer
	/*| initializer_list "," designation initializeri*/
	| initializer_list "," initializer
	;

/*designation
	: designator_list "="
	;

designator_list
	: designator
	| designator_list designator
	;

designator
	: "[" constant_expression "]"
	| "." IDENTIFIER
	;*/

/*static_assert_declaration
	: STATIC_ASSERT "(" constant_expression "," STRING_LITERAL ")" ";"
	;*/

statement
	: labeled_statement
	| compound_statement
	| expression_statement
	| selection_statement
	| iteration_statement
	| jump_statement
	;

labeled_statement
	: IDENTIFIER ":" statement
	| CASE constant_expression ":" statement
	| DEFAULT ":" statement
	;

compound_statement
	: "{" "}"
	| "{"  block_item_list "}"
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
	: ";"
	| expression ";"
	;

selection_statement
	: IF "(" expression ")" statement ELSE statement
	| IF "(" expression ")" statement
	| SWITCH "(" expression ")" statement
	;

iteration_statement
	: WHILE "(" expression ")" statement
	| DO statement WHILE "(" expression ")" ";"
	| FOR "(" expression_statement expression_statement ")" statement
	| FOR "(" expression_statement expression_statement expression ")" statement
	| FOR "(" declaration expression_statement ")" statement
	| FOR "(" declaration expression_statement expression ")" statement
	;

jump_statement
	: GOTO IDENTIFIER ";"
	| CONTINUE ";"
	| BREAK ";"
	| RETURN ";"
	| RETURN expression ";"
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
   std::cerr << l << ": " << m << "\n";
}

static llvm::AllocaInst *CreateEntryBlockAlloca(llvm::Type *TheType, llvm::Function *TheFunction, const std::string &VarName) 
{
    return llvm::IRBuilder<>(&TheFunction->getEntryBlock(), TheFunction->getEntryBlock().begin()).CreateAlloca(TheType, 0, VarName.c_str());
  //llvm::IRBuilder<> TmpB(&TheFunction->getEntryBlock(), TheFunction->getEntryBlock().begin());
  //return TmpB.CreateAlloca(TheType, 0, VarName.c_str());
}

llvm::Value *LogErrorV(const char *Str) 
{
  yyerror(Str);
  return nullptr;
}

void InitializeModuleAndPassManager() {
  // Open a new module.
  TheModule = llvm::make_unique<llvm::Module>("my cool jit", TheContext);
}

void start_parser()
{
    InitializeModuleAndPassManager();
}

void end_parser()
{
    using namespace llvm;
    using namespace llvm::sys;
    InitializeAllTargetInfos();
  InitializeAllTargets();
  InitializeAllTargetMCs();
  InitializeAllAsmParsers();
  InitializeAllAsmPrinters();

  auto TargetTriple = sys::getDefaultTargetTriple();
  TheModule->setTargetTriple(TargetTriple);

  std::string Error;
  auto Target = TargetRegistry::lookupTarget(TargetTriple, Error);

  // Print an error and exit if we couldn't find the requested target.
  // This generally occurs if we've forgotten to initialise the
  // TargetRegistry or we have a bogus target triple.
  if (!Target) {
    errs() << Error;
    return ;
  }

  auto CPU = "generic";
  auto Features = "";

  TargetOptions opt;
  auto RM = Optional<Reloc::Model>();
  auto TheTargetMachine =
      Target->createTargetMachine(TargetTriple, CPU, Features, opt, RM); //Crash

  TheModule->setDataLayout(TheTargetMachine->createDataLayout());

  auto Filename = "output.o";
  std::error_code EC;
  raw_fd_ostream dest(Filename, EC, sys::fs::F_None);

  if (EC) {
    errs() << "Could not open file: " << EC.message();
    return ;
  }

  legacy::PassManager pass;
  auto FileType = TargetMachine::CGFT_ObjectFile;

  if (TheTargetMachine->addPassesToEmitFile(pass, dest, nullptr, FileType)) {
    errs() << "TheTargetMachine can't emit a file of this type";
    return ;
  }

  pass.run(*TheModule);
  dest.flush();

  outs() << "Wrote " << Filename << "\n";

  return ;
}

