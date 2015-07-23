--------------------------------------------------------------------------------
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

library work;
use work.tpu_constants.all;

use IEEE.NUMERIC_STD.ALL;

entity ram_tb is
    Port ( I_clk : in  STD_LOGIC;
           I_we : in  STD_LOGIC;
           I_addr : in  STD_LOGIC_VECTOR (15 downto 0);
           I_data : in  STD_LOGIC_VECTOR (15 downto 0);
           O_data : out  STD_LOGIC_VECTOR (15 downto 0));
end ram_tb;

architecture Behavioral of ram_tb is
	type store_t is array (0 to 15) of std_logic_vector(15 downto 0);
--   signal ram: store_t := (
--		OPCODE_LOAD & "000" & '0' & X"fe",
--		OPCODE_LOAD & "001" & '1' & X"ed",
--		OPCODE_OR & "010" & '0' & "000" & "001" & "00",
--		OPCODE_LOAD & "011" & '1' & X"01",
--		OPCODE_LOAD & "100" & '1' & X"02",
--		OPCODE_ADD & "011" & '0' & "011" & "100" & "00",
--		OPCODE_OR & "101" & '0' & "000" & "011" & "00",
--		OPCODE_JUMP & "000" & '1' & X"05"
--		);
--		
		
		-- mul r1 by r2, result in r0
   signal ram: store_t := (
		OPCODE_LOAD & "001" & '1' & X"05",  --r1 = 5
		OPCODE_LOAD & "010" & '1' & X"03",  --r2 = 3
		OPCODE_XOR & "000" & '0' & "000" & "000" & "00", -- r0 = 0
		OPCODE_LOAD & "011" & '1' & X"01",     -- r3 = 1
		OPCODE_LOAD & "110" & '1' & X"0b",     -- r6 = 0xb
		OPCODE_OR & "100" & '0' & "010" & "010" & "00",  -- r4 = r2
		OPCODE_CMP & "101" & '0' & "100" & "000" & "00",  -- r5 = cmp(r4, r0)
		OPCODE_JUMPEQ & "000" & '0' & "101" & "110" & "01", -- jaz, r5, r6
		OPCODE_SUB & "100" & '0' & "100" & "011" & "00",
		OPCODE_ADD & "000" & '0' & "000" & "001" & "00",
		OPCODE_JUMP & "000" & '1' & X"06", -- jump 0x6
		OPCODE_JUMP & "000" & '1' & X"0b", -- jump self
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

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

library work;
use work.tpu_constants.all;
 
ENTITY decode_alu_reg_cs_pcu_tb IS
END decode_alu_reg_cs_pcu_tb;
 
ARCHITECTURE behavior OF decode_alu_reg_cs_pcu_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
	component ram_tb
	Port ( I_clk : in  STD_LOGIC;
			  I_we : in  STD_LOGIC;
			  I_addr : in  STD_LOGIC_VECTOR (15 downto 0);
			  I_data : in  STD_LOGIC_VECTOR (15 downto 0);
			  O_data : out  STD_LOGIC_VECTOR (15 downto 0)
			  );
	end component;
	
	 COMPONENT pc_unit
    PORT(
         I_clk : IN  std_logic;
         I_nPC : IN  std_logic_vector(15 downto 0);
         I_nPCop : IN  std_logic_vector(1 downto 0);
         O_PC : OUT std_logic_vector(15 downto 0)
        );
    END COMPONENT;
	 
    COMPONENT controlsimple 
    PORT ( 
          I_clk : in  STD_LOGIC;
          I_reset : in  STD_LOGIC;
          O_state : out  STD_LOGIC_VECTOR (5 downto 0)
         );
    END COMPONENT;

    COMPONENT decode
    PORT(
         I_clk : IN  std_logic;
         I_dataInst : IN  std_logic_vector(15 downto 0);
         I_en : IN  std_logic;
         O_selA : OUT  std_logic_vector(2 downto 0);
         O_selB : OUT  std_logic_vector(2 downto 0);
         O_selD : OUT  std_logic_vector(2 downto 0);
         O_dataIMM : OUT  std_logic_vector(15 downto 0);
         O_regDwe : OUT  std_logic;
         O_aluop : OUT  std_logic_vector(4 downto 0)
        );
    END COMPONENT;
 
    COMPONENT alu
    PORT(
         I_clk : IN  std_logic;
         I_en : IN  std_logic;
         I_dataA : IN  std_logic_vector(15 downto 0);
         I_dataB : IN  std_logic_vector(15 downto 0);
         I_dataDwe : IN  std_logic;
         I_aluop : IN  std_logic_vector(4 downto 0);
         I_PC : IN  std_logic_vector(15 downto 0);
         I_dataIMM : IN  std_logic_vector(15 downto 0);
         O_dataResult : OUT  std_logic_vector(15 downto 0);
         O_dataWriteReg : OUT  std_logic;
         O_shouldBranch : OUT  std_logic
        );
    END COMPONENT;
	 
	 COMPONENT reg16_8
    PORT(
         I_clk : IN  std_logic;
			I_en: in STD_LOGIC;
         I_dataD : IN  std_logic_vector(15 downto 0);
         O_dataA : OUT  std_logic_vector(15 downto 0);
         O_dataB : OUT  std_logic_vector(15 downto 0);
         I_selA : IN  std_logic_vector(2 downto 0);
         I_selB : IN  std_logic_vector(2 downto 0);
         I_selD : IN  std_logic_vector(2 downto 0);
         I_we : IN  std_logic
        );
    END COMPONENT;
    
   signal I_clk : std_logic := '0';
   signal reset : std_logic := '1';
   signal state : std_logic_vector(5 downto 0) := (others => '0');
	
   signal en_fetch : std_logic := '0';
   signal en_decode : std_logic := '0';
   signal en_regread : std_logic := '0';
   signal en_regwrite : std_logic := '0';
   signal en_alu : std_logic := '0';
	
	signal ramWE : std_logic := '0';
	signal ramAddr: std_logic_vector(15 downto 0);
	signal ramRData: std_logic_vector(15 downto 0);
	signal ramWData: std_logic_vector(15 downto 0);
	
	signal pcop: std_logic_vector(1 downto 0);
	signal in_pc: std_logic_vector(15 downto 0);
	
	signal instruction : std_logic_vector(15 downto 0) := (others => '0');
   signal dataA : std_logic_vector(15 downto 0) := (others => '0');
   signal dataB : std_logic_vector(15 downto 0) := (others => '0');
   signal dataDwe : std_logic := '0';
   signal aluop : std_logic_vector(4 downto 0) := (others => '0');
   signal PC : std_logic_vector(15 downto 0) := (others => '0');
   signal dataIMM : std_logic_vector(15 downto 0) := (others => '0');
	signal selA : std_logic_vector(2 downto 0) := (others => '0');
   signal selB : std_logic_vector(2 downto 0) := (others => '0');
   signal selD : std_logic_vector(2 downto 0) := (others => '0');
	signal dataregWrite: std_logic := '0';
   signal dataResult : std_logic_vector(15 downto 0) := (others => '0');
   signal dataWriteReg : std_logic := '0';
   signal shouldBranch : std_logic := '0';


	signal cpu_reset : std_logic := '0';
	
	
   -- Clock period definitions
   constant I_clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
	uut_ram: ram_tb Port map ( 
		I_clk => I_clk,
      I_we => ramWE,
	   I_addr => ramAddr,
	   I_data => ramWData,
	   O_data => ramRData
	);
	
	uut_pcunit: pc_unit Port map (
		I_clk => I_clk,
		I_nPC => in_pc,
		I_nPCop => pcop, 
		O_PC => PC
		);

	uut_control: controlsimple PORT MAP (
	       I_clk => I_clk,
			 I_reset => reset,
			 O_state => state
			);
			
	uut_decoder: decode PORT MAP (
          I_clk => I_clk,
          I_dataInst => instruction,
          I_en => en_decode,
          O_selA => selA,
          O_selB => selB,
          O_selD => selD,
          O_dataIMM => dataIMM,
          O_regDwe => dataDwe,
          O_aluop => aluop
        );
		  
   uut_alu: alu PORT MAP (
          I_clk => I_clk,
          I_en => en_alu,
          I_dataA => dataA,
          I_dataB => dataB,
          I_dataDwe => dataDwe,
          I_aluop => aluop,
          I_PC => PC,
          I_dataIMM => dataIMM,
          O_dataResult => dataResult,
          O_dataWriteReg => dataWriteReg,
          O_shouldBranch => shouldBranch
        );
		  
	uut_reg: reg16_8 PORT MAP (
          I_clk => I_clk,
			 I_en => en_regread or en_regwrite,
          I_dataD => dataResult,
          O_dataA => dataA,
          O_dataB => dataB,
          I_selA => selA,
          I_selB => selB,
          I_selD => selD,
          I_we => dataWriteReg and en_regwrite
        );

   -- Clock process definitions
   I_clk_process :process
   begin
		I_clk <= '0';
		wait for I_clk_period/2;
		I_clk <= '1';
		wait for I_clk_period/2;
   end process;


	en_fetch <= state(0);
	en_decode <= state(1);
	en_regread <= state(2);
	en_alu <= state(3);
	en_regwrite <= state(4);
	
	
	pcop <= PCU_OP_RESET when reset = '1' else	
	        PCU_OP_ASSIGN when shouldBranch = '1' and state(4) = '1' else 
	        PCU_OP_INC when shouldBranch = '0' and state(4) = '1' else 
			  PCU_OP_NOP;
		  
	in_pc <= dataResult;
	
	ramAddr <= PC;
	ramWData <= X"FFFF";
	ramWE <= '0';
	
	instruction <= ramRData;

   -- Stimulus process
   stim_proc: process
   begin		

		reset<='1'; -- reset control unit
      wait for I_clk_period; -- wait a cycle
		reset <= '0';
		
		wait;
   end process;

END;
