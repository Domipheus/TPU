----------------------------------------------------------------------------------
-- This file can act as a top level module for TPU testing purposes.
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


library work;
use work.tpu_constants.all;

entity leds_switch_test_expand is
    Port ( I_clk : in  STD_LOGIC;
           I_switch : in  STD_LOGIC_VECTOR (3 downto 0);
           O_leds : out  STD_LOGIC_VECTOR (7 downto 0));
end leds_switch_test_expand;

architecture Behavioral of leds_switch_test_expand is

  COMPONENT clock_divider is
  port ( 
    clk: in std_logic;
    reset: in std_logic;
    clock_out: out std_logic);
  end COMPONENT;

    COMPONENT pc_unit
    PORT(
         I_clk : IN  std_logic;
         I_nPC : IN  std_logic_vector(15 downto 0);
         I_nPCop : IN  std_logic_vector(1 downto 0);
         O_PC : OUT std_logic_vector(15 downto 0)
        );
    END COMPONENT;
   
    COMPONENT control_unit 
    PORT ( 
          I_clk : in  STD_LOGIC;
          I_reset : in  STD_LOGIC;
          I_aluop : in  STD_LOGIC_VECTOR (4 downto 0);
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
   
  component eram
  Port ( I_clk : in  STD_LOGIC;
        I_we : in  STD_LOGIC;
        I_addr : in  STD_LOGIC_VECTOR (15 downto 0);
        I_data : in  STD_LOGIC_VECTOR (15 downto 0);
        O_data : out  STD_LOGIC_VECTOR (15 downto 0)
        );
  end component;

   
   signal state : std_logic_vector(5 downto 0) := (others => '0');
  
   signal en_fetch : std_logic := '0';
   signal en_decode : std_logic := '0';
   signal en_regread : std_logic := '0';
   signal en_alu : std_logic := '0';
  signal en_memory : std_logic := '0';
   signal en_regwrite : std_logic := '0';
  
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

  signal registerWriteData : std_logic_vector(15 downto 0) := (others=>'0');
  
  signal I_reset :    STD_LOGIC;
  signal I_halt :    STD_LOGIC;
  signal I_data :   STD_LOGIC_VECTOR (15 downto 0);
  signal O_data :    STD_LOGIC_VECTOR (15 downto 0);
  signal O_address :    STD_LOGIC_VECTOR (15 downto 0);
  signal O_write :    STD_LOGIC;
  
  signal core_clock:STD_LOGIC := '0';
  
  signal leds : STD_LOGIC_VECTOR (7 downto 0):= "11011100";
begin
  divider: clock_divider port map( 
    clk => I_clk,
    reset=> I_reset,
    clock_out=>core_clock
  );

  eram_1: eram Port map ( 
    I_clk => core_clock,
      I_we => O_write,
     I_addr => O_address,
     I_data => O_data,
     O_data => I_data
  );

  uut_pcunit: pc_unit Port map (
    I_clk => core_clock,
    I_nPC => in_pc,
    I_nPCop => pcop, 
    O_PC => PC
    );

  uut_control: control_unit PORT MAP (
         I_clk => core_clock,
       I_reset => I_reset,
       I_aluop => aluop,
       O_state => state
      );
      
  uut_decoder: decode PORT MAP (
          I_clk => core_clock,
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
          I_clk => core_clock,
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
          I_clk => core_clock,
       I_en => en_regread or en_regwrite,
          I_dataD => registerWriteData,
          O_dataA => dataA,
          O_dataB => dataB,
          I_selA => selA,
          I_selB => selB,
          I_selD => selD,
          I_we => dataWriteReg and en_regwrite
        );
      
  en_fetch <= state(0);
  en_decode <= state(1);
  en_regread <= state(2);
  en_alu <= state(3);
  en_memory <= state(4);
  en_regwrite <= state(5);
  
  
  pcop <= PCU_OP_RESET when I_reset = '1' else	
          PCU_OP_ASSIGN when shouldBranch = '1' and state(5) = '1' else 
          PCU_OP_INC when shouldBranch = '0' and state(5) = '1' else 
        PCU_OP_NOP;
      
  in_pc <= dataResult;
  
  O_address <= dataResult when en_memory = '1' else PC;
  O_data <= dataB;
  O_write <= '1' when en_memory = '1' and aluop(4 downto 1) = OPCODE_WRITE else '0';
  
  
  registerWriteData <= I_data when en_regwrite = '1' and aluop(4 downto 1) = OPCODE_READ else dataResult;
  instruction <= I_data;
  
   process(I_clk, O_address)
   begin	
    if rising_edge(I_clk) then
      if (O_address = X"1000") then
        -- leds
        leds <= dataB(7 downto 0);
      end if;
    end if;
   end process;
  
  O_leds <= leds(7 downto 1) & I_reset;
  I_reset <= I_switch(0);

end Behavioral;

