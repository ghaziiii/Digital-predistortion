--* design name:   tb_fir .
--*
--*
--*
--* description:
--*            This design implements a test banch for fir filter 
--*         
--*      @author Ghazi Aoussaji  | ghazi.aoussaji@gmail.com
--*      @version 1.0
--*      @date created 5/20/2019
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Pack.all; 
use STD.textio.all;
use ieee.std_logic_textio.all;
entity tb_fir is 
end entity tb_fir;

architecture rtl of tb_fir is


  

	signal  clk	:	std_logic;
	signal  reset_n	:	std_logic;
	signal  enable	:	std_logic;
	signal  ready	:	std_logic;
	signal  data	:	STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
	signal  result	:	STD_LOGIC_VECTOR(data_width-1 downto 0); --((data_width + coeff_width + integer(ceil(log2(real(taps)))) - 1) DOWNTO 0);  --filtered result
	file my_input 	: TEXT open READ_MODE is "re_in.txt";  
 	file my_output 	: TEXT open WRITE_MODE is "output.txt";
begin
	uttt : fir
		PORT MAP (
			clk		=> clk,
			reset_n		=> reset_n,
			data		=> data,
			enable		=> enable,
			ready		=> ready,
			result		=> result
		);
	CLK_process1 :process
	begin
	clk<='0';
	wait for 10 ns;
	clk<='1';
	wait for 10 ns;
	end process;

 	-- Reset process
	rst_proc : process
	begin
	--wait for CLK_period * 5;
		reset_n <= '0';
		wait for 20 ns;
		reset_n <= '1';
		wait;
	end process;
 	-- enable process
	enable_proc : process
	begin
	--wait for CLK_period * 5;
		enable <= '0';
		wait for 30 ns;
		enable <= '1';
		wait;
	end process;
	
           process(clk)  
           	variable my_input_line : LINE;  
           	variable input1: std_logic_vector(data_width-1 downto 0);  
		--variable str_stimulus_in: string(data_width downto 1);
           	begin  
                	if rising_edge(clk) then                      
                     		readline(my_input, my_input_line);  
                     		read(my_input_line,input1);  
                     		--data <= std_logic_vector(to_unsigned(input1, DATA_WIDTH));  
				data <= input1;
                     
                      
                	end if;  
           end process;                      
           process(clk)  
           variable my_output_line : LINE;  
           variable input1: std_logic_vector(data_width-1 downto 0); 
	   
           begin  
                if falling_edge(clk) then  
                     if ready ='1' then  
                          write(my_output_line, to_integer(signed(result)));  
                          writeline(my_output,my_output_line);  
                     end if;  
                end if;  
           end process;


end architecture rtl;


