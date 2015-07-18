----------------------------------------------------------------------------------
-- Project Name: TPU
-- Description: Controlsimple - control unit for testing purposes
-- 
-- Revision: 1
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity controlsimple is
    Port ( I_clk : in  STD_LOGIC;
           I_reset : in  STD_LOGIC;
           O_state : out  STD_LOGIC_VECTOR (3 downto 0)
           );
end controlsimple;

architecture Behavioral of controlsimple is
	signal s_state: STD_LOGIC_VECTOR(3 downto 0) := "0001";
begin
	process(I_clk)
	begin
		if rising_edge(I_clk) then
			if I_reset = '1' then
				s_state <= "0001";
			else
				case s_state is
					when "0001" =>
						s_state <= "0010";
					when "0010" =>
						s_state <= "0100";
					when "0100" =>
						s_state <= "1000";
					when "1000" =>
						s_state <= "0001";
					when others =>
						s_state <= "0001";
				end case;
			end if;
		end if;
	end process;

	O_state <= s_state;
end Behavioral;

