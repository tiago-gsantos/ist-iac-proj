; *****************************************************************************
; Projeto IAC 2023
; Grupo 16
; Autores:
;   Tiago Santos - 106329
;   Matilde Santos - 107043
;   Filipe Costa - 106266
;
; Descrição do ficheiro:
;   Este ficheiro corre, no PEPE-16, o jogo "Beyond Mars", onde o jogador tem
;   de defender a sua nave de asteroides em rota de colisão
;   Comandos:
;       '0' - lança sonda esquerda
;       '1' - lança sonda central
;       '2' - lança sonda direita
;       'C' - inicia o jogo
;       'D' - pausa/continua o jogo
;       'E' - termina o jogo
; *****************************************************************************

; *****************************************************************************
;   Constantes
; *****************************************************************************
COMANDOS	    EQU	6000H			   ; endereço de base dos comandos do MediaCenter

DEFINE_LINHA    EQU COMANDOS + 0AH	   ; endereço do comando para definir a linha

DEFINE_COLUNA   EQU COMANDOS + 0CH	   ; endereço do comando para definir a coluna

DEFINE_PIXEL    EQU COMANDOS + 12H     ; endereço do comando para escrever um pixel

DEVOLVE_COR_PIXEL   EQU COMANDOS + 10H ; endereço do comando para ler a cor de um pixel

APAGA_AVISO     EQU COMANDOS + 40H     ; endereço do comando para apagar o aviso de 
                                       ; nenhum cenário selecionado

SELECIONA_ECRÃ  EQU COMANDOS + 04H     ; endereço do comando para selecionar um ecrã

APAGA_ECRÃ      EQU COMANDOS + 02H     ; endereço do comando para apagar todos os 
                                       ; pixels já desenhados

MOSTRA_ECRÃ     EQU COMANDOS + 06H     ; mostra o ecrã selecionado

ESCONDE_ECRÃ    EQU COMANDOS + 08H     ; esconde o ecrã selecionado

SELECIONA_CENARIO   EQU COMANDOS + 42H ; endereço do comando para 
                                       ; selecionar uma imagem de fundo

REPRODUZ_SOM    EQU COMANDOS + 05AH    ; reproduz um som selecionado (0, ..., n-1)

REPRODUZ_SOM_LOOP   EQU COMANDOS + 05CH; reproduz o som selecionado em ciclo

TERMINA_SOM_LOOP    EQU COMANDOS + 066H; para de reproduzir o som selecionado

PAUSA_SOM   EQU COMANDOS + 05EH        ; pausa o som selecionado

CONTINUA_SOM    EQU COMANDOS + 060H    ; continua a reprodução do som selecionado

FUNDO_NORMAL    EQU 0                  ; fundo usado durante o decorrer do jogo

FUNDO_START     EQU 1                  ; fundo usado antes do jogo começar

FUNDO_PAUSE     EQU 2                  ; fundo usado quando se dá pause

FUNDO_GAME_OVER EQU 3                  ; fundo usado quando o user termina o jogo carregando
                                       ; na tecla correspondente do teclado

FUNDO_GAME_OVER_ENERGIA     EQU 4      ; fundo usado quando o jogo termina porque a nave
                                       ; ficou sem energia 

FUNDO_GAME_OVER_EXPLOSAO    EQU 5      ; fundo usado quando o jogo termina porque a nave explodiu

VERMELHO	EQU	0FF00H  		       ; vermelho em ARGB (opaco e 
                                       ; vermelho no máximo, verde e azul a 0)

AZUL_NEON   EQU 0F0FFH                 ; azul néon em ARGB (tudo no máximo menos o 
                                       ; vermelho que está a 0)

VERDE_NEON  EQU 0F0F0H                 ; verde néon em ARGB (verde e opaco no máximo, 
                                       ; vermelho e azul a 0)

AMARELO     EQU 0FFF0H                 ; amarelo em ARGB (tudo no máximo menos azul
                                       ; que está a 0)

AZUL		EQU 0F26BH                 ; azul para a nave em ARGB

AZUL_CLARO	EQU 0F79CH                 ; azul claro para a nave em ARGB

CINZA_1		EQU 0F888H                 ; cinza para a nave em ARGB

CINZA_2		EQU	0F666H                 ; cinza menos claro que o 1 para a nave em ARGB

CINZA_3		EQU 0F444H                 ; cinza menos claro que o 2 para a nave em ARGB

CINZA_4		EQU 0F222H                 ; cinza menos claro que o 3 para a nave em ARGB

ROXO   EQU 0F94FH                      ; cor usada na sonda em ARGB

DISPLAYS    EQU 0A000H                 ; endereço dos displays de 7 segmentos
                                       ; (periférico POUT-1)

TEC_LIN     EQU 0C000H                 ; endereço das linhas do teclado
                                       ; (periférico POUT-2)

TEC_COL     EQU 0E000H                 ; endereço das colunas do teclado
                                       ; (periférico PIN)

LINHA1      EQU 1                      ; linha/coluna 0 do teclado
LINHA4      EQU 8                      ; linha/coluna 3 do teclado

LINHA_MAX_ECRÃ      EQU 31             ; índice máximo para as linhas do ecrã
COLUNA_MAX_ECRÃ     EQU 63             ; índice máximo para as colunas do ecrã

ECRÃ_ASTEROIDE_0    EQU 0              ; primeiro ecrã de asteroides, todos os asteroides
                                       ; vêm em ecrãs contíguos, ou seja, o
                                       ; ECRÃ_ASTEROIDE_4 seria ECRÃ_ASTEROIDE_0 + 3

ECRÃ_SONDAS    EQU 4                   ; ecrã das sondas

ECRÃ_NAVE   EQU 5                      ; ecrã da nave

MASCARA     EQU 0FH                    ; para isolar os 4 bits de menor peso,
                                       ; ao ler as colunas do teclado

LARGURA_NAVE    EQU 15                 ; largura da nave

ALTURA_NAVE     EQU 7                  ; altura da nave

LARGURA_ASTEROIDE_Ñ_MINERÁVEL   EQU 5  ; largura da template de um
                                       ; asteróide não minerável
ALTURA_ASTEROIDE_Ñ_MINERÁVEL    EQU 7  ; altura da template anterior

LARGURA_ASTEROIDE_Ñ_MINERÁVEL_DESTRUÍDO   EQU 5  ; largura da template de um
                                                 ; asteróide não minerável
                                                 ; após ser destruido
ALTURA_ASTEROIDE_Ñ_MINERÁVEL_DESTRUÍDO    EQU 4  ; altura da template anterior

LARGURA_ASTEROIDE_MINERÁVEL     EQU 7  ; largura da template de um
                                       ; asteróide minerável
ALTURA_ASTEROIDE_MINERÁVEL      EQU 7  ; altura da template anterior

LARGURA_ASTEROIDE_MINERÁVEL_DESTRUÍDO     EQU 5  ; largura da template de um
                                                 ; asteróide minerável destruido
ALTURA_ASTEROIDE_MINERÁVEL_DESTRUÍDO      EQU 5  ; altura da template anterior

ALTURA_ASTEROIDE_MINERÁVEL_TOTALMENTE_DESTRUÍDO     EQU 4
;   altura da última template usada na destruição do asteroide minerável
LARGURA_ASTEROIDE_MINERÁVEL_TOTALMENTE_DESTRUÍDO    EQU 4
;   largura desse mesma template

; é de notar que algumas templates de destruição têm linhas em branco para
; o pixel de referência não ter de mudar entre fases da animação de destruição

; Em vez de hitboxes, usa-se um sistema em que se verifica apenas o primeiro
; pixel que irá colidir de acordo com a velocidade que o asteroide tem
; Estes valores devem ser somados ao pixel de referencia e assim chegar
; ao pixel de verificação

; Pixel de colisão de um asteroide minerável (neste caso só é necessário um tipo)
PIXEL_COLISÃO_ASTEROIDE_MINERÁVEL_LINHA     EQU 6          ; é igual em todos
PIXEL_COLISÃO_ASTEROIDE_MINERÁVEL_COLUNA    EQU 3          ; os casos

; Pixel de colisão esquerdo de um asteroide não minerável
PIXEL_COLISÃO_ESQUERDO_ASTEROIDE_Ñ_MINERÁVEL_LINHA  EQU 6  ; quando tem velocidade
PIXEL_COLISÃO_ESQUERDO_ASTEROIDE_Ñ_MINERÁVEL_COLUNA EQU 0  ; para a esquerda

; Pixel de colisão central de um asteroide não minerável
PIXEL_COLISÃO_CENTRAL_ASTEROIDE_Ñ_MINERÁVEL_LINHA   EQU 6  ; quando tem velocidade
PIXEL_COLISÃO_CENTRAL_ASTEROIDE_Ñ_MINERÁVEL_COLUNA  EQU 2  ; apenas para baixo

; Pixel de colisão esquerdo de um asteroide não minerável
PIXEL_COLISÃO_DIREITO_ASTEROIDE_Ñ_MINERÁVEL_LINHA   EQU 6  ; quando tem velocidade
PIXEL_COLISÃO_DIREITO_ASTEROIDE_Ñ_MINERÁVEL_COLUNA   EQU 4 ; para a direita

TAMANHO_TABELA_ASTEROIDES   EQU 20     ; tamanho da tabela dos asteroides

TAMANHO_TABELA_ESTADO_ASTEROIDES    EQU 4   ; tamanho da tabela de estado dos asteroides

MEMORIA_POR_ASTEROIDE   EQU 10         ; memória ocupada por 1 asteróide

QUANTIDADE_DE_ASTEROIDES    EQU 4      ; número máximo de asteroides

MANTEM_ASTEROIDE    EQU 0              ; indica que um asteroide não deve ser destruido

DESTROI_ASTEROIDE   EQU 1              ; indica que um asteroide deve ser destruido

CRIAR_ASTEROIDE     EQU 2              ; indica que um asteroide deve ser criado

FIM_DESTRUIÇÃO_ASTEROIDE    EQU 0      ; indica que a animação de destruição acabou

ASTEROIDE_Ñ_MINERÁVEL   EQU 0          ; indica que o asteroide não é minerável

ASTEROIDE_MINERÁVEL     EQU 1          ; indica que o asteroide é minerável

LINHA_REFERENCIA_NAVE   EQU 25         ; linha do pixel de referência da nave 

COLUNA_REFERENCIA_NAVE  EQU 24         ; coluna do pixel de referência da nave

LINHA_REFERENCIA_LUZES_NAVE     EQU LINHA_REFERENCIA_NAVE + 4   ; linha do pixel de
                                                    ; referência das luzes da nave

NUMERO_FRAMES_NAVE      EQU 8          ; número de frames que a animação da nave tem

CRIAÇÃO_SUPERIOR_ESQ_LINHA      EQU 0  ; linha e coluna do pixel de referência
CRIAÇÃO_SUPERIOR_ESQ_COLUNA     EQU 0  ; para criação de asteroides no
                                       ; canto superior esquerdo

CRIAÇÃO_SUPERIOR_DIR_LINHA      EQU 0  ; linha e coluna do pixel de referência
CRIAÇÃO_SUPERIOR_DIR_COLUNA     EQU 59 ; para criação de asteroides no
                                       ; canto superior direito

CRIAÇÃO_SUPERIOR_CENTRO_LINHA   EQU 0  ; linha e coluna do pixel de referência
CRIAÇÃO_SUPERIOR_CENTRO_COLUNA  EQU 29 ; para criação de asteroides no
                                       ; centro, na parte superior do ecrã

TRANSLAÇÃO_ASTEROIDE_MINERÁVEL  EQU 2  ; translação para o asteroide minerável
                 ; ser criado na mesma coluna que os asteroides não mineráveis

VELOCIDADE_HORIZONTAL_NULA      EQU 0  ; velocidade horizontal nula
VELOCIDADE_HORIZONTAL_DIR       EQU 1  ; velocidade horizontal para a direita
VELOCIDADE_HORIZONTAL_ESQ       EQU -1 ; velocidade horizontal para a esquerda
VELOCIDADE_VERTICAL_BAIXO       EQU 1  ; velocidade vertical para baixo
VELOCIDADE_VERTICAL_CIMA        EQU -1 ; velocidade vertical para cima

INCREMENTO_DISPLAYS     EQU 1          ; incremento para o displays (versão intermédia)

SONDA_EM_RESERVA    EQU -1             ; valor quando uma sonda não está no ecrã
LARGURA_SONDA   EQU 1                  ; largura da template da sonda
ALTURA_SONDA    EQU 1                  ; altura da template da sonda

SONDA_ESQUERDA  EQU 0                  ; posição da sonda esquerda em SONDAS_EM_CURSO
SONDA_CENTRAL   EQU 1                  ; posição da sonda central em SONDAS_EM_CURSO
SONDA_DIREITA   EQU 2                  ; posição da sonda direita em SONDAS_EM_CURSO

MEMORIA_POR_SONDA   EQU 6              ; memória que cada sonda ocupa na tabela

TAMANHO_TABELA_SONDA_EM_CURSO   EQU 3  ; tamanho da tabela que indica
                                       ; que sondas é que estão em curso

LINHA_SONDA_ESQUERDA    EQU 27         ; linha do pixel de referência
                                       ; da sonda esquerda
COLUNA_SONDA_ESQUERDA   EQU 25         ; coluna do pixel de referência
                                       ; da sonda esquerda
LINHA_SONDA_CENTRAL     EQU 24         ; linha do pixel de referência 
                                       ; da sonda central
COLUNA_SONDA_CENTRAL    EQU 31         ; coluna do pixel de referência
                                       ; da sonda central
LINHA_SONDA_DIREITA     EQU 27         ; linha do pixel de referência 
                                       ; da sonda da direita
COLUNA_SONDA_DIREITA    EQU 37         ; coluna do pixel de referência
                                       ; da sonda da direita

NUMERO_MAXIMO_MOV_SONDA EQU 12         ; número máximo de movimentos que uma sonda pode 
                                       ; fazer antes de ser apagada

SOM_EXPLOSÃO    EQU 0                  ; som utilizado na destruição
                                       ; de um asteroide não minerável

SOM_SONDA   EQU 1                      ; som utilizado no disparo de uma sonda

SOM_MINERAÇÃO   EQU 2                  ; som utilizado na destruição
                                       ; de um asteroide minerável

SOM_INICIA  EQU 3                      ; som reproduzido quando um jogo é iniciado

SOM_PAUSA   EQU 4                      ; som reproduzido quando o jogo é pausado

SOM_DESPAUSA    EQU 5                  ; som reproduzido quando o jogo é retomado

SOM_MÚSICA_FUNDO    EQU 6              ; música de fundo do jogo

SOM_TERMINAR_POR_COMANDO    EQU 7      ; som reproduzido quando o comando
                                       ; terminar_jogo é executado

SOM_TERMINAR_POR_ASTEROIDE  EQU 8      ; som reproduzido quando o jogo acaba por colisão

SOM_TERMINAR_POR_ENERGIA    EQU 9      ; som reproduzido quando o jogo acaba por energia

INICIA  EQU 0                          ; indica que o jogo deve iniciar

