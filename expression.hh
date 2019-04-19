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
    /*public:
        enum Type
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
        };*/
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
