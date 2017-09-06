# Universidade Federal de Minas Gerais
# Escola de Engenharia
# Departamento de Engenharia Eletrônica
# Autoria: Professor Ricardo de Oliveira Duarte
# Versão: v1-2016 
# Disciplina: ELT005 - Sistemas, Processadores e Periféricos
#
# Este arquivo é um script para compilação e simulação temporal de um DUT (Device Under Test) no ModelSim-Altera
# Antes de executar este script é necessário que você já tenha executado o script de compilação:
# processador_ciclo_unico_quartusII_temporal_sem_pinos.tcl
# O script acima gera os arquivos dut.vho e dut_vhd.sdo que serão necessários à simulação temporal dentro do ModelSim-Altera.
# 
# O script processador_ciclo_unico_modelsim_temporal.do foi construído usando-se como base a referencia:
# ModelSim SE Command Reference Guide fornecido no conjunto de arquivos de referência.
#
# Para executar o script processador_ciclo_unico_modelsim_temporal.do abra o Modelsim e da janela transcript execute o comando:
# Modelsim> do processador_ciclo_unico_modelsim_temporal.do
#
# Mais algumas orientações de configuração do seu ambiente de trabalho:
# Lembre-se de incluir a pasta bin do executável do Quartus II na variável de ambiente de seu sistema operacional Windows.

## ALTERE A VARIÁVEL TCL A SEGUIR PARA ATENDER A CONFIGURAÇÃO DO SEU COMPUTADOR
# Esta variável guarda o Path (caminho) onde se encontra os arquivos dut.vho e dut_vhd.sdo gerados pelo compilador Quartus II
# para simulação temporal no ModelSim
set meu_path C:/Users/ALUNOS/Desktop/processadorciclo_unico/simulation/modelsim

## ALTERE A VARIÁVEL TCL A SEGUIR PARA ATENDER A CONFIGURAÇÃO DO SEU COMPUTADOR 
# Esta variável guarda a pasta e o caminho completo (path) onde serão gerados os arquivos produzidos pelo simulador ModelSim
set meu_home_path C:/Users/ALUNOS/Desktop/processadorciclo_unico/modelsim

# Path para geração da library. Uso o nome padrão de library: work
set meu_work_path $meu_home_path/work

## ALTERE A VARIÁVEL A SEGUIR PARA ATENDER O NOME DO DUT QUE VOCÊ VAI SIMULAR 
# The top level design name
set design processador_ciclo_unico

# A linguagem TCL deve oferecer maneira mais adequada para se fazer a chamada do vsim, mas enquanto eu não encontro,
# segue abaixo a gambiarra de definição de uma variável para guardar a extensão de arquivo _vhd.sdo 
# Quem souber como fazer isso melhor me escreva :-) ricardoduarte@ufmg.br
# Adicionando uma variavel auxiliar para guardar a extensão do arquivo a ser simulado
set auxiliar _vhd.sdo

# The source file(s), the last is the top
# Se precisar de vários arquivos, coloque um nome de arquivo por linha separado por um espaço ao final do nome do arquivo,
# seguido de "/" sem aspas
set src_files $meu_path/$design.vho

# Comandos para criar um novo projeto de dentro da janela transcript do Modelsim
project new $meu_home_path $design work
project addfile $src_files

# Exemplo de linha de comando para disparar a compilação do DUT dentro do Modelsim
# vcom -reportprogress 300 -work work C:/altera/90sp2/quartus/mux21/simulation/modelsim/mux21.vho
# Segue abaixo a linha que dispara a compilação do projeto com todos os arquivos fonte para a simulação temporal
vcom -reportprogress -error -warning 300 -work $meu_work_path $src_files

# Veja abaixo o modelo de chamada do simulador vsim do ModelSim
# vsim -t ps-sdf(typ) +transport_int_delays +transport_path_delays /=<design name>.sdo work.<top-level design entity>
# Segue abaixo a linha que dispara a simulação do DUT no ModelSim
vsim -voptargs=+acc -sdftyp /=$meu_path/$design$auxiliar work.$design