EM_ANDAMENTO    EQU 1                  ; indica que o jogo está em andamento

PAUSA   EQU 2                          ; indica que o jogo está em pausa

TERMINA     EQU 3                      ; indica que o jogo deve terminar por comando

TERMINA_COM_COMANDO     EQU 0          ; indica que o jogo terminou a pedido do jogador

TERMINA_SEM_COMANDO     EQU 1          ; indica que termina por embate ou energia

TECLA_TERMINA_JOGO  EQU 0EH            ; tecla do comando terminar_jogo

SEM_COMANDO     EQU -1                 ; indica que a tecla premida
                                       ; não tem comando associado

DECREMENTO_BASE    EQU -3              ; decrementa os displays em 3
        ; (valor de decremento base quando o jogo está em andamento)

INCREMENTA_25   EQU 25                 ; incrementa os displays em 25
        ; (valor de energia ganho quando se atinge um asteroide minerável)

DECREMENTA_5    EQU -5                 ; decrementa os displays em 5
                ; (valor de energia perdida quando se lança 1 sonda)

FATOR_CONVERSÃO     EQU 100            ; fator de conversão inicial
                                       ; de hexadecimal para decimal

ENERGIA_INICIAL     EQU 100            ; energia inicial da nave/valor
                                       ; inicial dos displays

ENERGIA_MÁXIMA      EQU 03E7H          ; energia máxima da nave

ALTURA_VIDRO_ANIMADO    EQU 2          ; altura dos frames dos vidros

LARGURA_VIDRO_ANIMADO   EQu 7          ; largura dos frames dos vidros

ALTURA_LUZ_NAVE     EQU 1              ; altura de uma luz da nave

LARGURA_LUZ_NAVE    EQU 1              ; largura de uma luz da nave

ETAPAS_LUZES    EQU 16                 ; número de templates no cinturão de luzes

; *****************************************************************************
;   Inicialização das stacks e da tabela de exceções
; *****************************************************************************
PLACE 1000H

STACK 100H                             ; reserva espaço para a pilha do processo base
SP_main:

STACK 80H                              ; reserva espaço para a pilha dos asteroides
SP_ASTEROIDES:

STACK 80H                              ; reserva espaço para a pilha das sondas
SP_SONDAS:

STACK 80H                              ; reserva espaço para a pilha da energia da nave
SP_ENERGIA_NAVE:

STACK 40H                              ; reserva espaço para a pilha do teclado
SP_TECLADO:

STACK 40H                              ; reserva espaço para a pilha da animação da nave
SP_ANIMA_NAVE:

TABELA_EXCEÇÕES:                       ; define as rotinas de interrupção
    WORD    int_asteroides, int_sondas, int_energia_nave, int_anima_nave


; *****************************************************************************
;   Locks dos processos e estado do jogo
; *****************************************************************************
ESTADO_JOGO:    WORD INICIA            ; define o estado atual do jogo

LOCK_JOGO:  LOCK 0                     ; serve para parar/recomeçar os processos quando
                                       ; o jogo entra em pausa ou termina

TIPO_DE_FIM:    WORD TERMINA_COM_COMANDO    ; variável que comunica ao controlo
                                            ; que tipo de fim executar

LOCK_CONTROLO:  LOCK 0                 ; comunicação processo teclado -> controlo

LOCK_ASTEROIDES:    LOCK 0             ; comunicação int_asteroides -> asteroides

LOCK_SONDAS:    LOCK 0                 ; comunicação int_sondas -> sondas

LOCK_ENERGIA_NAVE:  LOCK 0             ; comunicação para atualizar a energia da nave

LOCK_ANIMACAO_NAVE: LOCK 0             ; comunicação para atualizar o frame da nave


; *****************************************************************************
;   Tabela de comandos
; *****************************************************************************
; Comandos possíveis:
;    0 - cria a sonda esquerda
;    1 - cria a sonda central
;    2 - cria a sonda direita
;    C - inicia o jogo
;    D - pausa/continua o jogo
;    E - termina o jogo
; As outras teclas não têm efeito

TABELA_COMANDOS:
    ; permite mapear facilmente uma ação do jogador a uma funcionalidade
    WORD cria_sonda, cria_sonda, cria_sonda, SEM_COMANDO    ; primeira linha do teclado
    WORD SEM_COMANDO, SEM_COMANDO, SEM_COMANDO, SEM_COMANDO ; segunda linha do teclado
    WORD SEM_COMANDO, SEM_COMANDO, SEM_COMANDO, SEM_COMANDO ; terceira linha do teclado
    WORD inicia_jogo, pausa_jogo, termina_jogo, SEM_COMANDO ; quarta linha do teclado


; *****************************************************************************
;   Templates de desenho
; *****************************************************************************
DEF_NAVE_TEMPLATE:	                   ; tabela que define a nave
    WORD    ALTURA_NAVE                ; altura da template da nave
	WORD    LARGURA_NAVE               ; largura da template da nave
	WORD    0, 0, 0, 0, 0, AZUL, AZUL, AZUL, AZUL_CLARO, AZUL, 0, 0, 0, 0, 0
	WORD    0, 0, 0, 0, AZUL, AZUL, AZUL, AZUL, AZUL, AZUL_CLARO, AZUL, 0, 0, 0, 0
	WORD    0, 0, 0, 0, AZUL, AZUL, AZUL, AZUL, AZUL, AZUL, AZUL, 0, 0, 0, 0
	WORD    0, CINZA_2, CINZA_2, CINZA_1, CINZA_1, CINZA_1, CINZA_1, CINZA_1, CINZA_1
    WORD    CINZA_1, CINZA_1, CINZA_1, CINZA_2, CINZA_2, 0 ; desenhada na linha anterior
	WORD    CINZA_3, VERDE_NEON, CINZA_3, CINZA_3, CINZA_3, AMARELO, CINZA_3
    WORD    CINZA_3, CINZA_3, VERDE_NEON, CINZA_3, CINZA_3, CINZA_3, AMARELO
    WORD    CINZA_3                    ; ultimas 3 linhas são desenhadas todas na mesma
	WORD    0, CINZA_4, CINZA_3, CINZA_3, CINZA_2, CINZA_2, CINZA_2, CINZA_2, CINZA_2
    WORD    CINZA_2, CINZA_2, CINZA_3, CINZA_3, CINZA_4, 0 ; desenhada na linha anterior
	WORD    0, 0, 0, CINZA_4, CINZA_4, CINZA_3, CINZA_3, CINZA_3, CINZA_3, CINZA_3
    WORD    CINZA_4, CINZA_4, 0, 0, 0  ; desenhada na linha anterior

DEF_FRAME1_VIDRO_NAVE:                 ; frame 1 da animação do vidro da nave
    WORD    ALTURA_VIDRO_ANIMADO       ; altura / número de linhas afetadas pela animação
    WORD    LARGURA_VIDRO_ANIMADO      ; largura da template da nave
    WORD    0, AZUL, AZUL, AZUL, AZUL, AZUL_CLARO, 0
	WORD    AZUL, AZUL, AZUL, AZUL, AZUL, AZUL, AZUL_CLARO

DEF_FRAME2_VIDRO_NAVE:                 ; frame 2 da animação do vidro da nave
    WORD    ALTURA_VIDRO_ANIMADO       ; altura / número de linhas afetadas pela animação
    WORD    LARGURA_VIDRO_ANIMADO      ; largura da template da nave
    WORD    0, AZUL, AZUL, AZUL, AZUL, AZUL, 0
	WORD    AZUL, AZUL, AZUL, AZUL, AZUL, AZUL, AZUL

DEF_FRAME3_VIDRO_NAVE:                 ; frame 3 da animação do vidro da nave
    WORD    ALTURA_VIDRO_ANIMADO       ; altura / número de linhas afetadas pela animação
    WORD    LARGURA_VIDRO_ANIMADO      ; largura da template da nave
    WORD    0, AZUL_CLARO, AZUL, AZUL, AZUL, AZUL, 0
	WORD    AZUL_CLARO, AZUL, AZUL, AZUL, AZUL, AZUL, AZUL

DEF_FRAME4_VIDRO_NAVE:                 ; frame 4 da animação do vidro da nave
    WORD    ALTURA_VIDRO_ANIMADO       ; altura / número de linhas afetadas pela animação
    WORD    LARGURA_VIDRO_ANIMADO      ; largura da template da nave
    WORD    0, AZUL, AZUL_CLARO, AZUL, AZUL, AZUL, 0
	WORD    AZUL, AZUL_CLARO, AZUL, AZUL, AZUL, AZUL, AZUL

DEF_FRAME5_VIDRO_NAVE:                 ; frame 5 da animação do vidro da nave
    WORD    ALTURA_VIDRO_ANIMADO       ; altura / número de linhas afetadas pela animação
    WORD    LARGURA_VIDRO_ANIMADO      ; largura da template da nave
    WORD    0, AZUL, AZUL, AZUL_CLARO, AZUL, AZUL, 0
	WORD    AZUL, AZUL, AZUL_CLARO, AZUL, AZUL, AZUL, AZUL

DEF_FRAME6_VIDRO_NAVE:                 ; frame 6 da animação do vidro da nave
    WORD    ALTURA_VIDRO_ANIMADO       ; altura / número de linhas afetadas pela animação
    WORD    LARGURA_VIDRO_ANIMADO      ; largura da template da nave
    WORD    0, AZUL, AZUL, AZUL, AZUL_CLARO, AZUL, 0
	WORD    AZUL, AZUL, AZUL, AZUL, AZUL_CLARO, AZUL, AZUL

DEF_FRAME7_VIDRO_NAVE:                 ; frame 7 da animação do vidro da nave
    WORD    ALTURA_VIDRO_ANIMADO       ; altura / número de linhas afetadas pela animação
    WORD    LARGURA_VIDRO_ANIMADO      ; largura da template da nave
    WORD    0, AZUL, AZUL, AZUL, AZUL_CLARO, AZUL, 0
	WORD    AZUL, AZUL, AZUL, AZUL, AZUL, AZUL_CLARO, AZUL

DEF_LUZ_NAVE_AMARELA:                  ; template de uma luz amarela da nave
    WORD    ALTURA_LUZ_NAVE            ; altura de uma luz da nave
    WORD    LARGURA_LUZ_NAVE           ; largura de uma luz da nave
    WORD    AMARELO                    ; cor da luz

DEF_LUZ_NAVE_VERDE:                    ; template de uma luz verde da nave
    WORD    ALTURA_LUZ_NAVE            ; altura da luz
    WORD    LARGURA_LUZ_NAVE           ; largura da luz
    WORD    VERDE_NEON                 ; cor da luz

DEF_LUZ_NAVE_APAGADA:                  ; template de uma luz da nave, apagada
    WORD    ALTURA_LUZ_NAVE            ; altura da luz
    WORD    LARGURA_LUZ_NAVE           ; largura da luz
    WORD    CINZA_3                    ; a luz neste caso fica da cor do "metal" da nave

DEF_ASTEROIDE_Ñ_MINERÁVEL_TEMPLATE:                        ; alien do space invaders
    WORD    ALTURA_ASTEROIDE_Ñ_MINERÁVEL
    WORD    LARGURA_ASTEROIDE_Ñ_MINERÁVEL
    WORD    VERMELHO, 0, 0, 0, VERMELHO                    ; @   @
    WORD    0, VERMELHO, VERMELHO, VERMELHO, 0             ;  @@@ 
    WORD    VERMELHO, 0, VERMELHO, 0, VERMELHO             ; @ @ @
    WORD    VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO;@@@@@
    WORD    0, VERMELHO, 0, VERMELHO, 0                    ;  @ @ 
    WORD    VERMELHO, 0, VERMELHO, 0, VERMELHO             ; @ @ @
    WORD    VERMELHO, 0, VERMELHO, 0, VERMELHO             ; @ @ @

DEF_ASTEROIDE_Ñ_MINERÁVEL_DESTRUÍDO_TEMPLATE:         ; alien do space invaders destruído
    WORD    ALTURA_ASTEROIDE_Ñ_MINERÁVEL_DESTRUÍDO
    WORD    LARGURA_ASTEROIDE_Ñ_MINERÁVEL_DESTRUÍDO
    WORD    0, AZUL_NEON, AZUL_NEON, AZUL_NEON, 0                   ;  @@@
    WORD    AZUL_NEON, 0, AZUL_NEON, 0, AZUL_NEON                   ; @ @ @
    WORD    AZUL_NEON, AZUL_NEON, AZUL_NEON, AZUL_NEON, AZUL_NEON   ; @@@@@
    WORD    0, AZUL_NEON, 0, AZUL_NEON                              ;  @ @ 

DEF_ASTEROIDE_MINERÁVEL_TEMPLATE:      ; template de um asteroide minerável (estrela)
    WORD    ALTURA_ASTEROIDE_MINERÁVEL
    WORD    LARGURA_ASTEROIDE_MINERÁVEL
    WORD    0, 0, 0, VERDE_NEON, 0, 0, 0                                    ;    @   
    WORD    0, 0, 0, VERDE_NEON, 0, 0, 0                                    ;    @   
    WORD    0, 0, VERDE_NEON, VERDE_NEON, VERDE_NEON, 0, 0                  ;   @@@  
    WORD    VERDE_NEON, VERDE_NEON, VERDE_NEON, VERDE_NEON                  ; @@@@@@@
    WORD    VERDE_NEON, VERDE_NEON, VERDE_NEON                              ;   @@@  
    WORD    0, 0, VERDE_NEON, VERDE_NEON, VERDE_NEON, 0, 0                  ;    @   
    WORD    0, 0, 0, VERDE_NEON, 0, 0, 0                                    ;    @   
    WORD    0, 0, 0, VERDE_NEON, 0, 0, 0
; Nota: a quarta linha foi dividida em duas linhas aqui neste ficheiro porque fica enorme

DEF_ASTEROIDE_MINERÁVEL_DESTRUÍDO_TEMPLATE:
    ; template logo após um asteroide minerável ser destruído
    WORD    ALTURA_ASTEROIDE_MINERÁVEL_DESTRUÍDO
    WORD    LARGURA_ASTEROIDE_MINERÁVEL_DESTRUÍDO
    WORD    0, 0, 0, 0, 0
    WORD    0, 0, 0, 0, 0
    WORD    0, 0, 0, VERDE_NEON, 0                         ;  @ 
    WORD    0, 0, VERDE_NEON, VERDE_NEON, VERDE_NEON       ; @@@
    WORD    0, 0, 0, VERDE_NEON, 0                         ;  @ 

DEF_ASTEROIDE_MINERÁVEL_TOTALMENTE_DESTRUÍDO_TEMPLATE:
    ; template final da destruição de um asteroide minerável
    WORD    ALTURA_ASTEROIDE_MINERÁVEL_TOTALMENTE_DESTRUÍDO
    WORD    LARGURA_ASTEROIDE_MINERÁVEL_TOTALMENTE_DESTRUÍDO
    WORD    0, 0, 0, 0
    WORD    0, 0, 0, 0
    WORD    0, 0, 0, 0
    WORD    0, 0, 0, VERDE_NEON                            ;  @

