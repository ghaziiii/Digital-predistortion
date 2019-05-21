--************************************************************************
--* design name:   fir (finite impulse response filter).
--*
--*
--*
--* description:
--*            This design implements a fir filter with 32 symetric taps 
--*   	       @port reset_n  	: input, asynchronous reset active low
--*            @port Clk1      	: input, clock 
--*            @port enable 	: input, enable active high
--*            @port data   	: input,data input 
--*            @port result  	: output,output data    
--*            @port Ready 	: out, ready flag           
--*      @author Ghazi Aoussaji  | ghazi.aoussaji@gmail.com
--*      @version 1.0
--*      @date created 5/20/2019
---------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.math_real.all;
USE work.Pack.all;

ENTITY fir IS
	PORT(
			clk		: IN STD_LOGIC;                                  --system clock
			reset_n		: IN STD_LOGIC;                                  --active low asynchronous reset
			enable		: IN STD_LOGIC;		
			ready		: OUT STD_LOGIC;	
			data		: IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);    --data stream
			result		: OUT STD_LOGIC_VECTOR(data_width-1 downto 0)--((data_width + coeff_width + integer(ceil(log2(real(taps)))) - 1) DOWNTO 0)
);  --filtered result
END fir;

ARCHITECTURE behavior OF fir IS
	--SIGNAL coeff_int	: coefficient_array; --array of latched in coefficient values
	signal coeff_int:coefficient_array:=(
		"111111110010",
    		"000000010001",
    		"000000100101",
    		"000000010100",
    		"111111100111",
    		"111111001011",
   		"111111100011",
    		"000000100100",
    		"000001010000",
    		"000000101110",
    		"111111000110",
    		"111101110011",
    		"111110100110",
    		"000010000011",
    		"000110110001",
    		"001010001010"
	);
	SIGNAL data_pipeline	: data_array;        --pipeline of historic data values
	SIGNAL products 	: product_array;     --array of coefficient*data products
	SIGNAL out_tmp		:STD_LOGIC_VECTOR((data_width + coeff_width + integer(ceil(log2(real(taps)))) - 1) DOWNTO 0);
BEGIN

	PROCESS(clk, reset_n)
		VARIABLE sum : SIGNED((data_width + coeff_width + integer(ceil(log2(real(taps)))) - 1) DOWNTO 0); --sum of products
	BEGIN
		ready <='0';
		IF(reset_n = '0') THEN                               	--asynchronous reset
		
			data_pipeline <= (OTHERS =>  (OTHERS => '0'));	--clear data pipeline values
			out_tmp <= (OTHERS => '0');                  	--clear result output
			
		ELSIF(clk'EVENT AND clk = '1' and enable ='1') THEN	--not reset
											--input coefficients		
			data_pipeline <= SIGNED(data) & data_pipeline(0 TO 2*taps-2);	--shift new data into data pipeline
			sum := (OTHERS => '0');                                     	--initialize sum
			FOR i IN 0 TO taps-1 LOOP
				sum := sum + products(i);                       	--add the products
			END LOOP;
			
			out_tmp <= STD_LOGIC_VECTOR(sum);	                   	--output result
			ready <= '1';
		END IF;
	END PROCESS;
	
	--perform multiplies
	product_calc: FOR i IN 0 TO taps-1 GENERATE
		products(i) <= (data_pipeline(i)+data_pipeline(2*taps-1-i)) * SIGNED(coeff_int(i));
	END GENERATE;
	result <= out_tmp(2*data_width-1 downto data_width);
END behavior;

