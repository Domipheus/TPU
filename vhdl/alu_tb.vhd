--------------------------------------------------------------------------------
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
 
ENTITY alu_tb IS
END alu_tb;
 
ARCHITECTURE behavior OF alu_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT alu
    PORT(
         I_clk : IN  std_logic;
         I_en : IN  std_logic;
         I_dataA : IN  std_logic_vector(15 downto 0);
         I_dataB : IN  std_logic_vector(15 downto 0);
         O_dataResult : OUT  std_logic_vector(15 downto 0);
         I_dataDwe : IN  std_logic;
         O_dataWriteReg : OUT  std_logic;
         I_aluop : IN  std_logic_vector(4 downto 0);
			I_PC : in STD_LOGIC_VECTOR (15 downto 0);
         O_shouldBranch : OUT  std_logic;
         I_dataIMM : IN  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal I_clk : std_logic := '0';
   signal I_en : std_logic := '0';
   signal I_dataA : std_logic_vector(15 downto 0) := (others => '0');
   signal I_dataB : std_logic_vector(15 downto 0) := (others => '0');
   signal I_dataDwe : std_logic := '0';
   signal I_aluop : std_logic_vector(4 downto 0) := (others => '0');
   signal I_dataIMM : std_logic_vector(15 downto 0) := (others => '0');
   signal I_PC : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal O_dataResult : std_logic_vector(15 downto 0);
   signal O_dataWriteReg : std_logic;
   signal O_shouldBranch : std_logic;

   -- Clock period definitions
   constant I_clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: alu PORT MAP (
          I_clk => I_clk,
          I_en => I_en,
          I_dataA => I_dataA,
          I_dataB => I_dataB,
          O_dataResult => O_dataResult,
          I_dataDwe => I_dataDwe,
          O_dataWriteReg => O_dataWriteReg,
          I_aluop => I_aluop,
			 I_PC => I_PC,
          O_shouldBranch => O_shouldBranch,
          I_dataIMM => I_dataIMM
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
		I_en <= '1';
		I_dataA <= X"0001";
		I_dataB <= X"0002";
		I_aluop <= OPCODE_ADD & '0';
		I_dataIMM <= X"F1FA";

      wait for I_clk_period;
		I_dataA <= X"0005";
		I_dataB <= X"0003";
		I_aluop <= OPCODE_SUB & '0';
		
      wait for I_clk_period;
		
		I_dataA <= X"FEEE";
		I_dataB <= X"0000";
		I_aluop <= OPCODE_CMP & '0';
		
      wait for I_clk_period;
		I_dataA <= X"ABCD";
		I_dataB <= X"ABCD";
		I_aluop <= OPCODE_CMP & '0';
		
      wait for I_clk_period;
		I_dataA <= X"8000";
		I_dataB <= X"8111";
		I_aluop <= OPCODE_CMP & '0';
		
      wait for I_clk_period;
		I_dataA <= X"8000";
		I_dataB <= X"0111";
		I_aluop <= OPCODE_CMP & '0';
		
      wait for I_clk_period;
		I_dataA <= X"8000";
		I_dataB <= X"0111";
		I_aluop <= OPCODE_CMP & '1';
		
		
      wait for I_clk_period;
		I_dataA <= X"0001";
		I_dataB <= X"0001";
		I_aluop <= OPCODE_SHL & '0';

		
      wait for I_clk_period;
		I_dataA <= X"0001";
		I_dataB <= X"0002";
		I_aluop <= OPCODE_SHL & '0';
		
      wait for I_clk_period;
		I_dataA <= X"0001";
		I_dataB <= X"0003";
		I_aluop <= OPCODE_SHL & '0';
		
		
      wait for I_clk_period;
		I_dataA <= X"000A";
		I_dataB <= X"0004";
		I_aluop <= OPCODE_SHL & '0';
		
      wait for I_clk_period;
		I_dataA <= X"000B";
		I_dataB <= X"0008";
		I_aluop <= OPCODE_SHL & '0';
		
      wait for I_clk_period;
		I_dataA <= X"000C";
		I_dataB <= X"000c";
		I_aluop <= OPCODE_SHL & '0';
		
      wait for I_clk_period;
		I_dataA <= X"0004";
		I_dataB <= X"0001";
		I_aluop <= OPCODE_SHR & '0';
		
      wait for I_clk_period;
		I_dataA <= X"0008";
		I_dataB <= X"0002";
		I_aluop <= OPCODE_SHR & '0';
		
		wait for I_clk_period;
		I_dataA <= X"A000";
		I_dataB <= X"0004";
		I_aluop <= OPCODE_SHR & '0';
		
      wait for I_clk_period;
		I_dataA <= X"B000";
		I_dataB <= X"0008";
		I_aluop <= OPCODE_SHR & '0';
		
      wait for I_clk_period;
		I_dataA <= X"C000";
		I_dataB <= X"000c";
		I_aluop <= OPCODE_SHR & '0';
		
      wait for I_clk_period;
		I_dataA <= X"1234";
		I_dataB <= X"0000";
		I_dataIMM <= X"1111";
		I_aluop <= OPCODE_JUMP & '0';
		
      wait for I_clk_period;
		I_dataA <= X"1234";
		I_dataB <= X"0000";
		I_dataIMM <= X"1111";
		I_aluop <= OPCODE_JUMP & '1';
		
		-- not comprehensive testing of jumpeq, yet
      wait for I_clk_period;
		I_dataA <= '0' & "00000" & "00" & X"00";
		I_dataB <= X"FEE1";
		I_dataIMM <= X"000" & "00" & "00";
		I_aluop <= OPCODE_JUMPEQ & '0';
		
		
      wait for I_clk_period;
		I_dataA <= '0' & "10000" & "00" & X"00";
		I_dataB <= X"FEE1";
		I_dataIMM <= X"000" & "00" & "00";
		I_aluop <= OPCODE_JUMPEQ & '0';
				
      wait for I_clk_period;
		I_dataA <= '0' & "00000" & "00" & X"00";
		I_dataB <= X"FEE2";
		I_dataIMM <= X"000" & "00" & "00";
		I_aluop <= OPCODE_JUMPEQ & '0';
		
		
      wait for I_clk_period;
		I_dataA <= '0' & "01000" & "00" & X"00";
		I_dataB <= X"FEE2";
		I_dataIMM <= X"000" & "00" & "00";
		I_aluop <= OPCODE_JUMPEQ & '0';
				
      wait for I_clk_period;
		I_dataA <= '0' & "00000" & "00" & X"00";
		I_dataB <= X"FEE3";
		I_dataIMM <= X"000" & "00" & "00";
		I_aluop <= OPCODE_JUMPEQ & '0';
		
		
      wait for I_clk_period;
		I_dataA <= '0' & "00100" & "00" & X"00";
		I_dataB <= X"FEE3";
		I_dataIMM <= X"000" & "00" & "00";
		I_aluop <= OPCODE_JUMPEQ & '0';
		
				
      wait for I_clk_period;
		I_dataA <= '0' & "00000" & "00" & X"00";
		I_dataB <= X"FEE4";
		I_dataIMM <= X"000" & "00" & "00";
		I_aluop <= OPCODE_JUMPEQ & '0';
		
		
      wait for I_clk_period;
		I_dataA <= '0' & "00010" & "00" & X"00";
		I_dataB <= X"FEE4";
		I_dataIMM <= X"000" & "00" & "00";
		I_aluop <= OPCODE_JUMPEQ & '0';
		
      wait for I_clk_period;
		I_dataA <= '0' & "00000" & "00" & X"00";
		I_dataB <= X"FEE5";
		I_dataIMM <= X"000" & "00" & "00";
		I_aluop <= OPCODE_JUMPEQ & '0';
		
		
      wait for I_clk_period;
		I_dataA <= '0' & "00001" & "00" & X"00";
		I_dataB <= X"FEE5";
		I_dataIMM <= X"000" & "00" & "00";
		I_aluop <= OPCODE_JUMPEQ & '0';
      
		
		-- 
		wait for I_clk_period;
		I_dataA <= '0' & "00000" & "00" & X"00";
		I_dataB <= X"FEE1";
		I_dataIMM <= X"000" & "00" & "00";
		I_aluop <= OPCODE_JUMPEQ & '0';
		
		
      wait for I_clk_period;
		I_dataA <= '0' & "10000" & "00" & X"00";
		I_dataB <= X"FEE1";
		I_dataIMM <= X"000" & "00" & "00";
		I_aluop <= OPCODE_JUMPEQ & '0';
				
      wait for I_clk_period;
		I_dataA <= '0' & "00000" & "00" & X"00";
		I_dataB <= X"FEE2";
		I_dataIMM <= X"000" & "00" & "01";
		I_aluop <= OPCODE_JUMPEQ & '1';
		
		
      wait for I_clk_period;
		I_dataA <= '0' & "01000" & "00" & X"00";
		I_dataB <= X"FEE2";
		I_dataIMM <= X"000" & "00" & "01";
		I_aluop <= OPCODE_JUMPEQ & '1';
				
      wait for I_clk_period;
		I_dataA <= '0' & "00000" & "00" & X"00";
		I_dataB <= X"FEE3";
		I_dataIMM <= X"000" & "00" & "10";
		I_aluop <= OPCODE_JUMPEQ & '1';
		
		
      wait for I_clk_period;
		I_dataA <= '0' & "00100" & "00" & X"00";
		I_dataB <= X"FEE3";
		I_dataIMM <= X"000" & "00" & "10";
		I_aluop <= OPCODE_JUMPEQ & '1';
		
				
      wait for I_clk_period;
		I_dataA <= '0' & "00000" & "00" & X"00";
		I_dataB <= X"FEE4";
		I_dataIMM <= X"000" & "00" & "01";
		I_aluop <= OPCODE_JUMPEQ & '0';
		
		
      wait for I_clk_period;
		I_dataA <= '0' & "00010" & "00" & X"00";
		I_dataB <= X"FEE4";
		I_dataIMM <= X"000" & "00" & "01";
		I_aluop <= OPCODE_JUMPEQ & '0';
		
      wait for I_clk_period;
		I_dataA <= '0' & "00000" & "00" & X"00";
		I_dataB <= X"FEE5";
		I_dataIMM <= X"000" & "00" & "10";
		I_aluop <= OPCODE_JUMPEQ & '0';
		
		
      wait for I_clk_period;
		I_dataA <= '0' & "00001" & "00" & X"00";
		I_dataB <= X"FEE5";
		I_dataIMM <= X"000" & "00" & "10";
		I_aluop <= OPCODE_JUMPEQ & '0';
		
      wait for I_clk_period;
		I_dataA <= '0' & "00010" & "00" & X"00";
		I_dataB <= X"FEB4";
		I_dataIMM <= X"000" & "00" & "11";
		I_aluop <= OPCODE_JUMPEQ & '0';
		
      wait for I_clk_period;
		I_dataA <= '0' & "11101" & "00" & X"00";
		I_dataB <= X"FEB4";
		I_dataIMM <= X"000" & "00" & "11";
		I_aluop <= OPCODE_JUMPEQ & '0';
		
      wait for I_clk_period;
		I_dataA <= '0' & "11111" & "00" & X"00";
		I_dataB <= X"FEB5";
		I_dataIMM <= X"000" & "00" & "00";
		I_aluop <= OPCODE_JUMPEQ & '1';
		
		
      wait for I_clk_period;
		I_dataA <= '0' & "11110" & "00" & X"00";
		I_dataB <= X"FEB5";
		I_dataIMM <= X"000" & "00" & "00";
		I_aluop <= OPCODE_JUMPEQ & '1';
      wait;
		
   end process; 

END;