DEF_SONDA_TEMPLATE:
    WORD    ALTURA_SONDA               ; altura da template da sonda
    WORD    LARGURA_SONDA              ; largura da template da sonda
    WORD    ROXO                       ; cor da sonda


; *****************************************************************************
;   Última número escrito nos displays
; *****************************************************************************
ÚLTIMO_NÚMERO_DISPLAYS:  WORD ENERGIA_INICIAL
; último número escrito nos displays hexadecimais


; *****************************************************************************
;   Frame da animação da nave que vai ser desenhado
; *****************************************************************************
FRAME_ATUAL:  WORD 0
; guarda o frame da animação da nave que vai ser desenhado no ecrã

ETAPA_LUZES_ATUAL:  WORD 0
; guarda em que etapa vai o "cinturão" de luzes da nave


; *****************************************************************************
;   Tipos de velocidade
; *****************************************************************************
VELOCIDADE_DIR_BAIXO:                  ; velocidade para a direita e para para baixo
    WORD    VELOCIDADE_HORIZONTAL_DIR  ; velocidade horizontal para a direita
    WORD    VELOCIDADE_VERTICAL_BAIXO  ; velocidade vertical para baixo

VELOCIDADE_ESQ_BAIXO:                  ; velocidade para a esquerda e para baixo
    WORD    VELOCIDADE_HORIZONTAL_ESQ  ; velocidade horizontal para a esquerda
    WORD    VELOCIDADE_VERTICAL_BAIXO  ; velocidade vertical para baixo

VELOCIDADE_BAIXO:                      ; velocidade para baixo
    WORD    VELOCIDADE_HORIZONTAL_NULA ; não há componente horizontal
    WORD    VELOCIDADE_VERTICAL_BAIXO  ; velocidade vertical para baixo

VELOCIDADE_CIMA:                       ; velocidade para cima
    WORD    VELOCIDADE_HORIZONTAL_NULA ; não há componente horizontal
    WORD    VELOCIDADE_VERTICAL_CIMA   ; velocidade vertical para cima

VELOCIDADE_ESQ_CIMA:                   ; velocidade para a esquerda e para cima
    WORD    VELOCIDADE_HORIZONTAL_ESQ  ; componente para a esquerda
    WORD    VELOCIDADE_VERTICAL_CIMA   ; velocidade vertical para cima

VELOCIDADE_DIR_CIMA:                   ; velocidade para a direita e para cima
    WORD    VELOCIDADE_HORIZONTAL_DIR  ; velocidade horizontal para a direita
    WORD    VELOCIDADE_VERTICAL_CIMA   ; velocidade vertical para cima


; *****************************************************************************
;   Variáveis/tabelas dos asteroides
; *****************************************************************************
CRIAÇÃO_ASTEROIDE_SUPERIOR_ESQ:        ; posição de criação no canto superior esquerdo
    WORD CRIAÇÃO_SUPERIOR_ESQ_LINHA    ; linha de spawning no canto superior esquerdo
    WORD CRIAÇÃO_SUPERIOR_ESQ_COLUNA   ; coluna de spawning no canto superior esquerdo

CRIAÇÃO_ASTEROIDE_SUPERIOR_DIR:        ; posição de criação no canto superior direito
    WORD CRIAÇÃO_SUPERIOR_DIR_LINHA    ; linha de spawning no canto superior direito
    WORD CRIAÇÃO_SUPERIOR_DIR_COLUNA   ; coluna de spawning no canto superior direito

CRIAÇÃO__ASTEROIDE_SUPERIOR_CENTRO:    ; posição de criação no centro, na parte superior
    WORD CRIAÇÃO_SUPERIOR_CENTRO_LINHA ; linha de spawning no centro, na parte superior
    WORD CRIAÇÃO_SUPERIOR_CENTRO_COLUNA; coluna de spawning no centro, na parte superior

TABELA_CRIAÇÃO_ASTEROIDES:             ; tabela de procura de criação de asteroides
    WORD CRIAÇÃO_ASTEROIDE_SUPERIOR_ESQ ; asteroide no canto superior esquerdo
    WORD VELOCIDADE_DIR_BAIXO           ; com velocidade na diagonal, para o centro
    WORD CRIAÇÃO__ASTEROIDE_SUPERIOR_CENTRO ; asteroide no centro
    WORD VELOCIDADE_ESQ_BAIXO               ; com velocidade para a esquerda
    WORD CRIAÇÃO__ASTEROIDE_SUPERIOR_CENTRO ; asteroide no centro
    WORD VELOCIDADE_BAIXO                   ; com velocidade para baixo
    WORD CRIAÇÃO__ASTEROIDE_SUPERIOR_CENTRO ; asteroide no centro
    WORD VELOCIDADE_DIR_BAIXO               ; com velocidade para a direita
    WORD CRIAÇÃO_ASTEROIDE_SUPERIOR_DIR ; asteroide no canto superior direito
    WORD VELOCIDADE_ESQ_BAIXO           ; com velocidade na diagonal, para o centro

TEMPLATES_ASTEROIDE_MINERÁVEL:
    WORD DEF_ASTEROIDE_MINERÁVEL_TEMPLATE
    WORD DEF_ASTEROIDE_MINERÁVEL_DESTRUÍDO_TEMPLATE
    WORD DEF_ASTEROIDE_MINERÁVEL_TOTALMENTE_DESTRUÍDO_TEMPLATE
    WORD FIM_DESTRUIÇÃO_ASTEROIDE

TEMPLATES_ASTEROIDE_Ñ_MINERÁVEL:
    WORD DEF_ASTEROIDE_Ñ_MINERÁVEL_TEMPLATE
    WORD DEF_ASTEROIDE_Ñ_MINERÁVEL_DESTRUÍDO_TEMPLATE
    WORD FIM_DESTRUIÇÃO_ASTEROIDE

; Tabela com o pixel de colisão de um asteroide não minerável
; O índice do pixel correto pode ser acedido
; simplesmente ao somar 1 à velocidade horizontal
PIXELS_COLISÃO_ASTEROIDE_Ñ_MINERÁVEL:
    WORD PIXEL_COLISÃO_ESQUERDO_ASTEROIDE_Ñ_MINERÁVEL_LINHA     ; pixel esquerdo
    WORD PIXEL_COLISÃO_ESQUERDO_ASTEROIDE_Ñ_MINERÁVEL_COLUNA
    WORD PIXEL_COLISÃO_CENTRAL_ASTEROIDE_Ñ_MINERÁVEL_LINHA      ; pixel central
    WORD PIXEL_COLISÃO_CENTRAL_ASTEROIDE_Ñ_MINERÁVEL_COLUNA
    WORD PIXEL_COLISÃO_DIREITO_ASTEROIDE_Ñ_MINERÁVEL_LINHA      ; pixel direito
    WORD PIXEL_COLISÃO_DIREITO_ASTEROIDE_Ñ_MINERÁVEL_COLUNA

TABELA_ASTEROIDES: TABLE TAMANHO_TABELA_ASTEROIDES
    ; declaração da tabela para os asteroides
    ; cada asteróide tem 1 endereço a linha do pixel de referência, outro com a coluna,
    ; 1 com a velocidade horizontal, outro com a vertical e o endereço da template atual

TABELA_ESTADO_ASTEROIDES:              ; comunica ao processo das sondas o que deve ser
    WORD CRIAR_ASTEROIDE, CRIAR_ASTEROIDE ; feito com cada asteroide
    WORD CRIAR_ASTEROIDE, CRIAR_ASTEROIDE


; *****************************************************************************
;   Variáveis/tabelas das sondas
; *****************************************************************************
CRIAÇÃO_SONDA_ESQUERDA:                ; posição de criação da sonda da esquerda
    WORD LINHA_SONDA_ESQUERDA          ; linha inicial da sonda da esquerda
    WORD COLUNA_SONDA_ESQUERDA         ; coluna inicial da sonda da esquerda

CRIAÇÃO_SONDA_CENTRAL:                 ; posição de criação da sonda central
    WORD LINHA_SONDA_CENTRAL           ; linha inicial da sonda central
    WORD COLUNA_SONDA_CENTRAL          ; coluna inicial da sonda central

CRIAÇÃO_SONDA_DIREITA:                 ; posição de criação da sonda da direita
    WORD LINHA_SONDA_DIREITA           ; linha inicial da sonda da direita
    WORD COLUNA_SONDA_DIREITA          ; coluna inicial da sonda da direita

TABELA_POSIÇÃO_CRIAÇÃO_SONDA:          ; tabela de procura para escolher a posição
    WORD CRIAÇÃO_SONDA_ESQUERDA        ; certa de criação de uma sonda
    WORD CRIAÇÃO_SONDA_CENTRAL         ; ou seja, a sonda número 0 aparece à esquerda,
    WORD CRIAÇÃO_SONDA_DIREITA         ; a 1 no centro e a 2 na direita

SONDAS_EM_CURSO:
    WORD    SONDA_EM_RESERVA           ; tabela com o número de movimentos disponiveis
    WORD    SONDA_EM_RESERVA           ; para cada sonda, SONDA_EM_RESERVA significa que
    WORD    SONDA_EM_RESERVA           ; não está no ecrã

TABELA_SONDAS:
    ; declaração da tabela para as
    ; cada sonda tem 1 endereço a linha do pixel de referência, outro com a coluna,
    ; 1 com o endereço de um vetor da velocidade
    WORD LINHA_SONDA_ESQUERDA          ; linha do pixel da sonda esquerda
    WORD COLUNA_SONDA_ESQUERDA         ; coluna do pixel da sonda da esquerda
    WORD VELOCIDADE_ESQ_CIMA           ; velocidade da sonda 0
    WORD LINHA_SONDA_CENTRAL
    WORD COLUNA_SONDA_CENTRAL
    WORD VELOCIDADE_CIMA               ; velocidade da sonda 1
    WORD LINHA_SONDA_DIREITA
    WORD COLUNA_SONDA_DIREITA
    WORD VELOCIDADE_DIR_CIMA           ; velocidade da sonda 2


; *****************************************************************************
;   Variáveis/tabelas da animação da nave
; *****************************************************************************
TABELA_ANIMACAO_VIDRO_NAVE:            ; tabela com todos os frames da animação do vidro
    WORD DEF_FRAME1_VIDRO_NAVE         ; da nave por ordem
    WORD DEF_FRAME2_VIDRO_NAVE
    WORD DEF_FRAME2_VIDRO_NAVE         ; frame 2 repete-se
    WORD DEF_FRAME3_VIDRO_NAVE
    WORD DEF_FRAME4_VIDRO_NAVE
    WORD DEF_FRAME5_VIDRO_NAVE
    WORD DEF_FRAME6_VIDRO_NAVE
    WORD DEF_FRAME7_VIDRO_NAVE

TABELA_ESTADO_LUZ:                     ; animação cíclica do cinturão de luzes da nave
    WORD DEF_LUZ_NAVE_APAGADA
    WORD DEF_LUZ_NAVE_VERDE
    WORD DEF_LUZ_NAVE_APAGADA
    WORD DEF_LUZ_NAVE_APAGADA
    WORD DEF_LUZ_NAVE_APAGADA
    WORD DEF_LUZ_NAVE_AMARELA
    WORD DEF_LUZ_NAVE_APAGADA
    WORD DEF_LUZ_NAVE_APAGADA
    WORD DEF_LUZ_NAVE_APAGADA
    WORD DEF_LUZ_NAVE_VERDE
    WORD DEF_LUZ_NAVE_APAGADA
    WORD DEF_LUZ_NAVE_APAGADA
    WORD DEF_LUZ_NAVE_APAGADA
    WORD DEF_LUZ_NAVE_AMARELA
    WORD DEF_LUZ_NAVE_APAGADA
    WORD DEF_LUZ_NAVE_APAGADA


; *****************************************************************************
;   Main
; *****************************************************************************
PLACE 0
main:
    MOV SP, SP_main                    ; inicializa o stack pointer
    MOV BTE, TABELA_EXCEÇÕES           ; inicializa a tabela de exceções
    MOV [APAGA_AVISO], R1              ; apaga o aviso de nenhum cenário selecionado
                                       ; (o valor de R1 não é relevante)
    MOV [APAGA_ECRÃ], R1               ; apaga todos os pixels já desenhados
                                       ; (o valor de R1 não é relevante)
    MOV	R1, FUNDO_START			       ; cenário de fundo start
    MOV [SELECIONA_CENARIO], R1        ; seleciona o cenário de fundo
    MOV R0, SOM_INICIA                 ; reproduz o som
    MOV [REPRODUZ_SOM], R0             ; de inicio de jogo
    EI0                                ; permite a exceção dos asteroides
    EI1                                ; permite a exceção das sondas
    EI2                                ; permite a exceção da energia da nave
    EI3                                ; permite a exceção da animação da nave
    EI                                 ; permite as exceções no geral
    CALL processo_teclado              ; inicializa o teclado
ciclo_principal:
    CALL executa_comando               ; executa o comando associado
    JMP ciclo_principal                ; repete


; *****************************************************************************
;   Processos
;   Os processos usados são os seguintes:
;       - teclado
;       - asteroides
;       - sondas
;       - animação da nave
;       - energia da nave
;   Nota: o processo de controlo de jogo é executado pelo processo inicial
; *****************************************************************************
; *****************************************************************************
;   Processo dos asteroides
; *****************************************************************************
; PROCESSO_ASTEROIDES
; Cria/apaga asteroides, move os existentes e deteta a colisão com a nave
PROCESS SP_ASTEROIDES
processo_asteroides:
    MOV R0, TABELA_ASTEROIDES          ; seleciona a tabela de asteroides
    MOV R1, TAMANHO_TABELA_ASTEROIDES  ; indica o seu tamanho
    MOV R2, 0                          ; inicializa tudo a zeros
    CALL inicializa_tabela             ; inicializa a tabela
    MOV R0, TABELA_ESTADO_ASTEROIDES   ; seleciona a tabela de estado dos asteroides
    MOV R1, TAMANHO_TABELA_ESTADO_ASTEROIDES    ; indica o seu tamanho
    MOV R2, CRIAR_ASTEROIDE            ; inicializa tudo para indicar ao processo
    CALL inicializa_tabela             ; que deve criar todos os asteroides
processo_asteroides_em_andamento:
    MOV R0, [ESTADO_JOGO]              ; lê o novo estado do jogo
    MOV R1, EM_ANDAMENTO               ; se estiver em andamento
    CMP R1, R0                         ; espera pela próxima interrupção
    JZ processo_asteroides_espera_interrupção   ; para atualizar os asteroides
    MOV R1, PAUSA                      ; se estiver em pausa, lê novamente
    CMP R1, R0                         ; o LOCK_JOGO à espera de um sinal novo
    JZ processo_asteroides_pausa       ; para recomeçar as atualizações
    JMP processo_asteroides_termina    ; se não, estamos no estado INICIA
processo_asteroides_espera_interrupção:
    CALL atualiza_todos_asteroides     ; atualiza os asteroides
    MOV R1, [LOCK_ASTEROIDES]          ; espera pelo próximo sinal da interrupção
    JMP processo_asteroides_em_andamento    ; repete o processo
