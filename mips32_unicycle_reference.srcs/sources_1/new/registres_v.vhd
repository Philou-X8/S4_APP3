----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/25/2024 04:25:54 PM
-- Design Name: 
-- Module Name: registres_v - Behavioral
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


entity registres_v is
    Port ( clk         : in  std_logic;
           reset       : in  std_logic;
           i_v_RS1     : in  std_logic_vector (4 downto 0); -- 8 vector, 
           i_v_RS2     : in  std_logic_vector (4 downto 0);
           i_v_Wr_DAT  : in  std_logic_vector (127 downto 0);
           i_v_WDest   : in  std_logic_vector (4 downto 0);
           i_v_WE      : in  std_logic;
           o_v_RS1_DAT : out std_logic_vector (127 downto 0);
           o_v_RS2_DAT : out std_logic_vector (127 downto 0);
           o_v_RS3_DAT : out std_logic_vector (127 downto 0));
end registres_v;

architecture Behavioral of registres_v is

    signal regs: RAM(0 to 31) := (others => X"00000000"); -- 32 address, 4 address per vector, 8 vector of lenght four
    
begin
    
    process( clk )
    begin
        if clk='1' and clk'event then
            -- if i_v_WE = '1' and reset = '0' and i_v_WDest /= "00000" then -- removed to allow writing at adress $0
            if i_v_WE = '1' and reset = '0' then
            
                regs( to_integer( unsigned(i_v_WDest) ) ) <= i_v_Wr_DAT(127 downto 96);
                regs( to_integer( unsigned(i_v_WDest) + 1) ) <= i_v_Wr_DAT(95 downto 64);
                regs( to_integer( unsigned(i_v_WDest) + 2) ) <= i_v_Wr_DAT(63 downto 32);
                regs( to_integer( unsigned(i_v_WDest) + 3) ) <= i_v_Wr_DAT(31 downto 0);
                
            end if;
        end if;
    end process;
    
    o_v_RS1_DAT <= regs( to_integer(unsigned(i_v_RS1))) 
                 & regs( to_integer( unsigned(i_v_RS1)+1 ))
                 & regs( to_integer( unsigned(i_v_RS1)+2 ))
                 & regs( to_integer( unsigned(i_v_RS1)+3 ));
                 
    o_v_RS2_DAT <= regs( to_integer(unsigned(i_v_RS2))) 
                 & regs( to_integer( unsigned(i_v_RS2)+1 ))
                 & regs( to_integer( unsigned(i_v_RS2)+2 ))
                 & regs( to_integer( unsigned(i_v_RS2)+3 ));
                 
    o_v_RS3_DAT <= regs( to_integer(unsigned(i_v_WDest))) 
                 & regs( to_integer( unsigned(i_v_WDest)+1 ))
                 & regs( to_integer( unsigned(i_v_WDest)+2 ))
                 & regs( to_integer( unsigned(i_v_WDest)+3 ));
    
end Behavioral;
