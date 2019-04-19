#ifndef __EXPRESSION_HH__
#define __EXPRESSION_HH__

#include "common.hh"


template<typename def, typename inner = typename def::type> 
class safe_enum : public def
{
    private:
        typedef inner type;
        type val;
    public:
        safe_enum(){};
        safe_enum(type v)
            :val(v){}
        safe_enum &operator=(const type v)
        {
            val = v;
            return *this;
        }

        type underlying() const { return val; }

        friend bool operator == (const safe_enum &lhs, const safe_enum &rhs) { return lhs.val == rhs.val; }
        friend bool operator <= (const safe_enum &lhs, const safe_enum &rhs) { return lhs.val <= rhs.val; }
        friend bool operator != (const safe_enum &lhs, const safe_enum &rhs) { return lhs.val != rhs.val; }
        friend bool operator >= (const safe_enum &lhs, const safe_enum &rhs) { return lhs.val >= rhs.val; }
        friend bool operator <  (const safe_enum &lhs, const safe_enum &rhs) { return lhs.val <  rhs.val; }
        friend bool operator >  (const safe_enum &lhs, const safe_enum &rhs) { return lhs.val >  rhs.val; }
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

        std::string IDENTIFIERVal;
        llvm::Value *rval;

        Type type;
};
class InclusiveOrExpression
{
    public:
        enum Type
        {
            IDENTIFIER,
            RVALUE
        };
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

        std::string IDENTIFIERVal;
        llvm::Value *rval;
        Type type;
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

#endif
