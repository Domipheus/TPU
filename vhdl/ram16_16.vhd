----------------------------------------------------------------------------------
-- Project Name: TPU
-- Description: Test RAM unit of TPU
-- Name may say _16 but it can be larger!
-- Revision: 1
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity ram16_16 is
    Port ( I_clk : in  STD_LOGIC;
           I_we : in  STD_LOGIC;
           I_addr : in  STD_LOGIC_VECTOR (15 downto 0);
           I_data : in  STD_LOGIC_VECTOR (15 downto 0);
           O_data : out  STD_LOGIC_VECTOR (15 downto 0));
end ram16_16;

architecture Behavioral of ram16_16 is
	type store_t is array (0 to 31) of std_logic_vector(15 downto 0);
   signal ram_16: store_t := (others => X"0000");
begin

	process (I_clk)
	begin
		if rising_edge(I_clk) then
			if (I_we = '1') then
				ram_16(to_integer(unsigned(I_addr(3 downto 0)))) <= I_data;
			else
				O_data <= ram_16(to_integer(unsigned(I_addr(3 downto 0))));
			end if;
		end if;
	end process;

end Behavioral;

