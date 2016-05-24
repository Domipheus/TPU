LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

entity ebram2port is
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
end ebram2port;

architecture Behavioral of ebram2port is

	
		-- Port A Data: 32-bit (each) output: Port A data
      signal DOA : std_logic_vector( 31 downto 0) := (others => '0');       -- 32-bit output: A port data output
      signal DOPA : std_logic_vector( 3 downto 0);      	-- 4-bit output: A port parity output
      -- Port A Address/Control Signals: 14-bit (each) input: Port A address and control signals
      signal ADDRA  : std_logic_vector( 13 downto 0);    -- 14-bit input: A port address input
      signal CLKA  : std_logic:= '1';        				-- 1-bit input: A port clock input
      signal ENA : std_logic:= '1';          				-- 1-bit input: A port enable input
      signal REGCEA : std_logic:= '0';     					-- 1-bit input: A port register clock enable input
      signal RSTA : std_logic:= '0';     						-- 1-bit input: A port register set/reset input
      signal WEA : std_logic_vector( 3 downto 0) := "0000";        -- 4-bit input: Port A byte-wide write enable input
      -- Port A Data: 32-bit (each) input: Port A data
      signal DIA : std_logic_vector( 31 downto 0);       -- 32-bit input: A port data input
      signal DIPA  : std_logic_vector( 3 downto 0);      -- 4-bit input: A port parity input
	
		-- Port B Data: 32-bit (each) output: Port B data
      signal DOB : std_logic_vector( 31 downto 0);       -- 32-bit output: B port data output
      signal DOPB : std_logic_vector( 3 downto 0);      	-- 4-bit output: B port parity output
      -- Port B Address/Control Signals: 14-bit (each) input: Port B address and control signals
      signal ADDRB  : std_logic_vector( 13 downto 0);    -- 14-bit input: B port address input
      signal CLKB  : std_logic:= '1';        				-- 1-bit input: B port clock input
      signal ENB : std_logic:= '1';          				-- 1-bit input: B port enable input
      signal REGCEB : std_logic:= '0';     					-- 1-bit input: B port register clock enable input
      signal RSTB : std_logic:= '0';     						-- 1-bit input: B port register set/reset input
      signal WEB : std_logic_vector( 3 downto 0) := "0000";        -- 4-bit input: Port B byte-wide write enable input
      -- Port B Data: 32-bit (each) input: Port B data
      signal DIB : std_logic_vector( 31 downto 0);       -- 32-bit input: B port data input
      signal DIPB  : std_logic_vector( 3 downto 0);      -- 4-bit input: B port parity input

	signal data: std_logic_vector(15 downto 0) := X"0000";
	signal int_addr: integer := 0;
	
	signal data_p2: std_logic_vector(15 downto 0) := X"0000";
	
