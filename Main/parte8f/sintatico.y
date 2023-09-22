/*+-------------------------------------------------------------
  |          UNIFAL - Universidade Federal de Alfenas.
  |            BACHARELADO EM CIENCIA DA COMPUTACAO
  | Trabalho..: Funcao com retorno
  | Disciplina: Teoria de Linguagens e Compiladores
  | Professor.: Luiz Eduardo da Silva
  | Aluno.....: Vinicius Eduardo de Souza Honorio
  | Data......: 
  +-------------------------------------------------------------*/

%{
#include "lexico.c"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "utils.c"

int contaVar; // numero de variaveis (locais e globais) do programa
int contaPar; // numero temporario de parametros de uma funcao
int rotulo = 1; // numeracao do rotulo para desvio
int tipo; // variavel auxiliar para definicao de tipo (INT, LOG)
char escopo; // variavel auxiliar para definicao de escopo (g, l)
int tempAux;

%}

%token T_PROGRAMA
%token T_INICIO
%token T_FIM
%token T_LEIA
%token T_ESCREVA
%token T_SE
%token T_ENTAO
%token T_SENAO
%token T_FIMSE
%token T_FACA
%token T_ENQTO
%token T_FIMENQTO
%token T_INTEIRO
%token T_LOGICO
%token T_RETORNE
%token T_FUNC
%token T_FIMFUNC
%token T_MAIS
%token T_MENOS
%token T_VEZES
%token T_DIV
%token T_ATRIBUI
%token T_MAIOR
%token T_MENOR
%token T_IGUAL
%token T_E
%token T_OU
%token T_NAO
%token T_ABRE
%token T_FECHA
%token T_V 
%token T_F 
%token T_IDENTIF
%token T_NUMERO

%start programa 
%expect 1


%left T_E T_OU 
%left T_IGUAL 
%left T_MAIOR T_MENOR 
%left T_MAIS T_MENOS 
%left T_VEZES T_DIV

%%


programa
    // Estrutura do Programa
    : cabecalho 
        { contaVar = 0; escopo = 'g'; }
    // Declaracao das Variaveis
    variaveis 
        { 
            mostraTabela();
            empilha(contaVar, 'n');
            if (contaVar) 
                fprintf(yyout,"\tAMEM\t%d\n", contaVar); 
            
        }
        {fprintf(yyout, "\tDSVS\t0\n");}
   lista_funcoes
        {fprintf(yyout, "\tNADA\t0\n");}
       T_INICIO lista_comandos T_FIM
        { 
            int contaVarTemp = desempilha('n');
            if (contaVarTemp)
                fprintf(yyout,"\tDMEM\t%d\n", contaVarTemp); 
            fprintf(yyout,"\tFIMP\n");
        }
    ;

cabecalho
    // Sintaxe do Cabecalho do Programa (Nome)
    : T_PROGRAMA T_IDENTIF
        { fprintf(yyout,"\tINPP\n"); }
    ;

variaveis
    // Declaracao das variaveis globais do programa
    :
    | declaracao_variaveis
    ;

declaracao_variaveis
    // Sintaxe da declaracao das variaveis (globais ou locais) do programa
    : tipo lista_variaveis declaracao_variaveis
    | tipo lista_variaveis
    ;

tipo
    // Definicao do tipo das variaveis (LOG ou INT)
    : T_LOGICO 
        { tipo = LOG; }
    | T_INTEIRO
        { tipo = INT; }
    ;

lista_variaveis
    // Preenchimento das Variaveis na Tabela de Simbolos
    : lista_variaveis T_IDENTIF 
        { 
          strcpy(elemTab.id, atoma);
          elemTab.end = contaVar;
          elemTab.tip = tipo;
          elemTab.esc = escopo;
          elemTab.cat = 'v';
          insereSimbolo(elemTab);
          contaVar++; 
        }
    | T_IDENTIF
        { 
          strcpy(elemTab.id, atoma);
          elemTab.end = contaVar;
          elemTab.tip = tipo;
          elemTab.esc = escopo;
          elemTab.cat = 'v';
          insereSimbolo(elemTab);
          contaVar++;
        }
    ;

lista_funcoes
    // Lista de Funcoes
    : /* vazio */
    | funcao lista_funcoes
    ;

