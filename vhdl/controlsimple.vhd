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
           O_state : out  STD_LOGIC_VECTOR (5 downto 0)
           );
end controlsimple;

architecture Behavioral of controlsimple is
	signal s_state: STD_LOGIC_VECTOR(5 downto 0) := "000001";
begin
	process(I_clk)
	begin
		if rising_edge(I_clk) then
			if I_reset = '1' then
				s_state <= "000001";
			else
				case s_state is
					when "000001" =>
						s_state <= "000010";
					when "000010" =>
						s_state <= "000100";
					when "000100" =>
						s_state <= "001000";
					when "001000" =>
						s_state <= "010000";
					when "010000" =>
						s_state <= "000001"; -- skip last stage for now
					when "100000" =>
						s_state <= "000001";
					when others =>
						s_state <= "000001";
				end case;
			end if;
		end if;
	end process;

	O_state <= s_state;
end Behavioral;

