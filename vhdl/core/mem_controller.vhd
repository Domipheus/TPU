----------------------------------------------------------------------------------
-- Project Name: TPU
-- Description: Memory controller unit of TPU
--
-- Very simple. Allows for delays in reads, whilsts writes go through immediately.
-- 
-- Revision: 1
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity mem_controller is
    Port ( I_clk : in  STD_LOGIC;
           I_reset : in STD_LOGIC;
			  
			  O_ready : out STD_LOGIC;
			  I_execute: in STD_LOGIC;
           I_dataWe : in  STD_LOGIC;
           I_address : in  STD_LOGIC_VECTOR (15 downto 0);
           I_data : in  STD_LOGIC_VECTOR (15 downto 0);
			  I_dataByteEn : in STD_LOGIC_VECTOR(1 downto 0);
           O_data : out  STD_LOGIC_VECTOR (15 downto 0);
			  O_dataReady: out STD_LOGIC;
			  
			  MEM_I_ready: in STD_LOGIC;
			  MEM_O_cmd: out STD_LOGIC;
           MEM_O_we : out  STD_LOGIC;
			  MEM_O_byteEnable : out STD_LOGIC_VECTOR (1 downto 0);
           MEM_O_addr : out  STD_LOGIC_VECTOR (15 downto 0);
           MEM_O_data : out  STD_LOGIC_VECTOR (15 downto 0);
           MEM_I_data : in  STD_LOGIC_VECTOR (15 downto 0);
			  MEM_I_dataReady : in STD_LOGIC
			  );
end mem_controller;

architecture Behavioral of mem_controller is

	signal we : std_logic := '0';
	signal addr : STD_LOGIC_VECTOR (15 downto 0) := X"0000";
	signal indata: STD_LOGIC_VECTOR (15 downto 0) := X"0000";
	signal byteEnable: STD_LOGIC_VECTOR ( 1 downto 0) := "11";
	signal cmd : STD_LOGIC := '0';
	signal state: integer := 0;
	
	signal ready: STD_LOGIC := '0';
	
begin

	process (I_clk, I_execute)
	begin
		if rising_edge(I_clk) then
			if I_reset = '1' then
				we <= '0';
				cmd <= '0';
				state <= 0;
			elsif state = 0 and I_execute = '1' and MEM_I_ready = '1' then
				we <= I_dataWe;
				addr <= I_address;
				indata <= I_data;
				byteEnable <= I_dataByteEn;
				cmd <= '1';
				O_dataReady <= '0';
				if I_dataWe = '0' then
					-- read
					state <= 1;
				else
					state <= 2;-- write
				end if;
			elsif state = 1 then
				cmd <= '0';
				if MEM_I_dataReady = '1' then
					O_dataReady <= '1';
					state <= 2;
				end if;
			elsif state = 2 then
				cmd <= '0';
				state <= 0;
				O_dataReady <= '0';
			end if;
		end if;
	end process;
	
	O_ready <= ( MEM_I_ready and not I_execute ) when state = 0 else '0';
	
	--
	MEM_O_cmd <= cmd;
	O_data <= MEM_I_data;
	MEM_O_byteEnable <= byteEnable;
	MEM_O_data <= indata;
	MEM_O_addr <= addr;
	MEM_O_we <= we;

end Behavioral;