processo_asteroides_pausa:
    MOV R0, [LOCK_JOGO]                ; espera por um sinal do controlo, se o estado
    CMP R0, EM_ANDAMENTO               ; não estiver EM_ANDAMENTO, o jogo acabou
    JNZ processo_asteroides_termina    ; e o processo deve terminar
    MOV R1, [LOCK_ASTEROIDES]          ; espera pelo próximo sinal da interrupção
                                       ; para não ser atualizado 2 vezes de seguida
    JMP processo_asteroides_em_andamento    ; quando o recebe, volta a executar
processo_asteroides_termina:           ; termina o processo
    RET

; *****************************************************************************
;   Processo das sondas
; *****************************************************************************
; PROCESSO_SONDAS
; Move/apaga as sondas existentes, deteta a colisão com asteroides e apaga sondas
PROCESS SP_SONDAS
processo_sondas:
    MOV R0, SONDAS_EM_CURSO            ; seleciona a tabela de estado das sondas
    MOV R1, TAMANHO_TABELA_SONDA_EM_CURSO   ; indica o seu tamanho
    MOV R2, SONDA_EM_RESERVA           ; inicializa tudo a "em reserva" para indicar
    CALL inicializa_tabela             ; ao processo que qualquer uma pode ser criada
processo_sondas_em_andamento:
    MOV R0, [ESTADO_JOGO]              ; lê o estado do jogo, se estiver em andamento,
    CMP R0, EM_ANDAMENTO               ; espera pela próxima interrupção, para atualizar
    JZ processo_sondas_espera_interrupção   ; as sondas. Se estiver em PAUSA, espera por
    CMP R0, PAUSA                      ; um novo sinal do processo de controlo
    JZ processo_sondas_pausa           ; fica locked entretanto
    JMP processo_sondas_termina        ; se chegar aqui, o estado é INICIA ou TERMINA
processo_sondas_espera_interrupção:    ; e o processo deve acabar
    CALL atualiza_todas_sondas         ; atualiza as sondas no ecrã
    MOV R1, [LOCK_SONDAS]              ; espera pelo próximo sinal para atualizar
    JMP processo_sondas_em_andamento   ; repete o processo
processo_sondas_pausa:
    MOV R0, [LOCK_JOGO]                ; espera por um sinal do controlo, se o estado
    CMP R0, EM_ANDAMENTO               ; não estiver EM_ANDAMENTO, o jogo acabou
    JNZ processo_sondas_termina        ; e o processo deve terminar
    MOV R1, [LOCK_SONDAS]              ; espera pelo próximo sinal da interrupção
                                       ; para não atualizar as sondas duas vezes
    JMP processo_sondas_em_andamento   ; quando o recebe, volta a executar
processo_sondas_termina:               ; termina o processo
    RET

; *****************************************************************************
;   Processo da energia da nave
; *****************************************************************************
; PROCESSO_ENERGIA_NAVE
; Atualiza a energia da nave periodicamente e a pedido do processo das sondas
; e dos asteroides
PROCESS SP_ENERGIA_NAVE
processo_energia_nave:
    MOV R0, ENERGIA_INICIAL            ; colocando a energia inicial
    MOV [ÚLTIMO_NÚMERO_DISPLAYS], R0   ; como último número
    MOV R0, 0                          ; e incrementando zero, a energia é
    CALL incrementa_displays           ; efetivamente inicializada
processo_energia_nave_em_andamento:
    MOV R2, [ESTADO_JOGO]              ; lê o estado do jogo, se estiver EM_ANDAMENTO
    CMP R2, EM_ANDAMENTO               ; então espera pela próxima interrupção para
    JZ processo_energia_nave_interrupção   ; atualizar a energia. Se estiver em PAUSA,
    CMP R2, PAUSA                      ; espera por um novo sinal do processo de controlo
    JZ processo_energia_nave_pausa     ; (fica locked à espera de reiniciar)
    JMP processo_energia_nave_termina  ; se chegar aqui, o estado é INICIA
processo_energia_nave_interrupção:     ; e o processo acaba
    CALL incrementa_displays           ; incrementa/decrementa os displays
    MOV R0, [ÚLTIMO_NÚMERO_DISPLAYS]   ; lê o novo valor dos displays
    MOV R1, 0                          ; verifica se o valor dos displays
    CMP R0, R1                         ; ficou não positivo, nesse caso
    JLT processo_energia_nave_termina  ; o jogo acaba
    MOV R0, [LOCK_ENERGIA_NAVE]        ; com o último valor do LOCK
    JMP processo_energia_nave_em_andamento  ; repete o processo
processo_energia_nave_pausa:
    MOV R1, [LOCK_JOGO]                ; espera por um sinal do controlo, se o estado
    CMP R1, EM_ANDAMENTO               ; não for EM_ANDAMENTO, então o jogo terminou
    JNZ processo_energia_nave_termina  ; e o processo termina
    MOV R0, [LOCK_ENERGIA_NAVE]        ; espera pelo próximo sinal da interrupção
                                       ; para não atualizar as sondas duas vezes
    JMP processo_energia_nave_em_andamento  ; quando o recebe, volta a executar
processo_energia_nave_termina:         ; termina o processo
    RET

; *****************************************************************************
;   Processo do teclado
; *****************************************************************************
; PROCESSO_TECLADO
; Varre o teclado e comunica ao processo de controlo as teclas que são premidas
PROCESS SP_TECLADO
processo_teclado:
    CALL varre_teclado                 ; varre o teclado
    MOV [LOCK_CONTROLO], R10           ; comunica essa tecla ao controlo
    JMP processo_teclado               ; repete
    RET                                ; se chegar aqui aconteceu um erro grave

; *****************************************************************************
;   Processo da animação da nave
; *****************************************************************************
; PROCESSO_ANIMA_NAVE
; Executa as duas animações da nave (vidro e luzes)
PROCESS SP_ANIMA_NAVE
processo_anima_nave:
    MOV R0, 0                          ; inicializa o frame atual do vidro
    MOV [FRAME_ATUAL], R0              ; e a etapa de luzes atual a zeros
    MOV [ETAPA_LUZES_ATUAL], R0
processo_anima_nave_em_andamento:
    MOV R0, [ESTADO_JOGO]              ; lê o estado do jogo
    MOV R1, EM_ANDAMENTO               ; se estiver EM_ANDAMENTO, então
    CMP R1, R0                         ; espera pela próxima interrupção
    JZ processo_anima_nave_espera_interrupção   ; para atualizar a nave
    MOV R1, PAUSA                      ; se estiver em PAUSA, espera por
    CMP R1, R0                         ; um novo sinal do processo de controlo
    JZ processo_anima_nave_pausa       ; vai "lockar-se"
    JMP processo_anima_nave_termina    ; se chegar aqui, o estado é INICIA
processo_anima_nave_espera_interrupção:; e o processo acaba
    CALL atualiza_frame_nave           ; atualiza o frame da nave
    MOV R1, [LOCK_ANIMACAO_NAVE]       ; espera pelo próximo sinal para atualizar
    JMP processo_anima_nave_em_andamento    ; repete o processo
processo_anima_nave_pausa:
    MOV R0, [LOCK_JOGO]                ; espera por um sinal do controlo
    CMP R0, EM_ANDAMENTO               ; se o estado não estiver EM_ANDAMENTO
    JNZ processo_anima_nave_termina    ; o jogo acabou e o processo termina
    MOV R1, [LOCK_ANIMACAO_NAVE]       ; espera pelo próximo sinal da interrupção
                                       ; para não atualizar a nave duas vezes
    JMP processo_anima_nave_em_andamento  ; quando o recebe, volta a executar
processo_anima_nave_termina:           ; termina o processo
    RET


; *****************************************************************************
;   Interfaces/Rotinas
; *****************************************************************************
; *****************************************************************************
;   Rotinas de interrupção
; *****************************************************************************

; INT_ASTEROIDES
; Rotina de interrupção responsável por sinalizar o processo dos asteroides
; Não recebe argumentos
int_asteroides:
    MOV [LOCK_ASTEROIDES], R0          ; ativa o processo dos asteroides
    RFE

; INT_SONDAS
; Rotina de interrupção responsável por sinalizar o processo das sondas
; Não recebe argumentos
int_sondas:
    MOV [LOCK_SONDAS], R0              ; ativa o processo das sondas
    RFE

; INT_ENERGIA_NAVE
; Sinaliza o processo da energia da nave para decrementar a energia da nave,
; de 3 em 3 segundos
; Não recebe argumentos
int_energia_nave:
    PUSH R0                            ; guarda o estado do registo
    MOV R0, DECREMENTO_BASE            ; comunica ao processo da energia da nave
    MOV [LOCK_ENERGIA_NAVE], R0        ; que deve decrementar 3 e destranca-o
    POP R0                             ; restaura o estado
    RFE

; INT_ANIMA_NAVE
; Rotina de interrupção responsável por sinalizar o processo da animação da nave
; Não recebe argumentos
int_anima_nave:
    MOV [LOCK_ANIMACAO_NAVE], R0       ; ativa o processo da animacao da nave
    RFE

; *****************************************************************************
;   Interface do ecrã
; *****************************************************************************
; ESCREVE_TEMPLATE
; Desenha uma dada template
; Argumentos:
;   R0 - linha do pixel de referencia
;   R1 - coluna do pixel de referencia
;   R2 - template a desenhar (primeiro deve vir a altura, depois a largura)
;   R3 - ecrã do pixel de referencia
escreve_template:
    PUSH R0                            ; guarda os registos usados
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    MOV [SELECIONA_ECRÃ], R3           ; seleciona o ecrã da template
    MOV R3, [R2]                       ; guardar em R3 a altura da template
    ADD R2, 2                          ; segue para a próxima palavra
    MOV R4, [R2]                       ; guardar em R4 a largura da template
    ADD R2, 2                          ; vai para a primeira linha a desenhar
    MOV R5, R2                         ; R5 passa a ter os endereços das cores
    MOV R6, R4                         ; copia auxiliar da largura
escreve_template_desenha_linha:
    MOV R2, [R5]                       ; obtém a cor do pixel
    CALL escreve_pixel                ; escreve o pixel selecionado
    ADD R1, 1                          ; vai para o pixel logo à direita
    ADD R5, 2                          ; obtém o endereço da cor do próximo pixel
    SUB R4, 1                          ; menos um pixel dessa linha para tratar
    JNZ escreve_template_desenha_linha ; se não, continua a desenhar a linha
    JMP escreve_template_próxima_linha ; se sim, vai para a próxima linha
escreve_template_próxima_linha:
    MOV R4, R6                         ; reinicializa a largura
    SUB R1, R6                         ; volta o pixel a desenhar à coluna inicial
    ADD R0, 1                          ; incrementa a linha do pixel a desenhar
    SUB R3, 1                          ; menos uma linha a tratar
    JNZ escreve_template_desenha_linha ; se houver linhas a tratar, desenha-as
    POP R6                             ; restaura o estado dos registos
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET


; APAGA_TEMPLATE
; Apaga a template dada (coloca os pixeis a 0)
; Argumentos:
;   R0 - linha do pixel de referencia
;   R1 - coluna do pixel de referencia
;   R2 - template a apagar
;   R3 - ecrã do pixel de referencia
apaga_template:
    PUSH R0                            ; guarda os registos usados
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R6
    MOV [SELECIONA_ECRÃ], R3           ; seleciona o ecrã da template
    MOV R3, [R2]                       ; guardar em R3 a altura da template
    ADD R2, 2                          ; segue para a próxima palavra
    MOV R4, [R2]                       ; guardar em R4 a largura da template
    MOV R2, 0                          ; vai para a primeira linha a desenhar
    MOV R6, R4                         ; copia auxiliar da largura
apaga_template_apaga_linha:
    CALL escreve_pixel                ; escreve o pixel selecionado
    ADD R1, 1                          ; vai para o pixel logo à direita
    SUB R4, 1                          ; menos um pixel dessa linha para tratar
    JNZ apaga_template_apaga_linha     ; se não, continua a desenhar a linha
    JMP apaga_template_próxima_linha   ; se sim, vai para a próxima linha
apaga_template_próxima_linha:
    MOV R4, R6                         ; reinicializa a largura
    SUB R1, R6                         ; volta o pixel a desenhar à coluna inicial
    ADD R0, 1                          ; incrementa a linha do pixel a desenhar
    SUB R3, 1                          ; menos uma linha a tratar
    JNZ apaga_template_apaga_linha     ; se houver linhas a tratar, desenha-as
    POP R6                             ; restaura o estado dos registos
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET


; MOVE_TEMPLATE
; Move uma dada template de acordo com um vetor de movimento dado
; Argumentos:
;   R0 - linha do pixel de referencia
;   R1 - coluna do pixel de referencia
;   R2 - template a mover
;   R3 - ecrã do pixel de referencia
;   R4 - velocidade horizontal
;   R5 - velocidade vertical
; Importante - atualiza a posição do pixel de referencia (R0 e R1) pelo vetor dado
move_template:
    CALL apaga_template                ; apaga a template na posição inicial
    ADD R0, R5                         ; desloca a posição inicial
    ADD R1, R4
    CALL escreve_template              ; desenha a template no novo pixel de referencia
    RET


; VERIFICA_TEMPLATE_TODA_FORA
; Verifica se uma dada template está completamente fora do ecrã
; Argumentos:
;   R0 - linha do pixel de referencia
;   R1 - coluna do pixel de referencia
;   R2 - template a verificar
; Coloca em R10 0 se está completamente fora, 1 caso contrário
verifica_template_toda_fora:
    PUSH R0                            ; guarda o estado dos registos
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    MOV R3, [R2]                       ; guarda em R4 a altura da template
    ADD R2, 2                          ; segue para a a largura
    MOV R2, [R2]                       ; guarda em R2 a largura da template
    CALL verifica_pixel_dentro_do_ecrã     ; verifica se o pixel de referência está 
                                           ; dentro do ecrã
    MOV R4, R10                        ; guarda a verificação em R4
    ADD R1, R2                         ; seleciona a coluna da direita da template
    SUB R1, 1                          ; transforma a coluna no seu índice do ecrã
    CALL verifica_pixel_dentro_do_ecrã     ; verifica se o canto superior esquerdo está
    OR R10, R4                         ; dentro e junta os resultados das verificações
    MOV R4, R10                        ; guarda o resultado combinado em R4
    ADD R0, R3                         ; seleciona a linha final da template
    SUB R0, 1                          ; transforma a linha no seu índice do ecrã
    CALL verifica_pixel_dentro_do_ecrã     ; passa a verificar se o pixel oposto ao 
                  ; pixel de referência (canto inferior direito) está dentro do ecrã
    OR R10, R4                ; se qualquer um estiver dentro, então devolve 1 (dentro)
    POP R4                    ; se ambos estiverem fora, a template está toda fora, 
    POP R3                    ; então devolve 0 (fora)
    POP R2                    ; os POPs restauram os registos
    POP R1
    POP R0
    RET


