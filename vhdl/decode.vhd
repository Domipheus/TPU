----------------------------------------------------------------------------------
-- Project Name: TPU
-- Description: Decoder unit of TPU
-- 
-- Revision: 1
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.tpu_constants.all;

entity decode is
    Port ( I_clk : in  STD_LOGIC;
           I_en : in  STD_LOGIC;
           I_dataInst : in  STD_LOGIC_VECTOR (15 downto 0); -- Instruction to be decoded
           O_selA : out  STD_LOGIC_VECTOR (2 downto 0);     -- Selection out for regA
           O_selB : out  STD_LOGIC_VECTOR (2 downto 0);     -- Selection out for regB
           O_selD : out  STD_LOGIC_VECTOR (2 downto 0);     -- Selection out for regD
           O_dataIMM : out  STD_LOGIC_VECTOR (15 downto 0); -- Immediate value out
           O_regDwe : out  STD_LOGIC;                       -- RegD wrtite enable
           O_aluop : out  STD_LOGIC_VECTOR (4 downto 0)     -- ALU opcode
    );
end decode;

architecture Behavioral of decode is

begin

	process (I_clk, I_en)
	begin
		if rising_edge(I_clk) and I_en = '1' then
		
			O_selA <= I_dataInst(IFO_RA_BEGIN downto IFO_RA_END);
			O_selB <= I_dataInst(IFO_RB_BEGIN downto IFO_RB_END);
			O_selD <= I_dataInst(IFO_RD_BEGIN downto IFO_RD_END);
			O_dataIMM <= I_dataInst(IFO_IMM_BEGIN downto IFO_IMM_END) 
			           & I_dataInst(IFO_IMM_BEGIN downto IFO_IMM_END);
						  
			O_aluop <= I_dataInst(IFO_OPCODE_BEGIN downto IFO_OPCODE_END) 
			         & I_dataInst(IFO_F_LOC);
	
			case I_dataInst(IFO_OPCODE_BEGIN downto IFO_OPCODE_END) is
				when OPCODE_WRITE => 
					O_regDwe <= '0';
				when OPCODE_JUMP => 
					O_regDwe <= '0';
				when OPCODE_JUMPEQ => 
					O_regDwe <= '0';
				when others =>
					O_regDwe <= '1';
			end case;
		end if;
	end process;

end Behavioral;

