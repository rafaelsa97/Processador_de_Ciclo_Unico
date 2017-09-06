library ieee;
use ieee.std_logic_1164.all;

entity fsm is
	port
	(
		reset			: in std_logic;
		enter			: in std_logic;
		clock			: in std_logic;
		instrucao	: in std_logic_vector(31 downto 0);
		
		En_out_reg  : out std_logic;
		En_inp_reg  : out std_logic;
		reg_wrt		: out std_logic;
		estado 		: out std_logic_vector(2 downto 0);
		mantem_pc   : out std_logic;
		
	   in_out         : out std_logic;    -- saida que indica se ira salvar um valor que sai da ULA, que sai do shifter ou que e' recebido pela entrada de dados do usuario
		sel_ula        : out std_logic_vector (3 downto 0);		-- Bits de controle da ULA
		at_mux         : out std_logic;    -- controla mux 2x1 que deixa passar word do signal extend ou da saida do banco de regist.
		br_write       : out std_logic;    -- habilita a escrita no banco de registradores
		select_rdata   : out std_logic;    -- controla mux 2x1 que deixa passar word do shifter ou a da saída da ULA
		
		opcode_out		: out std_logic_vector(3 downto 0)
	);
end fsm;

architecture hardware of fsm is
type est is (s0,s1,s2,s3,s4,s5,s6);
signal est_atual, est_futuro : est;
signal S : std_logic_vector(2 downto 0);
signal opcode : std_logic_vector(3 downto 0);
--signal S : std_logic_vector(2 downto 0);
begin
	opcode <= instrucao(31 downto 28);
	
	-- Sequencial
	process(reset, clock)
	begin
		if(reset = '1') then
			est_atual <= s0;
		elsif(rising_edge(clock)) then
			est_atual <= est_futuro;
		end if;
	end process;
	
	-- Combinacional
	process(enter,opcode, est_atual)
	begin
		mantem_pc			<= '0';
		en_out_reg			<= '0';
		en_inp_reg			<= '0';
		est_futuro			<= s0;
		estado				<= "000";
		case est_atual is
			
	   when s0 =>			
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
				--sel_ula      <= "1000";
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
		
		
				estado	  <= "000";
				if(opcode = "1100") then
					mantem_pc  <= '1';
					en_out_reg <= '0';
					en_inp_reg <= '0';
					--br_write	  <= '0';
					est_futuro <= s1;
				elsif(opcode = "1101") then
					mantem_pc  <= '1';
					en_out_reg <= '0';
					en_inp_reg <= '0';
					--br_write   <= '0';
					est_futuro <= s4;
				else
					est_futuro <= s0;
				end if;
			when s1 =>
				estado				<= "001";
				if(enter = '1') then
					mantem_pc  <= '1';
					en_out_reg <= '0';
					en_inp_reg <= '1';
					br_write	  <= '0';
					est_futuro <= s2;
				elsif(enter = '0') then
					mantem_pc  <= '1';
					en_out_reg <= '0';
					en_inp_reg <= '0';
					br_write	  <= '0';
					est_futuro <= s1;
				end if;
			when s2 =>
				estado				<= "010";
				if(enter = '0') then
					mantem_pc  <= '0';
					en_out_reg <= '0';
					en_inp_reg <= '0';
					br_write	  <= '1';
					est_futuro <= s3;
				elsif(enter = '1') then
					mantem_pc  <= '1';
					en_out_reg <= '0';
					en_inp_reg <= '1';
					br_write	  <= '0';
					est_futuro <= s2;
				end if;
			when s3 =>
				estado				<= "011";
			-- Se não carregar o banco de registradores, colocar mais um estado intermediário com reg_wrt <= 1
				mantem_pc  <= '1';
				en_out_reg <= '0';
				en_inp_reg <= '0';
				br_write    <= '1';
				est_futuro <= s0;
			when s4 =>
				estado				<= "100";
				if(enter = '1') then
					mantem_pc  <= '1';
					en_out_reg <= '1';
					en_inp_reg <= '0';
					br_write	  <= '0';
					est_futuro <= s5;
				elsif(enter = '0') then
					mantem_pc  <= '1';
					en_out_reg <= '0';
					en_inp_reg <= '0';
					br_write    <= '0';
					est_futuro <= s4;
				end if;
			when s5 =>
				estado				<= "101";
				if(enter = '0') then
					mantem_pc  <= '0';
					en_out_reg <= '0';
					en_inp_reg <= '0';
					br_write	  <= '0';
					est_futuro <= s6;
				elsif(enter = '1') then
					mantem_pc  <= '1';
					en_out_reg <= '1';
					en_inp_reg <= '0';
					br_write	  <= '0';
					est_futuro <= s5;
				end if;
			when s6 =>
			estado				<= "110";
			-- Se não carregar o banco de registradores, colocar mais um estado intermediário com reg_wrt <= 1
				mantem_pc  <= '0';
				en_out_reg <= '0';
				en_inp_reg <= '0';
				br_write    <= '1';
				est_futuro <= s0;
		end case;
	end process;
	opcode_out <= opcode;
end hardware;