; ESCREVE_PIXEL
; Atualiza a cor do pixel dado para a cor dada
; Argumentos:
;   R0 - linha do pixel
;   R1 - coluna do pixel
;   R2 - cor do pixel
escreve_pixel:
    MOV [DEFINE_LINHA], R0             ; seleciona a linha
    MOV [DEFINE_COLUNA], R1            ; seleciona a coluna
    MOV [DEFINE_PIXEL], R2             ; altera a cor
    RET


; COR_PIXEL
; Devolve em R10 a cor do pixel no ecrã especificado
; Argumentos:
;   R0 - linha do pixel
;   R1 - coluna do pixel
;   R2 - ecrã do pixel
cor_pixel:
    MOV [DEFINE_LINHA], R0             ; seleciona a linha
    MOV [DEFINE_COLUNA], R1            ; seleciona a coluna
    MOV [SELECIONA_ECRÃ], R2           ; seleciona o primeiro ecrã
    MOV R10, [DEVOLVE_COR_PIXEL]       ; lê a cor do pixel selecionado
    RET


; VERIFICA_PIXEL_DENTRO_DO_ECRÃ
; Verifica se o pixel especificado está dentro do ecrã
; Argumentos:
;   R0 - linha do pixel
;   R1 - coluna do pixel
; Coloca em R10 1 se está dentro, 0 se está fora
; Importante: não verifica se o pixel está acima do ecrã (desnecessário)
verifica_pixel_dentro_do_ecrã:
    PUSH R2                            ; guarda estado dos registos
    PUSH R3
    MOV R2, LINHA_MAX_ECRÃ             ; índice máximo para das linhas do ecrã
    MOV R3, COLUNA_MAX_ECRÃ            ; índice máximo para as colunas do ecrã
    CMP R1, 0                          ; verifica se a coluna >= 0
    JLT verifica_pixel_dentro_do_ecrã_fora  ; se não, está fora
    CMP R1, R3                         ; verifica se a coluna <= 63
    JGT verifica_pixel_dentro_do_ecrã_fora  ; se não, está fora
    CMP R0, R2                         ; verifica se a linha é <= 31
    JGT verifica_pixel_dentro_do_ecrã_fora  ; se não, está fora
    MOV R10, 1                         ; se chegar aqui, está dentro
    JMP verifica_pixel_dentro_do_ecrã_saida ; basta sair
verifica_pixel_dentro_do_ecrã_fora:
    MOV R10, 0                         ; se chegar aqui, está fora
verifica_pixel_dentro_do_ecrã_saida:
    POP R3                             ; restaura os registos usados
    POP R2
    RET


; ESCONDE_ECRÃS
; Esconde todos os ecrãs utilizados
; Não recebe argumentos
esconde_ecrãs:
    PUSH R0                            ; guarda R0
    MOV R0, ECRÃ_NAVE                  ; inicializa R0 com o ecrã com valor mais alto
esconde_ecrãs_ciclo:
    MOV [ESCONDE_ECRÃ], R0             ; esconde o ecrã atual
    SUB R0, 1                          ; segue para o próximo ecrã
    JNN esconde_ecrãs_ciclo            ; enquanto não for negativo, vai esconder o resto
esconde_ecrãs_saída:                   ; quando for negativo, saí
    POP R0                             ; restaura R0
    RET


; MOSTRA_ECRÃS
; Mostra todos os ecrãs utilizados
; Não recebe argumentos
mostra_ecrãs:
    PUSH R0                            ; guarda R0
    MOV R0, ECRÃ_NAVE                  ; inicializa R0 com o ecrã com valor mais alto
mostra_ecrãs_ciclo:
    MOV [MOSTRA_ECRÃ], R0              ; mostra o ecrã
    SUB R0, 1                          ; segue para o próximo ecrã
    JNN mostra_ecrãs_ciclo             ; enquanto não for negativo, vai mostrar o resto
mostra_ecrãs_saída:                    ; quando for negativo, já mostrou tudo
    POP R0                             ; restaura R0
    RET


; *****************************************************************************
;   Interface do teclado
; *****************************************************************************
; VARRE_TECLADO
; Varre o teclado à procura de teclas premidas
; Não recebe argumentos
; Devolve em R10 a tecla premida
varre_teclado:
    PUSH R0                            ; guarda o estado dos registos
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    MOV R3, TEC_LIN                    ; endereço do periférico das linhas
    MOV R4, TEC_COL                    ; endereço do periférico das colunas
    MOV R5, MASCARA                    ; isolar os bits 3-0
    MOV R10, 0                         ; inicializa o R10 a zeros
varre_teclado_inicia_ciclo:
    WAIT                               ; espera por um acontecimento
    MOV R0, LINHA4                     ; começa na linha "5"
    JMP varre_teclado_uma_linha        ; varre a quarta linha
varre_teclado_proxima_linha:
    SHR R0, 1                          ; seleciona a linha imediatamente acima
    JC  varre_teclado_inicia_ciclo     ; se houve carry significa que terminou de varrer
    JMP varre_teclado_uma_linha        ; se não varre a linha selecionada
varre_teclado_uma_linha:
    MOVB [R3], R0                      ; seleciona a linha a testar
    MOVB R1, [R4]                      ; recebe a coluna premida (0000 se não estiver)
    AND R1, R5                         ; isola a coluna recebida
    JZ varre_teclado_proxima_linha     ; se for 0000 então não há nada selecionado
verifica_tecla_premida_ciclo:
    YIELD                              ; dá prioridade a outros processos
    MOVB [R3], R0                      ; testa a linha da ultima tecla
    MOVB R2, [R4]                      ; guarda a coluna premida
    AND R2, R5                         ; isola os bits 3-0
    CMP R1, R2                         ; verifica se a coluna é igual à anterior
    JZ verifica_tecla_premida_ciclo    ; se sim, é a mesma tecla e verifica novamente
varre_teclado_saida:
    CALL converte_linha_coluna_hexa    ; converte a posição lida para o seu valor no
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET


; CONVERTE_LINHA_COLUNA_HEXA
; Converte a linha e a coluna de uma tecla para o seu valor hexadecimal correspondente
; Argumentos:
;   R0: linha da tecla (deve estar no nibble low)
;   R1: coluna da tecla (deve estar no nibble low)
; Coloca o resultado da conversão em R10
converte_linha_coluna_hexa:
    PUSH R2                            ; guarda o estado dos registos usados
    PUSH R3
converte_linha_coluna_hexa_conversão:
    MOV R2, R0                         ; coloca a linha em R2
    CALL conta_bits_ate_primeiro_1    ; devolve o número da linha (0 a 3) em R10
    MOV R3, R10                        ; guarda em R3 o número da linha
    MOV R2, R1                         ; coloca a coluna em R2
    CALL conta_bits_ate_primeiro_1    ; devolve o número da coluna (0 a 3) em R10
    SHL R3, 2                          ; multiplica a linha por 4
    ADD R3, R10                        ; adiciona a coluna à posição inicial da linha
converte_linha_coluna_hexa_saida:
    MOV R10, R3                        ; coloca o valor de retorno em R10
    POP R3                             ; restaura os registos
    POP R2
    RET


; CONTA_BITS_ATE_PRIMEIRO_1
; Conta o número de zeros numa dada palavra até aparecer o primeiro 1
; Argumentos:
;   R2 - palavra a contar zeros
; Coloca o número de bits em R10
conta_bits_ate_primeiro_1:
    PUSH R2                            ; guarda estado de R2
    MOV R10, 0                         ; inicializa R10 a 0
    CMP R2, 0                          ; verifica se R2 já não é 0
    JZ conta_bits_ate_primeiro_1_saida ; se sim, já terminou
conta_bits_ate_primeiro_1_contador:
    SHR R2, 1                          ; menos 1 bit a tratar
    JC conta_bits_ate_primeiro_1_saida ; se houve carry então a palavra está a zeros
    ADD R10, 1                         ; se não incrementa o contador
    JMP conta_bits_ate_primeiro_1_contador  ; continua até ser 0
conta_bits_ate_primeiro_1_saida:
    POP R2
    RET


; *****************************************************************************
;   Interface dos displays/energia
; *****************************************************************************
; INCREMENTA_DISPLAYS
; Incrementa o valor atual dos displays por um incremento dado
; O valor máximo possível é 999, ou seja, qualquer incremento
; que resulte num valor maior é ignorado
; O valor mínimo possível é 0 e nesse caso, termina o jogo
; Argumentos:
;   R0 - incremento (positivo ou negativo)
incrementa_displays:
    PUSH R0                            ; guarda o estado dos registos
    PUSH R1
    PUSH R2
    MOV R1, [ÚLTIMO_NÚMERO_DISPLAYS]   ; obtém o último número escrito
    ADD R0, R1                         ; incrementa o valor
    MOV R2, 0                          ; verifica se o valor é menor que zero
    CMP R0, R2                         ; se sim, simplesmente atualiza a energia
    JLT incrementa_displays_negativo   ; e os displays para zero
    MOV R2, ENERGIA_MÁXIMA             ; verifica se a energia excedeu o limite
    CMP R0, R2                         ; nesse caso, os a energia fica a máxima
    JLT incrementa_displays_converte   ; caso contrário, atualiza-se os displays
    MOV R0, ENERGIA_MÁXIMA             ; coloca a energia como sendo máxima
    JMP incrementa_displays_converte
incrementa_displays_negativo:
    MOV R0, TERMINA                    ; neste caso assinala que a energia chegou
    MOV [ESTADO_JOGO], R0              ; ao ponto em que implica que o jogo termine
    MOV R0, FUNDO_GAME_OVER_ENERGIA    ; cenário de fundo sem energia
    MOV [SELECIONA_CENARIO], R0        ; seleciona o cenário de fundo
    MOV R0, SOM_TERMINAR_POR_ENERGIA   ; som de fim de jogo quando nave fica sem energia
    MOV [REPRODUZ_SOM], R0             ; reproduz som
    MOV R0, SOM_MÚSICA_FUNDO           ; termina o loop da música de fundo
    MOV [TERMINA_SOM_LOOP], R0
    MOV R0, TERMINA_SEM_COMANDO        ; indica ao controlo que o jogo
    MOV [TIPO_DE_FIM], R0              ; terminou por embate ou falta de energia
    MOV R0, TECLA_TERMINA_JOGO         ; pede ao processo de controlo
    MOV [LOCK_CONTROLO], R0            ; para terminar o jogo     
    MOV R0, 0                          ; coloca a energia a 0
incrementa_displays_converte:
    CALL converte_hexa_para_decimal   ; converte o valor para decimal
    MOV [DISPLAYS], R1                 ; escreve o novo valor nos displays
    MOV [ÚLTIMO_NÚMERO_DISPLAYS], R0   ; atualiza o último número escrito para o novo
    POP R2                             ; guarda o estado dos registos
    POP R1
    POP R0
    RET


; *****************************************************************************
;   Interface dos asteroides
; *****************************************************************************
; BUSCA_ASTEROIDE
; Coloca nos registos 1 a 5 os endereço das informações do asteróide
; na posição n (0, ..., 3)
; Argumentos:
;   R0 - número do asteróide
; No retorno:
;   R0 - endereço da linha
;   R1 - endereço da coluna
;   R2 - endereço da template usada
;   R3 - ecrã do asteroide
;   R4 - endereço da velocidade horizontal
;   R5 - endereço da velocidade vertical
busca_asteroide:
    PUSH R6
    PUSH R7
    PUSH R8
    MOV R8, R0                         ; inicializa R8 com R0 (R0 é usado no retorno)
    ADD R0, ECRÃ_ASTEROIDE_0           ; adiciona o offset dos ecrãs de asteroides
    MOV R3, R0                         ; coloca em R3 o número do ecrã deste asteroide
    MOV R7, TABELA_ASTEROIDES          ; guarda a posição inicial da tabela para somar
    MOV R6, MEMORIA_POR_ASTEROIDE      ; coloca em R6 a memória ocupada por 1 asteróide
    MUL R8, R6                         ; ignora os asteroides antes do desejado
    ADD R8, R7                         ; obtém o endereço inicial do asteróide desejado
    MOV R0, R8                         ; obtém o endereço da linha
    ADD R8, 2                          ; segue para a coluna
    MOV R1, R8                         ; obtém o endereço da coluna
    ADD R8, 2                          ; segue para a velocidade horizontal
    MOV R4, R8                         ; obtém o endereço da velocidade horizontal
    ADD R8, 2                          ; segue para a velocidade vertical
    MOV R5, R8                         ; obtém o endereço da velocidade vertical
    ADD R8, 2                          ; segue para a template
    MOV R2, R8                         ; obtém o endereço da template usada
    POP R8                             ; restaura os registos
    POP R7
    POP R6
    RET


; OBTÉM_PIXEL_COLISÃO
; Obtém o pixel de colisão de acordo com o tipo do asteroide e com a sua velocidade
; Argumentos:
;   R0 - linha do pixel de referência do asteroide
;   R1 - coluna do pixel de referência do asteroide
;   R2 - Template do asteroide
;   R4 - velocidade horizontal do asteroide
;   R5 - velocidade vertical do asteroide
; No retorno:
;   R0 - linha do pixel de referência do asteroide
;   R1 - coluna do pixel de referência do asteroide
obtém_pixel_colisão:
    PUSH R3                            ; guarda o estado dos registos
    PUSH R4
    PUSH R5                            ; o pixel de verificação tem de levar em
    ADD R0, R5                         ; conta a próxima posição, não a atual
    ADD R1, R4                         ; por isso, soma-se a velocidade à posição
    MOV R3, TEMPLATES_ASTEROIDE_Ñ_MINERÁVEL
    CMP R2, R3                         ; verifica se o asteroide é ou não minerável
    JNZ obtém_pixel_colisão_asteroide_minerável    ; se for, trata de acordo
    MOV R3, PIXELS_COLISÃO_ASTEROIDE_Ñ_MINERÁVEL   ; endereço base da tabela de pixels
    ADD R4, 1    ; a velocidade está entre -1 e 1, logo assim fica entre 0 e 2 passa
    SHL R4, 2    ; a agir como índice (o SHL leva em conta que cada elemento são 2 WORDs)
    MOV R5, [R3 + R4]                  ; obtém a linha do pixel de colisão
    ADD R0, R5                         ; ao somar-se obtém-se a linha de colisão
    ADD R4, 2                          ; segue para a coluna do pixel de colisão
    MOV R5, [R3 + R4]                  ; obtém esse valor e, finalmente, soma
    ADD R1, R5                         ; para obter a coluna de colisão
    JMP obtém_pixel_colisão_saída      ; R0 e R1 já têm a linha e coluna de colisão
obtém_pixel_colisão_asteroide_minerável:
    ; o asteroide minerável tem sempre o mesmo pixel de colisão
    MOV R3, PIXEL_COLISÃO_ASTEROIDE_MINERÁVEL_LINHA
    ADD R0, R3                         ; obtém a linha do pixel de colisão
    MOV R3, PIXEL_COLISÃO_ASTEROIDE_MINERÁVEL_COLUNA
    ADD R1, R3                         ; obtém a coluna do pixel de colisão
obtém_pixel_colisão_saída:
    POP R5                             ; restaura o estado dos registos
    POP R4
    POP R3
    RET


