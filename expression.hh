#ifndef __EXPRESSION_HH__
#define __EXPRESSION_HH__

#include "common.hh"

class InitDeclarator
{
    private:
        struct Type_def
        {
            enum type : int
            {
                INT,
                DOUBLE
            };
        };
    public:
        typedef safe_enum<Type_def> Type;

        Type type;
        std::string IDENTIFIERVal;
        int32_t INTval;
        double DOUBLEval;
};

class Declarator
{
    private:
        struct Type_def
        {
            enum type : int
            {
                IDENTIFIER
            };
        };
    public:
        typedef safe_enum<Type_def> Type;

        Type type;
        std::string IDENTIFIERVal;
    
        explicit operator InitDeclarator()
        {
            InitDeclarator o;
            o.IDENTIFIERVal = std::move(IDENTIFIERVal);
            o.INTval = 0;
            o.DOUBLEval = 0;
            return o;
        }

};

class DirectDeclarator
{
    private:
        struct Type_def
        {
            enum type : int
            {
                IDENTIFIER
            };
        };
    public:
        typedef safe_enum<Type_def> Type;

        Type type;
        std::string IDENTIFIERVal;

        explicit operator Declarator()
        {
            Declarator o;
            o.type = Declarator::Type::IDENTIFIER;
            o.IDENTIFIERVal = std::move(IDENTIFIERVal);
            return o;
        }
};

class DeclarationSpecifiers
{
    private:
        struct Type_def
        {
            enum type : int
            {
                INT,
                DOUBLE
            };
        };
    public:
        typedef safe_enum<Type_def> Type;

        Type type;
};


class TypeSpecifier
{
    private:
        struct Type_def
        {
            enum type : int
            {
                INT,
                DOUBLE
            };
        };
    public:
        typedef safe_enum<Type_def> Type;

        Type type;

        explicit operator DeclarationSpecifiers()
        {
            DeclarationSpecifiers o;
            o.type = type==Type::INT ? DeclarationSpecifiers::Type::INT : DeclarationSpecifiers::Type::DOUBLE;
            return o;
        }
};

class Expression
{
    private:
        struct Type_def
        {
            enum type : int
            {
                IDENTIFIER,
                RVALUE
            };
        };

    public:
        typedef safe_enum<Type_def> Type;

        std::string IDENTIFIERVal;
        llvm::Value *rval;
        Type type;
};

class AssignmentOperator
{
    private:
        struct Type_def
        {
            enum type : int
            {
                ASSIGN,
                DIV_ASSIGN,
                MUL_ASSIGN,
                MOD_ASSIGN,
                ADD_ASSIGN,
                SUB_ASSIGN,
                LEFT_ASSIGN,
                RIGHT_ASSIGN,
                AND_ASSIGN,
                XOR_ASSIGN,
                OR_ASSIGN
            };
        };

    public:
        typedef safe_enum<Type_def> Type;

        Type assignType;
};

class AssignmentExpression
{
    private:
        struct Type_def
        {
            enum type : int
            {
                IDENTIFIER,
                RVALUE
            };
        };

    public:
        typedef safe_enum<Type_def> Type;

        explicit operator Expression()
        {
            Expression o;
            o.IDENTIFIERVal = IDENTIFIERVal;
            o.rval = rval;
            if(type == AssignmentExpression::Type::IDENTIFIER)
                o.type = Expression::Type::IDENTIFIER;
            else if(type == AssignmentExpression::Type::RVALUE)
                o.type = Expression::Type::RVALUE;
            return o;
        }

        std::string IDENTIFIERVal;
        llvm::Value *rval;
        Type type;
};

class ConditionalExpression
{
    private:
        struct Type_def
        {
            enum type : int
            {
                IDENTIFIER,
                RVALUE
            };
        };

    public:
        typedef safe_enum<Type_def> Type;

        explicit operator AssignmentExpression()
        {
            AssignmentExpression o;
            o.IDENTIFIERVal = IDENTIFIERVal;
            o.rval = rval;
            if(type == ConditionalExpression::Type::IDENTIFIER)
                o.type = AssignmentExpression::Type::IDENTIFIER;
            else if(type == ConditionalExpression::Type::RVALUE)
                o.type = AssignmentExpression::Type::RVALUE;
            return o;
        }

        std::string IDENTIFIERVal;
        llvm::Value *rval;
        Type type;
};

class LogicalOrExpression
{
    private:
        struct Type_def
        {
            enum type : int
            {
                IDENTIFIER,
                RVALUE
            };
        };

    public:
        typedef safe_enum<Type_def> Type;

        explicit operator ConditionalExpression()
        {
            ConditionalExpression o;
            o.IDENTIFIERVal = IDENTIFIERVal;
            o.rval = rval;
            if(type == LogicalOrExpression::Type::IDENTIFIER)
                o.type = ConditionalExpression::Type::IDENTIFIER;
            else if(type == LogicalOrExpression::Type::RVALUE)
                o.type = ConditionalExpression::Type::RVALUE;
            return o;
        }

