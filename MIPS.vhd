				-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY MIPS IS
	GENERIC(sim					:integer:=10); ---8:Modelsim, 10:Quartus
	PORT( reset, clock					: IN 	STD_LOGIC; 
		-- Output important signals to pins for easy display in Simulator
		PC								: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		DataBus						    : INOUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		AddresBus						: OUT STD_LOGIC_VECTOR( 11 DOWNTO 0 );
		ALU_result_out, read_data_1_out, read_data_2_out, write_data_out,	
     	Instruction_out					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		Branch_out, Zero_out, Memwrite_out,MemRead_out,
		Regwrite_out					: OUT 	STD_LOGIC;
		GIE,INT_A								: OUT STD_LOGIC;
		INT_R							: IN 	STD_LOGIC		
		); 
END 	MIPS;

ARCHITECTURE structure OF MIPS IS


	COMPONENT Ifetch
		 GENERIC(sim					:integer:=10); ---8:Modelsim, 10:Quartus
   	     PORT(	Instruction 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				PC_plus_4_out 	: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
				Add_result 		: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
				beq 			: IN 	STD_LOGIC;
				bne				: IN	STD_LOGIC;
				Zero 			: IN 	STD_LOGIC;
				Jump				: IN 	STD_LOGIC; ---output of control
				Jr				: IN 	STD_LOGIC; ---output of control
				JampAddr		 	: IN	STD_LOGIC_VECTOR( 7 DOWNTO 0 ); ---output of the devode
				read_data_1		: IN	STD_LOGIC_VECTOR( 31 DOWNTO 0 ); ---output of decode
				PC_out 			: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
				read_data_DM	: IN STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				clock, reset 	: IN 	STD_LOGIC ;
				PC_EN           : IN    STD_LOGIC ;
				Next_PC_OUT          : OUT  STD_LOGIC_VECTOR( 7 DOWNTO 0 )
				);
	END COMPONENT; 

	COMPONENT Idecode
 	     PORT(	read_data_1	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				read_data_2	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Instruction : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				read_data_DM 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				ALU_result	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				RegWrite 	: IN 	STD_LOGIC;
				MemtoReg 	: IN 	STD_LOGIC;
				RegDst 		: IN 	STD_LOGIC_VECTOR(1 DOWNTO 0);
				Jal			: IN	STD_LOGIC;
				PC_plus_4 	: IN	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
				Sign_extend : OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				JampAddr		: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
				Jr				: IN	STD_LOGIC;
				GIE			: OUT STD_LOGIC;
				INTER_CLK   : IN STD_LOGIC_VECTOR( 3 DOWNTO 0 );
				PC 	: IN	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
				clock,reset	: IN 	STD_LOGIC );
	END COMPONENT;

	COMPONENT control
	     PORT(	Funct		: IN	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
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
	END COMPONENT;

	COMPONENT  Execute
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
	END COMPONENT;


	COMPONENT dmemory
		GENERIC(sim					:integer:=10); ---8:Modelsim, 10:Quartus
		PORT(	read_data_DM 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				address 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				ADRESS_BUS			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				MemRead, Memwrite 	: IN 	STD_LOGIC;
				INTER_CLK           : IN    STD_LOGIC_VECTOR( 3 DOWNTO 0 );
				clock,reset			: IN 	STD_LOGIC);
	END COMPONENT;


	COMPONENT BidirPin
		GENERIC( WIDTH: INTEGER:=16 );
		PORT(   Dout: 	IN 		STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
				en:		IN 		STD_LOGIC;
				Din:	OUT		STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
				IOpin: 	INOUT 	STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0)
		);
	END COMPONENT;


					-- declare signals used to connect VHDL components
	SIGNAL PC_plus_4 		: STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL read_data_1 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_data_2 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Sign_Extend 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Add_result 		: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL ALU_result 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_data_DM 	: STD_LOGIC_VECTOR( 31 DOWNTO 0 ); --
	SIGNAL ALUSrc 			: STD_LOGIC;
	SIGNAL beq 				: STD_LOGIC;
	SIGNAL bne				: STD_LOGIC;
	SIGNAL RegDst 			: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL Regwrite 		: STD_LOGIC;
	SIGNAL Zero 			: STD_LOGIC;
	SIGNAL MemWrite 		: STD_LOGIC;
	SIGNAL MemtoReg 		: STD_LOGIC;
	SIGNAL MemRead 			: STD_LOGIC;
	SIGNAL Jump 			: STD_LOGIC;
	SIGNAL Jr 		 		: STD_LOGIC;
	SIGNAL Jal 		 		: STD_LOGIC;	
	SIGNAL JampAddr 		: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL ALUop 			: STD_LOGIC_VECTOR(  1 DOWNTO 0 );
	SIGNAL Instruction		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL en_write_DM      : STD_LOGIC;
	SIGNAL Data_From_Bus	: STD_LOGIC_VECTOR( 31 DOWNTO 0 ); 
	SIGNAL read_data_DM_temp: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL PC_EN			: STD_LOGIC;
	SIGNAL INTER_CLK		: STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL PC_out			: STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL Next_PC_OUT			: STD_LOGIC_VECTOR( 7 DOWNTO 0 );

