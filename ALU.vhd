LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;


ENTITY  ALU IS
	PORT(	ALU_ctl 		: IN STD_LOGIC_VECTOR( 3 DOWNTO 0 ); 
			Ainput	 		: IN STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Binput 			: IN STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ALU_output_mux	: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 )
	);
END ALU;

ARCHITECTURE ALUprocess OF ALU IS
BEGIN


------------ ALU Proces -----------------------------
	PROCESS ( ALU_ctl, Ainput, Binput )
		BEGIN
	--------------- ALU operation ---------------------
		CASE ALU_ctl IS
			-- ALU performs ALUresult = A_input AND B_input
			WHEN "0000" 	=>	ALU_output_mux 	<= Ainput AND Binput; 
			-- ALU performs ALUresult = A_input OR B_input
			WHEN "0001" 	=>	ALU_output_mux 	<= Ainput OR Binput;
			-- ALU performs ALUresult = A_input + B_input
			WHEN "0010" 	=>	ALU_output_mux 	<= Ainput + Binput; 
			-- ALU performs ALUresult = A_input * B_input
			WHEN "0011" 	=>	ALU_output_mux <= Ainput(15 DOWNTO 0) * Binput(15 DOWNTO 0);
			-- ALU performs ALUresult = A_input XOR B_input
			WHEN "0100" 	=>	ALU_output_mux 	<= Ainput XOR Binput;
			-- ALU performs ALUresult = A_input SLL B_input
			WHEN "0101" 	=>	ALU_output_mux 	<=	std_logic_vector(shift_left(unsigned(Ainput),to_integer(unsigned(Binput(10 downto 6)))));

			-- ALU performs ALUresult = A_input SRL B_input
			WHEN "1000" 	=>	ALU_output_mux 	<=	std_logic_vector(shift_right(unsigned(Ainput),to_integer(unsigned(Binput(10 downto 6))))); 

			-- ALU performs ALUresult = A_input -B_input
			WHEN "0110"	=>	ALU_output_mux 	<= Ainput - Binput; 
			-- ALU preforms slt/slti
			WHEN "0111"	=>	ALU_output_mux 	<= Ainput - Binput; 
			-- ALU performs LUI
			WHEN "1001" 	=>	ALU_output_mux 	<= Binput(15 DOWNTO 0) & "0000000000000000";
			-- OUTPUT ZERO
			WHEN OTHERS	=>	ALU_output_mux 	<= X"00000000" ;
		END CASE;
	END PROCESS;
	
END ALUprocess;