        std::string IDENTIFIERVal;
        llvm::Value *rval;
        Type type;
};

class LogicalAndExpression
{
    private:
        struct Type_def
        {
            enum type : int
            {
                IDENTIFIER,
                RVALUE
            };
        };

    public:
        typedef safe_enum<Type_def> Type;

        explicit operator LogicalOrExpression()
        {
            LogicalOrExpression o;
            o.IDENTIFIERVal = IDENTIFIERVal;
            o.rval = rval;
            if(type == LogicalAndExpression::Type::IDENTIFIER)
                o.type = LogicalOrExpression::Type::IDENTIFIER;
            else if(type == LogicalAndExpression::Type::RVALUE)
                o.type = LogicalOrExpression::Type::RVALUE;
            return o;
        }

        std::string IDENTIFIERVal;
        llvm::Value *rval;
        Type type;
};

class InclusiveOrExpression
{
    private:
        struct Type_def
        {
            enum type : int
            {
                IDENTIFIER,
                RVALUE
            };
        };

    public:
        typedef safe_enum<Type_def> Type;

        explicit operator LogicalAndExpression()
        {
            LogicalAndExpression o;
            o.IDENTIFIERVal = IDENTIFIERVal;
            o.rval = rval;
            if(type == InclusiveOrExpression::Type::IDENTIFIER)
                o.type = LogicalAndExpression::Type::IDENTIFIER;
            else if(type == InclusiveOrExpression::Type::RVALUE)
                o.type = LogicalAndExpression::Type::RVALUE;
            return o;
        }
        std::string IDENTIFIERVal;
        llvm::Value *rval;

        Type type;
};

class ExclusiveOrExpression
{
    private:
        struct Type_def
        {
            enum type : int
            {
                IDENTIFIER,
                RVALUE
            };
        };

    public:
        typedef safe_enum<Type_def> Type;

        explicit operator InclusiveOrExpression()
        {
            InclusiveOrExpression o;
            o.IDENTIFIERVal = IDENTIFIERVal;
            o.rval = rval;
            if( type == ExclusiveOrExpression::Type::IDENTIFIER)
                o.type = InclusiveOrExpression::Type::IDENTIFIER;
            else if(type == ExclusiveOrExpression::Type::RVALUE)
                o.type = InclusiveOrExpression::Type::RVALUE;
            return o;
        }

        std::string IDENTIFIERVal;
        llvm::Value *rval;

        Type type;
};

class AndExpression
{
    private:
        struct Type_def
        {
            enum type : int
            {
                IDENTIFIER,
                RVALUE
            };
        };

    public:
        typedef safe_enum<Type_def> Type;

        explicit operator ExclusiveOrExpression()
        {
            ExclusiveOrExpression o;
            o.IDENTIFIERVal = IDENTIFIERVal;
            o.rval = rval;
            if(type == AndExpression::Type::IDENTIFIER)
                o.type = ExclusiveOrExpression::Type::IDENTIFIER;
            else if(type == AndExpression::Type::RVALUE)
                o.type = ExclusiveOrExpression::Type::RVALUE;
            return o;
        }

        std::string IDENTIFIERVal;
        llvm::Value *rval;

        Type type;
};

class EqualityExpression
{
    private:
        struct Type_def
        {
            enum type : int
            {
                IDENTIFIER,
                RVALUE
            };
        };

    public:
        typedef safe_enum<Type_def> Type;

        explicit operator AndExpression()
        {
            AndExpression o;
            o.IDENTIFIERVal = IDENTIFIERVal;
            o.rval = rval;
            if(type == EqualityExpression::Type::IDENTIFIER)
                o.type = AndExpression::Type::IDENTIFIER;
            else if(type == EqualityExpression::Type::RVALUE)
                o.type = AndExpression::Type::RVALUE;
            return o;
        }

        std::string IDENTIFIERVal;
        llvm::Value *rval;

        Type type;
};

class RelationalExpression
{
    private:
        struct Type_def
        {
            enum type : int
            {
                IDENTIFIER,
                RVALUE
            };
        };

    public:
        typedef safe_enum<Type_def> Type;

        explicit operator EqualityExpression()
        {
            EqualityExpression o;
            o.IDENTIFIERVal = IDENTIFIERVal;
            o.rval = rval;
            if(type == RelationalExpression::Type::IDENTIFIER)
                o.type = EqualityExpression::Type::IDENTIFIER;
            else if(type == RelationalExpression::Type::RVALUE)
                o.type = EqualityExpression::Type::RVALUE;
            return o;
        }

        std::string IDENTIFIERVal;
        llvm::Value *rval;

        Type type;
};

class ShiftExpression
{
    private:
        struct Type_def
        {
            enum type : int
            {
                IDENTIFIER,
                RVALUE
            };
        };

    public:
        typedef safe_enum<Type_def> Type;

