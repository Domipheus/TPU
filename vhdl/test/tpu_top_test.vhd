--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   08:43:06 01/12/2016
-- Design Name:   
-- Module Name:   C:/dev/github/MiniSpartan6plus/testpu - part10b - otheruart/tpu_top_test.vhd
-- Project Name:  testpu
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: tpu_top
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
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
 
ENTITY tpu_top_test IS
END tpu_top_test;
 
ARCHITECTURE behavior OF tpu_top_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT tpu_top
    PORT(
         I_clk : IN  std_logic;
         O_tx : OUT  std_logic;
         I_rx : IN  std_logic;
        -- O_tx2 : OUT  std_logic;
        -- I_rx2 : IN  std_logic;
         O_leds : OUT  std_logic_vector(7 downto 0);
         I_switches : IN  std_logic_vector(3 downto 0);
			
	hdmi_out_p : out  STD_LOGIC_VECTOR(3 downto 0);
	hdmi_out_n : out  STD_LOGIC_VECTOR(3 downto 0)
	
	; --
	  D_vram_addr    : out std_logic_vector(15 downto 0);
	  D_vram_data    : out std_logic_vector(15 downto 0)
	  ;
         D_I_int : out std_logic;
         D_O_int_ack : OUT  std_logic;
         D_MEM_I_ready : OUT  std_logic;
         D_MEM_O_cmd : OUT  std_logic;
         D_MEM_O_we : OUT  std_logic;
         D_MEM_O_byteEnable : OUT  std_logic_vector(1 downto 0);
         D_MEM_O_addr : OUT  std_logic_vector(15 downto 0);
         D_MEM_O_data : OUT  std_logic_vector(15 downto 0);
         D_MEM_I_data : OUT  std_logic_vector(15 downto 0);
         D_MEM_I_dataReady : OUT  std_logic;
         D_MEM_readyState : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal I_clk : std_logic := '0';
   signal I_rx : std_logic := '0';
   signal I_rx2 : std_logic := '0';
   signal I_switches : std_logic_vector(3 downto 0) := (others => '0');
   signal D_I_int : std_logic := '0';

 	--Outputs
   signal O_tx : std_logic;
   signal O_tx2 : std_logic;
   signal O_leds : std_logic_vector(7 downto 0);
   signal D_O_int_ack : std_logic;
   signal D_MEM_I_ready : std_logic;
   signal D_MEM_O_cmd : std_logic;
   signal D_MEM_O_we : std_logic;
   signal D_MEM_O_byteEnable : std_logic_vector(1 downto 0);
   signal D_MEM_O_addr : std_logic_vector(15 downto 0);
   signal D_MEM_O_data : std_logic_vector(15 downto 0);
   signal D_MEM_I_data : std_logic_vector(15 downto 0);
   signal D_MEM_I_dataReady : std_logic;
   signal D_MEM_readyState : std_logic_vector(7 downto 0);


	signal hdmi_out_p :    STD_LOGIC_VECTOR(3 downto 0);
	signal hdmi_out_n :    STD_LOGIC_VECTOR(3 downto 0)
	
	; --
	 signal D_vram_addr    :   std_logic_vector(15 downto 0);
	 signal D_vram_data    :   std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant I_clk_period : time := 20 ns;
 
BEGIN

I_rx2 <= O_tx2;
 
	-- Instantiate the Unit Under Test (UUT)
   uut: tpu_top PORT MAP (
          I_clk => I_clk,
          O_tx => O_tx,
          I_rx => I_rx,
        --  O_tx2 => O_tx2,
         -- I_rx2 => I_rx2,
          O_leds => O_leds,
          I_switches => I_switches,
			 
			 hdmi_out_p => hdmi_out_p,
			 hdmi_out_n => hdmi_out_n,
			 
			 D_vram_addr => D_vram_addr,
			 D_vram_data => D_vram_data,
			 
          D_I_int => D_I_int,
          D_O_int_ack => D_O_int_ack,
          D_MEM_I_ready => D_MEM_I_ready,
          D_MEM_O_cmd => D_MEM_O_cmd,
          D_MEM_O_we => D_MEM_O_we,
          D_MEM_O_byteEnable => D_MEM_O_byteEnable,
          D_MEM_O_addr => D_MEM_O_addr,
          D_MEM_O_data => D_MEM_O_data,
          D_MEM_I_data => D_MEM_I_data,
          D_MEM_I_dataReady => D_MEM_I_dataReady,
          D_MEM_readyState => D_MEM_readyState
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

      wait for I_clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
