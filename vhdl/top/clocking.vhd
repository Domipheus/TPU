----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:25:40 04/27/2016 
-- Design Name: 
-- Module Name:    clocking - Behavioral 
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

library UNISIM;
use UNISIM.VComponents.all;


entity clocking is
    Port ( I_unbuff_clk50 : in  STD_LOGIC;
           O_buff_clkcore : out STD_LOGIC;
           O_buff_clkpixel : out  STD_LOGIC;
           O_buff_clk5xpixel : out  STD_LOGIC;
           O_buff_clk5xpixelinv : out  STD_LOGIC;
			  O_buff_clkfmem : out STD_LOGIC;
           O_buff_clk50 : out STD_LOGIC;
           I_state : in  STD_LOGIC_VECTOR(7 downto 0)
			  );
end clocking;

architecture Behavioral of clocking is
   signal clock_core            : std_logic;
   signal clock_core_unbuffered : std_logic;
   signal clock_pixel            : std_logic;
   signal clock_pixel_unbuffered : std_logic;
   signal clock_x5pixel            : std_logic;
   signal clock_x5pixel_unbuffered : std_logic;
   signal clock_x5pixelinv            : std_logic;
   signal clock_x5pixelinv_unbuffered : std_logic;
	signal clock_fmem : std_logic;
	signal clock_fmem_unbuffered : std_logic;
   signal clk_feedback   : std_logic;
   signal clk50_buffered : std_logic;
   signal pll_locked     : std_logic;
	signal state : std_logic_vector(7 downto 0);
begin

   -- State will at some point allow for switching of clocks
   state <= I_state;
			  
   PLL_BASE_inst : PLL_BASE
   generic map (
      CLKFBOUT_MULT => 10,     --500MHz      
      CLKOUT0_DIVIDE => 20,    --25MHz
		CLKOUT0_PHASE => 0.0,   
		
      CLKOUT1_DIVIDE => 4,     --125MHz
		CLKOUT1_PHASE => 0.0,   
		
      CLKOUT2_DIVIDE => 4,     --125MHz
		CLKOUT2_PHASE => 180.0,  
		
      CLKOUT3_DIVIDE => 5,     --100MHz
		CLKOUT3_PHASE => 0.0,  
		
      CLKOUT4_DIVIDE => 2,     --250MHz
		CLKOUT4_PHASE => 0.0, 
		
      CLK_FEEDBACK => "CLKFBOUT", 
      CLKIN_PERIOD => 20.0,  
      DIVCLK_DIVIDE => 1 
   )
   port map (
      CLKFBOUT => clk_feedback, 
      CLKOUT0  => clock_pixel_unbuffered,
      CLKOUT1  => clock_x5pixel_unbuffered,
      CLKOUT2  => clock_x5pixelinv_unbuffered,
      CLKOUT3  => clock_core_unbuffered,
      CLKOUT4  => clock_fmem_unbuffered,
      CLKOUT5  => open,
      LOCKED   => pll_locked,      
      CLKFBIN  => clk_feedback,    
      CLKIN    => clk50_buffered, 
      RST      => '0' 
   );

	BUFG_clk : BUFG port map 
	( 
		I => I_unbuff_clk50,                
		O => clk50_buffered
	);

	BUFG_core : BUFG port map 
	( 
	   I => clock_core_unbuffered,                
		O => clock_core
	);
		
	BUFG_pclock : BUFG port map 
	( 
	  I => clock_pixel_unbuffered,  
	  O => clock_pixel
	);

	BUFG_pclockx5 : BUFG port map 
	( 
	  I => clock_x5pixel_unbuffered,  
	  O => clock_x5pixel
	);

	BUFG_pclockx5_180 : BUFG port map 
	( 
	  I => clock_x5pixelinv_unbuffered,  
	  O => clock_x5pixelinv
	);
	
	
	BUFG_fmem : BUFG port map 
	( 
	  I => clock_fmem_unbuffered,
	  O => clock_fmem
	);


   O_buff_clk50 <= clk50_buffered;
   O_buff_clkcore <= clock_core;
   O_buff_clkpixel <= clock_pixel;
   O_buff_clk5xpixel <= clock_x5pixel;
   O_buff_clk5xpixelinv <= clock_x5pixelinv;
	O_buff_clkfmem <= clock_fmem;
	
end Behavioral;

