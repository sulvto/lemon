
%include {
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "example1.h"
}

%token_type  { double }
%left PLUS   MINUS.
%left DIVIDE TIMES.

%syntax_error {
    printf("Syntax error!\n");
    exit(1);
}


program ::= expr(A). { printf("Result = %f\n",A); }
expr(A) ::= expr(B) MINUS   expr(C).  { A = B - C; }
expr(A) ::= expr(B) PLUS    expr(C).  { A = B + C; }
expr(A) ::= expr(B) TIMES   expr(C).  { A = B * C; }
expr(A) ::= expr(B) DIVIDE  expr(C).  { 
        if (C != 0) {
            A = B/C;
        } else {
            printf("divide by zero");
        }
} // end of DIVIDE

expr(A) ::= INTEGER(B).               { A = B; }  

%code {
int main() {
    void* pParser = ParseAlloc (malloc);
    Parse (pParser, INTEGER, 50.5);
    Parse (pParser, PLUS, 0);
    Parse (pParser, INTEGER, 125.5);
    Parse (pParser, TIMES, 0);
    Parse (pParser, INTEGER, 125.5);
    Parse (pParser, 0, 0);
    ParseFree(pParser, free);
    
  }
}

