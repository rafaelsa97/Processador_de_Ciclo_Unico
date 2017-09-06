-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Versão: v1-2016 
-- Disciplina: ELT005 - Sistemas, Processadores e Periféricos

library IEEE;
use IEEE.std_logic_1164.all;

entity processador_ciclo_unico is
	generic
	(
		DATA_WIDTH				: natural := 16;  	-- tamanho do barramento de dados em bits
		PROC_INSTR_WIDTH		: natural := 16;	-- tamanho da instrução do processador em bits
		PROC_ADDR_WIDTH		: natural := 8;		-- tamanho do endereço da memória de programa do processador em bits
		DP_CTRL_BUS_WIDTH		: natural := 6		-- tamanho do barramento de controle em bits
	);
	port(

		Leds_vermelhos_saida	: out std_logic_vector(15 downto 0);
		Chave_reset				: in std_logic;
		Chaves_entrada			: in std_logic_vector(15 downto 0);
		Chave_enter				: in std_logic;
		Clock 					: in std_logic
	);
end processador_ciclo_unico;

architecture comportamento of processador_ciclo_unico is
-- declare todos os componentes que serão necessários no seu processador_ciclo_unico a partir deste comentário
component via_de_dados_ciclo_unico is
	generic
	(
		-- declare todos os tamanhos dos barramentos (sinais) das portas da sua via_dados_ciclo_unico aqui.
		DP_CTRL_BUS_WIDTH : natural := 9; 	-- tamanho do barramento de controle da via de dados (DP) em bits
		DATA_WIDTH			: natural := 16;	-- tamanho do dado em bits
		PC_WIDTH				: natural := 8;		-- tamanho da entrada de endereços da MI ou MP em bits (memi.vhd)
		FR_ADDR_WIDTH		: natural := 4;		-- tamanho da linha de endereços do banco de registradores em bits
		ULA_CTRL_WIDTH		: natural := 4;		-- tamanho da linha de controle da ULA
		INSTR_WIDTH			: natural := 16		-- tamanho da instrução em bits
	);
	port(
		clock				: in std_logic;
		reset				: in std_logic;
		in_out         : in std_logic;    -- saida que indica se ira salvar um valor que sai da ULA, que sai do shifter ou que e' recebido pela entrada de dados do usuario
		sel_ula        : in std_logic_vector (3 downto 0);		-- Bits de controle da ULA
		at_mux         : in std_logic;    -- controla mux 2x1 que deixa passar word do signal extend ou da saida do banco de regist.
		br_write       : in std_logic;    -- habilita a escrita no banco de registradores
		select_rdata   : in std_logic;    -- controla mux 2x1 que deixa passar word do shifter ou a da saída da ULA
		instrucao		: in std_logic_vector (31 downto 0);
		En_out_reg  	: in std_logic;
		En_inp_reg  	: in std_logic;
		mantem_pc   	: in std_logic;
		teclado			: in std_logic_vector (15 downto 0);
		shifter 			: out std_logic_vector (15 downto 0);
		
		saida_A			: out std_logic_vector (15 downto 0);
		saida_B			: out std_logic_vector (15 downto 0);
		saida_ula		: out std_logic_vector (15 downto 0);
		pc_out			: out std_logic_vector (PC_WIDTH-1 downto 0);
		saida_dados		: out std_logic_vector (DATA_WIDTH-1 downto 0) --Saida de dados do registrador da FSM
	);
end component;


component memi is
	generic 
	(
		INSTR_WIDTH : natural := 32;	-- tamanho da instru��o em n�mero de bits
		MI_ADDR_WIDTH : natural := 8	-- tamanho do endere�o da mem�ria de instru��es em n�mero de bits
	);
	port(
		Endereco	   : in std_logic_vector(7 downto 0);
		Instrucao	: out std_logic_vector(31 downto 0)
	);
end component;

component fsm is
	port
	(
		reset			: in std_logic;
		enter			: in std_logic;
		clock			: in std_logic;
		instrucao	: in std_logic_vector(31 downto 0);
		
		En_out_reg  : out std_logic;
		estado 		: out std_logic_vector(2 downto 0);
		En_inp_reg  : out std_logic;
		mantem_pc   : out std_logic;
		
		opcode_out		: out std_logic_vector(3 downto 0);

	   in_out         : out std_logic;    -- saida que indica se ira salvar um valor que sai da ULA, que sai do shifter ou que e' recebido pela entrada de dados do usuario
		sel_ula        : out std_logic_vector (3 downto 0);		-- Bits de controle da ULA
		at_mux         : out std_logic;    -- controla mux 2x1 que deixa passar word do signal extend ou da saida do banco de regist.
		br_write       : out std_logic;    -- habilita a escrita no banco de registradores
		select_rdata   : out std_logic    -- controla mux 2x1 que deixa passar word do shifter ou a da saída da ULA
	);
