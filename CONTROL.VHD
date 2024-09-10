		-- control module (implements MIPS control unit)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY control IS
   PORT( 
	Funct		: IN	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	Opcode 		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	RegDst 		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	ALUSrc 		: OUT 	STD_LOGIC;
	MemtoReg 	: OUT 	STD_LOGIC;
	RegWrite 	: OUT 	STD_LOGIC;
	MemRead 	: OUT 	STD_LOGIC;
	MemWrite 	: OUT 	STD_LOGIC;
	beq 		: OUT 	STD_LOGIC;
	bne			: OUT	STD_LOGIC;
	ALUop 		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	Jump		: OUT	STD_LOGIC;
	Jal			: OUT	STD_LOGIC;
	Jr			: OUT	STD_LOGIC;
	PC_EN		: OUT	STD_LOGIC;
	INTER_CLK   : OUT   STD_LOGIC_VECTOR(3 DOWNTO 0);
	INT_R		: IN	STD_LOGIC;
	INT_A		: OUT	STD_LOGIC;
	clock, reset	: IN 	STD_LOGIC );

END control;

ARCHITECTURE behavior OF control IS

	SIGNAL  R_format, Lw, Sw,branch,Shift,addi,andi,ori,xori,lui,slti,Jr_temp,Jal_temp,mul 	: STD_LOGIC;---???
	SIGNAL	INTER_CLK_temp : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN           
				-- Code to generate control signals using opcode bits
	R_format 	<=  '1'  WHEN  Opcode = "000000"  ELSE '0';
	Lw          <=  '1'  WHEN  Opcode = "100011"  ELSE '0';
 	Sw          <=  '1'  WHEN  Opcode = "101011"  ELSE '0';
   	branch	    <=  '1'  WHEN  Opcode = "000100" OR Opcode = "000101" ELSE '0';
	Shift		<=	'1'	 WHEN  Opcode = "000000" AND (Funct = "000000" OR Funct = "000010")  ELSE '0';
	addi		<=	'1'	 WHEN  Opcode = "001000" ELSE '0';
	andi		<=	'1'	 WHEN  Opcode = "001100" ELSE '0';
	ori			<=	'1'	 WHEN  Opcode = "001101" ELSE '0';
	xori		<=	'1'	 WHEN  Opcode = "001110" ELSE '0';
	lui			<=	'1'	 WHEN  Opcode = "001111" ELSE '0';
	slti		<=	'1'	 WHEN  Opcode = "001010" ELSE '0';
	Jr_temp		<=	'1'	 WHEN  Opcode = "000000" AND Funct = "001000" ELSE '0';
	Jal_temp	<=	'1'	 WHEN  Opcode = "000011"  ELSE '0';
	mul			<=	'1'  WHEN  Opcode = "011100"  ELSE '0';
				-- outputs
	Jump		<=	'1'	 WHEN  Opcode = "000010" OR Opcode = "000011" OR INTER_CLK_temp = "0010" ELSE '0'; ---for emulatuve Jal
	Jr			<=  '1' WHEN Jr_temp='1' OR INTER_CLK_temp = "0010" ELSE '0'; ---for emulatuve Jal
	Jal			<=  Jal_temp; 
  	RegDst(0)  	<=  '1' WHEN R_format = '1' OR mul = '1' OR INTER_CLK_temp = "0010" ELSE '0';
	RegDst(1)	<=	'1' WHEN Jal_temp='1' OR INTER_CLK_temp = "0010" ELSE '0';
 	ALUSrc  	<=  '1'	 WHEN  addi='1' OR andi='1' OR ori='1' OR xori='1' OR lui='1' OR lw='1' OR sw='1' OR slti='1' OR Shift='1' ELSE '0'; ---addi,andi,ori,xori,lui,lw,sw,slti,sll,srl
	MemtoReg 	<=  Lw;
  	RegWrite 	<=  '1'	 WHEN (R_format='1' and ( Jr_temp/='1')) OR addi='1' OR andi='1' OR ori='1'
                              	OR xori='1' OR Lw='1' OR lui='1' OR slti='1' OR Jal_temp='1' OR mul='1'
								OR INTER_CLK_temp = "0010" ELSE '0'; --for emulatuve Jal 
  	MemRead 	<=  '1' WHEN Lw='1' OR INTER_CLK_temp = "0010" ELSE '0';---for emulatuve Jal
   	MemWrite 	<=  Sw; 
 	beq	        <=  '1'  WHEN  Opcode = "000100" ELSE '0';
	bne			<=	'1'  WHEN  Opcode = "000101" ELSE '0';
	ALUOp( 1 ) 	<=  R_format;
	ALUOp( 0 ) 	<=  '1'	 WHEN branch='1' OR Shift='1' ELSE '0'; 
	
	process(clock,INT_R,reset,Jr_temp)
		begin
			if reset='1' then
				INTER_CLK_temp <= "0000";
				PC_EN <='1';
			elsif (INT_R = '1' and reset = '0' and INTER_CLK_temp = "0000") and rising_edge(clock) then
				INTER_CLK_temp <= "0001";
				PC_EN <= '0';
			elsif rising_edge(clock) and INTER_CLK_temp = "0001" then 
				INT_A <= '0';
				INTER_CLK_temp <= "0010";
			elsif rising_edge(clock) and INTER_CLK_temp = "0010" then 
				INTER_CLK_temp <= "0100";
				PC_EN <= '1';
			elsif rising_edge(clock) and INTER_CLK_temp = "0100" then 
				
				INT_A <= '1';
				if Jr_temp = '1' then
					INTER_CLK_temp <= "1000" ;
				end if;
			elsif rising_edge(clock) and INTER_CLK_temp = "1000" then 	
				INTER_CLK_temp <= "0000" ;
			END if;
	END process;
	
	INTER_CLK <= INTER_CLK_temp;

   END behavior;


