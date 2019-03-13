#ifndef __CONSTANT_HH_
#define __CONSTANT_HH_

class I_Constant
{
    public:
        enum Type
        {
            INT,
            UINT,
            LONG,
            ULONG,
            LONGLONG,
            ULONGLONG
        };
        struct iType{};
        struct uiType{};
        struct lType{};
        struct ulType{};
        struct llType{};
        struct ullType{};

        int iVal;
        unsigned int uiVal;
        long int lVal;
        unsigned long int ulVal;
        long long llVal;
        unsigned long long ullVal;
        Type type;

        I_Constant()=default;
        I_Constant(int _iVal, const iType &)
            :iVal(_iVal), type(INT){}
        I_Constant(unsigned int _uiVal, const uiType &)
            :uiVal(_uiVal), type(UINT){};
        I_Constant(long int _lVal, const lType &)
            :lVal(_lVal), type(LONG){};
        I_Constant(unsigned long int _ulVal, const ulType &)
            :ulVal(_ulVal), type(ULONG){};
        I_Constant(long long int _llVal, const llType &)
            :llVal(_llVal), type(LONGLONG){};
        I_Constant(unsigned long long int _ullVal, const ullType &)
            :ullVal(_ullVal), type(ULONGLONG){};
};

class F_Constant
{
    public:
        enum Type
        {
            FLOAT,
            DOUBLE,
            LONG_DOUBLE
        };
        struct fType{};
        struct dType{};
        struct ldType{};

        float fVal;
        double dVal;
        long double ldVal;
        Type type;

        F_Constant()=default;
        F_Constant(float _fVal, const fType &)
            :fVal(_fVal), type(FLOAT){}
        F_Constant(double _dVal, const dType&)
            :dVal(_dVal), type(DOUBLE){}
        F_Constant(long double _ldVal, const ldType&)
            :ldVal(_ldVal), type(LONG_DOUBLE){}
};

#endif
