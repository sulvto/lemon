
%include {
#include <stdlib.h>
#include <assert.h>
#include "example2.h"


struct Token {
    int value;
    int n;
};

}

%token_type  { struct Token }
%default_type { struct Token } 

%left PLUS   MINUS.
%left DIVIDE TIMES.

%syntax_error {
    printf("Syntax error!\n");
    exit(1);
}


program ::= expr(A). { 
    printf("Result.value = %d\n", A.value);
    printf("Result.n = %d\n", A.n); 
}

expr(A) ::= expr(B) MINUS   expr(C).  { A.value = B.value - C.value; A.n = B.n + 1 + C.n + 1; }
expr(A) ::= expr(B) PLUS    expr(C).  { A.value = B.value + C.value; A.n = B.n + 1 + C.n + 1; }
expr(A) ::= expr(B) TIMES   expr(C).  { A.value = B.value * C.value; A.n = B.n + 1 + C.n + 1; }
expr(A) ::= expr(B) DIVIDE  expr(C).  { 
        if (C.value != 0) {
            A.value = B.value / C.value;
            A.n = B.n + 1 + C.n + 1;
        } else {
            printf("divide by zero");
        }
} // end of DIVIDE

expr(A) ::= NUM(B).               { A.value = B.value; A.n = B.n + 1; }  

%code {
    int main() {
        void* pParser = ParseAlloc (malloc);
        struct Token t0,t1;
        t0.value = 4;
        t0.n = 0;
        t1.value = 13;
        t1.n = 0;
    
        printf("\t to.value(4) PLUS t1.value(13) \n");
        Parse (pParser, NUM, t0);
        Parse (pParser, PLUS, t0);
        Parse (pParser, NUM, t1);
        Parse (pParser, 0, t0);

        printf("\t to.value(4) MINUS t1.value(13) \n");
        Parse (pParser, NUM, t0);
        Parse (pParser, MINUS, t0);
        Parse (pParser, NUM, t1);
        Parse (pParser, 0, t0);

        printf("\t to.value(4) TIMES t1.value(13) PLUS t1.value(13) PLUS t1.value(13) \n");
        Parse (pParser, NUM, t0);
        Parse (pParser, TIMES, t0);
        Parse (pParser, NUM, t1);
        Parse (pParser, PLUS, t0);
        Parse (pParser, NUM, t1);
        Parse (pParser, PLUS, t0);
        Parse (pParser, NUM, t1);
        Parse (pParser, 0, t0);

        ParseFree(pParser, free);
    
    }
}

