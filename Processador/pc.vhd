-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Versão: v1-2016 
-- Disciplina: ELT005 - Sistemas, Processadores e Periféricos

library ieee;
use ieee.std_logic_1164.all;

entity pc is
	generic
	(
		PC_WIDTH : natural := 8		-- tamanho de PC em bits
	);
	port(
		entrada	: in std_logic_vector (PC_WIDTH-1 downto 0);
		saida	: out std_logic_vector(PC_WIDTH-1 downto 0);
		clk		: in std_logic;
		reset	: in std_logic
	);
end entity;

architecture rtl of pc is
begin	
	process (clk, reset) is
	begin
		if (reset = '1') then
			saida <= (others => '0');
		elsif (rising_edge(clk)) then
				saida <= entrada;
		end if;
	end process;
end rtl;
