--************************************************************************
--* design name:   tb_DUC (w/ 2 asynchronous clocks).
--*
--*
--*
--* description:
--*            This design implements a test banch for digital upconverter with asynchronous FIFO  
--*         
--*      @author Ghazi Aoussaji  | ghazi.aoussaji@gmail.com
--*      @version 1.0
--*      @date created 5/17/2019
---------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.Pack.all;
ENTITY tb_DUC IS
END tb_DUC;

ARCHITECTURE behavior OF tb_DUC IS 

	
		signal Clk1 		 : STD_LOGIC;		
		signal Clk2		  :STD_LOGIC;
		signal Reset_n		  :STD_LOGIC;
		signal Write_en	 	  :STD_LOGIC;
		signal Data_in		  :STD_LOGIC_VECTOR (data_width - 1 downto 0);
		signal Read_en		  :STD_LOGIC;
		signal Data_out		:STD_LOGIC_VECTOR (data_width - 1 downto 0);
		signal Ready		: STD_LOGIC;
		signal Empty		: STD_LOGIC;
		signal Full		 :STD_LOGIC;
	
	-- Clock period definitions
	constant CLK_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: DUC
		Generic map(
		DATA_WIDTH  	=> 12,
		pointer_len	=> 4,
		N		=> 3		-- padding factor
	)
	Port map( 
		Clk1 		=> Clk1,		
		Clk2		=> Clk2,
		Reset_n		=>Reset_n,
		Write_en	=>Write_en,
		Data_in		=>Data_in,
		Read_en		=>Read_en	,
		Data_out	=>Data_out,
		Ready		=>Ready	,
		Empty		=>Empty	,
		Full		=>Full
	);
	
	-- Clock process definitions
	CLK1_process :process
	begin
		clk1 <= '0';
		wait for CLK_period*2;
		clk1 <= '1';
		wait for CLK_period*2;
	end process;
		CLK2_process :process
	begin
		clk2 <= '0';
		wait for CLK_period/2;
		clk2 <= '1';
		wait for CLK_period/2;
	end process;
	-- Reset process
	rst_proc : process
	begin
	
		reset_n <= '0';
		
		wait for CLK_period * 1;
		
		reset_n <= '1';
		
		wait;
	end process;
	
	-- Write process
	wr_proc : process
		variable count : integer := 0;
	begin		
		Data_in<=(others=>'0');
		wait for CLK_period/2;
		for i in 1 to 50 loop
			count:= count + 1;
			
			Data_in <= std_logic_vector(to_unsigned(count,DATA_WIDTH));
			
			wait for CLK_period*4;
		end loop;
		wait;
	end process;
	

			write_en_proc :process
			begin
			Write_en <= '0';
			wait for CLK_period * 1;
			Write_en <= '1';
			wait for CLK_period * 30;
			end process;
	-- Read process
	rd_proc : process
	begin
		
		
			
		Read_en <= '0';
		
		wait for CLK_period * 5;
		
		Read_en <= '1';
		wait for CLK_period * 40;
		
	end process;

END;

