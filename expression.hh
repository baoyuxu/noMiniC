#ifndef __EXPRESSION_HH__
#define __EXPRESSION_HH__

#include "common.hh"

class PrimaryExpression
{
    public:
        enum Type
        {
            IDENTIFIER,
            constant,
            expression
        };

        std::string IDENTIFIERVal;
        llvm::Constant *constantVal;
        llvm::Value *expressionVal;

        Type type;

};

#endif
