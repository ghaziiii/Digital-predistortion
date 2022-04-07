--* design name:   multplier.
--*
--*
--*
--* description:
--*            This design implements a complex numbers multiplier  
--*   	       @port clk			: input, clock domain
--*            @port reset_n		: input, asynchronous reset active low
--*            @port enable			: output, enable module   active high
--*            @port re_c1			: input, real part of complex coefficients c1
--*            @port re_c3			: input, real part of complex coefficients c3
--*            @port im_c1			: input, imag part of complex coefficients c1 
--*            @port im_c3			: input, imag part of complex coefficients c3
--*            @port I_in			: input, real input part     
--*            @port Q_in			: out, imag input part   
--*            @port ready			: output,ready		
--*            @port I_out			: output, real output part
--*            @port Q_out			: output, imag output part
--*       
--*      @author Ghazi Aoussaji  | ghazi.aoussaji@gmail.com
--*      @version 1.0
--*      @date created 5/23/2019
---------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.Pack.all;

ENTITY multplier IS
	PORT(		
			-- Input ports
			clk			: IN STD_LOGIC;                                  --system clock
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
END multplier;

ARCHITECTURE behavior OF multplier IS

	SIGNAL re_tmp	: signed((2*data_width)-1 DOWNTO 0);
	SIGNAL im_tmp	: signed((4*data_width)-1 DOWNTO 0);
	SIGNAL tmp	: signed((2*data_width)-1 DOWNTO 0);	
	SIGNAL tmp_1 :signed((2*data_width)-1 DOWNTO 0);
	SIGNAL tmp_2 :signed((2*data_width)-1 DOWNTO 0);
	SIGNAL tmp_3	:std_logic_vector((data_width)-1 DOWNTO 0);
	SIGNAL tmp_4	:std_logic_vector((data_width)-1 DOWNTO 0);
	SIGNAL tmp_5 :signed((data_width)-1 DOWNTO 0);
	SIGNAL tmp_6 :signed((data_width)-1 DOWNTO 0);
	SIGNAL tmp_7	:std_logic_vector((data_width)-1 DOWNTO 0);
	SIGNAL tmp_8	:std_logic_vector((data_width)-1 DOWNTO 0);
	SIGNAL tmp_9  :signed((2*data_width)-1 DOWNTO 0);
	SIGNAL tmp_10  :signed((2*data_width)-1 DOWNTO 0);
	SIGNAL tmp_11  :signed((data_width)-1 DOWNTO 0);
	SIGNAL tmp_12  :signed((2*data_width)-1 DOWNTO 0);
	SIGNAL tmp_13  :signed((2*data_width)-1 DOWNTO 0);
	SIGNAL tmp_14  :signed((data_width)-1 DOWNTO 0);
	SIGNAL ready_tmp : std_logic;
	SIGNAL ready_tmp_2 : std_logic;
	SIGNAL ready_tmp_3 : std_logic;
	SIGNAL ready_tmp_4 : std_logic;
	
BEGIN

	PROCESS(clk, reset_n)
	BEGIN
		
		IF(reset_n = '0') THEN                                  --asynchronous reset
			tmp				<= (OTHERS => '0');		
			re_tmp			<= (OTHERS => '0');		
			im_tmp			<= (OTHERS => '0');		
			ready_tmp		<= '0';                        	
			ready_tmp_2 	<= '0';
		ELSIF(clk'EVENT AND clk = '1') THEN     --not reset
			tmp <=signed(I_in)*signed(I_in) + signed(Q_in)*signed(Q_in);
			tmp_3 <= I_in;
			tmp_7 <= tmp_3;
			tmp_4 <= Q_in;
			tmp_8 <= tmp_4;
			tmp_1 <= tmp(2*data_width-3 DOWNTO data_width-2)*re_c3;
			tmp_2 <= tmp(2*data_width-3 DOWNTO data_width-2)*im_c3;
			tmp_5 <= re_c1+tmp_1(2*data_width-3 DOWNTO data_width-2);
			tmp_6 <= im_c1+tmp_2(2*data_width-3 DOWNTO data_width-2);
			tmp_9 <= tmp_5 * signed(tmp_7);
			tmp_10 <= tmp_6 * signed(tmp_8);
			tmp_11 <= tmp_9(2*data_width-3 downto data_width-2) - tmp_10(2*data_width-3 downto data_width-2);
			re_tmp <= signed((re_c1+tmp_1(2*data_width-2 DOWNTO data_width-1)))*signed(tmp_3)-signed((im_c1+(tmp_2(2*data_width-3 DOWNTO data_width-2)))*signed(tmp_4));
			-- imag output
			tmp_12 <= tmp_6 * signed(tmp_7);
			tmp_13 <= tmp_5 * signed(tmp_8);
			tmp_14 <=  tmp_12(2*data_width-3 downto data_width-2) + tmp_13(2*data_width-3 downto data_width-2);
			im_tmp <= (im_c1+tmp*im_c3)*signed(I_in)+(im_c1+tmp*im_c3)*signed(Q_in); 													
			ready_tmp_2<= '1';
			ready_tmp_3<= ready_tmp_2;
			ready_tmp_4<= ready_tmp_3;
			ready_tmp <= ready_tmp_4;
			
		END IF;
	END PROCESS;
	ready <= ready_tmp;
	I_out <= std_logic_vector(  tmp_11); 
	Q_out <= std_logic_vector(  tmp_14);   
END behavior;

