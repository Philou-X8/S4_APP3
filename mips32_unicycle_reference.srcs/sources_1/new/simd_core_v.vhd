----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/25/2024 06:05:13 PM
-- Design Name: 
-- Module Name: simd_core_v - Behavioral
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

entity simd_core_v is
Port ( 
	i_simd_a          : in std_logic_vector (127 downto 0);
	i_simd_b          : in std_logic_vector (127 downto 0);
	i_simd_alu_funct  : in std_logic_vector (3 downto 0);
	i_simd_shamt      : in std_logic_vector (4 downto 0);
	
	i_simd_opcode     : in std_logic_vector (5 downto 0); 
	i_simd_word       : in std_logic_vector (31 downto 0); -- word-sized input
	i_simd_enabled    : in std_logic;
	
	o_simd_result     : out std_logic_vector (127 downto 0);
	o_simd_multRes    : out std_logic_vector (255 downto 0);
	o_simd_zero       : out std_logic
	);
end simd_core_v;

architecture Behavioral of simd_core_v is
    
    component alu_v is
    Port ( 
        i_v_a          : in std_logic_vector (127 downto 0);
        i_v_b          : in std_logic_vector (127 downto 0);
        i_v_alu_funct  : in std_logic_vector (3 downto 0);
        i_v_shamt      : in std_logic_vector (4 downto 0);
        o_v_result     : out std_logic_vector (127 downto 0);
        o_v_multRes    : out std_logic_vector (255 downto 0);
        o_v_zero       : out std_logic
        );
    end component;
	
	signal s_v_result : std_logic_vector (127 downto 0);
	signal s_v_mov : std_logic_vector (127 downto 0);
	
begin

    inst_Alu_core: alu_v 
    port map( 
	   i_v_a         => i_simd_a,
	   i_v_b         => i_simd_b,
	   i_v_alu_funct => i_simd_alu_funct,
	   i_v_shamt     => i_simd_shamt,
	   o_v_result    => s_v_result,
	   o_v_multRes   => o_simd_multRes,
	   o_v_zero      => o_simd_zero
	   );
	   
	process(i_simd_opcode, i_simd_a, i_simd_b, i_simd_word)
    begin
        case i_simd_opcode is
            when OP_MOVNV =>
                if( unsigned(i_simd_word) /= 0 ) then
                    s_v_mov <= i_simd_a;      
                else
                    s_v_mov <= i_simd_b;
                end if;
                --s_v_result <= i_simd_a when (unsigned(i_simd_word) = 0 ) else i_simd_b;
            when OP_MOVZV =>
                if( unsigned(i_simd_word) = 0 ) then
                    s_v_mov <= i_simd_a;      
                else
                    s_v_mov <= i_simd_b;
                end if;
            
            when OP_ROTV =>
                s_v_mov(127 downto 96) <= i_simd_a(95 downto 64);
                s_v_mov(95 downto 64) <= i_simd_a(63 downto 32);
                s_v_mov(63 downto 32) <= i_simd_a(31 downto 0);
                s_v_mov(31 downto 0) <= i_simd_a(127 downto 96);
                
            
            when others => -- Vtype operation (that use the ALU_V instead)
                s_v_mov <= s_v_result;
        end case;
        
    end process;
    
    -- pick between ALU_V or SIMD_CORE result
    o_simd_result <= s_v_result when ( i_simd_opcode = OP_Vtype ) else s_v_mov;
    
    
end Behavioral;
