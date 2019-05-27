library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.math_real.all;
package Pack is




	CONSTANT taps        : INTEGER := 16; --number of fir filter taps
	CONSTANT data_width  : INTEGER := 12; --width of data input including sign bit
	CONSTANT coeff_width : INTEGER := 12; --width of coefficients including sign bit
	
	TYPE coefficient_array 	IS ARRAY (0 TO taps-1) 	OF STD_LOGIC_VECTOR(coeff_width-1 DOWNTO 0);  --array of all coefficients
	TYPE data_array 	IS ARRAY (0 TO 2*taps-1) OF SIGNED(data_width-1 DOWNTO 0);                    --array of historic data values
	TYPE product_array 	IS ARRAY (0 TO taps-1) 	OF SIGNED((data_width + coeff_width)-1 DOWNTO 0); --array of coefficient * data products
component fir_n_o IS
	PORT(
			clk		: IN STD_LOGIC;                                  --system clock
			reset_n		: IN STD_LOGIC;                                  --active low asynchronous reset
			enable		: IN STD_LOGIC;		
			ready		: OUT STD_LOGIC;	
			data		: IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);    --data stream
			result		: OUT STD_LOGIC_VECTOR(data_width-1 downto 0)--((data_width + coeff_width + integer(ceil(log2(real(taps)))) - 1) DOWNTO 0)
);  --filtered result
END component;
component multplier IS
	PORT(		
			-- Input ports
			clk		: IN STD_LOGIC;                                  --system clock
			reset_n		: IN STD_LOGIC;                                  --active low asynchronous reset
			enable		: IN STD_LOGIC;		
			re_c1		: IN signed(data_width-1 DOWNTO 0);	-- real part of first order coeff
			re_c3		: IN signed(data_width-1 DOWNTO 0);	-- real part of third order coeff
			im_c1		: IN signed(data_width-1 DOWNTO 0);	-- imag part of first order coeff
			im_c3		: IN signed(data_width-1 DOWNTO 0);	-- imag part of third order coeff
			I_in		: IN std_logic_vector(data_width-1 DOWNTO 0);
			Q_in		: IN std_logic_vector(data_width-1 DOWNTO 0); 
			-- Output ports
			ready		: OUT STD_LOGIC;	  
			I_out		: OUT std_logic_vector(data_width-1 DOWNTO 0);
			Q_out		: OUT std_logic_vector(data_width-1 DOWNTO 0)

); 
END component;
   component FIFO is
	
	Generic (
		constant pointer_len	: positive := 4;
		constant DATA_WIDTH  	: positive := 12;
		constant N		: positive := 3		-- padding factor
	);
	Port ( 
		Clk1 		: in  STD_LOGIC;		
		Clk2		: in  STD_LOGIC;
		Reset_n		: in  STD_LOGIC;
		Write_en	: in  STD_LOGIC;
		Data_in		: in  STD_LOGIC_VECTOR (data_width - 1 downto 0);
		Read_en		: in  STD_LOGIC;
		Data_out	: out STD_LOGIC_VECTOR (data_width - 1 downto 0);
		Ready		: out STD_LOGIC;
		Empty		: out STD_LOGIC;
		Full		: out STD_LOGIC
	);
end component;

 component DUC is
	Generic (
		constant pointer_len	: positive :=4;
		constant DATA_WIDTH  	: positive := 12;
		constant N		:positive  := 3

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
end  component;
 

Component fir IS
	PORT(

			clk		: IN STD_LOGIC;                                  --system clock
			reset_n		: IN STD_LOGIC;                                  --active low asynchronous reset
			enable		: IN STD_LOGIC;		
			ready		: OUT STD_LOGIC;	
			data		: IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0 );    --data stream
			result		: OUT STD_LOGIC_VECTOR(data_width-1 downto 0 ) -- ( data_width + coeff_width + integer(ceil(log2(real(taps)))) - 1 DOWNTO 0)
);  --filtered result
END component;


component DPD IS
	PORT(		
			-- Input ports
			Clk1		: IN STD_LOGIC;                                  --system clock
			Clk2		: IN STD_LOGIC;
			reset_n		: IN STD_LOGIC;                                  --active low asynchronous reset
			enable		: IN STD_LOGIC;		
			re_c1		: IN signed(data_width-1 DOWNTO 0);	-- real part of first order coeff
			re_c3		: IN signed(data_width-1 DOWNTO 0);	-- real part of third order coeff
			im_c1		: IN signed(data_width-1 DOWNTO 0);	-- imag part of first order coeff
			im_c3		: IN signed(data_width-1 DOWNTO 0);	-- imag part of third order coeff
			I_in		: IN std_logic_vector(data_width-1 DOWNTO 0);
			Q_in		: IN std_logic_vector(data_width-1 DOWNTO 0); 
			-- Output ports
			ready		: OUT STD_LOGIC;	  
			I_out		: OUT std_logic_vector(data_width-1 DOWNTO 0);
			Q_out		: OUT std_logic_vector(data_width-1 DOWNTO 0)

); 
END component;
end package;