# Definição das variáveis que definem os nomes dos sinais de simulação do DUT
## ALTERE AS VARIÁVEIS OU INCLUA NOVAS VARIÁVEIS A SEGUIR PARA ATENDER O NOME DO DUT QUE VOCÊ VAI SIMULAR
set saida /$design/saida
set Chave_reset /$design/Chave_reset
set Clock /$design/Clock
set Teclado /$design/teclado_in
set Enter /$design/enter_in
set Instrucao /$design/saida_instrucao
set ENOUT /$design/enable_out
set estado /$design/estado_fsm
set ula	/$design/saida_da_ula
set A /$design/saida_banco_A
set B /$design/saida_banco_B
set Write_Br /$design/br_wrt
set Opcode /$design/opcode
set Shifter /$design/shifter_out

# Os comandos abaixo configuram:
# 1) A base (o radix) que será exibido os sinais de entrada e saída do seu DUT durante a simulação.
# 2) A janela Wave do ModelSim onde vai aparecer a waveform com o resultado da simulação.
quietly WaveActivateNextPane {} 0

## ALTERE AS VARIÁVEIS OU INCLUA NOVAS VARIÁVEIS A SEGUIR PARA ATENDER O NOME DO DUT QUE VOCÊ VAI SIMULAR 
add wave -noupdate -radix hexadecimal $saida
add wave -noupdate -radix hexadecimal $Chave_reset
add wave -noupdate -radix hexadecimal $Clock
add wave -noupdate -radix hexadecimal $Teclado
add wave -noupdate -radix hexadecimal $Enter
add wave -noupdate -radix hexadecimal $Instrucao
add wave -noupdate -radix hexadecimal $ENOUT
add wave -noupdate -radix hexadecimal $estado
add wave -noupdate -radix hexadecimal $ula
add wave -noupdate -radix hexadecimal $A
add wave -noupdate -radix hexadecimal $B
add wave -noupdate -radix hexadecimal $Write_Br
add wave -noupdate -radix hexadecimal $Opcode
add wave -noupdate -radix hexadecimal $Shifter





TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
configure wave -namecolwidth 189
configure wave -valuecolwidth 137
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update

## ALTERE O VALOR DO TEMPO FINAL DA JANELA DE SIMULAÇÃO DO DUT
WaveRestoreZoom {0 ns} {480 ns}

# Abaixo segue a inicialização dos sinais de entrada do DUT
## INCLUA E/OU ALTERE O VALOR INICIAL DAS VARIÁVEIS DA LISTA DE ESTÍMULOS A SER APLICADA AO DUT DURANTE A SIMULAÇÃO 
# Usage: force [-freeze | -drive | -deposit] [-cancel <time>] [-repeat <time>] <object_name> {<value> [[@]<time>[<unit>]]}...

force $Chave_reset 	1 0
force $Clock 		0 0
force $Teclado 	 10#0 0
force $Enter       0  0

