#ifndef __SAFE_ENUM_HH_
#define __SAFE_ENUM_HH_ 

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

#endif
