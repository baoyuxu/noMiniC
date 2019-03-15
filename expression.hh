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

#endif
