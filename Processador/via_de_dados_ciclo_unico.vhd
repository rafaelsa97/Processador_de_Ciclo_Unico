-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Versão: v1-2016 
-- Disciplina: ELT005 - Sistemas, Processadores e Periféricos

library IEEE;
use IEEE.std_logic_1164.all;

entity via_de_dados_ciclo_unico is
	generic
	(
		-- declare todos os tamanhos dos barramentos (sinais) das portas da sua via_dados_ciclo_unico aqui.
		DP_CTRL_BUS_WIDTH 	: natural := 9; 	-- tamanho do barramento de controle da via de dados (DP) em bits
		DATA_WIDTH			: natural := 16;	-- tamanho do dado em bits
		PC_WIDTH			: natural := 8;		-- tamanho da entrada de endereços da MI ou MP em bits (memi.vhd)
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
		br_write_fsm	: in std_logic;
		teclado			: in std_logic_vector (15 downto 0);
		shifter			: out std_logic_vector (15 downto 0);
		
		saida_A			: out std_logic_vector (15 downto 0);
		saida_B			: out std_logic_vector (15 downto 0);
		pc_out			: out std_logic_vector (PC_WIDTH-1 downto 0);
		saida_dados		: out std_logic_vector (DATA_WIDTH-1 downto 0); --Saida de dados do registrador da FSM
		saida_ula		: out std_logic_vector (15 downto 0)
	);
end via_de_dados_ciclo_unico;

architecture comportamento of via_de_dados_ciclo_unico is
-- declare todos os componentes que serão necessários na sua via_de_dados_ciclo_unico a partir deste comentário
component pc is
	generic
	(
		PC_WIDTH : natural := 8		-- tamanho de PC em bits
	);
	port(
		entrada	: in std_logic_vector (PC_WIDTH-1 downto 0);
		saida		: out std_logic_vector(PC_WIDTH-1 downto 0);
		clk		: in std_logic;
		reset		: in std_logic
	);
end component;

component somador_de_8bits is	
	generic
	(
		PC_WIDTH : natural := 8		-- tamanho do somador em número de bits
	);
	port(
		entrada1	: in std_logic_vector (PC_WIDTH-1 downto 0);
		saida 	: out std_logic_vector (PC_WIDTH-1 downto 0)
	);
end component;

component banco_de_registradores is
	generic 
	(
		DATA_WIDTH 			: natural := 16;	-- tamanho de cada registrador do banco de registradores em bits
		QTY_REGISTERS		: natural := 16;	-- quantidade de registradores dentro do banco de registradores
		FR_ADDR_WIDTH		: natural := 4		-- tamanho da linha de endereços do banco de registradores em bits
	);
	port(
		clk 			: in std_logic;												-- Relógio
		write_regrd	: in std_logic_vector(FR_ADDR_WIDTH-1 downto 0); 	-- Índice no registrador rd
		data_in		: in std_logic_vector(DATA_WIDTH-1 downto 0);		-- entrada de dados para escrita
		reg_write	: in std_logic;												-- sinal de controle de escrita
		instrucao   : in std_logic_vector(31 downto 0);
		data_outrop1	: out std_logic_vector(DATA_WIDTH-1 downto 0);		-- saída de dados do registrador rs
		data_outrop2	: out std_logic_vector(DATA_WIDTH-1 downto 0)		-- saída de dados do registrador rt
	);
end component;

component ula is
	generic 
	(
		DATA_WIDTH : natural := 16;			-- tamanho das entradas e da saída de dados da ULA em bits
		ADDR_WIDTH : natural := 4			-- tamanho da entrada de controle da ULA em bits
	);
	port(
		A, B 	: in std_logic_vector (15 downto 0);		-- Barramentos A e B
-- A linha abaixo n�o produz erro de compila��o no Quartus II, mas no Modelsim produz. Have an idea?			
--F 		: in std_logic_vector (ADDR_WIDTH-1 downto 0);		-- Controle da ULA
		F 		: in std_logic_vector (3 downto 0);		-- Controle da ULA
		Y 		: out std_logic_vector (15 downto 0);		-- Saída da ULA
		Zero	: out std_logic;									-- flag resultado zero
		Negativo: out std_logic;										-- flag resultado negativo
		OUFlow: out std_logic
	);
end component;

component mux21_16bits  is
	generic
	(
		MUX21_16BITS_DATA_WIDTH	: natural := 16		-- tamanho em bits das entradas e da sa�da de dados
	);
	port(
		controle	: in std_logic;
		entrada0	: in std_logic_vector(MUX21_16BITS_DATA_WIDTH-1 downto 0);
		entrada1	: in std_logic_vector(MUX21_16BITS_DATA_WIDTH-1 downto 0);
		saida		: out std_logic_vector(MUX21_16BITS_DATA_WIDTH-1 downto 0)
	);
