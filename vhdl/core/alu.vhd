----------------------------------------------------------------------------------
-- Project Name: TPU
-- Description: ALU unit of TPU
-- 
-- Revision: 2
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

library work;
use work.tpu_constants.all;

entity alu is
  Port ( I_clk : in  STD_LOGIC;
         I_en : in  STD_LOGIC;
         I_dataA : in  STD_LOGIC_VECTOR (15 downto 0);
         I_dataB : in  STD_LOGIC_VECTOR (15 downto 0);
         I_dataDwe : in STD_LOGIC;
         I_aluop : in  STD_LOGIC_VECTOR (4 downto 0);
         I_PC : in STD_LOGIC_VECTOR (15 downto 0);
         I_dataIMM : in  STD_LOGIC_VECTOR (15 downto 0);
         O_dataResult : out  STD_LOGIC_VECTOR (15 downto 0);
         O_dataWriteReg : out STD_LOGIC;
         O_shouldBranch : out STD_LOGIC;
			I_idata: in STD_LOGIC_VECTOR(15 downto 0); -- interrupt register data
			I_set_idata:in STD_LOGIC;                  -- set interrup register data
			I_set_irpc: in STD_LOGIC;                  -- set interrupt return pc
			O_int_enabled: out STD_LOGIC;
			O_memMode : out STD_LOGIC
  );
end alu;

architecture Behavioral of alu is
	-- The internal register for results of operations. 
	-- 16 bit + carry/overflow
	signal s_result: STD_LOGIC_VECTOR(17 downto 0) := (others => '0');
	
	signal s_shouldBranch: STD_LOGIC := '0';
	signal s_interrupt_register: STD_LOGIC_VECTOR(15 downto 0) := X"0000";
	signal s_interrupt_rpc: STD_LOGIC_VECTOR(15 downto 0) := X"0000";
	signal s_interrupt_enable: std_logic := '0'; -- interrupts are disabled by default.
	signal s_prev_interrupt_enable: std_logic := '0';
	
	-- TODO: this is an in-test signal
	signal s_32_result: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
	signal s_32_cyclecounter: unsigned(31 downto 0) := (others => '0');
