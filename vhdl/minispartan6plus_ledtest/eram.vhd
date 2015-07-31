LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

library work;
use work.tpu_constants.all;

use IEEE.NUMERIC_STD.ALL;

entity eram is
    Port ( I_clk : in  STD_LOGIC;
           I_we : in  STD_LOGIC;
           I_addr : in  STD_LOGIC_VECTOR (15 downto 0);
           I_data : in  STD_LOGIC_VECTOR (15 downto 0);
           O_data : out  STD_LOGIC_VECTOR (15 downto 0));
end eram;

architecture Behavioral of eram is
	type store_t is array (0 to 15) of std_logic_vector(15 downto 0);
	signal ram: store_t := (
		OPCODE_LOAD & "000" & '1' & X"01",  -- r0 = 0x1
		OPCODE_LOAD & "001" & '1' & X"01",  -- r1 = 0x1
		OPCODE_LOAD & "111" & '0' & X"0a",  -- r7 = 0x000a -- legacy code, ignore!
		OPCODE_LOAD & "010" & '1' & X"01",  -- r2 = 0x0001 -- legacy code, ignore!
		OPCODE_LOAD & "110" & '0' & X"10",  -- r6 = 0x1000
		OPCODE_WRITE & "000" & '0' & "110" & "000" & "00", -- write r0 into mem[r6]
		OPCODE_ADD & "000" & '0' & "000" & "001" & "00", --r0 = r0 + r1
		OPCODE_JUMP & "000" & '1' & X"05", -- jump to write above
		OPCODE_JUMP & "000" & '1' & X"00", -- reset?
		OPCODE_JUMP & "000" & '1' & X"00", -- reset?
		OPCODE_JUMP & "000" & '1' & X"00", -- reset?
		X"0000",
		X"0000",
		X"0000",
		X"0000",
		X"0000"
		);
begin

	process (I_clk)
	begin
		if rising_edge(I_clk) then
			if (I_we = '1') then
				ram(to_integer(unsigned(I_addr(3 downto 0)))) <= I_data;
			else
				O_data <= ram(to_integer(unsigned(I_addr(3 downto 0))));
			end if;
		end if;
	end process;

end Behavioral;