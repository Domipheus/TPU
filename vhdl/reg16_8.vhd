----------------------------------------------------------------------------------
-- Project Name: TPU
-- Description: Register file unit of TPU
-- 
-- Revision: 1
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity reg16_8 is
    Port ( I_clk : in  STD_LOGIC;
	        I_en: in STD_LOGIC;
           I_dataD : in  STD_LOGIC_VECTOR (15 downto 0); -- Data to write to regD
           I_selA : in  STD_LOGIC_VECTOR (2 downto 0);   -- Select line for regA
           I_selB : in  STD_LOGIC_VECTOR (2 downto 0);   -- Select line for regB
           I_selD : in  STD_LOGIC_VECTOR (2 downto 0);   -- Select line for regD
           I_we : in  STD_LOGIC;                         -- Write enable for regD
           O_dataA : out  STD_LOGIC_VECTOR (15 downto 0);-- regA data out
           O_dataB : out  STD_LOGIC_VECTOR (15 downto 0) -- regB data out
			);
end reg16_8;

architecture Behavioral of reg16_8 is
	type store_t is array (0 to 7) of std_logic_vector(15 downto 0);
   signal regs: store_t := (others => X"0000");
begin

	process(I_clk, I_en)
	begin
		if rising_edge(I_clk) and I_en='1' then
			O_dataA <= regs(to_integer(unsigned(I_selA)));
			O_dataB <= regs(to_integer(unsigned(I_selB)));
			if (I_we = '1') then
				regs(to_integer(unsigned(I_selD))) <= I_dataD;
			end if;
		end if;
	end process;

end Behavioral;

