-- Empty Font ram for use in sim tests
-- you can find a near (this interface is double the size) drop in
-- for synthesis from http://ece320web.groups.et.byu.net/labs/VGATextGeneration/list_ch13_01_font_rom.vhd
-- I didn't include it as I am unsure of licencing.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity font_rom is
   port(
      clk: in std_logic;
      addr: in std_logic_vector(11 downto 0);
      data: out std_logic_vector(7 downto 0)
   );
end font_rom;

architecture arch of font_rom is
   constant ADDR_WIDTH: integer:=12;
   constant DATA_WIDTH: integer:=8;
   signal addr_reg: std_logic_vector(ADDR_WIDTH-1 downto 0);
   type rom_type is array (0 to 2**ADDR_WIDTH-1)
        of std_logic_vector(DATA_WIDTH-1 downto 0);
   -- ROM definition
   constant ROM: rom_type:=( 
	others => "00000000"
   );
begin
   -- addr register to infer block RAM
   process (clk)
   begin
      if (clk'event and clk = '1') then
        addr_reg <= addr;
      end if;
   end process;
   data <= ROM(to_integer(unsigned(addr_reg)));
end arch;

