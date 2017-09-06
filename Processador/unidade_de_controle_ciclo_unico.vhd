-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Versão: v1-2016 
-- Disciplina: ELT005 - Sistemas, Processadores e Periféricos

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- unidade de controle
entity unidade_de_controle_ciclo_unico is
	generic 
	(
		INSTR_WIDTH 			: natural := 32;      -- Tamanho da instrucao
		OPCODE_WIDTH			: natural := 4;		 -- Tamanho do OPCODE
		ULA_CTRL_WIDTH 		: natural := 4			 -- Tamanho do barramento de controle das operacoes da ULA
	);
	port
	(
		instrucao		: in std_logic_vector(31 downto 0);			-- instrução
	   in_out         : out std_logic;    -- saida que indica se ira salvar um valor que sai da ULA, que sai do shifter ou que e' recebido pela entrada de dados do usuario
		sel_ula        : out std_logic_vector (3 downto 0);		-- Bits de controle da ULA
		at_mux         : out std_logic;    -- controla mux 2x1 que deixa passar word do signal extend ou da saida do banco de regist.
		br_write       : out std_logic;    -- habilita a escrita no banco de registradores
		select_rdata   : out std_logic    -- controla mux 2x1 que deixa passar word do shifter ou a da saída da ULA
	);
end unidade_de_controle_ciclo_unico;

architecture beh of unidade_de_controle_ciclo_unico is
-- As linhas abaixo n�o produzem erro de compila��o no Quartus II, mas no Modelsim produz. Have an idea?	
--signal inst_aux : std_logic_vector (INSTR_WIDTH-1 downto 0);				-- instrucao
--signal opcode   : std_logic_vector (OPCODE_WIDTH-1 downto 0);			-- opcode
--signal ctrl_aux : std_logic_vector (DP_CTRL_BUS_WIDTH-1 downto 0);		-- controle

signal opcode   : std_logic_vector (3 downto 0);			-- opcode

begin
  opcode 		<= instrucao(31 downto 28);	-- Passa para o signal o valor da opcode da instrucao
  
	process (opcode)
   begin
		in_out 			<= '0';
		sel_ula 			<= (others => '0');
		at_mux 			<= '0';
		br_write 		<= '0';
		select_rdata 	<= '0';
		case opcode is
			-- ADD	
			when "0000" =>	
				in_out       <= '0';
				sel_ula      <= "0000";
				at_mux       <= '0';
				br_write     <= '1';
				select_rdata <= '1';
			-- SUB
			when "0001" => 
				in_out       <= '0';
				sel_ula      <= "0001";
				at_mux       <= '0';
				br_write     <= '1';
				select_rdata <= '1';
			-- ADDI	
			when "0010" =>
			   in_out       <= '0';
				sel_ula      <= "0010";
				at_mux       <= '1';
				br_write     <= '1';
				select_rdata <= '1';				
			-- NOR
			when "0100" =>
				in_out       <= '0';
				sel_ula      <= "0100";
				at_mux       <= '0';
				br_write     <= '1';
				select_rdata <= '1';
			-- XOR
			when "0110" =>
				in_out       <= '0';
				sel_ula      <= "0110";
				at_mux       <= '0';
				br_write     <= '1';
				select_rdata <= '1';
			-- AND
			when "0111" =>
				in_out       <= '0';
				sel_ula      <= "0111";
				at_mux       <= '0';
				br_write     <= '1';
				select_rdata <= '1';
			-- SHI
			when "1000" =>
				in_out       <= '0';
				sel_ula      <= "1000";
				at_mux       <= '0';  -- Don't care
				br_write     <= '1';
				select_rdata <= '0';
			-- INP
			when "1100" =>
				in_out       <= '1';
				sel_ula      <= "1100";
				at_mux       <= '0'; --Don't care
				br_write     <= '1';
				select_rdata <= '1'; --Don't care
			-- OUT
			when "1101" =>
				in_out       <= '0'; --Don't care
				sel_ula      <= "1101";
				at_mux       <= '0'; --Don't care
				br_write     <= '0';
				select_rdata <= '1'; --Don't care
			-- NOP
			when "1111" =>
				in_out       <= '0'; --Don't care
				sel_ula      <= "1111";
				at_mux       <= '0'; --Don't care
				br_write     <= '0';
				select_rdata <= '1'; --Don't care
			-- Para outras entradas indefinidas, o controle executará um NOP
			when others =>		
				in_out       <= '0'; --Don't care
				sel_ula      <= "1111";
				at_mux       <= '0'; --Don't care
				br_write     <= '0';
				select_rdata <= '1'; --Don't care
		end case;
	END process;
	--controle <= ctrl_aux;
end beh;
