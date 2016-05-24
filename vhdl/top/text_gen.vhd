----------------------------------------------------------------------------------
-- Company: Domipheus Labs
-- Engineer: Colin Riley
-- 
-- Create Date:    16:27:52 05/01/2016 
-- Design Name:    Text-mode output generator
-- Module Name:    text_gen - Behavioral 
-- Project Name:   
-- Target Devices: Tested on Spartan6
-- Tool versions: 
-- Description: 
--
--   For a 640x480 resolution set of input pixel locations an 80x25 text-mode 
--   representation is generated. It is assumed the x direction pixels are
--   scanned linearly.
--
--   Glyphs are stored in a font ram as 16 bytes, each bit selecting a foreground
--   or background colour to display for a given pizel in an 8x16 glyph.
--
--   A clock faster than the pixel clock is needed to account for latency from 
--   worse-case two dependant memory reads per pixel. It is adviced that pixel 
--   locations are inputted early to the text_gen so data can be prefetched.
--   
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

entity text_gen is
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
end text_gen;

architecture Behavioral of text_gen is
   -- state tracks the location in our state machine
	signal state: integer := 0;
	
	-- The blinking speed of characters is controlled by loctions 
	-- in this counter
	signal blinker_count: unsigned(31 downto 0) := X"00000000";
	
	-- _us is the result of the address computation,
	-- whereas the logic_vector is the latched output to memory
	signal fram_addr_us: unsigned(15 downto 0):= X"0000";
	signal fram_addr: std_logic_vector( 15 downto 0) := X"0000";
	signal fram_data_latched: std_logic_vector(15 downto 0);
	
	-- Font ram addresses for glyphs above, text ram for ascii and
	-- attributes below.
	signal tram_addr_us: unsigned(15 downto 0):= X"0000";
	signal tram_addr: std_logic_vector( 15 downto 0) := X"0000";
	signal tram_data_latched: std_logic_vector(15 downto 0);
	
	-- the latched current_x value we are computing
	signal current_x: std_logic_vector( 11 downto 0) := X"FFF";
	
	-- Current fg and bg colours
	signal colour_fg: std_logic_vector(23 downto 0) := X"FFFFFF"; 
	signal colour_bg: std_logic_vector(23 downto 0) := X"FFFFFF"; 
	signal blink: std_logic := '1';
	
	-- outputs for our pixel colour
	signal r: std_logic_vector(7 downto 0) := X"00";
	signal g: std_logic_vector(7 downto 0) := X"00";
	signal b: std_logic_vector(7 downto 0) := X"00";
	
	type colour_rom_t is array (0 to 15) of std_logic_vector(23 downto 0);
   -- ROM definition
   constant colours: colour_rom_t:=(  
   X"000000", -- 0 Black
   X"0000AA", -- 1 Blue
   X"00AA00", -- 2 Green
   X"00AAAA", -- 3 Cyan
   X"AA0000", -- 4 Red
   X"AA00AA", -- 5 Magenta
   X"AA5500", -- 6 Brown
   X"AAAAAA", -- 7 Light Gray
   X"555555", -- 8 Dark Gray
   X"5555FF", -- 9 Light Blue
   X"55FF55", -- a Light Green
   X"55FFFF", -- b Light Cyan
   X"FF5555", -- c Light Red
   X"FF55FF", -- d Light Magenta
   X"FFFF00", -- e Yellow
   X"FFFFFF"  -- f White
	);
	
begin


   tram_addr <= std_logic_vector(tram_addr_us);
	O_TRAM_ADDR <= tram_addr(14 downto 0) & '0';
	
	
   fram_addr <= std_logic_vector(fram_addr_us);
	O_FRAM_ADDR <= fram_addr(15 downto 0);
	
	process(I_clk_pixel)
   begin
      if rising_edge(I_clk_pixel) then
			blinker_count <= blinker_count + 1;
		end if;
	end process;
					
	process(I_clk_pixel10x)
   begin
      if rising_edge(I_clk_pixel10x) then
		   if state < 8 then
			   -- each clock either stay in a state, or move to the next one
				state <= state + 1;
			end if;
		   
			if state = 3 then
			   -- latch the data from TRAM and kick off FRAM read
			   tram_data_latched <= I_TRAM_DATA;
				fram_addr_us <= (unsigned(tram_data_latched(7 downto 0)) * 16 ) + unsigned(I_y(3 downto 0));
            blink <= tram_data_latched(15);
            colour_fg <= colours( to_integer(unsigned( tram_data_latched(11 downto 8))));
            colour_bg <= colours( to_integer(unsigned( tram_data_latched(14 downto 12))));
				
			elsif state = 6 then	
			   -- latch the data from FRAM
				fram_data_latched <= I_FRAM_DATA;
				state <= 8;
			
			elsif current_x /= I_x then
				if (I_x(2 downto 0) = "000") then
				   
	            -- Each 8-byte pixel start, set the state and kick off TRAM fetch
					state <= 1;
					-- this multiply becomes a DSP slice
					tram_addr_us <= (unsigned( I_y(11 downto 4)) * 80) + unsigned(I_x(11 downto 3));
				else
				   -- short circuit straight to shade state
					state <= 7;
				end if;
				current_x <= I_x;
			
			elsif state >= 8 then
			   -- shade a pixel
				
				-- If the curret pixel should be foreground, and is not in a blink state, shade it foreground
				if (fram_data_latched(7 - to_integer(unsigned(I_x(2 downto 0)))) = '1')
               and (blinker_count(24) = '1' or (blink = '0')) then
				  
				  r <= colour_fg(23 downto 16); 
				  g <= colour_fg(15 downto 8);
				  b <= colour_fg(7 downto 0);
				else
				  r <= colour_bg(23 downto 16);
				  g <= colour_bg(15 downto 8);
				  b <= colour_bg(7 downto 0);
				end if;
			
			end if;
			
		end if;
	end process;
	
	-- When we are outside of our text area, have black pixels
	O_r <= r when unsigned(I_y) < 400 else X"00";
	O_g <= g when unsigned(I_y) < 400 else X"00";
	O_b <= b when unsigned(I_y) < 400 else X"00";

end Behavioral;