; DETETA_COLISÃO_ASTEROIDE_NAVE
; Deteta se um asteroide colidiu com a nave
; Argumentos:
;   R0 - linha do pixel de referência do asteroide
;   R1 - coluna do pixel de referência do asteroide
;   R2 - template do asteroide
;   R4 - velocidade horizontal do asteroide
;   R5 - velocidade vertical do asteroide
; No retorno:
;   R10 - 1 se houve colisão, 0 caso contrário
deteta_colisão_asteroide_nave:
    PUSH R0                            ; guarda o estado dos registos
    PUSH R1
    PUSH R2
    CALL obtém_pixel_colisão          ; obtém o pixel a verificar por colisão
    MOV R2, ECRÃ_NAVE                  ; seleciona o ecrã da nave
    CALL cor_pixel                    ; obtém a cor do pixel no ecrã da nave
    CMP R10, 0                         ; verifica se tem cor
    JNZ deteta_colisão_asteroide_nave_colisão   ; se tiver, houve colisão
    MOV R10, 0                         ; se não tiver, não houve e retorna 0
    JMP deteta_colisão_asteroide_nave_saída
deteta_colisão_asteroide_nave_colisão:
    MOV R10, 1                         ; houve colisão e retorna 1
deteta_colisão_asteroide_nave_saída:
    POP R2
    POP R1                             ; restaura o estado dos registos usados
    POP R0
    RET


; CONVERTE_TIPO_DE_CRIAÇÃO
; Converte um índice de criação na TABELA_CRIAÇÃO_ASTEROIDES
; nos valores correspondentes
; Argumentos:
;   R7 - índice do tipo de criação na TABELA_CRIAÇÃO_ASTEROIDES
; No retorno:
;   R6 - posição de criação
;   R7 - vetor da velocidade
converte_tipo_de_criação:
    PUSH R0                            ; guarda o estado do registo
    MOV R0, TABELA_CRIAÇÃO_ASTEROIDES  ; endereço inicial da tabela de procura
    SHL R7, 2                          ; multiplica por 4 pois cada índice são 2 WORDs
    ADD R7, R0                         ; obtém o endereço do tipo de criação desejado
    MOV R6, [R7]                       ; obtém a posição de criação do asteroide
    ADD R7, 2                          ; segue para a velocidade
    MOV R7, [R7]                       ; obtém o vetor de velocidade do asteroide
    POP R0                             ; restaura o estado do registo
    RET


; ATUALIZA_ESTADO_ASTEROIDE
; Atualiza o estado do asteroide na tabela TABELA_ESTADO_ASTEROIDES
; Argumentos:
;   R0 - id do asteroide
;   R1 - novo estado do asteroide
atualiza_estado_asteroide:
    PUSH R0                            ; guarda o estado inicial dos registos
    PUSH R2
    MOV R2, TABELA_ESTADO_ASTEROIDES   ; endereço base da tabela de estado
    SHL R0, 1                          ; leva em conta o tamanho de cada elemento
    ADD R2, R0                         ; endereço do estado do asteroide
    MOV [R2], R1                       ; atualiza o estado do asteroide
    POP R2                             ; restaura o estado dos registos
    POP R0
    RET


; LÊ_ESTADO_ASTEROIDE
; Devolve o estado do asteroide (de acordo com o que está na TABELA_ESTADO_ASTEROIDES)
; Argumentos:
;   R0 - id do asteroide
; No retorno:
;   R10 - estado atual do asteroide
lê_estado_asteroide:
    PUSH R0                            ; guarda o estado inicial dos registos
    MOV R10, TABELA_ESTADO_ASTEROIDES  ; endereço base da tabela de estado
    SHL R0, 1                          ; leva em conta que cada elemento é uma WORD
    ADD R10, R0                        ; endereço do estado do asteroide
    MOV R10, [R10]                     ; move para R10 o valor desse estado
    POP R0
    RET


; CRIA_ASTEROIDE
; Cria um asteroide com uma dada posição, velocidade e tipo aleatórios
; Argumentos:
;   R0 - id do asteroide
cria_asteroide:
    PUSH R0                            ; guarda o estado dos registos usados
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9
    CALL busca_asteroide              ; obtém os endereços relevantes do asteroide
    CALL gera_asteroide_aleatório     ; obtém o tipo do asteroide (posição, etc)
    CALL converte_tipo_de_criação     ; converte o tipo de criação para
    MOV R9, [R6]                       ; um tipo de posição e velocidade
    MOV [R0], R9                       ; guarda a linha do pixel de referência em memória
    ADD R6, 2                          ; segue para a coluna do pixel de referência
    MOV R9, [R6]                       ; obtém o valor da coluna
    CMP R8, ASTEROIDE_MINERÁVEL        ; verifica se o asteroide é minerável
    JNZ cria_asteroide_continua        ; se não for, faz o processo normal
    CMP R9, CRIAÇÃO_SUPERIOR_ESQ_COLUNA; verifica se o asteroide está na coluna 0
    JZ cria_asteroide_continua         ; se estiver, faz o processo normal
    SUB R9, TRANSLAÇÃO_ASTEROIDE_MINERÁVEL  ; caso contrário, retira um pequeno
    ; valor à coluna para aparecer no mesmo sítio que os asteroides não mineráveis
cria_asteroide_continua:
    MOV [R1], R9                       ; guarda a coluna em memória
    MOV R9, [R7]                       ; obtém a velocidade horizontal
    MOV [R4], R9                       ; guarda-a como velocidade do asteroide
    ADD R7, 2                          ; segue para a velocidade vertical
    MOV R9, [R7]                       ; obtém a velocidade vertical
    MOV [R5], R9                       ; atualiza a velocidade vertical do asteroide
    CMP R8, ASTEROIDE_Ñ_MINERÁVEL      ; verifica se o asteroide é ou não minerável
    JZ cria_asteroide_ñ_minerável      ; e atualiza o asteroide com a template certa
    MOV R9, TEMPLATES_ASTEROIDE_MINERÁVEL   ; template se for minerável
    MOV [R2], R9                       ; atualiza a template do asteroide
    JMP cria_asteroide_desenha         ; vai desenhar o asteroide
cria_asteroide_ñ_minerável:
    MOV R9, TEMPLATES_ASTEROIDE_Ñ_MINERÁVEL ; template se não for minerável
    MOV [R2], R9                       ; atualiza a template do asteroide
cria_asteroide_desenha:
    MOV R0, [R0]                       ; transforma o endereço no valor da linha
    MOV R1, [R1]                       ; transforma o endereço no valor da coluna
    MOV R2, [R2]                       ; a template de um asteroide é na realidade
    MOV R2, [R2]                       ; um endereço para o endereço da template
    MOV [SELECIONA_ECRÃ], R3           ; seleciona o ecrã onde desenhar
    CALL escreve_template              ; desenha no ecrã
    POP R9                             ; restaura o estado dos registos
    POP R8
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    PUSH R1                            ; guarda R1 para uma pequena operação
    MOV R1, MANTEM_ASTEROIDE           ; de atualização do estado do asteroide
    CALL atualiza_estado_asteroide    ; e depois acaba a rotina
    POP R1
    RET


; MOVE_ASTEROIDE
; Move a posição de um asteroide no ecrã
; Argumentos:
;   R0 - id do asteroide
move_asteroide:
    PUSH R0                            ; guarda o estado dos registos usados
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R10
    MOV R8, R0                         ; cópia auxiliar o id do asteroide
    CALL busca_asteroide              ; obtém os endereços de informações do asteroide
    MOV R6, R0                         ; guarda uma copia do endereço da linha
    MOV R7, R1                         ; faz o mesmo para o endereço da coluna
    MOV R0, [R0]                       ; transforma o endereço da linha no valor
    MOV R1, [R1]                       ; transforma o endereço da coluna no valor
    MOV R4, [R4]                       ; obtém a componente horizontal da velocidade
    MOV R5, [R5]                       ; obtém a componente vertical da velocidade
    MOV R2, [R2]                       ; obtém a template do asteroide
    CALL deteta_colisão_asteroide_nave ; deteta se houve colisão com a nave
    CMP R10, 1                         ; verifica se houve colisão
    JZ move_asteroide_colisão          ; se houve, termina o jogo
    MOV R2, [R2]                       ; (o asteroide tem um endereço para o endereço)
    MOV [SELECIONA_ECRÃ], R3           ; seleciona o ecrã onde desenhar
    CALL move_template                 ; move a template
    MOV [R6], R0                       ; atualiza a linha de referência em memória
    MOV [R7], R1                       ; atualiza a coluna de referência em memória
    CALL verifica_template_toda_fora   ; verifica se o asteroide está fora do ecrã
    CMP R10, 0                         ; (0 significa que sim neste caso)
    JNZ move_asteroide_saída           ; se for falso, a rotina acaba
    CALL apaga_template                ; apaga o asteroide do ecrã
    MOV R0, R8                         ; coloca o id do asteroide  em R0
    MOV R1, CRIAR_ASTEROIDE            ; e o novo estado do asteroide
    CALL atualiza_estado_asteroide    ; e atualiza o seu estado
    JMP move_asteroide_saída
move_asteroide_colisão:
    MOV R0, TERMINA                    ; comunica ao controlo
    MOV [ESTADO_JOGO], R0              ; que o jogo terminou
    MOV	R0, FUNDO_GAME_OVER_EXPLOSAO   ; cenário de fundo da explosão
    MOV [SELECIONA_CENARIO], R0        ; seleciona o cenário de fundo
    MOV R0, SOM_TERMINAR_POR_ASTEROIDE ; som de fim de jogo após colisão com asteroide
    MOV [REPRODUZ_SOM], R0             ; reproduz som
    MOV R0, TERMINA_SEM_COMANDO        ; indica ao controlo que o jogo
    MOV [TIPO_DE_FIM], R0              ; terminou por embate ou falta de energia
    MOV R0, TECLA_TERMINA_JOGO         ; pede ao processo de controlo
    MOV [LOCK_CONTROLO], R0            ; para terminar o jogo
move_asteroide_saída:
    POP R10                            ; restaura o estado dos registos
    POP R8
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET


; REPRODUZ_SOM_DESTRUIÇÃO_ASTEROIDE
; Escolhe que som de destruição a reproduzir, de acordo com a template do asteroide
; Argumentos:
;   R2 - template do asteroide
reproduz_som_destruição_asteroide:
    PUSH R0                            ; guarda o registo
    MOV R0, DEF_ASTEROIDE_Ñ_MINERÁVEL_TEMPLATE  ; verifica se a template dada
    CMP R2, R0                                  ; é de um asteroide não mineável
    JNZ reproduz_som_destruição_asteroide_minerável ; se não for, salta este caso
    MOV R0, SOM_EXPLOSÃO               ; seleciona o som de explosão
    MOV [REPRODUZ_SOM], R0             ; reproduz o som (este caso é do não minerável)
    JMP reproduz_som_destruição_asteroide_saída ; a rotina termina
reproduz_som_destruição_asteroide_minerável:
    MOV R0, DEF_ASTEROIDE_MINERÁVEL_TEMPLATE    ; como há mais que duas templates e só
    CMP R2, R0      ; se reproduz o som uma vez, temos de garantir que é esta template
    JNZ reproduz_som_destruição_asteroide_saída ; se não for, não se reproduz nada
    MOV R0, SOM_MINERAÇÃO              ; seleciona o som de mineração
    MOV [REPRODUZ_SOM], R0             ; reproduz o som (este é o caso do minerável)
    MOV R0, INCREMENTA_25              ; incrementa o valor dos displays e a energia
    MOV [LOCK_ENERGIA_NAVE], R0        ; da nave em 25
reproduz_som_destruição_asteroide_saída:
    POP R0                             ; restaura o registo ao estado inicial
    RET


; DESTROI_ASTEROIDE
; Executa a animação de destruição de um asteroide e apaga-o no fim
; Argumentos:
;   R0 - id do asteroide
destroi_asteroide:
    PUSH R0                            ; guarda o estado atual dos registos
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    MOV R6, R0                         ; cópia do id para depois atualizar o seu estado
    CALL busca_asteroide              ; obtém os endereços de informações do asteroide
    MOV R0, [R0]                       ; transforma o endereço da linha no valor
    MOV R1, [R1]                       ; transforma o endereço da coluna no valor
    MOV R4, R2                         ; cópia do endereço da animação do asteroide
    MOV R2, [R2]                       ; obtém o estado atual da animação do asteroide
    MOV R5, R2                         ; cópia do estado atual da animação
    MOV R2, [R2]                       ; finalmente, obtém a template em si
    ADD R5, 2                          ; segue para a próxima template
    MOV R7, [R5]                       ; obtém essa template
    CMP R7, FIM_DESTRUIÇÃO_ASTEROIDE   ; verifica se chegou ao fim da animação
    JZ destroi_asteroide_apaga         ; se sim, apaga o asteroide
    CALL reproduz_som_destruição_asteroide
    CALL apaga_template                ; se não, apaga a template atual
    MOV [R4], R5                       ; atualiza em memória a nova template
    MOV R2, R7                         ; seleciona a nova template a desenhar
    CALL escreve_template              ; desenha a nova template
    JMP destroi_asteroide_saída        ; e a rotina termina
destroi_asteroide_apaga:
    CALL apaga_template                ; apaga o asteroide do ecrã
    MOV R0, R6                         ; seleciona o id do asteroide para depois
    MOV R1, CRIAR_ASTEROIDE            ; ir à TABELA_ESTADO_ASTEROIDES para mudar
    CALL atualiza_estado_asteroide    ; o seu estado (para ser criado a seguir)
destroi_asteroide_saída:
    POP R7                             ; restaura o estado atual dos registos
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET


; ATUALIZA_ASTEROIDE
; Atualiza um asteroide de acordo com o seu estado atual
; Argumentos:
;   R0 - id do asteroide
atualiza_asteroide:
    PUSH R10                           ; guarda o estado do registo
    CALL lê_estado_asteroide          ; lê o estado atual do asteroide
    CMP R10, MANTEM_ASTEROIDE          ; verifica se é para manter o asteroide
    JZ atualiza_asteroide_move         ; se for para manter, move o asteroide
    CMP R10, CRIAR_ASTEROIDE           ; verifica se é para criar o asteroide
    JZ atualiza_asteroide_cria         ; vai criar o asteroide (se for esse o caso)
    CALL destroi_asteroide             ; se não, é porque o asteroide está em
    JMP atualiza_asteroide_saída       ; processo de destruição
atualiza_asteroide_cria:
    CALL cria_asteroide                ; cria o asteroide
    JMP atualiza_asteroide_saída
atualiza_asteroide_move:
    CALL move_asteroide                ; move o asteroide
atualiza_asteroide_saída:
    POP R10                            ; restaura o estado de R10
    RET


; ATUALIZA_TODOS_ASTEROIDES
; Atualiza todos os asteroides (cria, move e apaga de acordo com o estado de cada um)
; Não recebe argumentos
atualiza_todos_asteroides:
    PUSH R0                            ; guarda o estado dos registos usados
    PUSH R1
    MOV R0, 0                          ; começa pelo asteroide com o id 0
    MOV R1, QUANTIDADE_DE_ASTEROIDES   ; id limite do asteroide
