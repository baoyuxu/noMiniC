#ifndef __DRIVER_HH__
#define __DRIVER_HH__

#include <string>
#include <map>
#include "parser.hh"

#define YY_DECL \
    yy::parser::symbol_type yylex(driver &drv)

YY_DECL;

class driver
{
    public:
        driver()
            :trace_parsing(false), trace_scanning(false)
        {}

        std::string result;
        int parse(const std::string &f)
        {
            file = f;
            location.initialize (&file);
            scan_begin ();
            yy::parser parse (*this);
            parse.set_debug_level (trace_parsing);
            int res = parse ();
            scan_end ();
            return res;
        }

        std::string file;
        bool trace_parsing;

        void scan_begin();
        void scan_end();
        bool trace_scanning;

        yy::location location;

};

#endif
