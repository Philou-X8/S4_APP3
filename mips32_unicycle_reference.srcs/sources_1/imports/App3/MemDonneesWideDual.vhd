---------------------------------------------------------------------------------------------
--
--	Universit� de Sherbrooke 
--  D�partement de g�nie �lectrique et g�nie informatique
--
--	S4i - APP4 
--	
--
--	Auteur: 		Marc-Andr� T�trault
--					Daniel Dalle
--					S�bastien Roy
-- 
---------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all; -- requis pour la fonction "to_integer"
use work.MIPS32_package.all;

entity MemDonneesWideDual is
Port ( 
	clk 		: in std_logic;
	reset 		: in std_logic;
	i_MemRead	: in std_logic;
	i_MemWrite 	: in std_logic;
    i_Addresse 	: in std_logic_vector (31 downto 0);
	i_WriteData : in std_logic_vector (31 downto 0);
    o_ReadData 	: out std_logic_vector (31 downto 0);
	
	-- ports pour acc�s � large bus, adresse partag�e
	i_MemReadWide       : in std_logic;
	i_MemWriteWide 		: in std_logic;
	i_WriteDataWide 	: in std_logic_vector (127 downto 0);
    o_ReadDataWide 		: out std_logic_vector (127 downto 0)
);
end MemDonneesWideDual;

architecture Behavioral of MemDonneesWideDual is
    signal ram_DataMemory : RAM(0 to 255) := ( -- type d�fini dans le package
------------------------
-- Ins�rez vos donnees ici
------------------------

------------------------
-- Fin de votre code
------------------------
    others => X"00000000");

    signal s_MemoryIndex 	: integer range 0 to 255; -- 0-127
	signal s_MemoryRangeValid 	: std_logic;
	
    signal s_WideMemoryRangeValid  : std_logic;

begin
    -- Transformation de l'adresse en entier � interval fix�s
    s_MemoryIndex 	<= to_integer(unsigned(i_Addresse(9 downto 2)));
	s_MemoryRangeValid <= '1' when i_Addresse(31 downto 10) = (X"10010" & "00") else '0'; 


	s_WideMemoryRangeValid <= '1' when (i_Addresse(31 downto 10) = (X"10010" & "00") and i_Addresse(3 downto 2) = "00") else '0'; 
	
	-- message de simulation
	-- Dans une v�ritable m�moire SRAM, l'octet "bas" sors toujours sur les m�me pattes physiques. 
	-- Par exemple, sur un bus 32-bits et en acc�s 8-bits, l'octet de l'adresse 0x00 sera aux bits (7 downto 0), 
	-- et celui de l'adresse 0x01 sur (15 downto 8). Donc typiquement, l'adresse "vue" � la m�moire sera 0x00 dans les deux
	-- cas, et un multiplexeur viendra replacer la donn�e au LSB du banc de registres.
	-- C'est la m�me chose pour les m�moires � large bus, comme notre cas ici. En assembleur, 
	-- il est plus r�aliste d'incr�menter par bloc d'acc�s en blocs de 128 bits.
	-- L'assertion � la ligne suivante vous averti si cette condition n'est pas respect�e pour la m�moire large mod�lis�e pour la probl�matique. 
	-- Il est possible de modifier le mod�le et retirer ce message, mais alors le mod�le ne sera pas r�aliste.
	process(clk, i_MemWriteWide,  i_MemReadWide, i_Addresse) --or i_MemReadWide = '1')
	begin
        if clk='0' and clk'event then -- sur front descendant
			if(i_MemWriteWide = '1' or i_MemReadWide = '1') then
				assert (i_Addresse(3 downto 0) = "0000") report "mauvais alignement de l'adresse pour une ecriture large" severity failure;
			end if;
	   end if;
	end process;
	
	-- Partie pour l'�criture
	process( clk )
    begin
        if clk='1' and clk'event then
            if i_MemWriteWide = '1' and reset = '0' and s_WideMemoryRangeValid = '1' then
				ram_DataMemory(s_MemoryIndex + 3) <= i_WriteDataWide(127 downto 96);
				ram_DataMemory(s_MemoryIndex + 2) <= i_WriteDataWide( 95 downto 64);
				ram_DataMemory(s_MemoryIndex + 1) <= i_WriteDataWide( 63 downto 32);
				ram_DataMemory(s_MemoryIndex + 0) <= i_WriteDataWide( 31 downto  0);
            elsif i_MemWrite = '1' and reset = '0' and s_MemoryRangeValid = '1' then
                ram_DataMemory(s_MemoryIndex) <= i_WriteData;
            end if;
        end if;
    end process;

    -- Valider que nous sommes dans le segment de m�moire, avec 256 addresses valides
    o_ReadData <= ram_DataMemory(s_MemoryIndex) when s_MemoryRangeValid = '1'
                    else (others => '0');
	
	-- valider le segment et l'alignement de l'adresse
	o_ReadDataWide <= ram_DataMemory(s_MemoryIndex + 3) & 
					  ram_DataMemory(s_MemoryIndex + 2) & 
					  ram_DataMemory(s_MemoryIndex + 1) & 
					  ram_DataMemory(s_MemoryIndex + 0)   when s_WideMemoryRangeValid = '1'
					else (others => '0');

end Behavioral;
