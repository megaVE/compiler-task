# Compiler Task (Tarefa de Compiladores)

EN: My solution for the final proposed task from the Language Theory and Compilers discipline, during the 4th period of the course.
PT: Resolução minha do trabalho final proposto durante a disciplina de Teoria de Linguagens e Compiladores, no 4º Período do curso.

## Task Description (Descrição do Trabalho)

Development of the functions scope of the program, as well as the implementation of the "retorn" instruction, which allows for the funciton to be ended and return its value. Also some other changes and adaptations were made to the base source code to make this possible and better.

(Desenvolvimento do escopo de funções do programa, bem como a implementação da instrução "retorne", que encerra a execução da função e retorna seu valor. Também outras mudanças e adaptações foram feitas ao código base para fazer isso possível e melhor.)

## Folders and Files Overview (Visão Geral das Pastas e Arquivos)
- /Examples:
  - EN: Sample programs for the compiler to run.
  - PT: Programas de exemplo para o compilador copilar.
- /Main:
  - All the development versions for the compiler task.
  - Todas as versões do desenvolvimento para a tarefa do compilador.
- **Simples Compiler.jar**:
  - Allows for SIMPLES language programs to be compiled and runned
  - Permite programas da linguagem SIMPLES serem compilados e rodados

## Setup (Configuração)

### Requirements (Requisitos)
- Windows 10, 64 bits
- WSL
- Docker Desktop

### Tutorial
1. Create a new folder on VS Code.\
(Crie uma nova pasta no VS Code.)
2. Have both **docker-compose.yaml** and **Dockerfile** files inside this root folder.\
(Tenha ambos os arquivos **docker-compose.yaml** e **Dockerfile** na raiz desta pasta.)
3. Create a new folder inside the root folder called **projects**.\
(Crie uma nova pasta dentro desta pasta raiz chamada **projects**.)
4. Compose up the .yaml file.\
(Use a opção "Compose Up" no arquivo .yaml.)
5. Attach a Shell to the project with the option Docker->Container->Attach Shell from **VS Code's Docker Extention**.\
(Anexe um Shell ao projeto pela opção Docker->Container->Attach Shell pela **Extensão do Docker do VS Code**)
