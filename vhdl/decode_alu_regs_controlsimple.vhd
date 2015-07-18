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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

library work;
use work.tpu_constants.all;
 
ENTITY decode_alu_reg_controlsimple_tb IS
END decode_alu_reg_controlsimple_tb;
 
ARCHITECTURE behavior OF decode_alu_reg_controlsimple_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
	 
    COMPONENT controlsimple 
    PORT ( 
          I_clk : in  STD_LOGIC;
          I_reset : in  STD_LOGIC;
          O_state : out  STD_LOGIC_VECTOR (3 downto 0)
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
   signal state : std_logic_vector(3 downto 0) := (others => '0');
	
   signal en_decode : std_logic := '0';
   signal en_regread : std_logic := '0';
   signal en_regwrite : std_logic := '0';
   signal en_alu : std_logic := '0';
	
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

   -- Clock period definitions
   constant I_clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
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


	en_decode <= state(0);
	en_regread <= state(1);
	en_alu <= state(2);
	en_regwrite <= state(3);

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for I_clk_period*10;
		
		reset<='1'; -- reset control unit
		--load.h r0,0xfe
		instruction <= OPCODE_LOAD & "000" & '0' & X"fe";
		reset<='0'; -- enable/start control unit
		wait until en_regwrite = '1';
		
		--load.l r1, 0xed
		instruction <= OPCODE_LOAD & "001" & '1' & X"ed";
		wait until en_regwrite = '1';
		
		--or r2, r0, r1
		instruction <= OPCODE_OR & "010" & '0' & "000" & "001" & "00";
		wait until en_regwrite = '1';

		--load.l r3, 1
		instruction <= OPCODE_LOAD & "011" & '1' & X"01";
		wait until en_regwrite = '1';
		
		--load.l r4, 2
		instruction <= OPCODE_LOAD & "100" & '1' & X"02";
		wait until en_regwrite = '1';
		
		--add.u r3, r3, r4
		instruction <= OPCODE_ADD & "011" & '0' & "011" & "100" & "00";
		wait until en_regwrite = '1';
		
		--or r5, r0, r3
		instruction <= OPCODE_OR & "101" & '0' & "000" & "011" & "00";
		wait until en_regwrite = '1';
		
		--and r5, r5, r2
		instruction <= OPCODE_AND & "101" & '0' & "101" & "010" & "00";
		wait until en_regwrite = '1';
      -- insert stimulus here 
      
      wait;
   end process;

END;
