
%include {
    #include <stdio.h>   
    #include <stdlib.h>
    #include <string.h>
    #include <assert.h> 
    #include <math.h>   
    #include <ctype.h>
    #include "example4.h"

    #define NUMBER 20    // maximum of symbols

    struct Symbol {
        char* name;
        double value;
    }; 

    union Token {
        double value;
        struct Symbol* symt;
    };

}

%token_type  { union Token }
%default_type { union Token } 

%left PLUS   MINUS.
%left DIVIDE TIMES.
%right POW   NOT.

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


// "=" -> EQ 
program ::= NAME(A) EQ expr(B).     { A.symt->value = B.value; } 

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
// gcc example4.c -0 example4 -lm

expr(A) ::= expr(B) POW expr(C).    { A.value = pow(B.value, C.value); }
expr(A) ::= MINUS expr(B).[NOT]     { A.value = -B.value; }
expr(A) ::= LP expr(B) RP.          { A.value = B.value; }

expr(A) ::= NUM(B).                 { A.value = B.value; }  

expr(A) ::= NAME(B).                { A.value = B.symt->value; }

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

            case '=' : {
                    *tokenType = EQ;
                    return 1;
                }

            case 'A': case 'B': case 'C': case 'D': case 'E': case 'F': 
            case 'G': case 'H': case 'I': case 'J': case 'K': case 'L': 
            case 'M': case 'N': case 'O': case 'P': case 'Q': case 'R': 
            case 'S': case 'T': case 'U': case 'V': case 'W': case 'X': 
            case 'Y': case 'Z':  
            case 'a': case 'b': case 'c': case 'd': case 'e': case 'f': 
            case 'g': case 'h': case 'i': case 'j': case 'k': case 'l': 
            case 'm': case 'n': case 'o': case 'p': case 'q': case 'r': 
            case 's': case 't': case 'u': case 'v': case 'w': case 'x':  
            case 'y': case 'z': {
                    for (i=1; isalnum(z[i]) || z[i]=='_'; i++) {}
                    *tokenType = NAME;
                    return i;
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

    static struct Symbol* symlook(char* s, struct Symbol* symtab) {
        struct Symbol* sp;
        for (sp = symtab; sp < &symtab[NUMBER]; sp++) {
            if (sp->name && !strcmp(sp->name, s)) {
                return sp;
            }

            if (!sp->name) {
                sp->name = s;
                return sp;
            }
        }
        
        printf("Too many symbols!");
        exit(1); 
    }


    int main() {
        FILE *f;
        f  = fopen("record.txt", "w");
        ParseTrace(f, "");

        union Token* t0;
        int n;
        char* z;
        int* tokenType;
        struct Symbol symtab[NUMBER];

        t0 = (union Token *)malloc(sizeof(union Token));
        if ( t0==0 ) {
            printf("out of memory\n");
            exit(1);
        }

        t0->value = 0.0;

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

        for (int i=0; i<NUMBER; i++) {
            symtab[i].value = 0.0;
            symtab[i].name = NULL;
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

                if (*tokenType == NAME) {           
                    char* s = getstring(z, n);
                    t0->symt = symlook(s, symtab);
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

