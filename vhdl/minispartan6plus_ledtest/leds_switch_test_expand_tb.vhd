--------------------------------------------------------------------------------
-- VHDL Test Bench Created by ISE for module: leds_switch_test_expand
--
-- *** Due to clock divider, simulation time needs to be in the 10,000s of ns ***
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY leds_switch_test_expand_tb IS
END leds_switch_test_expand_tb;
 
ARCHITECTURE behavior OF leds_switch_test_expand_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT leds_switch_test_expand
    PORT(
         I_clk : IN  std_logic;
         I_switch : IN  std_logic_vector(3 downto 0);
         O_leds : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal I_clk : std_logic := '0';
   signal I_switch : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal O_leds : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant I_clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: leds_switch_test_expand PORT MAP (
          I_clk => I_clk,
          I_switch => I_switch,
          O_leds => O_leds
        );

   -- Clock process definitions
   I_clk_process :process
   begin
		I_clk <= '0';
		wait for I_clk_period/2;
		I_clk <= '1';
		wait for I_clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		I_switch(0) <= '1';
      wait for I_clk_period*10;

		I_switch(0) <= '0';
      -- insert stimulus here 

      wait;
   end process;

END;