funcao
    // Preenchimento da Variavel de Retorno da Funcao
    : T_FUNC tipo T_IDENTIF 
    {
        printf("Vai ler a porcaria da funcao");
        escopo = 'l';
        contaPar = 0;
        strcpy(elemTab.id, atoma);
        elemTab.tip = tipo;
        elemTab.cat = 'f';
        elemTab.esc = 'g';
        elemTab.rot = ++rotulo;
        insereSimbolo(elemTab);
        contaVar++;
        fprintf(yyout,"L%d\tENSP\n", rotulo);
    // buscaRot = buscaSimbolo.elemTab id;

    }
    // Registro dos Parametros na Tabela de Simbolos
    T_ABRE lista_parametros T_FECHA
        {
            ajustar_parametros(elemTab.id);
        }
      variaveis T_INICIO lista_comandos T_FIMFUNC
      {
        posTab = posTab - contaPar;
        escopo = 'g';
      }
    ;

lista_parametros
    :
    | parametro lista_parametros
    ;

parametro 
    // Preenchimento dos Parametros na Tabela de Simbolos
    : tipo T_IDENTIF
    {
        contaPar++;
        strcpy(elemTab.id, atoma);
        elemTab.tip = tipo;
        elemTab.esc = 'l';
        elemTab.cat = 'p';
        insereSimbolo(elemTab);
        contaVar++;
    }
    ;


lista_comandos
    :
    | comando lista_comandos
    ;

comando
    // Possiveis operacoes a serem realizadas
    : entrada_saida
    | repeticao 
    | selecao
    | atribuicao 
    | retorne
    ;

retorne
    // Faz com que a funcao encerre e devolva seu valor definido
    : T_RETORNE expressao
        {
            // Falta conferir a atribuir a funcao ao elemento elemTab (creio estar certa)
            int tip = desempilha('t');
            if(tip != elemTab.tip) yyerror("Retorno com Tipo Errado");
            fprintf(yyout, "\tARZL\t%d\n", elemTab.end);
            int nvar = desempilha('n');
            fprintf(yyout, "\tDMEM\t%d\n", nvar);
            fprintf(yyout, "\tRTSP\t%d\n", elemTab.npa);
        }
    ;

entrada_saida
    // Operacoes de entrada e saida (Leitura e Escrita)
    : leitura
    | escrita
    ;


leitura
    // Armazena uma variavel lida
    : T_LEIA T_IDENTIF
        { 
            int pos = buscaSimbolo(atoma);
            /*int tip = desempilha('t');
            if(tip != tabSimb[pos].tip) yyerror("Incompatibilidade de tipo!");*/
            if(escopo == 'g')
                fprintf(yyout,"\tLEIA\n\tARZG\t%d\n", tabSimb[pos].end);
            else
                fprintf(yyout,"\tLEIA\n\tARZL\t%d\n", tabSimb[pos].end);
        }
    ;

escrita
    // Escreve a variavel carregada da memoria
    : T_ESCREVA expressao 
        {
            desempilha('t'); 
            fprintf(yyout,"\tESCR\n");
        }
    ;

repeticao
    // Laco de repeticao while
    : T_ENQTO
        { 
            fprintf(yyout,"L%d\tNADA\n", ++rotulo); 
            empilha(rotulo, 'r');
        } 
    expressao T_FACA  
        { 
            int tip = desempilha('t');
            if(tip != LOG) yyerror("Incompatibilidade de tipo!");
            fprintf(yyout,"\tDSVF\tL%d\n", ++rotulo); 
            empilha(rotulo, 'r');
        }
    lista_comandos
    T_FIMENQTO
        {
            int rot1 = desempilha('r');
            int rot2 = desempilha('r');
            fprintf(yyout,"\tDSVS\tL%d\nL%d\tNADA\n", rot2, rot1); 

        }
    ;

selecao
    // Comando de repeticao if then else
    : T_SE expressao T_ENTAO 
        { 
            int tip = desempilha('t');
            if(tip != LOG) yyerror("Incompatibilidade de tipo!");
            fprintf(yyout,"\tDSVF\tL%d\n", ++rotulo);
            empilha(rotulo, 'r'); 
        }
    lista_comandos T_SENAO 
        {
            int rot = desempilha('r'); 
            fprintf(yyout,"\tDSVS\tL%d\nL%d\tNADA\n", ++rotulo, rot); 
            empilha(rotulo, 'r');
        }
    lista_comandos T_FIMSE
        {
            int rot = desempilha('r'); 
            fprintf(yyout,"L%d\tNADA\n", rot); 
        }
    ;

// Talvez precise mudar para o caso de variaveis locais
atribuicao
    // Atribuicao de um valor lido a uma variavel armazenada
    : T_IDENTIF
        {
            int pos = buscaSimbolo(atoma);
            empilha(pos, 'p');
            //empilha(tabSimb[pos].tip, 't');
        } 
      T_ATRIBUI expressao 
        { 
            int tip = desempilha('t');
            int pos = desempilha('p');
            if(tabSimb[pos].tip != tip) yyerror("Incompatibilidade de tipo!");
            if(escopo == 'g')
                fprintf(yyout,"\tARZG\t%d\n", tabSimb[pos].end); 
            else
                fprintf(yyout,"\tARZL\t%d\n", tabSimb[pos].end);
        }