atualiza_todos_asteroides_ciclo:
    CMP R0, R1                         ; verifica se já atualizou todos os asteroides
    JZ atualiza_todos_asteroides_saída ; se sim, a rotina acaba
    CALL atualiza_asteroide            ; se não, atualiza o asteroide atual
    ADD R0, 1                          ; segue para o próximo id
    JMP atualiza_todos_asteroides_ciclo; repete os passos até atualizar tudo
atualiza_todos_asteroides_saída:
    POP R1                             ; restaura o estado dos registos
    POP R0
    RET


; *****************************************************************************
;   Interface das sondas
; *****************************************************************************
; BUSCA_SONDA
; Coloca nos registos 1 a 5 os endereço das informações da sonda
; na posição n (0, 1, 2)
; Argumentos:
;   R0 - número da sonda
; No retorno:
;   R0 - endereço da linha
;   R1 - endereço da coluna
;   R4 - velocidade horizontal
;   R5 - velocidade vertical
;   R6 - endereço do número de movimentos da sonda
busca_sonda:
    PUSH R7                            ; guarda o estado de R7 e R8
    PUSH R8
    MOV R8, R0                         ; cópia auxiliar do número da sonda
    MOV R7, MEMORIA_POR_SONDA          ; obtém o espaço que cada sonda ocupa
    MUL R7, R0                         ; ignora as sondas antes da requesitada
    MOV R0, TABELA_SONDAS              ; obtém o endereço da tabela das sondas
    ADD R7, R0                         ; vai para o endereço da sonda
    MOV R0, R7                         ; obtém o endereço da linha da sonda
    ADD R7, 2                          ; segue para o endereço da coluna
    MOV R1, R7                         ; obtém o endereço da coluna da sonda
    ADD R7, 2                          ; segue para o endereço do tipo de velocidade
    MOV R7, [R7]                       ; obtém o endereço da velocidade horizontal
    MOV R4, [R7]                       ; obtém a componente horizontal da velocidade
    ADD R7, 2                          ; segue para o endereço da componente vertical
    MOV R5, [R7]                       ; obtém a componente vertical da velocidade
    MOV R7, SONDAS_EM_CURSO            ; endereço da tabela do estado das sondas
    SHL R8, 1                          ; multiplica R8 por 2 por cada estado ser 2 bytes
    ADD R7, R8                         ; endereço especifico do estado da sonda
    MOV R6, R7                         ; obtém o número de movimentos da sonda
    POP R8                             ; restaura o estado de R7 e R8
    POP R7
    RET


; DETETA_COLISÃO_SONDA_ASTEROIDE
; Deteta se a sonda colidiu com um asteroide
; Argumentos:
;   R0 - endereço da linha do pixel da sonda
;   R1 - endereço da coluna do pixel da sonda
; Devolve em R8 MANTEM_ASTEROIDE se não houve colisões
deteta_colisão_sonda_asteroide:
    PUSH R0                            ; guarda o estado dos registos usados
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R10
    MOV R0, [R0]                       ; transforma os endereços da linha e coluna
    MOV R1, [R1]                       ; nos seus valores reais
    MOV R2, ECRÃ_ASTEROIDE_0           ; número do ecrã do primeiro asteroide
    MOV R3, QUANTIDADE_DE_ASTEROIDES   ; quantidade de ecrãs usados
    ADD R3, R2                         ; R3 passa a ter o ecrã limite do ciclo
    MOV R8, MANTEM_ASTEROIDE           ; valor de retorno caso não haja colisão
deteta_colisão_sonda_asteroide_ciclo:
    CMP R2, R3                         ; verifica se já percorreu todos os ecrãs
    JZ deteta_colisão_sonda_asteroide_saída ; se sim, a rotina acaba
    CALL cor_pixel                    ; testa se o pixel da sonda no ecrã selecionado
                                       ; tem cor (se sim, será sempre um asteroide)
    CMP R10, 0                         ; verifica se não tem cor
    JZ deteta_colisão_sonda_asteroide_seguinte    ; se não tiver cor, ignora este ecrã
    MOV R8, R2                         ; faz uma cópia auxiliar do ecrã da colisão
    SUB R8, ECRÃ_ASTEROIDE_0           ; transforma o ecrã num índice de tabela
    SHL R8, 1                          ; leva em conta que cada elemento é uma WORD
    MOV R10, TABELA_ESTADO_ASTEROIDES  ; endereço da tabela de destruição
    ADD R8, R10                        ; obtém o endereço de destruição do asteroide
    MOV R10, DESTROI_ASTEROIDE         ; obtém o sinal de destruição
    MOV [R8], R10                      ; pede ao processo dos asteroides para o destruir
deteta_colisão_sonda_asteroide_seguinte:
    ADD R2, 1                          ; próximo ecrã a verificar
    JMP deteta_colisão_sonda_asteroide_ciclo    ; repete o ciclo
deteta_colisão_sonda_asteroide_saída:
    MOV R3, ECRÃ_SONDAS                ; cor_pixel muda o ecrã selecionado
    MOV [SELECIONA_ECRÃ], R3           ; volta a selecionar o das sondas
    POP R10                            ; restaura o estado dos registos
    POP R3
    POP R2
    POP R1
    POP R0
    RET


; MOVE_SONDA
; Move a sonda especificada (atualiza a memória)
; Argumentos:
;   R0 - número da sonda
; Devolve em R8 se a sonda deve ser apagada ou não
move_sonda:
    PUSH R0                            ; guarda o estado dos registos usados
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    CALL busca_sonda                  ; vai buscar as informações da sonda a memória
    CALL deteta_colisão_sonda_asteroide ; deteta se há alguma colisão no lugar onde está
    CMP R8, MANTEM_ASTEROIDE           ; verifica se o valor de retorno indica colisão
    JNZ move_sonda_saída               ; se for o caso, a sonda não é movida
    MOV R7, R0                         ; cópia auxiliar do endereço da linha
    MOV R8, R1                         ; cópia auxiliar do endereço da coluna
    MOV R0, [R0]                       ; obtém a linha do pixel da sonda
    MOV R1, [R1]                       ; obtém a coluna do pixel da sonda
    MOV R2, DEF_SONDA_TEMPLATE         ; obtém a template da sonda
    MOV R3, ECRÃ_SONDAS                ; obtém o ecrã onde desenhar
    CALL move_template                 ; move a sonda
    MOV [R7], R0                       ; atualiza a linha da sonda em memória
    MOV [R8], R1                       ; atualiza a coluna da sonda em memória
    MOV R0, R7                         ; volta a colocar o endereço da linha em R0
    MOV R1, R8                         ; e o da coluna em R1, para detetar a colisão
    MOV R7, -1                         ; decrementa o número de movimentos da sonda
    MOV R8, [R6]                       ; (registo auxiliar para realizar a soma)
    ADD R8, R7                         ; por 1 (ou seja, fica mais perto de desaparecer)
    MOV [R6], R8                       ; coloca o decremento em memória
    CALL deteta_colisão_sonda_asteroide ; deteta se há alguma colisão no novo lugar
    CMP R8, MANTEM_ASTEROIDE           ; é necessário uma verificação dupla pois
    JNZ move_sonda_saída               ; os asteroides têm movimento independente
    MOV R8, MANTEM_ASTEROIDE           ; transmite que não houve colisão
move_sonda_saída:
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET


; CRIA_SONDA
; Cria uma nova sonda na posição especificada (0, 1, 2) e desenha-a
; no ecrã (0 - esquerda, 1 - centro, 2 - direita)
; Argumentos:
;   R0 - número da sonda
cria_sonda:
    PUSH R0                            ; guarda o estado dos registos
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    MOV R1, [ESTADO_JOGO]              ; verifica se o estado do jogo
    MOV R2, EM_ANDAMENTO               ; está "EM_ANDAMENTO", se não estiver
    CMP R1, R2                         ; então é inválido criar uma sonda
    JNZ cria_sonda_saída               ; e a rotina acaba
    MOV R3, R0                         ; cópia auxiliar do número da sonda
    CALL busca_sonda                  ; obtém as informações da sonda
    MOV R2, [R6]                       ; obtém o estado da sonda (nº movimentos)
    CMP R2, SONDA_EM_RESERVA           ; verifica se a sonda está em curso
    JNZ cria_sonda_saída               ; se sim, a rotina acaba
    MOV R5, TABELA_POSIÇÃO_CRIAÇÃO_SONDA ; vai à lookup table de posição de criação
    SHL R3, 1                          ; conta com o facto de cada índice ser 2 bytes
    MOV R5, [R5 + R3]                  ; coloca em R5 o tipo de posição de criação
    MOV R3, [R5]                       ; coloca em R3 a linha da posição de criação
    MOV R5, [R5 + 2]                   ; coloca em R5 a coluna de posição de criação
    MOV [R0], R3                       ; inicializa em memória a linha da sonda
    MOV [R1], R5                       ; inicializa em memória a coluna da sonda
    MOV R0, NUMERO_MAXIMO_MOV_SONDA    ; obtém o número máximo de movimentos da sonda
    MOV [R6], R0                       ; inicializa a sonda nesse estado
    MOV R0, R3                         ; obtém a linha onde desenhar a sonda
    MOV R1, R5                         ; obtém a coluna onde desenhar a sonda
    MOV R2, DEF_SONDA_TEMPLATE         ; obtém a template da sonda
    MOV R3, ECRÃ_SONDAS                ; escolhe o ecrã onde desenhar a sonda
    CALL escreve_template              ; desenha a sonda no ecrã
    MOV R6, SOM_SONDA                  ; coloca em R6 o som de disparo da sonda
    MOV [REPRODUZ_SOM], R6             ; reproduz o som
    MOV R0, DECREMENTA_5               ; Decrementa 5 aos displays
    MOV [LOCK_ENERGIA_NAVE], R0        ; e à energia da nave
cria_sonda_saída:                      ; termina a rotina
    POP R6                             ; restaura o estado dos registos
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET


; APAGA_SONDA
; Apaga uma sonda quer em memória, quer no ecrã
; Argumentos:
;   R0 - número da sonda
apaga_sonda:
    PUSH R0                            ; guarda o estado dos registos
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    CALL busca_sonda                  ; vai buscar as informações da sonda
    MOV R4, SONDA_EM_RESERVA           ; prepara para atualizar o estado da sonda
    MOV [R6], R4                       ; atualiza o estado da sonda para SONDA_EM_RESERVA
    MOV R0, [R0]                       ; transforma os endereços da linha e coluna
    MOV R1, [R1]                       ; da sonda para o seu valor
    MOV R2, DEF_SONDA_TEMPLATE         ; seleciona a template a apagar
    MOV R3, ECRÃ_SONDAS                ; seleciona o ecrã onde apagar
    CALL apaga_template                ; apaga a sonda do ecrã
    POP R6                             ; restaura o estado dos registos
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET


; ATUALIZA_SONDA
; Atualiza uma sonda de acordo com o seu estado atual
; Argumentos:
;   R0 - número da sonda a atualizar
atualiza_sonda:
    PUSH R0                            ; guarda o estado dos registos
    PUSH R2
    PUSH R8
    MOV R2, SONDAS_EM_CURSO            ; tabela de lookup do estado das sondas
    SHL R0, 1                          ; obtém o índice na tabela
    ADD R2, R0                         ; obtém o endereço do índice certo
    SHR R0, 1                          ; restaura o número da sonda
    MOV R2, [R2]                       ; obtém o estado da sonda (nº movimentos)
    CMP R2, SONDA_EM_RESERVA           ; verifica se a sonda está em reserva
    JZ atualiza_sonda_saída            ; se estiver em reserva, não faz nada
    CMP R2, 0                          ; verifica se a sonda já exaustou os seus
    JZ atualiza_sonda_apaga            ; movimentos todos, se sim, apaga-a
atualiza_sonda_move:
    CALL move_sonda                    ; move a sonda e termina a rotina
    CMP R8, MANTEM_ASTEROIDE           ; verifica se houve colisão
    JZ atualiza_sonda_saída            ; se não, termina a rotina
atualiza_sonda_apaga:                  ; caso contrário, apaga a sonda
    CALL apaga_sonda                   ; apaga a sonda
    JMP atualiza_sonda_saída           ; termina a rotina
atualiza_sonda_saída:
    POP R8                             ; restaura os registos usados
    POP R2
    POP R0
    RET


; ATUALIZA_TODAS_SONDAS
; Atualiza todas as sondas presentes em ecrã
atualiza_todas_sondas:
    PUSH R0                            ; guarda o estado do R0
    MOV R0, 0                          ; ID da sonda da esquerda
atualiza_todas_sondas_ciclo:
    CMP R0, SONDA_DIREITA              ; se o ID da atual for maior que o da última sonda
    JGT atualiza_todas_sondas_saída    ; já atualizou tudo e a rotina acaba
    CALL atualiza_sonda                ; se não, atualiza a sonda selecionada
    ADD R0, 1                          ; segue para  a sonda seguinte
    JMP atualiza_todas_sondas_ciclo    ; repete até atualizar tudo
atualiza_todas_sondas_saída:
    POP R0                             ; restaura o estado do R0
    RET


; *****************************************************************************
;   Interface da animação da nave
; *****************************************************************************
; ATUALIZA_FRAME_NAVE
; Atualiza o frame da nave para o seguinte
atualiza_frame_nave:
    PUSH R0                            ; guarda o estado dos registos
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    MOV R4, [FRAME_ATUAL]              ; vai buscar o número do frame atual
    MOV R5, NUMERO_FRAMES_NAVE         ; e vê se chegou ao último
    MOD R4, R5                         ; se sim, passa para o primeiro (zero)
    MOV R0, LINHA_REFERENCIA_NAVE      ; linha do pixel de referência da nave 
                                       ; (que corresponde ao pixel de referencia do vidro)
    MOV R1, COLUNA_REFERENCIA_NAVE     ; coluna do pixel de referência da nave
    ADD R1, 4                          ; segue para a coluna do vidro
    MOV R5, R4
    MOV R4, TABELA_ANIMACAO_VIDRO_NAVE ; endereço da tabela da animação do vidro da nave
    SHL R5, 1                          ; multiplica R4 por 2 pois a tabela é de WORDs
    MOV R2, [R5 + R4]                  ; R2 fica com a template do frame atual do vidro
    MOV R3, ECRÃ_NAVE                  ; ecrã onde desenhar o vidro
    CALL escreve_template              ; desenha o vidro
    CALL atualiza_luzes_nave          ; desenha as luzes da nave
    SHR R5, 1                          ; divide R4 por 2 para voltar ao numero de frames
    ADD R5, 1                          ; segue para o frame seguinte
    MOV [FRAME_ATUAL], R5              ; atualiza frame atual
    POP R5                             ; restaura o estado dos registos
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET


