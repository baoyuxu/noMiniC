#ifndef __CONSTANT_HH_
#define __CONSTANT_HH_

class IConstant
{
    public:
        enum Type
        {
            INT = 10,
            UINT = 20,
            LONG = 30,
            ULONG = 40,
            LONGLONG = 50,
            ULONGLONG = 60
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

        IConstant() = default;
        IConstant(int _iVal, const iType &)
            :iVal(_iVal), type(INT){}
        IConstant(unsigned int _uiVal, const uiType &)
            :uiVal(_uiVal), type(UINT){};
        IConstant(long int _lVal, const lType &)
            :lVal(_lVal), type(LONG){};
        IConstant(unsigned long int _ulVal, const ulType &)
            :ulVal(_ulVal), type(ULONG){};
        IConstant(long long int _llVal, const llType &)
            :llVal(_llVal), type(LONGLONG){};
        IConstant(unsigned long long int _ullVal, const ullType &)
            :ullVal(_ullVal), type(ULONGLONG){};
};

#endif
