----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:33:24 07/29/2015 
-- Design Name: 
-- Module Name:    clock_divider - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;



entity clock_divider is
port ( 
  clk: in std_logic;
  reset: in std_logic;
  clock_out: out std_logic);
end clock_divider;

architecture Behavioral of clock_divider is
  signal scaler : std_logic_vector(23 downto 0) := (others => '0');
begin

  process(clk)
  begin 
    if rising_edge(clk) then   -- rising clock edge
        scaler <= std_logic_vector( unsigned(scaler) + 1);
    end if;
  end process;

clock_out <= scaler(16);

end Behavioral;



 