begin
-- RAMB16BWER: 16k-bit Data and 2k-bit Parity Configurable Synchronous Dual Port Block RAM with Optional Output Registers
   --             Spartan-6
   -- Xilinx HDL Language Template, version 14.4

   RAMB16BWER_inst : RAMB16BWER
   generic map (
      -- DATA_WIDTH_A/DATA_WIDTH_B: 0, 1, 2, 4, 9, 18, or 36
      DATA_WIDTH_A => 18,
      DATA_WIDTH_B => 18,
      -- DOA_REG/DOB_REG: Optional output register (0 or 1)
      DOA_REG => 0,
      DOB_REG => 0,
      -- EN_RSTRAM_A/EN_RSTRAM_B: Enable/disable RST
      EN_RSTRAM_A => TRUE,
      EN_RSTRAM_B => TRUE,
      -- INITP_00 to INITP_07: Initial memory contents.
      INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
      -- INIT_00 to INIT_3F: Initial memory contents.

-- 565
-- R F800
-- G 07e0
-- B 001F

-- BEGIN TASM RAMB16BWER INIT OUTPUT  
INIT_00 => X"020f010f00000000000000000000000000000000000000000000000000000000",
INIT_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_04 => X"0000000000000000000000000000000000000000000000000000000000000000",

INIT_05 => X"040f030f00000000000000000000000000000000000000000000000000000000",
INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_09 => X"0000000000000000000000000000000000000000000000000000000000000000",

INIT_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_0F => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_10 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_11 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_12 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_13 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_14 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_15 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_16 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_17 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_18 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_19 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_1A => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_1B => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_1C => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_36 => X"002f002f002f002f002f002f002f002f002f002f002f002f002f002f002f002f",
INIT_37 => X"002f002f002f002f002f002f002f002f002f002f002f002f002f002f002f002f",
INIT_38 => X"002f002f002f002f002f002f002f002f002f002f002f002f002f002f002f002f",
INIT_39 => X"002f002f002f002f002f002f002f002f002f002f002f002f002f002f002f002f",
INIT_3A => X"002f002f002f002f002f002f002f002f002f002f002f002f002f002f002f002f",
INIT_3B => X"002f002f002f002f002f002f002f002f002f002f002f002f002f002f002f002f",
INIT_3C => X"002f002f002f002f002f002f002f002f002f002f002f002f002f002f002f002f",
INIT_3D => X"002f002f002f002f002f002f002f002f002f002f002f002f002f002f002f002f",
INIT_3E => X"002f002f002f002f002f002f002f002f002f002f002f002f002f002f002f002f",
INIT_3F => X"002f002f002f002f002f002f002f002f002f002f002f002f002f002f002f002f",
-- END TASM RAMB16BWER INIT OUTPUT




      -- INIT_A/INIT_B: Initial values on output port
      INIT_A => X"000000000",
      INIT_B => X"000000000",
      -- INIT_FILE: Optional file used to specify initial RAM contents
      INIT_FILE => "NONE",
      -- RSTTYPE: "SYNC" or "ASYNC" 
      RSTTYPE => "SYNC",
      -- RST_PRIORITY_A/RST_PRIORITY_B: "CE" or "SR" 
      RST_PRIORITY_A => "CE",
      RST_PRIORITY_B => "CE",
      -- SIM_COLLISION_CHECK: Collision check enable "ALL", "WARNING_ONLY", "GENERATE_X_ONLY" or "NONE" 
      SIM_COLLISION_CHECK => "ALL",
      -- SIM_DEVICE: Must be set to "SPARTAN6" for proper simulation behavior
      SIM_DEVICE => "SPARTAN6",
      -- SRVAL_A/SRVAL_B: Set/Reset value for RAM output
      SRVAL_A => X"af0000000",
      SRVAL_B => X"bf0000000",
      -- WRITE_MODE_A/WRITE_MODE_B: "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE" 
      WRITE_MODE_A => "WRITE_FIRST",
      WRITE_MODE_B => "WRITE_FIRST" 
   )
   port map (
      -- Port A Data: 32-bit (each) output: Port A data
      DOA => DOA,       -- 32-bit output: A port data output
      DOPA => DOPA,     -- 4-bit output: A port parity output
      -- Port B Data: 32-bit (each) output: Port B data
      DOB => DOB,       -- 32-bit output: B port data output
      DOPB => DOPB,     -- 4-bit output: B port parity output
      -- Port A Address/Control Signals: 14-bit (each) input: Port A address and control signals
      ADDRA => ADDRA,   -- 14-bit input: A port address input
      CLKA => CLKA,     -- 1-bit input: A port clock input
      ENA => ENA,       -- 1-bit input: A port enable input
      REGCEA => REGCEA, -- 1-bit input: A port register clock enable input
      RSTA => RSTA,     -- 1-bit input: A port register set/reset input
      WEA => WEA,       -- 4-bit input: Port A byte-wide write enable input
      -- Port A Data: 32-bit (each) input: Port A data
      DIA => DIA,       -- 32-bit input: A port data input
      DIPA => DIPA,     -- 4-bit input: A port parity input
      -- Port B Address/Control Signals: 14-bit (each) input: Port B address and control signals
      ADDRB => ADDRB,   -- 14-bit input: B port address input
      CLKB => CLKB,     -- 1-bit input: B port clock input
      ENB => ENB,       -- 1-bit input: B port enable input
      REGCEB => REGCEB, -- 1-bit input: B port register clock enable input
      RSTB => RSTB,     -- 1-bit input: B port register set/reset input
      WEB => WEB,       -- 4-bit input: Port B byte-wide write enable input
      -- Port B Data: 32-bit (each) input: Port B data
      DIB => DIB,       -- 32-bit input: B port data input
      DIPB => DIPB      -- 4-bit input: B port parity input
   );
	
   -- End of RAMB16BWER_inst instantiation
	
	
	--
	--todo: assertion on non-aligned 16b read?
	--
	
	CLKA <= I_clk;
	CLKB <= I_p2_clk;
	
	ENA <= I_cs;
	ENB <= I_p2_cs;
	
	ADDRA <= I_addr(10 downto 1) & "0000";
	ADDRB <= I_p2_addr(10 downto 1) & "0000";
	
	WEB <= "0000";
				
	process (I_clk, I_cs)
	begin
		if rising_edge(I_clk) and I_cs = '1' then
			if (I_we = '1') then
				if I_size = '1' then
					-- 1 byte
					if I_addr(0) = '1' then
						WEA <= "0010";
						DIA <= X"0000" & I_data(7 downto 0) & X"00";
					else
						WEA <= "0001";
						DIA <= X"000000" & I_data(7 downto 0);
					end if;
				else
					WEA <= "0011";
					DIA <= X"0000" & I_data(7 downto 0)& I_data(15 downto 8);
				end if;
			else
				WEA <= "0000";
				if I_size = '1' then
					if I_addr(0) = '0' then
						data(15 downto 8) <= X"00";
						data(7 downto 0)  <= DOA(7 downto 0);
					else
						data(15 downto 8) <= X"00";
						data(7 downto 0)  <= DOA(15 downto 8);
					end if;
				else
					data(15 downto 8) <= DOA(7 downto 0);
					data(7 downto 0) <= DOA(15 downto 8);
				end if;
			end if;
		end if;
		
		
	end process;
	
	process (I_p2_clk, I_p2_cs)
	begin			
		-- read port b
		if rising_edge(I_p2_clk) and I_p2_cs = '1' then
			data_p2(15 downto 8) <=  DOB(7 downto 0);
			data_p2(7 downto 0) <= DOB(15 downto 8);
		end if;
	end process;
	
	O_data <= data when I_cs = '1' else "ZZZZZZZZZZZZZZZZ";
   O_p2_data <= data_p2 when I_p2_cs = '1' else "ZZZZZZZZZZZZZZZZ";

end Behavioral;