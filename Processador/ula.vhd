-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Versão: v1-2016 
-- Disciplina: ELT005 - Sistemas, Processadores e Periféricos

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ula is
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
end ula;

architecture beh of ula is 
-- A linha abaixo n�o produz erro de compila��o no Quartus II, mas no Modelsim produz. Have an idea?	
--signal saida: std_logic_vector(DATA_WIDTH-1 downto 0);
signal saida  : std_logic_vector(15 downto 0);
signal res_ou : std_logic_vector(16 downto 0);  -- Registrador de 17 bits (para operaçao de overflow/underflow)
begin
	process (A, B, F,res_ou)
    begin
		-- Testa se os numeros sao iguais usando uma subtração:
		if((signed (A) - signed (B)) = 0) then
			Zero <= '1';
		else
			Zero <= '0';
		end if;
		
		-- Testa se A e' maior que B usando uma subtração:
		if((signed (A) - signed (B)) < 0) then
			Negativo <= '1';
		else
			Negativo <= '0';
		end if;
		
		-- Testa se teve overflow ou underflow:
		res_ou <= std_logic_vector (signed ('0' & A) + signed ('0' & B));
		if (res_ou(16) = '1') then 
			OUFlow <= '1';
		else 
			OUFlow <= '0';
		end if;
		
		case F is
			when "0000" => -- ADD
			   	saida <= std_logic_vector (signed (A) + signed (B));
			when "0010" => -- ADDI
			   	saida <= std_logic_vector (signed (A) + signed (B));
			when "0001" => -- SUB
			   	saida <= std_logic_vector (signed (A) - signed (B));
			when "0100" => -- NOR
					saida <= A NOR B;
			when "0110" => -- XOR
					saida <= A XOR B;
			when "0111" => -- AND
					saida <= A AND B;
			when others => saida <= (others => '0');
		end case;
	end process;
	-- Atribui o sinal da operacao realizada a saida:
	Y <= saida;
end beh; 