begin
   O_int_enabled <= s_interrupt_enable;

	process (I_clk)
	begin
		if rising_edge(I_clk) then
			s_32_cyclecounter <= s_32_cyclecounter + 1;
		end if;
	end process;

	process (I_clk, I_en) 
	begin
		if rising_edge(I_clk) then
		  if I_set_irpc = '1' then
			s_interrupt_rpc <= I_PC;
		  end if;
		  if I_set_idata = '1' then
		   s_prev_interrupt_enable <= s_interrupt_enable;
			s_interrupt_enable <= '0';
			s_interrupt_register <= I_idata;
		  end if;
		  if I_en = '1' then
		   O_dataWriteReg <= I_dataDwe;
			case I_aluop(4 downto 1) is
			   -- TODO: Handle correct overflow result (s_result 17)
				when OPCODE_ADD => 
					if I_aluop(0) = '0' then
						if I_dataImm(0) = '0' then
							s_result(16 downto 0) <= std_logic_vector(unsigned('0' & I_dataA) + unsigned( '0' & I_dataB));
						else
							s_result(16 downto 0) <= std_logic_vector(unsigned('0' & I_dataA) + unsigned( '0' & X"000" & I_dataIMM(4 downto 1)));
						end if;
					else
						s_result(16 downto 0) <= std_logic_vector(signed(I_dataA(15) & I_dataA) + signed( I_dataB(15) & I_dataB));
					end if;
					s_shouldBranch <= '0';
					
			   -- TODO: Handle correct overflow result (s_result 17)
				when OPCODE_SUB => 
					if I_aluop(0) = '0' then
						if I_dataImm(0) = '0' then
							s_result(16 downto 0) <= std_logic_vector(unsigned('0' & I_dataA) - unsigned( '0' & I_dataB));
						else
							s_result(16 downto 0) <= std_logic_vector(unsigned('0' & I_dataA) - unsigned( '0' & X"000" & I_dataIMM(4 downto 1)));
						end if;
					else
						s_result(16 downto 0) <= std_logic_vector(signed(I_dataA(15) & I_dataA) - signed( I_dataB(15) & I_dataB));
					end if;
					s_shouldBranch <= '0';
					
				when OPCODE_OR => 
					s_result(15 downto 0) <= I_dataA or I_dataB;
					s_shouldBranch <= '0';
					
				when OPCODE_XOR => 
					s_result(15 downto 0) <= I_dataA xor I_dataB;
					s_shouldBranch <= '0';
					
				when OPCODE_AND => 	
					s_result(15 downto 0) <= I_dataA and I_dataB;
					s_shouldBranch <= '0';
					
				when OPCODE_NOT => 
					s_result(15 downto 0) <= not I_dataA;
					s_shouldBranch <= '0';
					
				when OPCODE_READ => 	
					-- The result is the address we want. 
					-- Last 5 bits of the Imm value is a signed offset.
					s_result(15 downto 0) <= std_logic_vector(signed(I_dataA) + signed(I_dataIMM(4 downto 0)));
					s_shouldBranch <= '0';
					O_memMode <= I_aluop(0); -- 1 when 1 byte read, 0 16bit
				when OPCODE_WRITE =>  -- result is again the address
					s_result(15 downto 0) <= std_logic_vector(signed(I_dataA) + signed(I_dataIMM(15 downto 11)));
					s_shouldBranch <= '0';
					O_memMode <= I_aluop(0); -- 1 when 1 byte read, 0 16bit
				when OPCODE_LOAD => 
					if I_aluop(0) = '0' then
						s_result(15 downto 0) <= I_dataIMM(7 downto 0) & X"00";
					else
						s_result(15 downto 0) <= X"00" & I_dataIMM(7 downto 0);
					end if;
					s_shouldBranch <= '0';
					
				when OPCODE_CMP => 
					if I_dataA = I_dataB then
						s_result(CMP_BIT_EQ) <= '1';
					else
						s_result(CMP_BIT_EQ) <= '0';
					end if;
					
					if I_dataA = X"0000" then
						s_result(CMP_BIT_AZ) <= '1';
					else
						s_result(CMP_BIT_AZ) <= '0';
					end if;
					
					if I_dataB = X"0000" then
						s_result(CMP_BIT_BZ) <= '1';
					else
						s_result(CMP_BIT_BZ) <= '0';
					end if;
					
					if I_aluop(0) = '0' then
						if unsigned(I_dataA) > unsigned(I_dataB) then
							s_result(CMP_BIT_AGB) <= '1';
						else
							s_result(CMP_BIT_AGB) <= '0';
						end if;
						if unsigned(I_dataA) < unsigned(I_dataB) then
							s_result(CMP_BIT_ALB) <= '1';
						else
							s_result(CMP_BIT_ALB) <= '0';
						end if;
					else
						if signed(I_dataA) > signed(I_dataB) then
							s_result(CMP_BIT_AGB) <= '1';
						else
							s_result(CMP_BIT_AGB) <= '0';
						end if;
						if signed(I_dataA) < signed(I_dataB) then
							s_result(CMP_BIT_ALB) <= '1';
						else
							s_result(CMP_BIT_ALB) <= '0';
						end if;
					end if;
					s_result(15) <= '0';
					s_result(9 downto 0) <= "0000000000";
					s_shouldBranch <= '0';
					
				when OPCODE_SHL => 
					case I_dataB(3 downto 0) is
						when "0001" =>
							s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 1));
						when "0010" =>
							s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 2));
						when "0011" =>
							s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 3));
						when "0100" =>
							s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 4));
						when "0101" =>
							s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 5));
						when "0110" =>
							s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 6));
						when "0111" =>
							s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 7));
						when "1000" =>
							s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 8));
						when "1001" =>
							s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 9));
						when "1010" =>
							s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 10));
						when "1011" =>
							s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 11));
						when "1100" =>
							s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 12));
						when "1101" =>
							s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 13));
						when "1110" =>
							s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 14));
						when "1111" =>
							s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 15));
						when others =>
							s_result(15 downto 0) <= I_dataA;
					end case;
					s_shouldBranch <= '0';
					
				when OPCODE_SHR => 	
					case I_dataB(3 downto 0) is
						when "0001" =>
							s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA), 1));
						when "0010" =>
							s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA), 2));
						when "0011" =>
							s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA), 3));
						when "0100" =>
							s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA), 4));
						when "0101" =>
							s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA), 5));
						when "0110" =>
							s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA), 6));
						when "0111" =>
							s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA), 7));
						when "1000" =>
							s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA), 8));
						when "1001" =>
							s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA), 9));
						when "1010" =>
							s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA), 10));
						when "1011" =>
							s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA), 11));
						when "1100" =>
							s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA), 12));
						when "1101" =>
							s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA), 13));
						when "1110" =>
							s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA), 14));
						when "1111" =>
							s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA), 15));
						when others =>
							s_result(15 downto 0) <= I_dataA;
					end case;
					s_shouldBranch <= '0';
					
				when OPCODE_JUMP => 
					if I_aluop(0) = '0' then
						-- set PC to reg(a) 
						s_result(15 downto 0) <= I_dataA;
					else
						--biro - v1.5isa
						s_result(15 downto 0) <= std_logic_vector(signed(I_PC) + signed(I_dataIMM(10 downto 0) & '0'));
					end if;
					s_shouldBranch <= '1';
				when OPCODE_JUMPEQ => 	
					-- set branch target regardless
					if I_aluop(0) = '1' then
					   s_result(15 downto 0) <= std_logic_vector(signed(I_PC) + signed(I_dataIMM(4 downto 0)));
					else
						s_result(15 downto 0) <= I_dataB;
					end if;
					
					-- the condition to jump is based on aluop(0) and dataimm(1 downto 0);
					case I_dataIMM(15 downto 13) is
						when CJF_EQ =>
							s_shouldBranch <= I_dataA(CMP_BIT_EQ);
						when CJF_AZ =>
							s_shouldBranch <= I_dataA(CMP_BIT_Az);
						when CJF_BZ =>
							s_shouldBranch <= I_dataA(CMP_BIT_Bz);
						when CJF_ANZ =>
							s_shouldBranch <= not I_dataA(CMP_BIT_AZ);
						when CJF_BNZ =>
							s_shouldBranch <= not I_dataA(CMP_BIT_Bz);
						when CJF_AGB =>
							s_shouldBranch <= I_dataA(CMP_BIT_AGB);
						when CJF_ALB =>
							s_shouldBranch <= I_dataA(CMP_BIT_ALB);
						when others =>
							s_shouldBranch <= '0';
					end case;
				when OPCODE_SPEC => 	-- special instructions
					if I_aluop(0) = '1' then
						case I_dataIMM(IFO_F2_BEGIN downto IFO_F2_END) is
						
							when OPCODE_SPEC_F2_GIEF =>
								s_result(15 downto 0) <= s_interrupt_register;
								s_shouldBranch <= '0';	
							when OPCODE_SPEC_F2_BBI =>
								s_result(15 downto 0) <= s_interrupt_rpc;
								s_shouldBranch <= '1';
								s_interrupt_enable <= s_prev_interrupt_enable;
							when OPCODE_SPEC_F2_EI =>
								s_result(15 downto 0) <= X"0000";
								s_interrupt_enable <= '1';
								s_shouldBranch <= '0';
							when OPCODE_SPEC_F2_DI =>
								s_result(15 downto 0) <=  X"0000";
								s_interrupt_enable <= '0';
								s_shouldBranch <= '0';
							when others =>
						end case;
					else
						case I_dataIMM(IFO_F2_BEGIN downto IFO_F2_END) is
							when OPCODE_SPEC_F2_GETPC =>
								s_result(15 downto 0) <= I_PC;
								s_shouldBranch <= '0';	
							when OPCODE_SPEC_F2_GETSTATUS =>
								s_result(1 downto 0) <= s_result(17 downto 16);
								s_shouldBranch <= '0';	
							when OPCODE_SPEC_F2_INT =>
								s_result(15 downto 0) <= ADDR_INTVEC;
								s_interrupt_rpc <= std_logic_vector(unsigned(I_PC) + 2);
								s_interrupt_register <= X"00" & "00" & I_dataIMM(7 downto 2);
								
								s_prev_interrupt_enable <= s_interrupt_enable;
								s_interrupt_enable <= '0';
								s_shouldBranch <= '1';	
							when others =>
						end case;
					end if;
				when OPCODE_RES2 => 
				   -- Currently the RES2 opcode is under investigation. Instructions are not documented yet
					if I_aluop(0) = '1' then
						s_shouldBranch <= '0';
						-- todo: multiply is not tested
						-- Synthesizes to a DSP block on Spartan6
						s_32_result <= std_logic_vector(unsigned(I_dataA) * unsigned( I_dataB));
						s_result(16 downto 0) <= s_32_result(16 downto 0);
					else
					   case I_dataIMM(IFO_F2_BEGIN downto IFO_F2_END) is
						
							when OPCODE_SPEC_F2_GETCOUNTLOW =>
								s_result(15 downto 0) <= std_logic_vector(s_32_cyclecounter(15 downto 0));
								s_shouldBranch <= '0';

							when OPCODE_SPEC_F2_GETCOUNTHIGH =>
								s_result(15 downto 0) <= std_logic_vector(s_32_cyclecounter(31 downto 16));
								s_shouldBranch <= '0';								
							when others =>
						end case;
					end if;
				when others =>
					s_result <= "00" & X"FEFE";
			end case;
		end if;
	  end if;
	end process;
	
	O_dataResult <= s_result(15 downto 0);
	O_shouldBranch <= s_shouldBranch;
	
end Behavioral;