expressao
    // Tipos de operacoes para expressao (soma, multiplicacao, divisao,...)
    : T_IDENTIF chamada // precisa empilhar tipo e pedir endereço
    | expressao T_VEZES expressao 
        { 
            testaTipo(INT, INT, INT);
            fprintf(yyout,"\tMULT\n"); 
        }
    | expressao T_DIV expressao 
        { 
            testaTipo(INT, INT, INT);
            fprintf(yyout,"\tDIVI\n"); 
        }
    | expressao T_MAIS expressao
        {   
            testaTipo(INT, INT, INT);
            fprintf(yyout,"\tSOMA\n"); 
        } 
    | expressao T_MENOS expressao
        { 
            testaTipo(INT, INT, INT);
            fprintf(yyout,"\tSUBT\n"); 
        } 
    | expressao T_MAIOR expressao
        { 
            testaTipo(INT, INT, LOG);
            fprintf(yyout,"\tCMMA\n"); 
        } 
    | expressao T_MENOR expressao 
        {
            testaTipo(INT, INT, LOG);
            fprintf(yyout,"\tCMME\n"); 
        }
    | expressao T_IGUAL expressao
        { 
            testaTipo(INT, INT, LOG);
            fprintf(yyout,"\tCMIG\n");
        } 
    | expressao T_E expressao 
        { 
            testaTipo(LOG, LOG, LOG);
            fprintf(yyout,"\tCONJ\n"); 
        }
    | expressao T_OU expressao
        { 
            testaTipo(LOG, LOG, LOG);
            fprintf(yyout,"\tDISJ\n"); 
        } 
    | termo 
    ;

chamada
    : // sem parametros eh uma variavel
    | T_ABRE 
        {  
            //int pos = buscaSimbolo(atoma);
            // fprintf(yyout, "\tAMEM\t%d\n", tabSimb[pos].end);
            fprintf(yyout, "\tAMEM\t1\n");
        }
    lista_argumentos T_FECHA
        {
            fprintf(yyout, "\tSVCP\n\tDSVS\tL%d\n", rotulo); // o rotulo da funcao a ser chamada deve ser recuperado
        }
    ;

lista_argumentos
    : 
    | expressao lista_argumentos
    ;


/*identificador
    // Identificador
    : T_IDENTIF
       { 
            int pos = buscaSimbolo(atoma);
            if(escopo == 'g')
                fprintf(yyout,"\tCRVG\t%d\n", tabSimb[pos].end);
            else
                fprintf(yyout,"\tCRVL\t%d\n", tabSimb[pos].end);
            empilha(tabSimb[pos].tip, 't');
       }
    ;*/

//termo : identificador chamada
//    | T_NUMERO
//    :
//    ;

termo 
    : T_IDENTIF//identificador chamada
       { 
            int pos = buscaSimbolo(atoma);
            if(escopo == 'g')
                fprintf(yyout,"\tCRVG\t%d\n", tabSimb[pos].end);
            else
                fprintf(yyout,"\tCRVL\t%d\n", tabSimb[pos].end);
            empilha(tabSimb[pos].tip, 't');
        }
    | T_NUMERO
        { 
            fprintf(yyout,"\tCRCT\t%s\n", atoma); 
            empilha(INT, 't');
        }
    | T_V 
        { 
            fprintf(yyout,"\tCRCT\t1\n"); 
            empilha(LOG, 't');    
        }
    | T_F 
        { 
            fprintf(yyout,"\tCRCT\t0\n");
            empilha(LOG, 't');    
        }
    | T_NAO termo
        {
            int t = desempilha('t');
            if(t != LOG) yyerror("Incompatibilidade de tipo!");
            fprintf(yyout,"\tNEGA\n"); 
            empilha(LOG, 't');
        }
    | T_ABRE expressao T_FECHA
    ;

%%


int main (int argc, char *argv[]) {
    char *p, nameIn[100], nameOut[100];
    argv++;
    if (argc < 2) {
        puts("\nCompilador Simples");
        puts("\n\tUso: ./simples <NOME>[.simples]\n\n");
        exit(10);
    }
    p = strstr(argv[0], ".simples");
    if (p) *p = 0;
    strcpy(nameIn, argv[0]);
    strcat(nameIn, ".simples");
    strcpy(nameOut, argv[0]);
    strcat(nameOut, ".mvs");
    yyin = fopen (nameIn, "rt");
    if (!yyin) {
        puts("Programa fonte não encontrado!");
        exit(20);
    }
    yyout = fopen(nameOut, "wt");
    yyparse();
    puts("Programa ok!");
}