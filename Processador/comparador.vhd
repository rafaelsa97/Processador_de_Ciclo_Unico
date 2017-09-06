-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Versão: v1-2016 
-- Disciplina: ELT005 - Sistemas, Processadores e Periféricos

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparador is
	generic 
	(
		-- tamanho das entradas e da saída de dados da ULA em bits
		FLAG_WIDTH : natural := 4			-- tamanho da entrada de controle da ULA em bits
	);
	port(
		instrucao: in std_logic_vector(31 downto 0);
		OU 		: in std_logic;											-- entrada sinal de overflow ou underflow
		Zero		: in std_logic;											-- entrada sinal de resultado zero
		Negativo : in std_logic;										-- entrada sinal de resultado negativo
		
		Y 			: out std_logic	 									-- Saída do comparador
	);
end comparador;

architecture beh of comparador is 
-- A linha abaixo n�o produz erro de compila��o no Quartus II, mas no Modelsim produz. Have an idea?	
--signal saida: std_logic_vector(DATA_WIDTH-1 downto 0);
signal saida : std_logic;
signal Flag: std_logic_vector(3 downto 0);

begin
	Flag <= instrucao(15 downto 12);
	process (Flag,Zero,Negativo,OU)
    begin
		saida <= '0';
		-- Testa se os numeros sao iguais usando uma subtração:		
		case Flag is
			when "0001" => -- = 0
				if (Zero = '1') then
			   	saida <= '1';
				end if;
			when "0010" => -- < 0
				if (Negativo = '1') then
			   	saida <= '1';
				end if;
			when "0100" => -- Overflow ou Underflow
				if (OU = '1') then
			   	saida <= '1';
				end if;
			when "1000" => -- > 0
				if (Negativo = '0' and Zero = '0') then
			   	saida <= '1';
				end if;
			when "1001" => -- >= 0
				if (Negativo = '0') then
			   	saida <= '1';
				end if;
			when "0011" => -- <= 0
				if (Negativo = '1' or Zero = '1') then
			   	saida <= '1';
				end if;
				
			when "0101" => -- = 0 (com Overflow e Underflow)
				if (Zero = '1' or OU = '1') then
			   	saida <= '1';
				end if;
			when "0110" => -- < 0 (com Overflow e Underflow)
				if (Negativo = '1' or OU = '1') then
			   	saida <= '1';
				end if;
			when "1100" => -- > 0 (com Overflow e Underflow)
				if ((Negativo = '0' and Zero = '0') or OU = '1') then
			   	saida <= '1';
				end if;
			when "1101" => -- >= 0 (com Overflow e Underflow)
				if (Negativo = '0' or OU = '1') then
			   	saida <= '1';
				end if;
			when "0111" => -- <= 0 (com Overflow e Underflow)
				if (Negativo = '1' or Zero = '1' or OU = '1') then
			   	saida <= '1';
				end if;
			when "1111" => -- Pulo incondicional
				 saida <= '1';
			when others => saida <=  '0';
		end case;
	end process;
	-- Atribui o sinal da operacao realizada a saida:
	Y <= saida;
end beh; 
