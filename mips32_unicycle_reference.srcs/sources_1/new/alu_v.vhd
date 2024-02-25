----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/25/2024 12:12:07 PM
-- Design Name: 
-- Module Name: alu_v - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPS32_package.all;

entity alu_v is
Port ( 
	i_v_a          : in std_logic_vector (127 downto 0);
	i_v_b          : in std_logic_vector (127 downto 0);
	i_v_alu_funct  : in std_logic_vector (3 downto 0);
	i_v_shamt      : in std_logic_vector (4 downto 0);
	o_v_result     : out std_logic_vector (127 downto 0);
	o_v_multRes    : out std_logic_vector (255 downto 0);
	o_v_zero       : out std_logic
	);
end alu_v;

architecture Behavioral of alu_v is

    component alu is
	Port ( 
		i_a			: in std_logic_vector (31 downto 0);
		i_b			: in std_logic_vector (31 downto 0);
		i_alu_funct	: in std_logic_vector (3 downto 0);
		i_shamt		: in std_logic_vector (4 downto 0);
		o_result	: out std_logic_vector (31 downto 0);
	    o_multRes    : out std_logic_vector (63 downto 0);
		o_zero		: out std_logic
		);
	end component;
    
    signal s_v_zero : std_logic_vector (3 downto 0);
    
begin

    inst_Alu_1: alu 
    port map( 
	   i_a         => i_v_a(127 downto 96),
	   i_b         => i_v_b(127 downto 96),
	   i_alu_funct => i_v_alu_funct,
	   i_shamt     => i_v_shamt,
	   o_result    => o_v_result(127 downto 96),
	   o_multRes   => o_v_multRes(255 downto 192),
	   o_zero      => s_v_zero(3)
	   );
	inst_Alu_2: alu 
    port map( 
	   i_a         => i_v_a(95 downto 64),
	   i_b         => i_v_b(95 downto 64),
	   i_alu_funct => i_v_alu_funct,
	   i_shamt     => i_v_shamt,
	   o_result    => o_v_result(95 downto 64),
	   o_multRes   => o_v_multRes(191 downto 128),
	   o_zero      => s_v_zero(2)
	   );
	inst_Alu_3: alu 
    port map( 
	   i_a         => i_v_a(63 downto 32),
	   i_b         => i_v_b(63 downto 32),
	   i_alu_funct => i_v_alu_funct,
	   i_shamt     => i_v_shamt,
	   o_result    => o_v_result(63 downto 32),
	   o_multRes   => o_v_multRes(127 downto 64),
	   o_zero      => s_v_zero(1)
	   );
	inst_Alu_4: alu 
    port map( 
	   i_a         => i_v_a(31 downto 0),
	   i_b         => i_v_b(31 downto 0),
	   i_alu_funct => i_v_alu_funct,
	   i_shamt     => i_v_shamt,
	   o_result    => o_v_result(31 downto 0),
	   o_multRes   => o_v_multRes(63 downto 0),
	   o_zero      => s_v_zero(0)
	   );
	   
    o_v_zero <= '1' when (unsigned(s_v_zero) = 0) else '0';
    
end Behavioral;
