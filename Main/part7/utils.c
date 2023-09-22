/*+-------------------------------------------------------------
  |          UNIFAL - Universidade Federal de Alfenas.
  |            BACHARELADO EM CIENCIA DA COMPUTACAO
  | Trabalho..: Funcao com retorno
  | Disciplina: Teoria de Linguagens e Compiladores
  | Professor.: Luiz Eduardo da Silva
  | Aluno.....: Vinicius Eduardo de Souza Honorio
  | Data......: 
  +-------------------------------------------------------------*/

#include <ctype.h>

#define TAM_TAB 100
#define MAX_PAR 20

enum {INT, LOG};

void mostra_pilha(int lim);
int desempilha(char tipo);
void empilha(int valor, char tipo);

// Tabela de Simbolos

struct elemTabSimbolos {
    char id[100]; 
    int end;            //endereço (global) ou deslocamento (local)
    int tip;            // tipo: 0 = inteiro, 1 = logico
    char cat;           //categoria: "f" = Função, "p" = Parametro, ou "v" = Variavel
    char esc;           // escopo "g" = Global, "l" = Local
    int rot;            // rotulo (especifico para função)
    int npa;            // numero de parametros (para função)
    int par[MAX_PAR];   //Tipos dos parametros (para função)
} tabSimb[TAM_TAB], elemTab;

int posTab = 0; 

void maiscula (char *s) {
    for(int i = 0; s[i]; i++)
        s[i] = toupper(s[i]);
}

int buscaSimbolo(char *id)
{
    // Busca, pelo Identificador, Determinada Variavel na Tabela de Simbolos
    int i;
    //maiscula(id);
    for (i = posTab - 1; strcmp(tabSimb[i].id, id) && i >= 0; i--)
        ;
    if (i == -1) {
        char msg[200];
        sprintf(msg, "Identificador [%s] não encontrado!", id);
        yyerror(msg);
    }
    return i;
}
void insereSimbolo (struct elemTabSimbolos elem) {
    int i; 
    //maiscula(elem.id);
    if (posTab == TAM_TAB)
        yyerror("Tabela de Simbolos Cheia!");
    for (i = posTab - 1; strcmp(tabSimb[i].id, elem.id) && i >= 0; i--)
        ;
    if (i != -1) {
        char msg[200];
        sprintf(msg, "Identificador [%s] duplicado!", elem.id);
        yyerror(msg);
    }
    tabSimb[posTab++] = elem; 
}

void mostraTabela () {
    // Imprime a Tabela de Simbolos
    puts("Tabela de Simbolos");
    puts("------------------");
    printf("\n%30s | %s | %s | %s | %s | %s | %s \n", "ID", "END", "TIP", "CAT", "ESC", "ROT", "NPA");
    for(int i = 0; i < 50; i++) 
        printf(".");
    for(int i = 0; i < posTab; i++)
    {
        printf("\n%30s | %3d | %s | %3c | %3c | %3d | %3d\n", tabSimb[i].id, tabSimb[i].end, tabSimb[i].tip == INT ? "INT" : "LOG", tabSimb[i].cat, tabSimb[i].esc, tabSimb[i].rot, tabSimb[i].npa);
        if(tabSimb[i].cat == 'f' && tabSimb[i].npa > 0)
        {
            printf("PAR");
            for(int j = 0; j < tabSimb[i].npa; j++)
                printf(" ->[%s]", tabSimb[i].tip == INT ? "INT" : "LOG");
        }
        printf("\n");
    }
    printf("\n");
}

void testaTipo(int tipo1, int tipo2, int ret){
    // Compara 2 Tipos de Entrada de uma Expressao e Define o Tipo de Saida desta
    int t1 = desempilha('t');
    int t2 = desempilha('t');
    if(t1 != tipo1 || t2 != tipo2) yyerror("Incompatibilidade de tipo!");
    empilha(ret, 't');
}

// Estrutura para Pilha Semantica

#define TAM_PIL 100
struct{
    int valor;
    char tipo; // 'r' = rotulo, 'n' = numero de variaveis, 't' = tipo, 'p' = endereco
} pilha[TAM_PIL];
int topo = -1;

void empilha (int valor, char tipo) {
    // Adiciona um Elemento na Pilha Semantica do Tipo Informado
    printf("[+]Adicionando (%d, %c) em %d\n", valor, tipo, topo+1);
    if (topo == TAM_PIL)
        yyerror("Pilha semântica cheia");
    pilha[++topo].valor = valor;
    pilha[topo].tipo = tipo;
    printf("! - Pilha Semântica Aumentada - !\n");
    mostra_pilha(topo);
}

int desempilha(char tipo) {
    // Remove um Elemento da Pilha Semantica do Tipo Solicitado
    printf("[-]Removendo [%c] de %d\n", tipo, topo);
    if (topo == -1)
        yyerror("Pilha semântica vazia");
    if(pilha[topo].tipo != tipo)
        yyerror("Desempilhamento ERRADO!");
    printf("! - Pilha Semântica Reduzida - !\n");
    mostra_pilha(topo-1);
    return pilha[topo--].valor;
}

void mostra_pilha(int lim){
    puts("\nPilha Semantica");
    puts("---------------");
    printf("POS | TIP | VAL\n");
    for(int i = 0; i <= lim; i++)
        printf("%3d | %3c | %3d\n", i, pilha[i].tipo, pilha[i].valor);
    printf("\n");
}

void ajustar_parametros(char *id){
    // Atribui os Enderecos das Variaveis Locais da Funcao
    int base = -3;
    int npar = 0;
    int vpar[MAX_PAR];
    int i = posTab;
    for(; tabSimb[i].id != id; i--){
        if(tabSimb[i].tip == INT)
            vpar[npar++] = INT;
        else
            vpar[npar++] = LOG;
        tabSimb[i].end = base--;
    }
    tabSimb[i].end = base;
    tabSimb[i].npa = npar;
    for(int j = 0; j < npar; j++)
        tabSimb[i].par[j] = vpar[j];
}