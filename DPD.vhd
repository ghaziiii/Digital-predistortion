--* design name:   DPD (Digital Predistortion).
--*
--*
--*
--* description:
--*            This design implements a complex numbers multiplier  
--*   	       @port clk1			: input, input clock domain
--*   	       @port clk2			: output, input clock domain
--*            @port reset_n			: input, asynchronous reset active low
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

ENTITY DPD IS
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
END DPD;

ARCHITECTURE behavior OF DPD IS

	signal r1	:std_logic; 									-- to link the ready of the real DUC to the filter enable
	signal r2	:std_logic; 									-- to link the ready of the imag DUC to the filter enable
	signal r3	:std_logic; 									-- to link the ready of the real fir filter  to the multipiler enable
	signal r4	:std_logic; 									-- to link the ready of the imag fir filter  to the multipiler enable
	signal e1	:std_logic; 									-- to link the empty of the real DUC to ... 
	signal e2	:std_logic; 									-- to link the empty of the imag DUC to ... 
	signal f1	:std_logic; 									-- to link the full of the real DUC to ... 
	signal f2	:std_logic; 									-- to link the full of the imag DUC to ...
	SIGNAL tmp_1 :std_logic_vector(data_width-1 DOWNTO 0);    	-- to link the the real DUC output to the filter 
	SIGNAL tmp_2 :std_logic_vector(data_width-1 DOWNTO 0);    	-- to link the the imag DUC output to the filter 
	SIGNAL tmp_3 :std_logic_vector(data_width-1 DOWNTO 0);    	-- to link the the real fir filter output to the multiplier input 
	SIGNAL tmp_4	:std_logic_vector(data_width-1 DOWNTO 0);   -- to link the the imag fir filter output to the multiplier input 

	
BEGIN
-- real part DUC
u1 : DUC 
generic map(
    	pointer_len	=> 4,
    	DATA_WIDTH  	=> 12,
    	N  		=> 3
	)
	port map (
    				
	Clk1    	=> Clk1 ,
	Clk2		=> Clk2	,
	Reset_n		=>	Reset_n ,
	Write_en 	=> enable,	
	Data_in		=> I_in,
	Read_en	  	=> enable, 	
    	Data_out	=> tmp_1,
    	Ready		=> r1,
    	Empty		=> e1,
	Full		=> f1
	);
	
u2 : DUC
generic map(
    	pointer_len	=> 4,
    	DATA_WIDTH  	=> 12,
    	N  		=> 3
	)
	port map (
    				
	Clk1    	=> Clk1 ,
	Clk2		=> Clk2	,
	Reset_n		=>	Reset_n ,
	Write_en 	=> enable,	
	Data_in		=> Q_in,
	Read_en	  	=> enable, 	
    	Data_out	=> tmp_2,
    	Ready		=> r2,
    	Empty		=> e2,
	Full		=> f2
	);	
u3 : fir 

port map(
clk		=> clk2,			
reset_n		=>reset_n	,
enable		=>r1,	
ready		=>r3,	
data		=> tmp_1,
result		=> tmp_3	
	
);

u4 : fir
port map(
clk		=> clk2,			
reset_n		=>reset_n	,
enable		=>r2,	
ready		=>r4,	
data		=> tmp_2,
result		=> tmp_4	
	
);

u5 : multplier

port map(

	clk		=> clk2,
	reset_n		=> reset_n,
	enable		=> r3,
	re_c1		=> re_c1,
	re_c3		=> re_c3,
	im_c1		=> im_c1,
	im_c3		=> im_c3,
	I_in		=> tmp_3,
	Q_in		=> tmp_4,
	-- Output 
	ready		=> ready,
	I_out		=> I_out,
	Q_out		=> Q_out
	);

END behavior;