end component;

-- Declare todos os sinais auxiliares que serão necessários no seu processador_ciclo_unico a partir deste comentário.
-- Você só deve declarar sinais auxiliares se estes forem usados como "fios" para interligar componentes.
-- Os sinais auxiliares devem ser compatíveis com o mesmo tipo (std_logic, std_logic_vector, etc.) e o mesmo tamanho dos sinais dos portos dos
-- componentes onde serão usados.
-- Veja os exemplos abaixo:

-- A partir deste comentário faça associações necessárias das entradas declaradas na entidade do seu processador_ciclo_unico com 
-- os sinais que você acabou de definir.
-- Veja os exemplos abaixo:
signal aux_instrucao 	: std_logic_vector(31 downto 0);
signal aux_endereco		: std_logic_vector(PROC_ADDR_WIDTH-1 downto 0);
signal aux_endereco_pc	: std_logic_vector(7 downto 0);
signal aux_select_rdata	: std_logic;
signal aux_in_out			: std_logic;
signal aux_br_write		: std_logic;
signal aux_at_mux			: std_logic;
signal aux_sel_ula      : std_logic_vector (3 downto 0);
signal aux_En_out_reg	: std_logic;
signal aux_En_inp_reg  	: std_logic;
signal aux_mantem_pc		: std_logic;
signal aux_saida			: std_logic_vector(15 downto 0);
signal aux_saida_ula		: std_logic_vector(15 downto 0);
signal aux_saida_A		: std_logic_vector(15 downto 0);
signal aux_saida_B		: std_logic_vector(15 downto 0);
signal aux_opcode			: std_logic_vector(3 downto 0);
signal aux_shifter		: std_logic_vector(15 downto 0);
begin 
-- A partir deste comentário instancie todos o componentes que serão usados no seu processador_ciclo_unico.
-- A instanciação do componente deve começar com um nome que você deve atribuir para a referida instancia seguido de : e seguido do nome
-- que você atribuiu ao componente.
-- Depois segue o port map do referido componente instanciado.
-- Para fazer o port map, na parte da esquerda da atribuição "=>" deverá vir o nome de origem da porta do componente e na parte direita da 
-- atribuição deve aparecer um dos sinais ("fios") que você definiu anteriormente, ou uma das entradas da entidade processador_ciclo_unico,
-- ou ainda uma das saídas da entidade processador_ciclo_unico.
-- Veja os exemplos de instanciação a seguir:
	
	
	instancia_memi : memi
	port map(
		Endereco		=> aux_endereco_pc,
		Instrucao	=> aux_instrucao
	);
	
	
	instancia_via_de_dados_ciclo_unico : via_de_dados_ciclo_unico
	port map(
		-- declare todas as portas da sua via_dados_ciclo_unico aqui.
		clock			=> Clock,
		reset			=> Chave_reset,
		instrucao	=> aux_instrucao,
		pc_out		=> aux_endereco_pc,
		in_out 		=> aux_in_out,
		select_rdata => aux_select_rdata,
		br_write		=> aux_br_write,
		at_mux		=> aux_at_mux,
		sel_ula		=> aux_sel_ula,		
		saida_dados	=> aux_saida,
		mantem_pc 	=> aux_mantem_pc,
		En_out_reg 	=> aux_En_out_reg,
		En_inp_reg	=> aux_En_inp_reg,
		teclado		=> Chaves_entrada,
		saida_A		=> aux_saida_A,
		saida_B		=> aux_saida_B,
		shifter		=> aux_shifter,
		saida_ula	=> aux_saida_ula
	);
	
	instancia_fsm : fsm
	port map(
		clock			=> Clock,
		reset			=> Chave_reset,
		En_out_reg 	=> aux_En_out_reg,
		En_inp_reg	=> aux_En_inp_reg,
		instrucao	=> aux_instrucao,
		enter			=> Chave_enter,
		
	   mantem_pc 	=> aux_mantem_pc,
		
		in_out		=> aux_in_out,
		select_rdata => aux_select_rdata,
		br_write		=> aux_br_write,
		at_mux		=> aux_at_mux,
		opcode_out	=> aux_opcode,	
		sel_ula		=> aux_sel_ula		
		);
		
		Leds_vermelhos_saida <=  aux_saida;
		
end comportamento;