end component;

component mux21_8bits  is
	generic
	(
		MUX21_DATA_WIDTH	: natural := 8		-- tamanho em bits das entradas e da sa�da de dados
	);
	port(
		controle	: in std_logic;
		entrada0	: in std_logic_vector(MUX21_DATA_WIDTH-1 downto 0);
		entrada1	: in std_logic_vector(MUX21_DATA_WIDTH-1 downto 0);
		saida		: out std_logic_vector(MUX21_DATA_WIDTH-1 downto 0)
	);
end component;

component extensor_de_sinal is
	generic
	(
		EXT_DATA_WIDTH	: natural := 16;	-- tamanho do dado estendido (sa�da) em quantidade de bits
		IMMEDIATE		: natural := 4		-- tamanho do dado a ser estendido (entrada) em quantidade de bits
	);
	port(
		instrucao	: in std_logic_vector(31 downto 0);
		saida			: out std_logic_vector(EXT_DATA_WIDTH-1 downto 0)
	);
end component;

component deslocador is
    generic
    (
      DATA_SIZE	: natural := 16; 	   -- tamanho do dado a ser deslocado em bits
		SHTY_SIZE	: natural := 4;		-- tamanho do campo shty em bits
		SHMT_SIZE	: natural := 4 		-- tamanho do campo shmt em bits
    );
    port(
        Entrada_Dados		:in std_logic_vector(DATA_SIZE-1 downto 0);
		  instrucao          :in std_logic_vector(31 downto 0);
        Saida	 				:out std_logic_vector(DATA_SIZE-1 downto 0)
    );
end component;

component comparador is
	generic 
	(
		-- tamanho das entradas e da saída de dados da ULA em bits
		FLAG_WIDTH : natural := 4			-- tamanho da entrada de controle da ULA em bits
	);
	port(
		instrucao: in std_logic_vector (31 downto 0);		-- Flag
		OU 		: in std_logic;											-- entrada sinal de overflow ou underflow
		Zero		: in std_logic;											-- entrada sinal de resultado zero
		Negativo : in std_logic;										-- entrada sinal de resultado negativo
		
		Y 			: out std_logic	 									-- Saída do comparador
	);
end component;

component registrador_de_16bits is
	generic
	(
		DATA_WIDTH : natural := 16
	);
	port(
		entrada	: in std_logic_vector(DATA_WIDTH-1 downto 0);
		saida	   : out std_logic_vector(DATA_WIDTH-1 downto 0);
		clk		: in std_logic;
		we		   : in std_logic;
		reset	   : in std_logic
	);
end component;

-- Declare todos os sinais auxiliares que serão necessários na sua via_de_dados_ciclo_unico a partir deste comentário.
-- Você só deve declarar sinais auxiliares se estes forem usados como "fios" para interligar componentes.
-- Os sinais auxiliares devem ser compatíveis com o mesmo tipo (std_logic, std_logic_vector, etc.) e o mesmo tamanho dos sinais dos portos dos
-- componentes onde serão usados.
-- Veja os exemplos abaixo:
signal aux_write_rd 		: std_logic_vector(FR_ADDR_WIDTH-1 downto 0);
signal aux_data_in 		: std_logic_vector(DATA_WIDTH-1 downto 0);
signal aux_data_ula 		: std_logic_vector(DATA_WIDTH-1 downto 0);
signal aux_data_outrs 	: std_logic_vector(DATA_WIDTH-1 downto 0);
signal aux_data_outrt 	: std_logic_vector(DATA_WIDTH-1 downto 0);
signal aux_data_B 	: std_logic_vector(DATA_WIDTH-1 downto 0);
signal aux_endereco		: std_logic_vector(7 downto 0);
signal aux_reg_write 	: std_logic;
signal aux_reg_write_fsm : std_logic;

signal zero_aux			: std_logic;
signal negativo_aux		: std_logic;
signal UO_aux				: std_logic;

signal flag_aux         : std_logic_vector(3 downto 0);
signal bit_mux_somador  : std_logic;
signal mux_shift_aux    : std_logic_vector(15 downto 0);
signal aux_mux_somador	: std_logic_vector(7 downto 0);
signal aux_mux_pc			: std_logic_vector(7 downto 0);
signal aux_mux_fsm		: std_logic_vector(15 downto 0);

signal aux_imed         : std_logic_vector(3 downto 0);
signal aux_imed_ext     : std_logic_vector(15 downto 0);

signal aux_ula_ctrl 		: std_logic_vector(ULA_CTRL_WIDTH-1 downto 0);

signal aux_pc_out			: std_logic_vector(PC_WIDTH-1 downto 0);
signal aux_novo_pc		: std_logic_vector(PC_WIDTH-1 downto 0);
signal aux_we				: std_logic;

signal aux_inp				: std_logic_vector(15 downto 0);