BEGIN


					-- copy important signals to output pins for easy 
					-- display in Simulator
   Instruction_out 	<= Instruction;
   ALU_result_out 	<= ALU_result;
   read_data_1_out 	<= read_data_1;
   read_data_2_out 	<= read_data_2;
   write_data_out  	<= read_data_DM WHEN MemtoReg = '1' ELSE ALU_result;
   Branch_out 		<= '1' WHEN beq='1' OR bne='1' ELSE '0';
   Zero_out 		<= Zero;
   RegWrite_out 	<= RegWrite;
   MemWrite_out 	<= MemWrite;	
   MemRead_out      <= MemRead;

   ------------------------------BUS-----------------------------------------

BiDirPin_Date: BidirPin
GENERIC MAP ( 32 )
PORT MAP (	Dout 		=> read_data_2,  
			en	=> en_write_DM,
			Din			=> Data_From_Bus,    
			IOpin 		=> dataBus);

   
   AddresBus <= ALU_Result (11 DOWNTO 0);
   en_write_DM	<= '1' WHEN (MemWrite = '1' AND ALU_Result(11) = '1') ELSE '0'; -- en write to the bus from SFR (special function register)
   read_data_DM <= read_data_DM_temp WHEN (ALU_Result(11) = '0')  ELSE Data_From_Bus; ---read from dmem or from SFR (special function register) to the bus



--------------------------PC_EN-----------------------------




					-- connect the 5 MIPS components   
  IFE : Ifetch
    GENERIC MAP(sim		=> sim ) ---8:Modelsim, 10:Quartus
	PORT MAP (	Instruction 	=> Instruction,
    	    	PC_plus_4_out 	=> PC_plus_4,
				Add_result 		=> Add_result,
				beq 			=> beq,
				bne				=> bne,
				Zero 			=> Zero,
				Jump			=> Jump,
				Jr				=> Jr,
				JampAddr		=> JampAddr,
				read_data_1 	=> read_data_1,				
				PC_out 			=> PC_out, 
				read_data_DM	=> read_data_DM_temp,
				clock 			=> clock,  
				reset 			=> reset,
				PC_EN          => PC_EN,
				Next_PC_OUT        => Next_PC_OUT				
				);

   ID : Idecode
   	PORT MAP (	read_data_1 	=> read_data_1,
        		read_data_2 	=> read_data_2,
        		Instruction 	=> Instruction,
        		read_data_DM 	=> read_data_DM,
				ALU_result 		=> ALU_result,
				RegWrite 		=> RegWrite,
				MemtoReg 		=> MemtoReg,
				RegDst 			=> RegDst,
				Jal				=> Jal,
				PC_plus_4 		=> PC_plus_4,
				Sign_extend 	=> Sign_extend,
				JampAddr		=> JampAddr,
				Jr				=> Jr,
				GIE				=> GIE,
				INTER_CLK 		=> INTER_CLK,
				PC		        => PC_out(9 DOWNTO 2),
        		clock 			=> clock,  
				reset 			=> reset );


   CTL:   control
	PORT MAP ( 	Funct			=> Instruction( 5 DOWNTO 0 ),
				Opcode 			=> Instruction( 31 DOWNTO 26 ),
				RegDst 			=> RegDst,
				ALUSrc 			=> ALUSrc,
				MemtoReg 		=> MemtoReg,
				RegWrite 		=> RegWrite,
				MemRead 		=> MemRead,
				MemWrite 		=> MemWrite,
				beq 			=> beq,
				bne				=> bne,
				ALUop 			=> ALUop,
				Jump			=> Jump,
				Jal				=> Jal,
				Jr				=> Jr,
				PC_EN			=> PC_EN,
				INTER_CLK 		=> INTER_CLK,
				INT_R			=> INT_R,
				INT_A			=> INT_A,
                clock 			=> clock,
				reset 			=> reset );

   EXE:  Execute
   	PORT MAP (	Opcode 			=> Instruction( 31 DOWNTO 26 ),
				Read_data_1 	=> read_data_1,
             	Read_data_2 	=> read_data_2,
				Sign_extend 	=> Sign_extend,
                Function_opcode	=> Instruction( 5 DOWNTO 0 ),
				ALUOp 			=> ALUop,
				ALUSrc 			=> ALUSrc,
				Zero 			=> Zero,
                ALU_Result		=> ALU_Result,
				Add_Result 		=> Add_Result,
				PC_plus_4		=> PC_plus_4,
                Clock			=> clock,
				Reset			=> reset );

   MEM:  dmemory
	GENERIC MAP(sim		=> sim ) ---8:Modelsim, 10:Quartus
	PORT MAP (	read_data_DM 	=> read_data_DM_temp,
				address 		=> ALU_Result,--jump memory address by 4
				ADRESS_BUS		=> Data_From_Bus, -- need to check it ?
				write_data 		=> read_data_2,
				MemRead 		=> MemRead, 
				Memwrite 		=> MemWrite,
				INTER_CLK		=> INTER_CLK,
                clock 			=> clock,  
				reset 			=> reset);


	PC <= PC_out;


END structure;

