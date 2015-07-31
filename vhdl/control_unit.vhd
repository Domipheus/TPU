----------------------------------------------------------------------------------
-- Project Name: TPU
-- Description: control_unit - control unit of TPU for all stages
-- 
-- Revision: 1
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.tpu_constants.all;

entity control_unit is
    Port ( I_clk : in  STD_LOGIC;
           I_reset : in  STD_LOGIC;
           I_aluop : in  STD_LOGIC_VECTOR (4 downto 0);
           O_state : out  STD_LOGIC_VECTOR (5 downto 0)
           );
end control_unit;

architecture Behavioral of control_unit is
  signal s_state: STD_LOGIC_VECTOR(5 downto 0) := "000001";
begin
  process(I_clk)
  begin
    if rising_edge(I_clk) then
      if I_reset = '1' then
        s_state <= "000001";
      else
        case s_state is
          when "000001" =>
            s_state <= "000010"; --D
          when "000010" =>
            s_state <= "000100"; --R
          when "000100" =>
            s_state <= "001000"; --E
          when "001000" =>
            --MEM/WB
            -- if it's not a memory alu op, goto writeback
            if (I_aluop(4 downto 1) = OPCODE_READ or
               I_aluop(4 downto 1) = OPCODE_WRITE) then
               s_state <= "010000"; -- MEM
            else
              s_state <= "100000"; -- WB
            end if;
          when "010000" =>
              s_state <= "100000"; -- WB
          when "100000" =>
            s_state <= "000001"; --F
          when others =>
            s_state <= "000001";
        end case;
      end if;
    end if;
  end process;

  O_state <= s_state;
end Behavioral;



