#ifndef __EXPRESSION_HH__
#define __EXPRESSION_HH__

#include "common.hh"

class PrimaryExpression
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

class PostfixExpression
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

class UnaryExpression
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

class CastExpression
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

class MultiplicativeExpression
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

class AdditiveExpression
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

class ShiftExpression
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

class RelationalExpression
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

class EqualityExpression
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

class AndExpression
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

class ExclusiveOrExpression
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


#endif