        explicit operator RelationalExpression()
        {
            RelationalExpression o;
            o.IDENTIFIERVal = IDENTIFIERVal;
            o.rval = rval;
            if(type == ShiftExpression::Type::IDENTIFIER)
                o.type = RelationalExpression::Type::IDENTIFIER;
            else if(type == ShiftExpression::Type::RVALUE)
                o.type = RelationalExpression::Type::RVALUE;
            return o;
        }
        std::string IDENTIFIERVal;
        llvm::Value *rval;
        
        Type type;
};

class AdditiveExpression
{
    private:
        struct Type_def
        {
            enum type : int
            {
                IDENTIFIER,
                RVALUE
            };
        };

    public:
        typedef safe_enum<Type_def> Type;
        
        explicit operator ShiftExpression()
        {
            ShiftExpression o;
            o.IDENTIFIERVal = IDENTIFIERVal;
            o.rval = rval;
            if(type == AdditiveExpression::Type::IDENTIFIER)
                o.type = ShiftExpression::Type::IDENTIFIER;
            else if(type == AdditiveExpression::Type::RVALUE)
                o.type = ShiftExpression::Type::RVALUE;
            return o;
        }

        std::string IDENTIFIERVal;
        llvm::Value *rval;

        Type type;
};

class MultiplicativeExpression
{
    private:
        struct Type_def
        {
            enum type : int
            {
                IDENTIFIER,
                RVALUE
            };
        };

    public:
        typedef safe_enum<Type_def> Type;
        
        explicit operator AdditiveExpression()
        {
            AdditiveExpression o;
            o.IDENTIFIERVal = IDENTIFIERVal;
            o.rval = rval;
            if(type == MultiplicativeExpression::Type::IDENTIFIER)
                o.type = AdditiveExpression::Type::IDENTIFIER;
            else if(type == MultiplicativeExpression::Type::RVALUE)
                o.type = AdditiveExpression::Type::RVALUE;
            return o;
        }
        
        std::string IDENTIFIERVal;
        llvm::Value *rval;

        Type type;
};

class CastExpression
{
    private:
        struct Type_def
        {
            enum type : int
            {
                IDENTIFIER,
                RVALUE
            };
        };

    public:
        typedef safe_enum<Type_def> Type;

        explicit operator MultiplicativeExpression()
        {
            MultiplicativeExpression o;
            o.IDENTIFIERVal = IDENTIFIERVal;
            o.rval = rval;
            if(type == CastExpression::Type::IDENTIFIER)
                o.type = MultiplicativeExpression::Type::IDENTIFIER;
            else if(type == CastExpression::Type::RVALUE)
                o.type = MultiplicativeExpression::Type::RVALUE;
            return o;
        }

        std::string IDENTIFIERVal;
        llvm::Value *rval;

        Type type;
};

class UnaryExpression
{
    private:
        struct Type_def
        {
            enum type : int
            {
                IDENTIFIER,
                RVALUE
            };
        };

    public:
        typedef safe_enum<Type_def> Type;
        
        std::string IDENTIFIERVal;
        llvm::Value *rval;

        explicit operator CastExpression()
        {
            CastExpression o;
            o.IDENTIFIERVal = IDENTIFIERVal;
            o.rval = rval;
            if( type == Type::IDENTIFIER )
                o.type = CastExpression::Type::IDENTIFIER;
            else if(type == Type::RVALUE)
                o.type = CastExpression::Type::RVALUE;
            return o;
        }

        Type type;
};

class PostfixExpression
{
    private:
        struct Type_def
        {
            enum type : int
            {
                IDENTIFIER,
                RVALUE
            };
        };

    public:
        typedef safe_enum<Type_def> Type;

        explicit operator UnaryExpression()
        {
            UnaryExpression o;
            o.IDENTIFIERVal = IDENTIFIERVal;
            o.rval = rval;
            if(type == PostfixExpression::Type::IDENTIFIER)
                o.type = UnaryExpression::Type::IDENTIFIER;
            else if(type == PostfixExpression::Type::RVALUE)
                o.type = UnaryExpression::Type::RVALUE;
            return o;
        }

        std::string IDENTIFIERVal;
        llvm::Value *rval;

        Type type;
};
class PrimaryExpression
{
    private:
        struct Type_def
        {
            enum type : int
            {
                IDENTIFIER,
                RVALUE
            };
        };

    public:
        typedef safe_enum<Type_def> Type;

        explicit operator PostfixExpression()
        {
            PostfixExpression o;
            o.IDENTIFIERVal = IDENTIFIERVal;
            o.rval = rval;
            if(type == PrimaryExpression::Type::IDENTIFIER)
                o.type = PostfixExpression::Type::IDENTIFIER;
            else if(type == PrimaryExpression::Type::RVALUE)
                o.type = PostfixExpression::Type::RVALUE;
            return o;
        }

        std::string IDENTIFIERVal;
        llvm::Value *rval;

        Type type;
};

#endif
