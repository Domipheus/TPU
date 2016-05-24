----------------------------------------------------------------------------------
-- Project Name: TPU
-- Description: Constants for instruction forms, opcodes, conditional flags, etc.
-- 
-- Revision: 1.5
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package tpu_constants is

constant ADDR_RESET:    std_logic_vector(15 downto 0) :=  X"0000";
constant ADDR_INTVEC:   std_logic_vector(15 downto 0) :=  X"0008";

-- Opcodes
constant OPCODE_ADD:    std_logic_vector(3 downto 0) :=  "0000";	-- ADD
constant OPCODE_SUB:    std_logic_vector(3 downto 0) :=  "0001";	-- SUB 
constant OPCODE_OR:     std_logic_vector(3 downto 0) :=  "0010";	-- OR 
constant OPCODE_XOR:    std_logic_vector(3 downto 0) :=  "0011";	-- XOR 
constant OPCODE_AND:    std_logic_vector(3 downto 0) :=  "0100";	-- AND 
constant OPCODE_NOT:    std_logic_vector(3 downto 0) :=  "0101";	-- NOT 
constant OPCODE_READ:   std_logic_vector(3 downto 0) :=  "0110";	-- READ 
constant OPCODE_WRITE:  std_logic_vector(3 downto 0) :=  "0111";	-- WRITE 
constant OPCODE_LOAD:   std_logic_vector(3 downto 0) :=  "1000";	-- LOAD 
constant OPCODE_CMP:    std_logic_vector(3 downto 0) :=  "1001";	-- CMP 
constant OPCODE_SHL:    std_logic_vector(3 downto 0) :=  "1010";	-- SHL 
constant OPCODE_SHR:    std_logic_vector(3 downto 0) :=  "1011";  -- SHR 
constant OPCODE_JUMP:   std_logic_vector(3 downto 0) :=  "1100";	-- JUMP 
constant OPCODE_JUMPEQ: std_logic_vector(3 downto 0) :=  "1101";	-- JUMPEQ 
constant OPCODE_SPEC:   std_logic_vector(3 downto 0) :=  "1110";	-- SPECIAL
constant OPCODE_RES2:   std_logic_vector(3 downto 0) :=  "1111";  -- RESERVED 

constant OPCODE_SPEC_F2_GETPC: std_logic_vector(1 downto 0) := "00";
constant OPCODE_SPEC_F2_GETSTATUS: std_logic_vector(1 downto 0) := "01";
constant OPCODE_SPEC_F2_INT: std_logic_vector(1 downto 0) := "10";

constant OPCODE_SPEC_F2_GIEF: std_logic_vector(1 downto 0) := "00";
constant OPCODE_SPEC_F2_BBI: std_logic_vector(1 downto 0) := "01";
constant OPCODE_SPEC_F2_EI: std_logic_vector(1 downto 0) := "10";
constant OPCODE_SPEC_F2_DI: std_logic_vector(1 downto 0) := "11";


constant OPCODE_SPEC_F2_GETCOUNTLOW: std_logic_vector(1 downto 0) := "00";
constant OPCODE_SPEC_F2_GETCOUNTHIGH: std_logic_vector(1 downto 0) := "01";

-- Instruction Form Offsets
constant IFO_OPCODE_BEGIN: integer := 15;
constant IFO_OPCODE_END:   integer := 12;

constant IFO_RD_BEGIN: integer := 11;
constant IFO_RD_END:   integer := 9;

constant IFO_RA_BEGIN: integer := 7;
constant IFO_RA_END:   integer := 5;

constant IFO_RB_BEGIN: integer := 4;
constant IFO_RB_END:   integer := 2;

constant IFO_IMM_BEGIN: integer := 7;
constant IFO_IMM_END:   integer := 0;

constant IFO_F_LOC: integer := 8;

constant IFO_F2_BEGIN: integer := 1;
constant IFO_F2_END:   integer := 0;

-- Conditional jump flags
constant CJF_EQ: std_logic_vector(2 downto 0):= "000";
constant CJF_AZ: std_logic_vector(2 downto 0):= "001";
constant CJF_BZ: std_logic_vector(2 downto 0):= "010";
constant CJF_ANZ: std_logic_vector(2 downto 0):= "011";
constant CJF_BNZ: std_logic_vector(2 downto 0):= "100";
constant CJF_AGB: std_logic_vector(2 downto 0):= "101";
constant CJF_ALB: std_logic_vector(2 downto 0):= "110";

-- cmp output bits
constant CMP_BIT_EQ: integer := 14;
constant CMP_BIT_AGB: integer := 13;
constant CMP_BIT_ALB: integer := 12;
constant CMP_BIT_AZ: integer := 11;
constant CMP_BIT_BZ: integer := 10;

-- the bits are offset when writing the intermediate register
constant CMP_BIT_OFFSET: integer := 0;

-- PC unit opcodes
constant PCU_OP_NOP: std_logic_vector(1 downto 0):= "00";
constant PCU_OP_INC: std_logic_vector(1 downto 0):= "01";
constant PCU_OP_ASSIGN: std_logic_vector(1 downto 0):= "10";
constant PCU_OP_RESET: std_logic_vector(1 downto 0):= "11";

end tpu_constants;

package body tpu_constants is
 
end tpu_constants;
