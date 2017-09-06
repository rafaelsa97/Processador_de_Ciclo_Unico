-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletr�nica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Vers�o: v1-2016 
-- Disciplina: ELT005 - Sistemas, Processadores e Perif�ricos

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memi is
	generic 
	(
		INSTR_WIDTH : natural := 32;	-- tamanho da instru��o em n�mero de bits
		MI_ADDR_WIDTH : natural := 8	-- tamanho do endere�o da mem�ria de instru��es em n�mero de bits
	);
	port(
		Endereco	   : in std_logic_vector(MI_ADDR_WIDTH-1 downto 0);
		Instrucao	: out std_logic_vector(31 downto 0)
	);
end entity;

architecture rtl of memi is
type rom_type is array (0 to 2**MI_ADDR_WIDTH-1) of std_logic_vector(INSTR_WIDTH-1 downto 0);
constant rom: rom_type :=(
						0	=> X"22000100", -- addi 1 reg 2
						1  => X"23000100", -- addi 1 reg 3
						2  => X"C1000000", -- INP reg 1
					   3  => X"81122000", -- reg 1 = reg 1 << 2
					   4  => X"02220000", -- reg 2 = reg 2 + reg 2
					   5  => X"12210000", -- reg 2 = reg 2 - reg 1
					   6  => X"63210000", -- reg 3 = reg 2 ^ reg 1
					   7  => X"1421800A", -- if(b<a)
						8  => X"22220100", -- addi 1 reg 2
					   9  => X"4132F00B", -- reg 1 = ~(reg 2 < reg 3)
					   10 => X"71230000", -- reg 1 = reg 2 & reg 3
						11 => X"D0100000", -- out reg 1
						12 => X"F0000000", -- NOP
						others => X"F0000000" 
					);
begin
	Instrucao <= rom(to_integer(unsigned(Endereco)));
end rtl;
