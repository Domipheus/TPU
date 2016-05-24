----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:18:24 10/13/2015 
-- Design Name: 
-- Module Name:    tpu_top - Behavioral 
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
 
use IEEE.NUMERIC_STD.ALL;
 
library UNISIM;
use UNISIM.VComponents.all;

entity tpu_top is
  Port ( 
    I_clk      : in  STD_LOGIC;
    
	 O_tx       : out STD_LOGIC;
    I_rx       : in  STD_LOGIC;
	 
	 O_AUDIO1   : out STD_LOGIC;
	 O_AUDIO2   : out STD_LOGIC;
	 
    O_leds     : out STD_LOGIC_VECTOR (7 downto 0);
    I_switches : in  STD_LOGIC_VECTOR (3 downto 0);

	 hdmi_out_p : out STD_LOGIC_VECTOR(3 downto 0);
	 hdmi_out_n : out STD_LOGIC_VECTOR(3 downto 0)
	
	 ; -- debug signals - useful for simulation
	 D_vram_addr    : out std_logic_vector(15 downto 0);
	 D_vram_data    : out std_logic_vector(15 downto 0);
    D_I_int        : out std_logic;
    D_O_int_ack    : out std_logic;
    D_MEM_I_ready  : out  std_logic;
    D_MEM_O_cmd    : out  std_logic;
    D_MEM_O_we     : out  std_logic;
    D_MEM_O_byteEnable : out  std_logic_vector(1 downto 0);
    D_MEM_O_addr   : out  std_logic_vector(15 downto 0);
    D_MEM_O_data   : out  std_logic_vector(15 downto 0);
    D_MEM_I_data   :out  std_logic_vector(15 downto 0);
    D_MEM_I_dataReady : out  std_logic;
    D_MEM_readyState: out  std_logic_vector (7 downto 0)
  );
end tpu_top;

architecture Behavioral of tpu_top is

	COMPONENT clocking
   PORT ( 
	        I_unbuff_clk50 : in  STD_LOGIC;
           O_buff_clkcore : out  STD_LOGIC;
           O_buff_clkpixel : out  STD_LOGIC;
           O_buff_clk5xpixel : out  STD_LOGIC;
           O_buff_clk5xpixelinv : out  STD_LOGIC;
			  O_buff_clkfmem : out STD_LOGIC;
           O_buff_clk50 : out STD_LOGIC;
           I_state : in  STD_LOGIC_VECTOR(7 downto 0)
			  );
	END COMPONENT;

    COMPONENT core
    PORT(
         I_clk : IN  std_logic;
         I_reset : IN  std_logic;
         I_halt : IN  std_logic;
			
			I_int: in STD_LOGIC;
			O_int_ack: out STD_LOGIC;

         MEM_I_ready : IN  std_logic;
         MEM_O_cmd : OUT  std_logic;
         MEM_O_we : OUT  std_logic;
         MEM_O_byteEnable : OUT  std_logic_vector(1 downto 0);
         MEM_O_addr : OUT  std_logic_vector(15 downto 0);
         MEM_O_data : OUT  std_logic_vector(15 downto 0);
         MEM_I_data : IN  std_logic_vector(15 downto 0);
         MEM_I_dataReady : IN  std_logic
        );
    END COMPONENT;
     
	component ebram
	Port ( I_clk : in  STD_LOGIC;
			  I_cs : in STD_LOGIC;
			  I_we : in  STD_LOGIC;
			  I_addr : in  STD_LOGIC_VECTOR (15 downto 0);
			  I_data : in  STD_LOGIC_VECTOR (15 downto 0);
			  I_size : in  STD_LOGIC;
			  O_data : out  STD_LOGIC_VECTOR (15 downto 0)
			  );
	end component;
	
	component ebram2port 
    Port (I_clk : in  STD_LOGIC;
          I_cs : in STD_LOGIC;
          I_we : in  STD_LOGIC;
          I_addr : in  STD_LOGIC_VECTOR (15 downto 0);
          I_data : in  STD_LOGIC_VECTOR (15 downto 0);
          I_size : in STD_LOGIC;
          O_data : out  STD_LOGIC_VECTOR (15 downto 0);
          
			 I_p2_clk : in STD_LOGIC;
          I_p2_cs : in STD_LOGIC;
          I_p2_addr : in  STD_LOGIC_VECTOR (15 downto 0);
          O_p2_data : out  STD_LOGIC_VECTOR (15 downto 0)
          
          );
	end component;
	
	  COMPONENT uart_simple
    PORT(
         I_clk : IN  std_logic;
	      I_clk_baud_count : in STD_LOGIC_VECTOR (15 downto 0);
         I_reset : IN  std_logic;
         I_txData : IN  std_logic_vector(7 downto 0);
         I_txSig : IN  std_logic;
         O_txRdy : OUT  std_logic;
         O_tx : OUT  std_logic;
         I_rx : IN  std_logic;
         I_rxCont : IN  std_logic;
         O_rxData : OUT  std_logic_vector(7 downto 0);
         O_rxSig : OUT  std_logic;
			O_rxFrameError : out STD_LOGIC;
			
			
			  D_rxClk : out STD_LOGIC;
			  D_rxState: out integer;
			  D_txClk : out STD_LOGIC;
			  D_txState: out integer
        );
    END COMPONENT;
	 
	component uart_tx6
		Port (             
		data_in : in std_logic_vector(7 downto 0);
		en_16_x_baud : in std_logic;
		serial_out : out std_logic;
		buffer_write : in std_logic;
		buffer_data_present : out std_logic;
		buffer_half_full : out std_logic;
		buffer_full : out std_logic;
		buffer_reset : in std_logic;
		clk : in std_logic);
	end component;
	
	component uart_rx6
		Port (           
		serial_in : in std_logic;
		en_16_x_baud : in std_logic;
		data_out : out std_logic_vector(7 downto 0);
		buffer_read : in std_logic;
		buffer_data_present : out std_logic;
		buffer_half_full : out std_logic;
		buffer_full : out std_logic;
		buffer_reset : in std_logic;
		clk : in std_logic);
	end component;
	
		------------ VIDEO SUBSYSTEM ---------
	
	   COMPONENT vga_gen
   PORT(    
      pixel_clock     : in std_logic; 
		
		pixel_h 			 : out STD_LOGIC_VECTOR(11 downto 0);
		pixel_v 			 : out STD_LOGIC_VECTOR(11 downto 0);
		
		
			  
			  pixel_h_pref : out STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
			  pixel_v_pref : out STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
			  blank_pref : OUT std_logic;
		
      blank           : OUT std_logic;
      hsync           : OUT std_logic;
      vsync           : OUT std_logic
      );
   END COMPONENT;
 
 COMPONENT text_gen is
    Port ( I_clk_pixel : in  STD_LOGIC;
	        I_clk_pixel10x : in  STD_LOGIC;
			  
			  -- Inputs from VGA signal generator
			  -- defines the 'next pixel' 
           I_blank : in  STD_LOGIC;
           I_x : in  STD_LOGIC_VECTOR (11 downto 0);
           I_y : in  STD_LOGIC_VECTOR (11 downto 0);
			  
			  -- Request data for a glyph row from FRAM
			  O_FRAM_ADDR : out STD_LOGIC_VECTOR (15 downto 0);
			  I_FRAM_DATA : in STD_LOGIC_VECTOR (15 downto 0);
			  
			  -- Request data from textual memory TRAM
			  O_TRAM_ADDR : out STD_LOGIC_VECTOR (15 downto 0);
			  I_TRAM_DATA : in STD_LOGIC_VECTOR (15 downto 0);
			  
			  -- The data for the relevant requested pixel
			  O_R : out STD_LOGIC_VECTOR (7 downto 0);
			  O_G : out STD_LOGIC_VECTOR (7 downto 0);
			  O_B : out STD_LOGIC_VECTOR (7 downto 0)
			  );