# Alguns exemplos de formatos de representação de estímulos de sinais de entrada:
# 	em hexadecimal: 16#FFC2 
# 	em binário: 2#11111110
# 	em decimal: 10#-23749
# Alguns exemplos de uso do comando force para definição de estímulos de sinais de entrada:
# Exemplo (1):
# force bus1 16#f @200
# 	Forces bus1 to 16#F at the absolute time 200 measured in the resolution units selected at
# 	simulation start-up.
# Exemplo (2):
# force input1 1 10, 0 20 -r 100
#	Forces input1 to 1 at 10 time units after the current simulation time and to 0 at 20 time
#	units after the current simulation time. This cycle repeats starting at 100 time units after
#	the current simulation time, so the next transition is to 1 at 100 time units after the current
#	simulation time.
# Exemplo (3):
# force input1 1 10 ns, 0 {20 ns} -r 100ns
#	Similar to the previous example, but also specifies the time units. Time unit expressions
#	preceding the "-r" must be placed in curly braces.
# Exemplo (4):
# when {/mydut/siga = 10#1} {
#	force -deposit /mydut/siga 10#85
# }
#	Forces siga to decimal value 85 whenever the value on the signal is 1.
# Exemplo (5):
# Se o seu DUT necessitar da geração de um sinal de clock, siga este exemplo a seguir:
# force clock 0 0 ns, 1 {20 ns} -r 40 ns
#	O exemplo acima gera um sinal de clock que começa em 0 e alterna para 1 após 20 ns e repete este comportamento após
#	40 ns, ou seja, é um sinal de clock com período de 40 ns e duty cycle de 50% começando em nível lógico 0.
# Exemplo (6):
# Se o seu DUT necessitar da geração de estímulos de uma forma repetitiva, você pode usar um comando for para programar
# a repetição dos estímulos.
# ## faz um loop com 4 repetições
#	for {set num 0} {$num <= 3} {incr num 1} {
#		incr time 50
#		force $controle 1 $time
#		incr time 50
#		force $controle 0 $time
#		incr time 100
#		force $controle 1 $time
#		incr time 50
#		force $controle 0 $time
#		incr time 50
#	}

# Abaixo segue a sequencia de estímulos que você deseja que seja aplicada as entradas do DUT a ser simulado.
# INCLUA E/OU ALTERE O VALOR DAS VARIÁVEIS DA LISTA DE ESTÍMULOS A SER APLICADA AO DUT DURANTE A SIMULAÇÃO 
force $Chave_reset 	1 0 ns, 0 {100 ns} -cancel 5000 ns
force $Clock 		0 0 ns, 1 {40 ns} -r 80 ns
force $Teclado   	10#10 0 ns
force $Enter		1 400 ns, 0 500 ns, 1 1300 ns, 0 1360 ns
run 5000 ns

# A seguir segue uma lista de sinais de entrada e saída do DUT para escrever os 
# resultados da simulação em um arquivo de saída que daremos o nome de $design.simulated.lst
# Listaremos no arquivo $design.simulated.lst todos os sinais abaixo na base (radix) hexadecimal 
# INCLUA E/OU ALTERE O VALOR DAS VARIÁVEIS DA LISTA DE ESTÍMULOS A SER APLICADA AO DUT DURANTE A SIMULAÇÃO 
add list -hexadecimal $saida
add list -hexadecimal $Chave_reset
add list -hexadecimal $Clock
add list -hexadecimal $Teclado
add list -hexadecimal $Enter
add list -hexadecimal $Instrucao
add list -hexadecimal $ENOUT
add list -hexadecimal $estado
add list -hexadecimal $ula
add list -hexadecimal $A
add list -hexadecimal $B
add list -hexadecimal $Write_Br
add list -hexadecimal $Opcode
add list -hexadecimal $Shifter


# O arquivo abaixo contém os resultados simulados na forma textual
# O arquivo será gerado na pasta work
write list $design.simulated.lst

# Na mesma pasta work o Modelsim salvará um arquivo de nome vsim.wlf
# Este arquivo contém a forma de onda completa da sua simulação.
# Este arquivo pode ser aberto posteriormente dentro do Modelsim para exibir a forma de onda da simulação.
# Para você abrir este arquivo vsim.wlf você deverá copiar a seguinte linha de comando na tela de Transcript do Modelsim e pressionar a tecla de enter
# vsim -view vsim.wlf
# Para que o comando acima seja executado há necessidade de terminar todas as simulações abertas com o comando quit -sim na janela Transcript

# Termina a simulação
# Descomente a linha abaixo se desejar que o script finalize a simulação sem que você observe o resultado na janela Wave
#quit -sim