; ATUALIZA_LUZES_NAVE
; Atualiza as luzes da nave
; Não recebe argumentos
atualiza_luzes_nave:
    PUSH R0                            ; guarda o estado dos registos
    PUSH R1
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    MOV R7, [ETAPA_LUZES_ATUAL]        ; obtém em que desenho se vai
    MOV R1, 0                          ; inicializa a coluna inicial de desenho a 0
    MOV R5, TABELA_ESTADO_LUZ          ; descreve as templates de cada luz em sequência
    MOV R4, ETAPAS_LUZES               ; contador de quantas vezes tem de desenhar
    SUB R4, 1                          ; (há 1 etapa a mais que é a de "transição")
    MOV R0, LINHA_REFERENCIA_LUZES_NAVE; linha onde desenhar as luzes
atualiza_luzes_nave_ciclo:
    SHL R7, 1                          ; tem em conta que a tabela é de WORDs
    MOV R2, [R5 + R7]                  ; obtém a template da luz atual
    MOV R6, COLUNA_REFERENCIA_NAVE     ; offset da coluna inicial da nave
    ADD R1, R6                         ; desenha partir da coluna esquerda da nave
    CALL escreve_template              ; desenha a luz
    SUB R1, R6                         ; obtém o valor original de R1
    MOV R6, ETAPAS_LUZES               ; tamanho da tabela (igual ao da nave)
    ADD R1, 1                          ; segue para o pixel à direita
    MOD R1, R6                         ; se sair da tabela, volta a 0
    SHR R7, 1                          ; volta o índice ao normal
    SUB R7, 1                          ; decrementa o índice
    MOD R7, R6                         ; se sair da tabela, volta ao fim
    SUB R4, 1                          ; menos um pixel por desenhar
    JNZ atualiza_luzes_nave_ciclo      ; repete, se ainda houver pixels por desenhar
    MOV R4, [ETAPA_LUZES_ATUAL]        ; reobtém a etapa atual
    ADD R4, 1                          ; incrementa o número da etapa atual
    MOD R4, R6                         ; se exceder o número de etapas, volta a 0
    MOV [ETAPA_LUZES_ATUAL], R4        ; atualiza a etapa atual
    POP R7                             ; restaura o estado dos registos
    POP R6
    POP R5
    POP R4
    POP R1
    POP R0
    RET


; *****************************************************************************
;   Interface de comandos e controlo
; *****************************************************************************
; TECLA_PARA_COMANDO
; Lê a ultima tecla premida e retorna em R10 o comando a executar (se houver algum)
; Argumentos:
;   R0 - tecla a converter
tecla_para_comando:
    MOV R10, TABELA_COMANDOS           ; obtém o endereço da tabela de conversão
    SHL R0, 1                          ; índice do comando na tabela
    MOV R10, [R10 + R0]                ; coloca em R10 o comando associado à tecla
    SHR R0, 1                          ; restaura a tecla para o valor original
    RET


; EXECUTA_COMANDO
; Executa o comando selecionado pelo utilizador
; Não recebe argumentos
executa_comando:
    PUSH R0                            ; guarda o estado do registos
    PUSH R10                           ; espera pelo teclado
    MOV R0, [LOCK_CONTROLO]            ; e obtém a tecla associada ao comando
    CALL tecla_para_comando           ; coloca em R10 o comando a executar
    CMP R10, SEM_COMANDO               ; verifica se a tecla lida tem comando associado
    JZ executa_comando_saída           ; se não, não faz nada
    CALL R10                           ; se sim, executa a rotina do comando
executa_comando_saída:
    POP R10                            ; restaura o estado dos registos
    POP R0
    RET


; INICIA_JOGO
; Executa o comando de iniciar o jogo
inicia_jogo:
    PUSH R0                            ; guarda o estado dos registos
    PUSH R1
    PUSH R2
    PUSH R3
    MOV R0, [ESTADO_JOGO]              ; lê o estado do jogo
    MOV R1, INICIA                     ; e verifica se esse estado está
    CMP R0, R1                         ; a "INICIA", se não estiver
    JNZ inicia_jogo_saída              ; não executa o comando
    MOV	R1, FUNDO_NORMAL               ; cenário de fundo normal
    MOV [SELECIONA_CENARIO], R1        ; seleciona o cenário de fundo
    MOV R0, LINHA_REFERENCIA_NAVE      ; linha do pixel de referência da nave
    MOV R1, COLUNA_REFERENCIA_NAVE     ; coluna do pixel de referência da nave
    MOV R2, DEF_NAVE_TEMPLATE          ; template da nave
    MOV R3, ECRÃ_NAVE                  ; ecrã onde a desenhar
    CALL escreve_template              ; desenha a nave
    MOV R0, EM_ANDAMENTO               ; coloca ESTADO_JOGO como estando EM_ANDAMENTO
    MOV [ESTADO_JOGO], R0              ; para os processos correrem normalmente
    EI0                                ; permite a exceção dos asteroides
    EI1                                ; permite a exceção das sondas
    EI2                                ; permite a exceção da energia da nave
    EI3                                ; permite a exceção da animação da nave
    EI                                 ; permite as exceções no geral
    CALL processo_asteroides           ; inicializa o processo dos asteroides
    CALL processo_sondas               ; inicializa o processo das sondas
    CALL processo_energia_nave         ; inicializa o processo da energia da nave
    CALL processo_anima_nave           ; inicializa o processo da animação da nave
    MOV R0, SOM_MÚSICA_FUNDO           ; começa a música de fundo
    MOV [REPRODUZ_SOM_LOOP], R0
inicia_jogo_saída:
    POP R3                             ; restaura o estado dos registos
    POP R2
    POP R1
    POP R0
    RET


; PAUSA_JOGO
; Executa o comando de pausar o jogo, se este estiver em andamento, ou
; de recomeçar o jogo, se este estiver em pausa
; Não recebe argumentos
pausa_jogo:
    PUSH R0                            ; guarda o estado do registo
    MOV R0, [ESTADO_JOGO]              ; obtém o estado atual do jogo. Se estiver
    CMP R0, EM_ANDAMENTO               ; EM_ANDAMENTO, vai colocar o jogo em pausa
    JZ pausa_jogo_pausa                ; se não estiver em andamento
    CMP R0, PAUSA                      ; se não estiver em pausa, não faz nada
    JNZ pausa_jogo_saída               ; se estiver em pausa, coloca o jogo
    MOV R0, EM_ANDAMENTO               ; em andamento e destranca todos os locks
    MOV [ESTADO_JOGO], R0              ; pois isso volta a libertar todos os processos
    CALL destranca_processos           ; relativos ao jogo (relevantes ao jogador)
    MOV R0, FUNDO_NORMAL               ; cenário de fundo normal
    MOV [SELECIONA_CENARIO], R0        ; seleciona o cenário de fundo
    MOV R0, SOM_DESPAUSA               ; reproduz o som de despausar o jogo
    MOV [REPRODUZ_SOM], R0
    CALL mostra_ecrãs                  ; revela tudo o que tinha sido escondido
    MOV R0, SOM_MÚSICA_FUNDO           ; recomeça a música de fundo
    MOV [CONTINUA_SOM], R0             ; a partir de onde estava
    JMP pausa_jogo_saída               ; depois, termina a rotina
pausa_jogo_pausa:
    MOV R0, PAUSA                      ; estando em andamento
    MOV [ESTADO_JOGO], R0              ; sinaliza aos processos, que se irão "trancar"
    CALL destranca_processos           ; destranca os processos que possam estar
                                       ; num lock de interrupção
    CALL esconde_ecrãs                 ; esconde tudo o que foi desenhado
    MOV R0, FUNDO_PAUSE                ; cenário de fundo de pausa
    MOV [SELECIONA_CENARIO], R0        ; seleciona o cenário de fundo
    MOV R0, SOM_MÚSICA_FUNDO           ; pausa a música de fundo
    MOV [PAUSA_SOM], R0                ; enquanto estiver pausado
    MOV R0, SOM_PAUSA                  ; reproduz o som de pausar o jogo
    MOV [REPRODUZ_SOM], R0
pausa_jogo_saída:
    POP R0                             ; restaura o estado do registo
    RET


; TERMINA_JOGO
; Executa o comando de terminar o jogo, selecionando a imagem de fundo
; de acordo com o tipo de fim de jogo
termina_jogo:
    PUSH R0                            ; guarda os registos usados
    PUSH R1
    MOV R0, [ESTADO_JOGO]              ; verifica se o estado atual do jogo
    CMP R0, INICIA                     ; é inicia, se for, a rotina acaba
    JZ termina_jogo_saída              ; caso contrário, termina o jogo
    MOV [APAGA_ECRÃ], R0               ; apaga tudo o que foi desenhado
    MOV R0, [TIPO_DE_FIM]              ; verifica se o fim de jogo
    CMP R0, TERMINA_SEM_COMANDO        ; foi causado por embate ou energia
    JZ termina_jogo_termina_processos  ; ou se foi por comando
    MOV R0, FUNDO_GAME_OVER            ; se foi por comando, atualiza o cenário
    MOV [SELECIONA_CENARIO], R0        
    MOV R0, SOM_TERMINAR_POR_COMANDO   ; e toca o som apropriado
    MOV [REPRODUZ_SOM], R0             
termina_jogo_termina_processos:
    MOV R0, TERMINA_COM_COMANDO        ; por default, reinicializa o tipo de fim
    MOV [TIPO_DE_FIM], R0              ; para TERMINA_COM_COMANDO
    CALL mostra_ecrãs                  ; mostra os ecrãs caso estejam escondidos
    MOV [ESTADO_JOGO], R0              ; em TERMINA, de seguida
    CALL destranca_processos           ; destranca todos os processos
    YIELD                              ; deixa-os terminarem por si próprios
    MOV R0, INICIA                     ; a seguir atualiza o estado do jogo para INICIA
    MOV [ESTADO_JOGO], R0              ; para poder recomeçar o jogo
    MOV R0, SOM_MÚSICA_FUNDO
    MOV [TERMINA_SOM_LOOP], R0
termina_jogo_saída:
    POP R1                             ; restaura o estado dos registos usados
    POP R0
    RET


; DESTRANCA_PROCESSOS
; Destranca todos os processos com o valor presente em R0
; Argumentos:
;   R0 - estado do jogo
destranca_processos:
    PUSH R0
    MOV [LOCK_JOGO], R0                ; destranca todos os processos em pausa
    MOV [LOCK_ASTEROIDES], R0          ; destranca a interrupção dos asteroides
    MOV [LOCK_SONDAS], R0              ; destranca a interrupção das sondas
    MOV [LOCK_ANIMACAO_NAVE], R0       ; destranca a interrupção da animação da nave
    MOV R0, 0                          ; a energia da nave tem de ser destrancada a 0
    MOV [LOCK_ENERGIA_NAVE], R0        ; caso contrário, incrementa a energia por R0
    POP R0
    RET


; *****************************************************************************
;   Gerador de números pseudo-aleatórios
; *****************************************************************************
; GERA_ASTEROIDE_ALEATÓRIO
; Gera um asteroide aleatório, ou seja, com tipo (minerável ou não) aleatório e
; combinação posição-velocidade aleatória
; Não recebe argumentos
; No retorno:
;   R7 - combinação posição-velocidade
;   R8 - tipo do asteroide (ASTEROIDE_MINERÁVEL ou ASTEROIDE_Ñ_MINERÁVEL)
gera_asteroide_aleatório:
    PUSH R0                            ; guarda o registo
    MOV R0, TEC_COL                    ; os bits 7-4 de TEC_COL não têm nada ligado
    MOVB R7, [R0]                      ; podem ser aproveitados para gerar os valores
    SHR R7, 4                          ; isola-se os bits 7-4
    MOV R8, R7                         ; cópia para R8 porque R7 vai ser alterado
    MOV R0, 5                          ; módulo a usar para o par posição-velocidade
    MOD R7, R0                         ; obtém o par posição-velocidade (valor de 0 a 5)
    SHR R8, 2                          ; obtém um valor entre 0 e 3
    CMP R8, ASTEROIDE_MINERÁVEL        ; verifica se tem o valor de ASTEROIDE_MINERÁVEL
    JZ gera_asteroide_aleatório_saída  ; se sim, já temos o valor certo
    MOV R8, ASTEROIDE_Ñ_MINERÁVEL      ; se não, por facilidade, colocamos o valor
    ; ASTEROIDE_Ñ_MINERÁVEL, para o tipo do asteroide ter sempre só 2 possibilidades
gera_asteroide_aleatório_saída:
    POP R0                             ; restaura o estado do registo
    RET


; *****************************************************************************
;   Conversor HEXADECIMAL->DECIMAL
; *****************************************************************************
; CONVERTE_HEXA_PARA_DECIMAL
; Converter um número em hexadecimal especificado, para a sua equivalente
; decimal, com um máximo de 3 dígitos
; Argumentos:
;   R0 - valor em hexadecimal
; Retorna em R1 o valor em decimal
converte_hexa_para_decimal:
    PUSH R0                            ; guarda os registos usados
    PUSH R2
    PUSH R3
    PUSH R4
    MOV R1, 0                          ; inicializa o resultado a 0
    MOV R2, 100            ; fator usado para retirar dígito a dígito
    MOV R3, 10                         ; fator de divisão para obter o 
converte_hexa_para_decimal_ciclo:
    MOV R4, R0                         ; cópia auxiliar do valor HEXA atual
    DIV R4, R2                         ; "quantas centenas/dezenas/unidades
                                       ; há no meu número?", ou seja, é o novo dígito
    OR R1, R4                          ; colocamos o novo dígito
                                       ; no último dígito do resultado
    SHL R1, 4                          ; puxa todos os dígitos 1 dígito para a esquerda
    MOD R0, R2                         ; retira o fator do número HEXA
    DIV R2, R3                         ; obtém o novo fator
    CMP R2, 1                          ; se o fator for 1, acabou a conversão
    JZ converte_hexa_para_decimal_saída    ; a rotina termina
    JMP converte_hexa_para_decimal_ciclo   ; se não, repete o ciclo
converte_hexa_para_decimal_saída:
    OR R1, R0                          ; obtém as unidades
    POP R4                             ; restaura os registos
    POP R3
    POP R2
    POP R0
    RET


; *****************************************************************************
;   Rotina auxiliar para inicializar tabelas
; *****************************************************************************
; INICIALIZA_TABELA
; Inicializa uma tabela de qualquer tamanho, em WORDS, com um valor à escolha
; Só aceita tabelas de tamanho par
; Argumentos:
;   R0 - endereço da tabela
;   R1 - tamanho da tabela
;   R2 - valor de inicialização
inicializa_tabela:
    PUSH R0                            ; guarda os registos usados
    PUSH R1
inicializa_tabela_ciclo:
    CMP R1, 0                          ; verifica se já inicializou todos os elementos
    JLE inicializa_tabela_saída        ; se sim, a rotina acaba
    MOV [R0], R2                       ; se não, inicializa o elemento atual
    SUB R1, 1                          ; decrementa o número de elemntos por inicializar
    ADD R0, 2                          ; segue para o endereço da WORD seguinte
    JMP inicializa_tabela_ciclo        ; repete até inicializar tudo
inicializa_tabela_saída:
    POP R1                             ; restaura o estado dos registos
    POP R0
    RET