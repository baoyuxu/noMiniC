#include <stdio.h>

void print_int(int a)
{
    printf("%d", a);
}

void print_double( double d )
{
    printf("%lf", d);
}
void print_char(int ch)
{
    printf("%c", ch);
}
void print_enter()
{
    printf("\n");
}
int read_int()
{
    int a;
    fscanf(stdin, "%d", &a);
    return a;
}
double read_double()
{
    double a;
    fscanf(stdin, "%lf", &a);
    return a;
}
