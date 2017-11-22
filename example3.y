
%include {
    #include <stdio.h>   
    #include <stdlib.h>
    #include <string.h>
    #include <assert.h> 
    #include <math.h>   
    #include <ctype.h>
    #include "example3.h"
    
    
    struct Token {
        double value;
        int n;
    };

}

%token_type  { struct Token }
%default_type { struct Token } 

%left PLUS   MINUS.
%left DIVIDE TIMES.
%left POW   NOT.

%parse_accept {
    printf("parsing completa!\n");
}


%syntax_error {
    printf("Syntax error!\n");
    exit(1);
}


main ::= in.
in ::= .
in ::= in program NEWLINE.

program ::= expr(A). { 
    printf("= %f\n", A.value);
}

expr(A) ::= expr(B) MINUS   expr(C).  { A.value = B.value - C.value; }
expr(A) ::= expr(B) PLUS    expr(C).  { A.value = B.value + C.value; }
expr(A) ::= expr(B) TIMES   expr(C).  { A.value = B.value * C.value; }
expr(A) ::= expr(B) DIVIDE  expr(C).  { 
        if (C.value != 0) {
            A.value = B.value / C.value;
        } else {
            printf("divide by zero");
        }
} // end of DIVIDE


// use pow 
// gcc example3.c -0 example3 -lm

expr(A) ::= expr(B) POW expr(C).    { A.value = pow(B.value, C.value); }
expr(A) ::= MINUS expr(B).[NOT]     { A.value = -B.value; }
expr(A) ::= LP expr(B) RP.          { A.value = B.value; }

expr(A) ::= NUM(B).                 { A.value = B.value; A.n = B.n + 1; }  

%code {
    static int getToken(const char *z, int *tokenType) {
        int i,c;

        switch (*z) {
            case '\n' : {
                    *tokenType = NEWLINE;
                    return 1;
                }
           
            case '-' : {
                    *tokenType = MINUS;
                    return 1;
                }

            case '+' : {
                    *tokenType = PLUS;
                    return 1;
                }

            case '*' : {
                    *tokenType = TIMES;
                    return 1;
                }

            case '/' : {
                    *tokenType = DIVIDE;
                    return 1;
                }

            case '^' : {
                    *tokenType = POW;
                    return 1;
                }

            case '(' : {
                    *tokenType = LP;
                    return 1;
                }

            case ')' : {
                    *tokenType = RP;
                    return 1;
                }

            case '0': case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9': {
                    for (i=1; isdigit(z[i]); i++) {}
                    if (z[i]=='.' && isdigit(z[i+1])) {
                        i += 2;
                        while (isdigit(z[i]))  {
                            i++;    
                        }
                    }
                    *tokenType = NUM;
                    return i;
                }

            default: {
                    *tokenType = -1;
                    return 1;
                }


        }           

    }

    static char* getstring (char *z, int n) {
        char* paz;
        paz = (char *)malloc( n + 1);
        if (paz == 0) {
            printf("out of memory\n");
            exit(1);
        }
        strncpy(paz, z, n);
        paz[n] = '\0';
        return paz;      
    }


    int main() {
        FILE *f;
        f  = fopen("record.txt", "w");
        ParseTrace(f, "");

        struct Token* t0;
        int n;
        char* z;
        int* tokenType;

        t0 = (struct Token *)malloc(sizeof(struct Token));
        if ( t0==0 ) {
            printf("out of memory\n");
            exit(1);
        }

        t0->value = 0.0;
        t0->n = 0;

        tokenType = (int*)malloc(sizeof(int));
        if ( tokenType==0 ) {
            printf("out of memory\n");
            exit(1);
        }     
        
        z = (char*)malloc(1024);
        if ( z==0 ) {
            printf("out of memory\n");
            exit(1);
        }                                                     


        void* pParser = ParseAlloc (malloc);

        while (1) {
            gets(z);
            if (z == "") break;
            strcat(z, "\n");
            while (*z) {
                n = getToken(z, tokenType);
                
                if (*tokenType == NUM) {
                    char* s = getstring(z, n);
                    t0->value = atof(s);
                }
        
                if (*tokenType >= 0) {
                    Parse(pParser, *tokenType, *t0);
                }

                z = z + n;
            }
        }

    
        Parse (pParser, 0, *t0);
        ParseFree(pParser, free);    
        ParseTrace(NULL, "");
        fclose(f);
        return 0; 
    }
}