end COMPONENT;

COMPONENT font_rom is
   port(
      clk: in std_logic;
      addr: in std_logic_vector(11 downto 0);
      data: out std_logic_vector(7 downto 0)
   );
end COMPONENT;
      

   COMPONENT dvid
   PORT(
      clk      : IN std_logic;
      clk_n    : IN std_logic;
      clk_pixel: IN std_logic;
      red_p   : IN std_logic_vector(7 downto 0);
      green_p : IN std_logic_vector(7 downto 0);
      blue_p  : IN std_logic_vector(7 downto 0);
      blank   : IN std_logic;
      hsync   : IN std_logic;
      vsync   : IN std_logic;          
      red_s   : OUT std_logic;
      green_s : OUT std_logic;
      blue_s  : OUT std_logic;
      clock_s : OUT std_logic
      );
   END COMPONENT;

   ----------------------------------------------------------------------------
	-- Memory Systems 
	
	signal MEM_readyState: integer := 0;
	
	signal MEM_REQ_SIZE: std_logic := '0';
	signal MEM_WE : std_logic := '0';
	
	signal MEM_2KB_ADDR : std_logic_vector(15 downto 0);
	signal MEM_BANK_ID : std_logic_vector(4 downto 0);
	
	signal MEM_CS_ERAM_1 : std_logic := '0';
	signal MEM_CS_ERAM_2 : std_logic := '0';
	signal MEM_CS_ERAM_3 : std_logic := '0';
	signal MEM_CS_ERAM_4 : std_logic := '0';
	signal MEM_CS_ERAM_5 : std_logic := '0';
	signal MEM_CS_ERAM_6 : std_logic := '0';
	signal MEM_CS_ERAM_7 : std_logic := '0';
	signal MEM_CS_ERAM_8 : std_logic := '0';
	
	signal MEM_CS_FRAM_1 : std_logic := '0';
	signal MEM_CS_FRAM_2 : std_logic := '0';
	
	signal MEM_CS_TRAM_1 : std_logic := '0';
	signal MEM_CS_TRAM_2 : std_logic := '0';
	
	signal MEM_CS_VRAM_1 : std_logic := '0';
	signal MEM_CS_VRAM_2 : std_logic := '0';
	signal MEM_CS_VRAM_3 : std_logic := '0';
	signal MEM_CS_VRAM_4 : std_logic := '0';
	signal MEM_CS_VRAM_5 : std_logic := '0';
	signal MEM_CS_VRAM_6 : std_logic := '0';
	signal MEM_CS_VRAM_7 : std_logic := '0';
	signal MEM_CS_VRAM_8 : std_logic := '0';

	signal MEM_CS_SYSTEM : std_logic := '0';
	
	
	signal MEM_ANY_CS : std_logic := '0';

	signal MEM_DATA_OUT_ERAM_1: std_logic_vector(15 downto 0);
	signal MEM_DATA_OUT_ERAM_2: std_logic_vector(15 downto 0);
	signal MEM_DATA_OUT_ERAM_3: std_logic_vector(15 downto 0);
	signal MEM_DATA_OUT_ERAM_4: std_logic_vector(15 downto 0);
	signal MEM_DATA_OUT_ERAM_5: std_logic_vector(15 downto 0);
	signal MEM_DATA_OUT_ERAM_6: std_logic_vector(15 downto 0);
	signal MEM_DATA_OUT_ERAM_7: std_logic_vector(15 downto 0);
	signal MEM_DATA_OUT_ERAM_8: std_logic_vector(15 downto 0);
	
	signal MEM_DATA_OUT_FRAM_1: std_logic_vector(15 downto 0);
	signal MEM_DATA_OUT_FRAM_2: std_logic_vector(15 downto 0);

	signal MEM_DATA_OUT_TRAM_1: std_logic_vector(15 downto 0);
	signal MEM_DATA_OUT_TRAM_2: std_logic_vector(15 downto 0);

	signal MEM_DATA_OUT_VRAM_1: std_logic_vector(15 downto 0);
	
	signal MEM_Access_error : std_logic := '0';
	signal MEM_Access_error_bank : std_logic_vector(7 downto 0);
	signal MEM_access_int_state : integer := 0;

   ----------------------------------------------------------------------------
	-- UART 
	signal uart_tx_data_in : std_logic_vector (7 downto 0) := X"00";
	signal uart_tx_data_present : std_logic ;
	signal uart_tx_half_full : std_logic ;
	signal uart_tx_full : std_logic ;
	signal uart_tx_reset : std_logic := '0';
	signal uart_rx_data_out: std_logic_vector (7 downto 0) := X"00";  
	signal uart_rx_read : std_logic := '0';       
	signal uart_rx_data_present: std_logic ;   
	signal uart_rx_half_full: std_logic ;       
	signal uart_rx_full: std_logic ;            
	signal uart_rx_reset : std_logic := '0';
	
	signal write_to_uart_tx : std_logic := '0';
	
	signal baud_count : integer range 0 to 325:= 0; 
	signal en_16_x_baud : std_logic := '0';
	
	
	----------------------------------------------------------------------------
	-- Clock engine
	signal cEng_state : std_logic_vector(7 downto 0) := X"00";
	signal cEng_clk_core : std_logic;
	signal cEng_clk_pixel : std_logic;
	signal cEng_clk_5xpixel : std_logic;	
	signal cEng_clk_5xpixel_inv : std_logic;
	signal cEng_clk_fmem : std_logic;
	signal cEng_clk_50 : std_logic;
	
	----------------------------------------------------------------------------
	-- I/O
	signal IO_DATA : std_logic_vector(15 downto 0) := X"0000";
	signal IO_LEDS : std_logic_vector(7 downto 0) := X"00";
	signal IO_SWITCH: std_logic_vector(3 downto 0) := "0000";

	----------------------------------------------------------------------------
	-- TPU Core 1 memory
   signal MEM_I_ready : std_logic := '1';
   signal MEM_I_data : std_logic_vector(15 downto 0) := (others => '0');
   signal MEM_I_dataReady : std_logic := '1';
   signal MEM_O_cmd : std_logic;
   signal MEM_O_we : std_logic;
   signal MEM_O_byteEnable : std_logic_vector(1 downto 0);
   signal MEM_O_addr : std_logic_vector(15 downto 0);
   signal MEM_O_data : std_logic_vector(15 downto 0);
	
	----------------------------------------------------------------------------
	-- VRAM
	signal MEM_VRAM_ADDR: std_logic_vector (15 downto 0) := X"0000";  
	signal vram_output_data: std_logic_vector (15 downto 0) := X"0000";  
	
	----------------------------------------------------------------------------
	-- Interrupts
	signal INT_DATA : std_logic_vector(15 downto 0) := X"0000";
	signal I_int:   std_logic := '0';
	signal O_int_ack:   std_logic;
	
	----------------------------------------------------------------------------
	-- TPU Control
	signal I_reset : std_logic := '0';
	signal I_halt : std_logic := '0';
	
	----------------------------------------------------------------------------
	-- TPU Control
	signal red_p   : std_logic_vector(7 downto 0);
   signal green_p : std_logic_vector(7 downto 0);
   signal blue_p  : std_logic_vector(7 downto 0);
   signal blank   : std_logic;
   signal hsync   : std_logic;
   signal vsync   : std_logic;          
	
	----------------------------------------------------------------------------
	-- Graphics Subsystem
	signal pixel_h : STD_LOGIC_VECTOR(11 downto 0);
	signal pixel_v : STD_LOGIC_VECTOR(11 downto 0);
	
	signal pixel_h_pref : STD_LOGIC_VECTOR(11 downto 0);
	signal pixel_v_pref : STD_LOGIC_VECTOR(11 downto 0);
	signal blank_pref: std_logic;
	signal vram_addr    : std_logic_vector(15 downto 0); 
	signal vram_data    : std_logic_vector(15 downto 0);
	signal vram_output_2: std_logic_vector(15 downto 0);
	signal ram_write_addr: std_logic_vector(15 downto 0);
	signal vram_we : std_logic := '0';
   signal red_ram_p   : std_logic_vector(7 downto 0) := (others => '0');
   signal green_ram_p : std_logic_vector(7 downto 0) := (others => '0');
   signal blue_ram_p  : std_logic_vector(7 downto 0) := (others => '0');
	signal video_enable : std_logic := '1';
	signal CS_VRAM : std_logic:= '0';
   signal red_s   : std_logic;
   signal green_s : std_logic;
   signal blue_s  : std_logic;
   signal clock_s : std_logic;
	
	----------------------------------------------------------------------------
	-- Text Graphics Subsystem
	
	signal SYS_TRAM1_OUTDATA: std_logic_vector(15 downto 0);
	signal SYS_TRAM2_OUTDATA: std_logic_vector(15 downto 0);
	signal SYS_TRAM_2K_ADDR: std_logic_vector(15 downto 0);
		
	signal SYS_FRAM1_ADDR: std_logic_vector(15 downto 0);
	signal SYS_FRAM1_OUTDATA: std_logic_vector(15 downto 0);
	
	signal SYS_FRAM2_ADDR: std_logic_vector(15 downto 0);
	signal SYS_FRAM2_OUTDATA: std_logic_vector(15 downto 0);
	
	
	signal GFX_MODE: std_logic := '0';  -- 0 = text 1 = pixel
	
	signal TXT_R: std_logic_vector(7 downto 0);
	signal TXT_G: std_logic_vector(7 downto 0);
	signal TXT_B: std_logic_vector(7 downto 0);
	
	signal FRAM_DATA: std_logic_vector(15 downto 0);
	signal FRAM_ADDR: std_logic_vector(15 downto 0);
	
	
	signal FRAM_DATA_TEST: std_logic_vector(7 downto 0);
	signal FRAM_ADDR_TEST: std_logic_vector(11 downto 0);
	
	signal TRAM_DATA: std_logic_vector(15 downto 0);
	signal TRAM_ADDR: std_logic_vector(15 downto 0);
	
	
	signal SYS_COUNTER: integer := 0;
	signal SYS_AUDIO : std_logic:='0';
	signal SYS_AUDIO_REGISTER: std_logic_vector(15 downto 0) := X"0000";
