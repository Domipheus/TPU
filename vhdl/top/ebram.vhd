LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

entity ebram is
    Port (I_clk : in  STD_LOGIC;
          I_cs : in STD_LOGIC;
          I_we : in  STD_LOGIC;
          I_addr : in  STD_LOGIC_VECTOR (15 downto 0);
          I_data : in  STD_LOGIC_VECTOR (15 downto 0);
          I_size : in STD_LOGIC;
          O_data : out  STD_LOGIC_VECTOR (15 downto 0));
end ebram;

architecture Behavioral of ebram is

	
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
		
-- BEGIN TASM RAMB16BWER INIT OUTPUT
INIT_00 => X"189C408D00E1F876F674F074EE72E872E670E070FD1E03E100C00420A6830080",
INIT_01 => X"D10C00ECE51EE666E464E262E060C06AC00C04A00183D42C748B008C15C1C4DD",
INIT_02 => X"0C7001874420A285008206C144D72494204280820BC1E670E070E50EA0C0F870",
INIT_03 => X"3C0402049004D003C203000001E102E1FD0EEC6CEA6AE868E666E464E262E060",
INIT_04 => X"000000000000000000000000000000B0000000000F0050050000000000000000",
INIT_05 => X"0F810EE020810EE010810AE00083098106E0028116E0E91E088E000000000000",
INIT_06 => X"0283098112E028200584B6830AE00183098106E0088112E028200584608306E0",
INIT_07 => X"0183028112E028200584D8830AE00083028106E00E8112E02820058492830AE0",
INIT_08 => X"A485008212E028200584E8830AE00483018106E00F8112E028200584E0830AE0",
INIT_09 => X"F51E0AE004830A8128709582038584DB2C982B868ADD2C982A86008500624420",
INIT_0A => X"DD0C00ECE8740085EA720A85E472230200624420A4850082E270442092850082",
INIT_0B => X"A485008212E028200584F28312E0282000849283F50E00C00420BC830480F870",
INIT_0C => X"44201C850182A4706CD7009600604C20A285008603E1206502E12302A062442A",
INIT_0D => X"06E00F810EE05F8106E08F8112E028200584AE830AE00683018106E0038100C0",
INIT_0E => X"0AE006830781A070282A0384BC8314C1A4D7B49A141B0D8B2AE092800EE02081",
INIT_0F => X"0F810AE008830181E7CF0EE05F8106E08F810EE0A060282A0384BC8306E00F81",
INIT_10 => X"648B15C1A4D7B49A141B6C8B0EE0A060282A0384BC8312E028200684028306E0",
INIT_11 => X"06840E8306E004810AE008830A8121C1A4D7B49A141B6D8B1BC1A4D7B49A141B",
INIT_12 => X"08830A81A4CF0470FF83908012E02820068418830AE008830A81AFCF12E02820",
INIT_13 => X"12E0282006842C830AE008830A8199CF04700083908012E02820068422830AE0",
INIT_14 => X"0F81047004834420BE850382047009834420C0850382047000834420A4850082",
INIT_15 => X"0082E270442092850082F51E0AE020624422C085038200604420BE85038206E0",
INIT_16 => X"F50E00C00420BC830480F870DD0C00ECE8740485EA721085E47200624420A485",
INIT_17 => X"0082E270442092850082F51E0EE02D8112E028200084928312E028200584FA83",
INIT_18 => X"BC830480F870DD0C00ECE8740485EA721085E4723802C31C088C00624420A485",
INIT_19 => X"00820EE020810EE03A8112E028200084928312E028200584FA83F50E00C00420",
INIT_1A => X"088C00604C20A285008603E1206502E14C7000874C24A2850086A062442AA485",
INIT_1B => X"0684368306E0028107C112E0282006843E8306E0048108C164D70096A4703802",
INIT_1C => X"09834420C085038284CF64D1289618850470230200624420C085038212E02820",
INIT_1D => X"0000000000C1F5CD74CF64DB2896328504703F023F0200624420BE8503820470",
INIT_1E => X"F870DD0C00ECEC72EA70ED1E5087E464C0C0E06C2C7028228A850082E2660000",
INIT_1F => X"E06C20702822908500820400B08204A001830400E262ED0E00C004205E830480",
INIT_20 => X"F870DD0C00ECE670E91EE070E51EA0C0B82A388D048A4AD724940063E260C0C0",
INIT_21 => X"BF84B082C0C0E06CA0C0B82A048D048A0300E50EE060E90E00C0042090830480",
INIT_22 => X"E462C0C0E06C2C70B086282290850082FCCF2502307068DB28960F894C24BF87",
INIT_23 => X"0ED706E066D740960081E464E262C0C0E06CFCCF43140400A8D3489A0081E264",
INIT_24 => X"B086A4DD109AC0882066282290850082C0C0E06C76D3FF86281203006ADD2896",
INIT_25 => X"E460E26AC0C0E06C2C70282290850082650668716571E262216528228A850082",
INIT_26 => X"E06AED0E00C0042072830480F870DD0C00ECE872E270ED1EF470E51EE664E664",
INIT_27 => X"B01CE26860C07026C28904866AD30096A30AAC7180672C0870263E890586E50E",
INIT_28 => X"05826ADD9496E268A31AAC710087F6CFA30AA47130836ADD649701837817E866",
INIT_29 => X"3130C0C0E06C40C044241A850582A31A8308A4718871A065806340C044243A85",
INIT_2A => X"C0C0E06C46617CD36C964867E264018300004645444342413938373635343332",
INIT_2B => X"2020312E30206E6F697372655620534F4942202B366E617472617053696E696D",
INIT_2C => X"6F642E7362616C2F2F3A70747468202D000020352E312041534920555043202D",
INIT_2D => X"3A726F737365636F725000003E2320646D630000206D6F632E7375656870696D",
INIT_2E => X"00000084838281800000207A484D30303120746120555054207469622D363120",
INIT_2F => X"58580000783000007365747962200000203A79726F6D654D0000008988878685",
INIT_30 => X"006E6F205344454C0000216E776F6E6B6E55000000203A646E616D6D6F430000",
INIT_31 => X"6E55000064657070614D0000203F79726F6D654D000066666F205344454C0000",
INIT_32 => X"76207373656363612079726F6D656D2064657070616D6E55000064657070616D",
INIT_33 => X"0000000000000000000000000000000000007830207461206E6F6974616C6F69",
INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
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
	CLKB <= I_clk;
	
	ENA <= I_cs;
	ENB <= '0';--port B unused
	
	ADDRA <= I_addr(10 downto 1) & "0000";
	
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
				WEB <= "0000";
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
	
	O_data <= data when I_cs = '1' else "ZZZZZZZZZZZZZZZZ";

end Behavioral;