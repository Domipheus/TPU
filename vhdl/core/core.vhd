----------------------------------------------------------------------------------
-- Project Name: TPU
-- Description: TPU core glue entity
--
--  Brings all core components together with a little glue logic.
--  This is the CPU interface required.
-- 
-- Revision: 1
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


library work;
use work.tpu_constants.all;


entity core is
	Port (I_clk : in  STD_LOGIC;
			I_reset : in  STD_LOGIC;
			I_halt : in  STD_LOGIC;
			
			I_int: in STD_LOGIC;
			O_int_ack: out STD_LOGIC;

			-- new memory interface
			MEM_I_ready : IN  std_logic;
			MEM_O_cmd : OUT  std_logic;
			MEM_O_we : OUT  std_logic;
			MEM_O_byteEnable : OUT  std_logic_vector(1 downto 0);
			MEM_O_addr : OUT  std_logic_vector(15 downto 0);
			MEM_O_data : OUT  std_logic_vector(15 downto 0);
			MEM_I_data : IN  std_logic_vector(15 downto 0);
			MEM_I_dataReady : IN  std_logic
	);
end core;

architecture Behavioral of core is
       COMPONENT pc_unit
    PORT(
         I_clk : IN  std_logic;
         I_nPC : IN  std_logic_vector(15 downto 0);
         I_nPCop : IN  std_logic_vector(1 downto 0);
			I_intVec: IN std_logic;
         O_PC : OUT std_logic_vector(15 downto 0)
        );
    END COMPONENT;
	 
    COMPONENT control_unit 
    PORT ( 
			I_clk : in  STD_LOGIC;
			I_reset : in  STD_LOGIC;
			I_aluop : in  STD_LOGIC_VECTOR (4 downto 0);
			O_state : out  STD_LOGIC_VECTOR (6 downto 0);

			I_int: in STD_LOGIC;
			O_int_ack: out STD_LOGIC;

			I_int_enabled: in STD_LOGIC;
			I_int_mem_data: in STD_LOGIC_VECTOR(15 downto 0);  
			O_idata: out STD_LOGIC_VECTOR(15 downto 0);  
			O_set_idata:out STD_LOGIC;
			O_set_ipc: out STD_LOGIC;
			O_set_irpc: out STD_LOGIC;  

			I_ready: in STD_LOGIC;
			O_execute: out STD_LOGIC;
			I_dataReady: in STD_LOGIC
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
         O_shouldBranch : OUT  std_logic;
			I_idata: in STD_LOGIC_VECTOR(15 downto 0); --interrupt register data
			I_set_idata:in STD_LOGIC;-- set interrup register data
			I_set_irpc: in STD_LOGIC; -- set interrupt return pc
			
			O_int_enabled: out STD_LOGIC;
			O_memMode : out STD_LOGIC
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
	 
	 
	 	 
    COMPONENT mem_controller
    PORT(
         I_clk : IN  std_logic;
         I_reset : IN  std_logic;
         O_ready : OUT  std_logic;
         I_execute : IN  std_logic;
         I_dataWe : IN  std_logic;
         I_address : IN  std_logic_vector(15 downto 0);
         I_data : IN  std_logic_vector(15 downto 0);
         I_dataByteEn : IN  std_logic_vector(1 downto 0);
         O_data : OUT  std_logic_vector(15 downto 0);
         O_dataReady : OUT  std_logic;
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

	 
	signal state : std_logic_vector(6 downto 0) := (others => '0');
	
	
	signal pcop: std_logic_vector(1 downto 0);
	signal in_pc: std_logic_vector(15 downto 0);
	
	signal instruction : std_logic_vector(15 downto 0) := (others => '0');
   signal dataA : std_logic_vector(15 downto 0) := (others => '0');
   signal dataB : std_logic_vector(15 downto 0) := (others => '0');
   signal dataDwe : std_logic := '0';
   signal aluop : std_logic_vector(4 downto 0) := (others => '0');
   signal dataIMM : std_logic_vector(15 downto 0) := (others => '0');
	signal selA : std_logic_vector(2 downto 0) := (others => '0');
   signal selB : std_logic_vector(2 downto 0) := (others => '0');
   signal selD : std_logic_vector(2 downto 0) := (others => '0');
	signal dataregWrite: std_logic := '0';
   signal dataResult : std_logic_vector(15 downto 0) := (others => '0');
   signal dataWriteReg : std_logic := '0';
   signal shouldBranch : std_logic := '0';
	signal memMode : std_logic := '0';
	signal ram_req_size : std_logic := '0';
	
	signal reg_en: std_logic := '0';
	signal reg_we: std_logic := '0';

	signal registerWriteData : std_logic_vector(15 downto 0) := (others=>'0');
	
	signal en_fetch : std_logic := '0';
   signal en_decode : std_logic := '0';
   signal en_regread : std_logic := '0';
   signal en_alu : std_logic := '0';
	signal en_memory : std_logic := '0';
   signal en_regwrite : std_logic := '0';
   signal en_stall : std_logic := '0';
	
   signal PC : std_logic_vector(15 downto 0) := (others => '0');
	 
	signal memctl_ready :    std_logic;
   signal memctl_execute :   std_logic := '0';
   signal memctl_dataWe :    std_logic;
   signal memctl_address :    std_logic_vector(15 downto 0);
   signal memctl_in_data :    std_logic_vector(15 downto 0);
   signal memctl_dataByteEn :   std_logic_vector(1 downto 0);
   signal memctl_out_data :    std_logic_vector(15 downto 0);
   signal memctl_dataReady :    std_logic;
	
	signal PCintVec: STD_LOGIC := '0';
	
	signal int_idata:   STD_LOGIC_VECTOR(15 downto 0); 
	signal int_set_idata:  STD_LOGIC;
	signal int_enabled: std_logic;
	signal int_set_irpc:  STD_LOGIC;
	
	signal core_clock:STD_LOGIC := '0';
	
	signal leds : STD_LOGIC_VECTOR (7 downto 0):= "11011100";
begin
	core_clock <= I_clk;
	
	memctl: mem_controller PORT MAP (
          I_clk => I_clk,
          I_reset => I_reset,
			 
          O_ready => memctl_ready,
          I_execute => memctl_execute,
          I_dataWe => memctl_dataWe,
          I_address => memctl_address,
          I_data => memctl_in_data,
          I_dataByteEn => memctl_dataByteEn,
          O_data => memctl_out_data,
          O_dataReady => memctl_dataReady,
			 
          MEM_I_ready => MEM_I_ready,
          MEM_O_cmd => MEM_O_cmd,
          MEM_O_we => MEM_O_we,
          MEM_O_byteEnable => MEM_O_byteEnable,
          MEM_O_addr => MEM_O_addr,
          MEM_O_data => MEM_O_data,
          MEM_I_data => MEM_I_data,
          MEM_I_dataReady => MEM_I_dataReady
        );

	uut_pcunit: pc_unit Port map (
		I_clk => core_clock,
		I_nPC => in_pc,
		I_nPCop => pcop, 
		I_intVec => PCintVec,
		O_PC => PC
		);

	uut_control: control_unit PORT MAP (
	       I_clk => core_clock,
			 I_reset => I_reset,
			 I_aluop => aluop,
			 
			I_int => I_int,
			O_int_ack => O_int_ack,
		
			I_int_enabled => int_enabled,
			I_int_mem_data=>MEM_I_data,
			O_idata=> int_idata,
			O_set_idata=> int_set_idata,
			O_set_ipc=> PCintVec,
			O_set_irpc => int_set_irpc,
			 I_ready => memctl_ready,
			 O_execute => memctl_execute,
			 I_dataReady => memctl_dataReady,
			 
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
          O_shouldBranch => shouldBranch,
			 O_int_enabled => int_enabled,
			 I_idata => int_idata,
			 I_set_idata => int_set_idata,
			 I_set_irpc => int_set_irpc,
			 O_memMode => memMode
        );
		  
	uut_reg: reg16_8 PORT MAP (
          I_clk => core_clock,
			 I_en => reg_en,
          I_dataD => registerWriteData,
          O_dataA => dataA,
          O_dataB => dataB,
          I_selA => selA,
          I_selB => selB,
          I_selD => selD,
          I_we => reg_we
        );
		  
	reg_en <= en_regread or en_regwrite;
	reg_we <= dataWriteReg and en_regwrite;
	
		  
	en_fetch <= state(0);
	en_decode <= state(1);
	en_regread <= state(2);
	en_alu <= state(3);
	en_memory <= state(4);
	en_regwrite <= state(5);
	en_stall <= state(6);
	
	
	pcop <= PCU_OP_RESET when I_reset = '1' else	
	        PCU_OP_ASSIGN when shouldBranch = '1' and state(5) = '1' else 
	        PCU_OP_INC when shouldBranch = '0' and state(5) = '1' else 
			  PCU_OP_NOP;
		  
	in_pc <= dataResult;
	
	memctl_address <= dataResult when en_memory = '1' else PC;
	ram_req_size <= memMode when en_memory = '1' else '0';
	memctl_dataByteEn <= "10" when ram_req_size = '1' else "11";
	memctl_in_data <= dataB;
	
	memctl_dataWe <= '1' when en_memory = '1' and aluop(4 downto 1) = OPCODE_WRITE else '0';
	
	registerWriteData <= memctl_out_data when en_regwrite = '1' and aluop(4 downto 1) = OPCODE_READ else dataResult;
	instruction <= memctl_out_data;
	
end Behavioral;

