-- MIT License

-- Copyright (c) 2023 Ghazi Aousaji

-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
-- to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
-- IN THE SOFTWARE.

--************************************************************************
--* design name:   Asynchronous FIFO (w/ 2 asynchronous clocks).
--*
--*
--*
--* description:
--*            This design implements an asynchronous FIFO  
--*   	       @port reset_n  	: input, asynchronous reset active low
--*            @port Clk1      	: input, write clock domain
--*	       @port Clk1      	: input, read clock domain
--*            @port Data_out  	: output, enable module   active high
--*            @port Empty 	: output, empty flag
--*            @port Read_en 	: input, pop data when high
--*            @port Data_in   	: input,data input 
--*            @port Full  	: output,full flag
--*            @port Write_en	: in, push data when high     
--*            @port Ready 	: out, ready flag           
--*      @author Ghazi Aoussaji  | ghazi.aoussaji@gmail.com
--*      @version 1.0
--*      @date created 5/16/2019
---------------------------------------------------------------------
library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
 
entity FIFO is
	Generic (
		constant pointer_len	: positive :=4;
		constant DATA_WIDTH  	: positive := 12

	);
	Port ( 
		Clk1 		: in  STD_LOGIC;	-- writing clk	
		Clk2		: in  STD_LOGIC;	-- reading clk
		Reset_n		: in  STD_LOGIC;	
		Write_en	: in  STD_LOGIC;
		Data_in		: in  STD_LOGIC_VECTOR (data_width - 1 downto 0);
		Read_en		: in  STD_LOGIC;
		Data_out	: out STD_LOGIC_VECTOR (data_width - 1 downto 0);
		Ready		: out STD_LOGIC;
		Empty		: out STD_LOGIC;
		Full		: out STD_LOGIC
	);
end FIFO;
 
architecture Behavioral of FIFO is
 
 constant FIFO_DEPTH	: positive := 2**pointer_len;
 -- Generating the memory array
 type FIFO_Memory is array (0 to FIFO_DEPTH - 1) of STD_LOGIC_VECTOR (data_width - 1 downto 0);
 signal Memory 		: FIFO_Memory :=(others =>(others => '0'));
 signal data_out_tmp	: std_logic_vector(data_width - 1 downto 0);
 signal Ready_tmp	: std_logic ;
 signal Head 		: std_logic_vector(pointer_len downto 0); -- with an over flow bit
 signal Tail 		: std_logic_vector(pointer_len downto 0);-- same
 signal Full_t		: std_logic; 
 signal Empty_t		: std_logic; 

begin


	-- Writing into memory Process
	write_proc : process (Clk1, reset_n)
	begin
		if reset_n 	= '0' then
		Head <=  (others=>'0');

		elsif rising_edge(Clk1) then
			if (write_en = '1') then
				if (Full_t/='1') then
					-- Write Data to Memory
					Memory(conv_integer(Head)) <= Data_in;
						
					-- Increment Head pointer as needed
					if (conv_integer(Head) = FIFO_DEPTH - 1) then
						Head 	<= (others=>'0');
						
					else
						Head 	<= std_logic_vector(unsigned(Head+1));
					end if;

				end if;
			end if;
		end if;
	end process;
	
	read_proc : process (Clk2, reset_n)
	begin
		if reset_n 	= '0' then
			data_out_tmp <= (others => '0');
			Tail <= (others=>'0');
			Full_t  <= '0';
			Empty_t <= '1';
			
			
		elsif (Read_en = '1') then
			if (Empty_t/='1') then
				-- Update data output
				data_out_tmp 	<= Memory(conv_integer(Tail));
				Ready_tmp 	<= '1';
				
				-- Update Tail pointer as needed
				if (unsigned(Tail) = FIFO_DEPTH - 1) then
					Tail 	<=  (others=>'0');
				else
					Tail 	<= std_logic_vector(unsigned(Tail) + 1);
				end if;
				

			end if;


		end if;
		-- Update Empty and Full flags
		if (Head = Tail) then
			if Head(pointer_len)= Tail(pointer_len) then
				Empty_t <= '1';
			else
				Full_t 	<= '1';
			end if;
		else
			Empty_t	<= '0';
			Full_t	<= '0';
		end if;
	
end process;

-- Assignment Statements
Full <= Full_t;
Empty <= Empty_t;
Data_out <= data_out_tmp;
Ready <= Ready_tmp;

end Behavioral;

