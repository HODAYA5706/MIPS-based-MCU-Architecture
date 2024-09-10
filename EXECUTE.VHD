--  Execute module (implements the data ALU and Branch Address Adder  
--  for the MIPS computer)
LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;


ENTITY  Execute IS
	PORT(	Opcode			: IN	STD_LOGIC_VECTOR( 5 DOWNTO 0 ); 
			Read_data_1 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Read_data_2 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Sign_extend 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Function_opcode : IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			ALUOp 			: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			ALUSrc 			: IN 	STD_LOGIC;
			Zero 			: OUT	STD_LOGIC;
			ALU_Result 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Add_Result 		: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			PC_plus_4 		: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			clock, reset	: IN 	STD_LOGIC );
END Execute;

ARCHITECTURE behavior OF Execute IS

component  ALUcontrol IS
	PORT(	ALUOp 	: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			Funct 	: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			Opcode 	: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			ALU_ctl : OUT   STD_LOGIC_VECTOR( 3 DOWNTO 0 ));
END component;

component  ALU IS
	PORT(	ALU_ctl 		: IN STD_LOGIC_VECTOR( 3 DOWNTO 0 ); 
			Ainput	 		: IN STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Binput 			: IN STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ALU_output_mux	: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 )
	);
END component;

SIGNAL Ainput, Binput 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL ALU_output_mux		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL Branch_Add 			: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
SIGNAL ALU_ctl				: STD_LOGIC_VECTOR( 3 DOWNTO 0 );
BEGIN
	-- ALU input muxes
	Ainput <= Read_data_2 WHEN ALUOp="11" ---for shift (sll\srl)
			  ELSE Read_data_1;
						
	Binput <= Read_data_2 WHEN ( ALUSrc = '0' ) ELSE
			  (X"0000" & Sign_extend(15 DOWNTO 0)) WHEN (Opcode="001100" OR Opcode = "001101" OR Opcode="001110") ---andi\ori\xori
			  ELSE  Sign_extend( 31 DOWNTO 0 );
			  ------------ALU control
	ALU_control: ALUcontrol
		PORT map( ALUOp => ALUOp,
				  Funct => Function_opcode,
				  Opcode => Opcode,
				  ALU_ctl => ALU_ctl);
						--ALU process
ALUprocess : ALU

	PORT map(	ALU_ctl => ALU_ctl, 
				Ainput	=> Ainput,
				Binput 	=> Binput,
				ALU_output_mux	=> ALU_output_mux
	);
						-- Generate Zero Flag 
	Zero <= '1' 
		WHEN ( ALU_output_mux( 31 DOWNTO 0 ) = X"00000000" )
		ELSE '0';    
						-- Select ALU output        
	ALU_result <= (X"0000000" & B"000"  & ALU_output_mux( 31 )) 
		WHEN  ALU_ctl = "0111" 
		ELSE  	ALU_output_mux( 31 DOWNTO 0 );
						-- Adder to compute Branch Address
	Branch_Add	<= PC_plus_4( 9 DOWNTO 2 ) +  Sign_extend( 7 DOWNTO 0 ) ;
		Add_result 	<= Branch_Add( 7 DOWNTO 0 );



END behavior;