BEGIN
	I_reset <= I_switches(0);
	IO_SWITCH <= I_switches;
	--O_leds <= I_reset & I_rx & uart_rx_data_present & IO_LEDS( 4 downto 0);
   O_leds <= IO_LEDS(7 downto 0);
	
--   D_MEM_I_ready <= MEM_I_ready ;
--   D_MEM_O_cmd  <= MEM_O_cmd;
--   D_MEM_O_we  <= MEM_O_we;
--   D_MEM_O_byteEnable  <= MEM_O_byteEnable;
   D_MEM_O_addr  <= MEM_O_addr;
   D_MEM_O_data  <= MEM_O_data;
   D_MEM_I_data  <= MEM_I_data;
   D_MEM_I_dataReady  <=MEM_I_dataReady ;
--   D_MEM_readyState <= std_logic_vector(to_unsigned(MEM_readyState, D_MEM_readyState'length));		
  --D_vram_addr <= X"00" & "000" & MEM_Access_error_bank; 
--	  D_vram_data <= X"00" & "000" & MEM_O_addr(15 downto 11);	

	clock_engine: clocking port map (
		    I_unbuff_clk50 => I_clk,
          O_buff_clkcore => cEng_clk_core,
          O_buff_clkpixel => cEng_clk_pixel,
          O_buff_clk5xpixel => cEng_clk_5xpixel,
          O_buff_clk5xpixelinv => cEng_clk_5xpixel_inv,
			 O_buff_clkfmem => cEng_clk_fmem,
			 O_buff_clk50 => cEng_clk_50,
          I_state => cEng_state
			 );

	
	 -- at 0x1200
	tx1: uart_tx6 port map (              
		data_in => uart_tx_data_in,                   --0x1200
		en_16_x_baud => en_16_x_baud,
		serial_out => O_tx,
		buffer_write => write_to_uart_tx,             --0x1201 
		buffer_data_present => uart_tx_data_present,  --0x1202
		buffer_half_full => uart_tx_half_full,        --0x1203
		buffer_full => uart_tx_full,                  --0x1204
		buffer_reset => uart_tx_reset,                --0x1205             
		clk => cEng_clk_50
	);
		
	rx1: uart_rx6 port map (
		serial_in => I_rx,
		en_16_x_baud => en_16_x_baud,
		data_out => uart_rx_data_out,                 --0x1206
		buffer_read => uart_rx_read,                  --0x1207
		buffer_data_present => uart_rx_data_present,  --0x1208
 		buffer_half_full => uart_rx_half_full,        --0x1209
		buffer_full => uart_rx_full,                  --0x120a
		buffer_reset => uart_rx_reset,                --0x120b
		clk => cEng_clk_50
	);

 
   core_1: core PORT MAP (
          I_clk => cEng_clk_core,
          I_reset => I_reset,
          I_halt => I_halt,
			 
			I_int => I_int,
			O_int_ack => O_int_ack,
          MEM_I_ready => MEM_I_ready,
          MEM_O_cmd => MEM_O_cmd,
          MEM_O_we => MEM_O_we,
          MEM_O_byteEnable => MEM_O_byteEnable,
          MEM_O_addr => MEM_O_addr,
          MEM_O_data => MEM_O_data,
          MEM_I_data => MEM_I_data,
          MEM_I_dataReady => MEM_I_dataReady
        );
		  
	ebram_1: ebram Port map ( 
		I_clk => cEng_clk_core,
		I_cs => MEM_CS_ERAM_1,
      I_we => MEM_WE,
	   I_addr => MEM_2KB_ADDR,
	   I_data => MEM_O_data,
		I_size => MEM_REQ_SIZE,
	   O_data => MEM_DATA_OUT_ERAM_1
	);
	
	ebram_2: ebram Port map ( 
		I_clk => cEng_clk_core,
		I_cs => MEM_CS_ERAM_2,
      I_we => MEM_WE,
	   I_addr => MEM_2KB_ADDR,
	   I_data => MEM_O_data,
		I_size => MEM_REQ_SIZE,
	   O_data => MEM_DATA_OUT_ERAM_2
	);
	
	ebram_3: ebram Port map ( 
		I_clk => cEng_clk_core,
		I_cs => MEM_CS_ERAM_3,
      I_we => MEM_WE,
	   I_addr => MEM_2KB_ADDR,
	   I_data => MEM_O_data,
		I_size => MEM_REQ_SIZE,
	   O_data => MEM_DATA_OUT_ERAM_3
	);
	
	ebram_4: ebram Port map ( 
		I_clk => cEng_clk_core,
		I_cs => MEM_CS_ERAM_4,
      I_we => MEM_WE,
	   I_addr => MEM_2KB_ADDR,
	   I_data => MEM_O_data,
		I_size => MEM_REQ_SIZE,
	   O_data => MEM_DATA_OUT_ERAM_4
	);
	
		  
	ebram_5: ebram Port map ( 
		I_clk => cEng_clk_core,
		I_cs => MEM_CS_ERAM_5,
      I_we => MEM_WE,
	   I_addr => MEM_2KB_ADDR,
	   I_data => MEM_O_data,
		I_size => MEM_REQ_SIZE,
	   O_data => MEM_DATA_OUT_ERAM_5
	);
	
	ebram_6: ebram Port map ( 
		I_clk => cEng_clk_core,
		I_cs => MEM_CS_ERAM_6,
      I_we => MEM_WE,
	   I_addr => MEM_2KB_ADDR,
	   I_data => MEM_O_data,
		I_size => MEM_REQ_SIZE,
	   O_data => MEM_DATA_OUT_ERAM_6
	);
	
	ebram_7: ebram Port map ( 
		I_clk => cEng_clk_core,
		I_cs => MEM_CS_ERAM_7,
      I_we => MEM_WE,
	   I_addr => MEM_2KB_ADDR,
	   I_data => MEM_O_data,
		I_size => MEM_REQ_SIZE,
	   O_data => MEM_DATA_OUT_ERAM_7
	);
	
	ebram_8: ebram Port map ( 
		I_clk => cEng_clk_core,
		I_cs => MEM_CS_ERAM_8,
      I_we => MEM_WE,
	   I_addr => MEM_2KB_ADDR,
	   I_data => MEM_O_data,
		I_size => MEM_REQ_SIZE,
	   O_data => MEM_DATA_OUT_ERAM_8
	);

	audio_counter: process(cEng_clk_50)
	begin
		if rising_edge(cEng_clk_50) then
		   if SYS_COUNTER > (50000)/2 then 
				SYS_COUNTER <= 0;
				SYS_AUDIO <= not SYS_AUDIO;
			else
				SYS_COUNTER <= SYS_COUNTER + 1;
			end if;
		end if;
	end process;

	O_AUDIO2 <= SYS_AUDIO and SYS_AUDIO_REGISTER(0);
	O_AUDIO1 <= SYS_AUDIO and SYS_AUDIO_REGISTER(1);
				
	
	--50MHz => ~9600baud
	baud_rate: process(cEng_clk_50)
	begin
		if cEng_clk_50'event and cEng_clk_50 = '1' then
			if baud_count = 325 then
				baud_count <= 0;
				en_16_x_baud <= '1';   
			else
				baud_count <= baud_count + 1;
				en_16_x_baud <= '0';
			end if;
		end if;
	end process baud_rate;
 
	MEM_REQ_SIZE <= '1' when MEM_O_byteEnable = "10" else '0';
				
	-- select the correct data to send to tpu
	MEM_I_data <= INT_DATA when O_int_ack = '1' 	
	              else  MEM_DATA_OUT_ERAM_1 when MEM_CS_ERAM_1 = '1' 
	              else  MEM_DATA_OUT_ERAM_2 when MEM_CS_ERAM_2 = '1' 
	              else  MEM_DATA_OUT_ERAM_3 when MEM_CS_ERAM_3 = '1' 
	              else  MEM_DATA_OUT_ERAM_4 when MEM_CS_ERAM_4 = '1' 
	              else  MEM_DATA_OUT_ERAM_5 when MEM_CS_ERAM_5 = '1' 
	              else  MEM_DATA_OUT_ERAM_6 when MEM_CS_ERAM_6 = '1' 
	              else  MEM_DATA_OUT_ERAM_7 when MEM_CS_ERAM_7 = '1' 
	              else  MEM_DATA_OUT_ERAM_8 when MEM_CS_ERAM_8 = '1'
					  
	              else  MEM_DATA_OUT_FRAM_1 when MEM_CS_FRAM_1 = '1' 
	              else  MEM_DATA_OUT_FRAM_2 when MEM_CS_FRAM_2 = '1'
					  
	              else  MEM_DATA_OUT_TRAM_1 when MEM_CS_TRAM_1 = '1' 
	              else  MEM_DATA_OUT_TRAM_2 when MEM_CS_TRAM_2 = '1'
					  
	              else  MEM_DATA_OUT_VRAM_1 when MEM_CS_VRAM_1 = '1' 
				     else IO_DATA ;
	
				
   MEM_WE <= MEM_O_cmd and MEM_O_we;
	
	-- mem brams banks are 2KB. to address inside we need to and with 0x07ff
	MEM_2KB_ADDR <= MEM_O_addr and X"07FF";
	MEM_BANK_ID <= MEM_O_addr(15 downto 11);
	
	-- Embedded ram
	MEM_CS_ERAM_1 <= '1' when (MEM_BANK_ID = X"0"&'0') else '0'; -- 0x00 bank
	MEM_CS_ERAM_2 <= '1' when (MEM_BANK_ID = X"0"&'1') else '0'; -- 0x08 bank
	MEM_CS_ERAM_3 <= '1' when (MEM_BANK_ID = X"1"&'0') else '0'; -- 0x10 bank
	MEM_CS_ERAM_4 <= '1' when (MEM_BANK_ID = X"1"&'1') else '0'; -- 0x18 bank
	MEM_CS_ERAM_5 <= '1' when (MEM_BANK_ID = X"2"&'0') else '0'; -- 0x20 bank
	MEM_CS_ERAM_6 <= '1' when (MEM_BANK_ID = X"2"&'1') else '0'; -- 0x28 bank
	MEM_CS_ERAM_7 <= '1' when (MEM_BANK_ID = X"3"&'0') else '0'; -- 0x30 bank
	MEM_CS_ERAM_8 <= '1' when (MEM_BANK_ID = X"3"&'1') else '0'; -- 0x38 bank
	
	MEM_CS_SYSTEM <= '1' when (MEM_BANK_ID = X"9"&'0') else '0'; -- 0x90 bank - system maps
	-- 4KB of font bitmap ram
	MEM_CS_FRAM_1 <= '1' when (MEM_BANK_ID = X"A"&'0') else '0'; -- 0xA0 bank
	MEM_CS_FRAM_2 <= '1' when (MEM_BANK_ID = X"A"&'1') else '0'; -- 0xA8 bank
	-- 4KB of text character ram
	MEM_CS_TRAM_1 <= '1' when (MEM_BANK_ID = X"B"&'0') else '0'; -- 0xB0 bank
	MEM_CS_TRAM_2 <= '1' when (MEM_BANK_ID = X"B"&'1') else '0'; -- 0xB8 bank
	
	-- 16KB of video ram 
	MEM_CS_VRAM_1 <= '1' when (MEM_BANK_ID = X"C"&'0') else '0'; -- 0xC0 bank
	MEM_CS_VRAM_2 <= '1' when (MEM_BANK_ID = X"C"&'1') else '0'; -- 0xC8 bank
	MEM_CS_VRAM_3 <= '1' when (MEM_BANK_ID = X"D"&'0') else '0'; -- 0xD0 bank
	MEM_CS_VRAM_4 <= '1' when (MEM_BANK_ID = X"D"&'1') else '0'; -- 0xD8 bank
	MEM_CS_VRAM_5 <= '1' when (MEM_BANK_ID = X"E"&'0') else '0'; -- 0xE0 bank
	MEM_CS_VRAM_6 <= '1' when (MEM_BANK_ID = X"E"&'1') else '0'; -- 0xE8 bank
	MEM_CS_VRAM_7 <= '1' when (MEM_BANK_ID = X"F"&'0') else '0'; -- 0xF0 bank
	MEM_CS_VRAM_8 <= '1' when (MEM_BANK_ID = X"F"&'1') else '0'; -- 0xF8 bank
	
	-- if any CS line is active, this is 1
	MEM_ANY_CS <= MEM_CS_ERAM_1 or MEM_CS_ERAM_2 or MEM_CS_ERAM_3 or MEM_CS_ERAM_4 or
	              MEM_CS_ERAM_5 or MEM_CS_ERAM_6 or MEM_CS_ERAM_7 or MEM_CS_ERAM_8 or
	              MEM_CS_FRAM_1 or MEM_CS_FRAM_2 or MEM_CS_TRAM_1 or MEM_CS_TRAM_2 or
	              MEM_CS_VRAM_1 or MEM_CS_VRAM_2 or MEM_CS_VRAM_3 or MEM_CS_VRAM_4 or
	              MEM_CS_VRAM_5 or MEM_CS_VRAM_6 or MEM_CS_VRAM_7 or MEM_CS_VRAM_8 or
					  MEM_CS_SYSTEM;
					  
	
	
	
	--MEM_VRAM_ADDR <= X"0" & MEM_O_addr(11 downto 0);
	
   -- exception line handling:
	exception_notifier: process (cEng_clk_core, MEM_Access_error)
	begin
		if rising_edge(cEng_clk_core) then
			if MEM_Access_error = '1' and MEM_access_int_state = 0 then
				I_int <= '1';
				MEM_access_int_state <= 1;
				INT_DATA <= X"80"  & MEM_Access_error_bank;
			elsif MEM_access_int_state = 1 and I_int = '1' and O_int_ack = '1' then
				I_int <= '0';
				MEM_access_int_state <= 2; 
			elsif MEM_access_int_state = 2 then
				MEM_access_int_state <= 3; 
			elsif MEM_access_int_state = 3 then
				MEM_access_int_state <= 0;
			end if;
		end if;
		
	end process;
	
	MEM_proc: process(cEng_clk_core)
	begin
		if rising_edge(cEng_clk_core) then
		
			if MEM_readyState = 0 then
				if MEM_O_cmd = '1' then
					
					if MEM_ANY_CS = '0' then
						-- a memory command with unmapped memory
						-- throw interrupt
						MEM_Access_error <= '1';
						MEM_Access_error_bank <= MEM_O_addr(15 downto 8);
					end if;
				
					-- system memory maps
					if MEM_O_addr = X"9000" and MEM_O_we = '1' then
						-- onboard leds
						IO_LEDS <= MEM_O_data( 7 downto 0);
					end if;
					
					if MEM_O_addr = X"9001" and MEM_O_we = '0' then
						-- onboard switches
						IO_DATA <= X"000" & IO_SWITCH;
					end if;
					
					-- Memory mapped audio config register
					if MEM_O_addr = X"9500" and MEM_O_we = '1' then
						SYS_AUDIO_REGISTER <= MEM_O_data( 15 downto 0);
					end if;
					
					if MEM_O_addr = X"9500" and MEM_O_we = '0' then
						IO_DATA <= SYS_AUDIO_REGISTER;
					end if;
					
		--tx
		--uart_tx_data_in,                              --0x9200
		--buffer_write => write_to_uart_tx,             --0x9201  nop
		--buffer_data_present => uart_tx_data_present,  --0x9202
		--buffer_half_full => uart_tx_half_full,        --0x9203
		--buffer_full => uart_tx_full,                  --0x9204
		--buffer_reset => uart_tx_reset,                --0x9205
		--rx
		--data_out => uart_rx_data_out,                 --0x9206
		--buffer_read => uart_rx_read,                  --0x9207 nop
		--buffer_data_present => uart_rx_data_present,  --0x9208
 		--buffer_half_full => uart_rx_half_full,        --0x9209
		--buffer_full => uart_rx_full,                  --0x920a
		--buffer_reset => uart_rx_reset,                --0x920b
		
					case MEM_O_addr is
						when X"9200" =>
							if MEM_O_we = '1' then
								uart_tx_data_in <= MEM_O_data(7 downto 0);
								write_to_uart_tx <= '1';
							end if;
						when X"9201" =>
							if MEM_O_we = '1' then
						      -- NOP
							end if;
						when X"9202" =>
							if MEM_O_we = '0' then
								IO_DATA <= X"000" & "000" & uart_tx_data_present;
							end if;
						when X"9203" =>
							if MEM_O_we = '0' then
								IO_DATA <= X"000" & "000" & uart_tx_half_full;
							end if;
						when X"9204" =>
							if MEM_O_we = '0' then
								IO_DATA <= X"000" & "000" & uart_tx_full;
							end if;
						when X"9205" =>
							if MEM_O_we = '1' then
								uart_tx_reset <= MEM_O_data(0);
							end if;
							
						--rx2
						when X"9206" =>  
							if MEM_O_we = '0' then 
								IO_DATA <= X"00" & uart_rx_data_out;
								uart_rx_read <= '1';
								-- The 'real' read into IO_DATA is performed a cycle later
								-- Check readystate > 0 block below.
							end if;
						when X"9208" =>  
							if MEM_O_we = '0' then 
								IO_DATA <= X"000" & "000" & uart_rx_data_present;
							end if;
						when X"9209" =>  
							if MEM_O_we = '0' then 
								IO_DATA <= X"000" & "000" & uart_rx_half_full;
							end if;
						when X"920a" =>  
							if MEM_O_we = '0' then 
								IO_DATA <= X"000" & "000" & uart_rx_full;
							end if;
						when X"920b" =>  
							if MEM_O_we = '1' then 
								uart_rx_reset <= MEM_O_data(0);
							end if;

						when others =>
					end case;
					
					MEM_I_ready <= '0';
					MEM_I_dataReady  <= '0';
					if MEM_O_we = '1' then
						MEM_readyState <= 7;
					else
						MEM_readyState <= 4;
					end if;
				end if;
			elsif MEM_readyState >= 1 then
				-- reset any strobes
				write_to_uart_tx <= '0';
				if uart_rx_read = '1' then
					uart_rx_read <= '0';
					IO_DATA <= X"00" & uart_rx_data_out;
				end if;
				
				if MEM_readyState = 6 then
					MEM_I_ready <= '1';
					MEM_I_dataReady <= '1';
					MEM_Access_error <= '0';
					MEM_readyState <= 0;
				elsif MEM_readyState = 8 then
					MEM_I_ready <= '0';
					MEM_I_dataReady  <= '0';
					MEM_readyState <= 9;
				elsif MEM_readyState = 9 then
					MEM_I_ready <= '1';
					MEM_Access_error <= '0';
					MEM_readyState <= 0;
				else
					MEM_readyState <= MEM_readyState + 1;
				end if;
			end if;
		
		end if;
	
	end process;


--	fram_1: ebram2port Port map (
--		I_clk => cEng_clk_core,
--		I_cs => MEM_CS_FRAM_1,
--		I_we => MEM_WE,
--		I_addr => MEM_2KB_ADDR,
--		I_data => MEM_O_data,
--		I_size => MEM_REQ_SIZE,
--		O_data => MEM_DATA_OUT_FRAM_1,
--
--	   I_p2_clk => cEng_clk_5xpixel,
--		I_p2_cs => video_enable,
--		I_p2_addr => SYS_FRAM1_ADDR,
--		O_p2_data => SYS_FRAM1_OUTDATA
--   );
--	
--	fram_2: ebram2port Port map (
--		I_clk => cEng_clk_core,
--		I_cs => MEM_CS_FRAM_2,
--		I_we => MEM_WE,
--		I_addr => MEM_2KB_ADDR,
--		I_data => MEM_O_data,
--		I_size => MEM_REQ_SIZE,
--		O_data => MEM_DATA_OUT_FRAM_2,
--
--	   I_p2_clk => cEng_clk_5xpixel,
--		I_p2_cs => video_enable,
--		I_p2_addr => SYS_FRAM2_ADDR,
--		O_p2_data => SYS_FRAM2_OUTDATA
--   );

-- at the moment I'm using an external font rom and the above frams
-- are not connected This will change in the future.
   fram_test: font_rom port map(
      clk => cEng_clk_fmem,
      addr => FRAM_ADDR_TEST,
      data => FRAM_DATA_TEST
   );

   ---------------- TEXT MODE RAM

	tram_1: ebram2port Port map (
		I_clk => cEng_clk_core,
		I_cs => MEM_CS_TRAM_1,
		I_we => MEM_WE,
		I_addr => MEM_2KB_ADDR,
		I_data => MEM_O_data,
		I_size => MEM_REQ_SIZE,
		O_data => MEM_DATA_OUT_TRAM_1,

	   I_p2_clk => cEng_clk_fmem,
		I_p2_cs => video_enable,
		I_p2_addr => SYS_TRAM_2K_ADDR,
		O_p2_data => SYS_TRAM1_OUTDATA
   );
	
	tram_2: ebram2port Port map (
		I_clk => cEng_clk_core,
		I_cs => MEM_CS_TRAM_2,
		I_we => MEM_WE,
		I_addr => MEM_2KB_ADDR,
		I_data => MEM_O_data,
		I_size => MEM_REQ_SIZE,
		O_data => MEM_DATA_OUT_TRAM_2,

	   I_p2_clk => cEng_clk_fmem,
		I_p2_cs => video_enable,
		I_p2_addr => SYS_TRAM_2K_ADDR,
		O_p2_data => SYS_TRAM2_OUTDATA
   );

	SYS_TRAM_2K_ADDR <= TRAM_ADDR AND X"07FF";
	
	TRAM_DATA <= SYS_TRAM1_OUTDATA when (TRAM_ADDR(15 downto 11) = X"0"& '0') else
	             SYS_TRAM2_OUTDATA when (TRAM_ADDR(15 downto 11) = X"0"& '1');
	
	---------------- VIDEO SYSTEM BELOW
	

	vram_1: ebram2port Port map (
		I_clk => cEng_clk_core,
		I_cs => MEM_CS_VRAM_1,
		I_we => MEM_WE,
		I_addr => MEM_2KB_ADDR,
		I_data => MEM_O_data,
		I_size => MEM_REQ_SIZE,
		O_data => MEM_DATA_OUT_VRAM_1,

	   I_p2_clk => cEng_clk_5xpixel,
		I_p2_cs => video_enable,
		I_p2_addr => vram_addr,
		O_p2_data => vram_output_2
   );
	
	-- This generates clocks, controls and offsets required for a fixed resolution
	Inst_vga_gen: vga_gen PORT MAP( 
      pixel_clock     	=> cEng_clk_pixel,    
 
		pixel_h	=> pixel_h,
		pixel_v	=> pixel_v,
		
		
		pixel_h_pref 	=> pixel_h_pref ,
		pixel_v_pref 	=> pixel_v_pref ,     
		blank_pref    => blank_pref,
		
      blank    => blank,
      hsync    => hsync,
      vsync    => vsync
   );

   FRAM_ADDR_TEST <= FRAM_ADDR(11 downto 0);
   FRAM_DATA <= X"00" & FRAM_DATA_TEST;

	text_generator_engine: text_gen PORT MAP (
		I_clk_pixel => cEng_clk_pixel,
		I_clk_pixel10x => cEng_clk_fmem,
 
		I_blank => blank_pref,
		I_x => pixel_h_pref ,
		I_y => pixel_v_pref ,
 
		O_FRAM_ADDR => FRAM_ADDR,
		I_FRAM_DATA => FRAM_DATA,
 
		O_TRAM_ADDR => TRAM_ADDR,
		I_TRAM_DATA => TRAM_DATA,
 
		O_R => TXT_R,
		O_G => TXT_G, 
		O_B => TXT_B
	);
	
 
	-- generate the vram scan address, forcing reads at 2 byte boundaries
   vram_addr <= X"0" & "000" & pixel_v(8 downto 5) & pixel_h(8 downto 5) & '0';
	
	-- Only show 512x512 of the display with our expanded virtual pixels
	vram_data <= vram_output_2 when ((pixel_h(11 downto 9) = "000") and (pixel_v(11 downto 9) = "000"))
						else X"0000"	 ;
	
 
	
	red_ram_p <= X"FF" when unsigned(pixel_h) < 0 else TXT_R;
	green_ram_p <= X"FF" when( unsigned(pixel_h) < 0 and unsigned(pixel_h) > 8) else  TXT_G;
	blue_ram_p <= X"FF" when (unsigned(pixel_h) < 0 and unsigned(pixel_h) > 16) else  TXT_B;
	
--	red_ram_p(7) <= vram_data(15);
--	red_ram_p(6) <= vram_data(14);
--	red_ram_p(5) <= vram_data(13);
--	red_ram_p(4) <= vram_data(13);
--	red_ram_p(3) <= vram_data(12);
--	red_ram_p(2) <= vram_data(12);
--	red_ram_p(1) <= vram_data(11);
--	red_ram_p(0) <= vram_data(11);
--	
-- green_ram_p(7) <= vram_data(10);
--	green_ram_p(6) <= vram_data(9);
--	green_ram_p(5) <= vram_data(8);
--	green_ram_p(4) <= vram_data(7);
--	green_ram_p(3) <= vram_data(6);
--	green_ram_p(2) <= vram_data(6);
--	green_ram_p(1) <= vram_data(5);
--	green_ram_p(0) <= vram_data(5);
--	
--	blue_ram_p(7) <= vram_data(4);
--	blue_ram_p(6) <= vram_data(3);
--	blue_ram_p(5) <= vram_data(2);
--	blue_ram_p(4) <= vram_data(2);
--	blue_ram_p(3) <= vram_data(1);
--	blue_ram_p(2) <= vram_data(1);
--	blue_ram_p(1) <= vram_data(0);
--	blue_ram_p(0) <= vram_data(0);
	
	-- this generates the dvi tmds signalling, depening on the inputs for pixels
	-- and sync/blank controls. Input signal neds to be well formed.
	-- clk and clk_n should be 5x pixel, with clkn at 180 degrees phase
	dvid_1: dvid PORT MAP(
      clk       => cEng_clk_5xpixel,
      clk_n     => cEng_clk_5xpixel_inv, 
      clk_pixel  => cEng_clk_pixel,
		
      red_p      => red_ram_p,
      green_p    => green_ram_p,
      blue_p     => blue_ram_p,
		
      blank      => blank,
      hsync      => hsync,
      vsync      => vsync,
		
      -- outputs to TMDS drivers
      red_s      => red_s,
      green_s    => green_s,
      blue_s     => blue_s,
      clock_s    => clock_s
   );
	
   
	OBUFDS_blue  : OBUFDS port map ( O  => hdmi_out_p(0), OB => hdmi_out_n(0), I  => blue_s );
	OBUFDS_green   : OBUFDS port map ( O  => hdmi_out_p(1), OB => hdmi_out_n(1), I  => green_s );
	OBUFDS_red : OBUFDS port map ( O  => hdmi_out_p(2), OB => hdmi_out_n(2), I  => red_s );
	OBUFDS_clock : OBUFDS port map ( O  => hdmi_out_p(3), OB => hdmi_out_n(3), I  => clock_s );

end Behavioral;

