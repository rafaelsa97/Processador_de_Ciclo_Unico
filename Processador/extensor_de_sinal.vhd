-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletr�nica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Vers�o: v1-2016 
-- Disciplina: ELT005 - Sistemas, Processadores e Perif�ricos

library ieee;
use ieee.std_logic_1164.all;

entity extensor_de_sinal is
	generic
	(
		EXT_DATA_WIDTH	: natural := 16;	-- tamanho do dado estendido (sa�da) em quantidade de bits
		IMMEDIATE		: natural := 4		-- tamanho do dado a ser estendido (entrada) em quantidade de bits
	);
	port(
		instrucao	: in std_logic_vector(31 downto 0);
		saida			: out std_logic_vector(EXT_DATA_WIDTH-1 downto 0)
	);
end entity;

architecture rtl of extensor_de_sinal is
signal entrada    : std_logic_vector(3 downto 0);
begin	
	entrada <= instrucao(11 downto 8);
	process (entrada) is
	begin
		-- Replica o bit mais significativo do campo immediate para ps outros bits da palavra de 16 bits
		if (entrada(IMMEDIATE-1) = '1') then
			saida(EXT_DATA_WIDTH-1 downto IMMEDIATE) <= (others => '1');
		else
			saida(EXT_DATA_WIDTH-1 downto IMMEDIATE) <= (others => '0');
		end if;
		saida(IMMEDIATE-1 downto 0) <= entrada;
	end process;
end rtl;