signal aux_somador		: std_logic_vector(PC_WIDTH-1 downto 0);


begin
-- A partir deste comentário faça associações necessárias das entradas declaradas na entidade da sua via_dados_ciclo_unico com 
-- os sinais que você acabou de definir.
-- Veja os exemplos abaixo: 
aux_write_rd	<= instrucao(27 downto 24); 
aux_endereco 	<= instrucao(7 downto 0);
aux_reg_write 	<= br_write;			  		-- WE RW UL UL UL UL
aux_ula_ctrl 	<= instrucao(31 downto 28); 	-- WE RW UL UL UL UL
pc_out			<= aux_pc_out;

-- A partir deste comentário instancie todos o componentes que serão usados na sua via_de_dados_ciclo_unico.
-- A instanciação do componente deve começar com um nome que você deve atribuir para a referida instancia seguido de : e seguido do nome
-- que você atribuiu ao componente.
-- Depois segue o port map do referido componente instanciado.
-- Para fazer o port map, na parte da esquerda da atribuição "=>" deverá vir o nome de origem da porta do componente e na parte direita da 
-- atribuição deve aparecer um dos sinais ("fios") que você definiu anteriormente, ou uma das entradas da entidade via_de_dados_ciclo_unico,
-- ou ainda uma das saídas da entidade via_de_dados_ciclo_unico.
-- Veja os exemplos de instanciação a seguir:

	instancia_ula1 : ula
	port map(
		A 			=> aux_data_outrs,
		B 			=> aux_data_B,
		F 			=> aux_ula_ctrl,
		Y 			=> aux_data_ula,
		Zero 		=> zero_aux,
		Negativo	=> negativo_aux,
		OUFlow   => UO_aux
	);

	instancia_banco_de_registradores : banco_de_registradores
	port map(
		clk 			 => clock,
		write_regrd	 => aux_write_rd,
		data_in		 => aux_data_in,
		reg_write	 => aux_reg_write,
		instrucao    => instrucao,
		data_outrop1 => aux_data_outrs,
		data_outrop2 => aux_data_outrt
	);
	
	instancia_pc : pc
	port map(
		entrada	=> aux_novo_pc,
		saida		=> aux_pc_out,
		clk		=> clock,
		reset		=> reset
	);
	
	instancia_comparador : comparador
	port map(
		instrucao => instrucao,
		OU 		 => UO_aux,
		Zero		 => zero_aux,
		Negativo  => negativo_aux,
		Y         => bit_mux_somador
	);
	
	instancia_deslocador : deslocador
	port map(
		Entrada_Dados => aux_data_outrs,
		instrucao     => instrucao,
		Saida         => mux_shift_aux
	);
	
	instancia_extensor: extensor_de_sinal
	port map(
		instrucao   => instrucao,
		saida 	   => aux_imed_ext
	);
	
	instancia_somador: somador_de_8bits
	port map(
		entrada1 =>	aux_pc_out,
		saida		=> aux_somador
	
	);
	
	instancia_muxsomador: mux21_8bits
	port map(
		controle	=> bit_mux_somador,
		entrada0	=> aux_somador,
		entrada1	=>	aux_endereco,
		saida		=> aux_mux_somador
	);
	
	instancia_muxpc: mux21_8bits
	port map(
		controle	=> mantem_pc,
		entrada0	=> aux_mux_somador,
		entrada1	=>	aux_pc_out,
		saida		=> aux_novo_pc
	);
	
	instancia_muxdeslocador: mux21_16bits
	port map(
		controle	=> select_rdata,
		entrada0	=> mux_shift_aux,
		entrada1	=>	aux_data_ula,
		saida		=> aux_mux_fsm
	);
	
	instancia_muxula: mux21_16bits
	port map(
		controle	=> at_mux,
		entrada0	=> aux_data_outrt,
		entrada1	=>	aux_imed_ext,
		saida		=> aux_data_B
	);
	
	instancia_muxfsm: mux21_16bits
	port map(
		controle	=> in_out,
		entrada0	=> aux_mux_fsm,
		entrada1	=>	aux_inp,
		saida		=> aux_data_in
	);
	
	instancia_reg_in: registrador_de_16bits
	port map(
		entrada	=> teclado,
		saida	   =>	aux_inp,
		clk		=> clock,
		we		   =>	en_inp_reg,
		reset	   => reset
	);
	
	instancia_reg_out: registrador_de_16bits
	port map(
		entrada	=> aux_data_outrs,
		saida	   =>	saida_dados,
		clk		=> clock,
		we		   =>	en_out_reg,
		reset	   => reset
	);
	shifter 	 <= mux_shift_aux;
	saida_ula <= aux_data_ula;
	saida_A 	 <= aux_data_outrs;
	saida_B 	 <= aux_data_outrt;
end comportamento;
