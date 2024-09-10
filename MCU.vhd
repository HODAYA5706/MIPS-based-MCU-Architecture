LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY MCU IS
	GENERIC(sim					:integer:=10); ---8:Modelsim, 10:Quartus
	PORT(
		clock								: IN 	STD_LOGIC; 
		-- Output important signals to pins for easy display in Simulator
--		PC									: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
--     	Instruction_out						: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		LEDS						 		: OUT 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		HEX_0, HEX_1, HEX_2, HEX_3, HEX_4,HEX_5 : OUT 	STD_LOGIC_VECTOR( 6 DOWNTO 0 );
		SW_IN 								: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		KEY_0, KEY_1, KEY_2, KEY_3 			: IN 	STD_LOGIC;
		PWMout								: OUT   STD_LOGIC );
END 	MCU;

ARCHITECTURE MCU_ARC OF MCU IS



component MIPS IS
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
END 	component;




component GPIO IS
	PORT(	clock		 	: IN 	STD_LOGIC;
			reset		 	: IN 	STD_LOGIC; 
			address		 	: IN 	STD_LOGIC_VECTOR( 11 DOWNTO 0 );
			dataBus		 	: INOUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			MemRead 		: IN 	STD_LOGIC;
			MemWrite 		: IN 	STD_LOGIC;
			PORT_LEDR		: OUT 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			PORT_HEX0		: OUT 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			PORT_HEX1		: OUT 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			PORT_HEX2		: OUT 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			PORT_HEX3		: OUT 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			PORT_HEX4		: OUT 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			PORT_HEX5		: OUT 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			PORT_SW		: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 ));
END component;


component Display_HEX IS
 PORT (data		: in STD_LOGIC_VECTOR (3 DOWNTO 0);
		segment   		: out STD_LOGIC_VECTOR (6 downto 0));
END component;

component  basic_timer IS
	PORT(	clock		 	: IN 	STD_LOGIC;
			reset		 	: IN 	STD_LOGIC;
			address		 	: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			dataBus		 		: INOUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			MemRead 		: IN 	STD_LOGIC;
			MemWrite 		: IN 	STD_LOGIC;
			Set_BTIFG 			: OUT 	STD_LOGIC;
			PWM				: OUT   STD_LOGIC
			);
END component;

--component MUL_accelerator is
--    generic(N : integer := 32 )  ;    
--    Port ( 
--        clk			 : in STD_LOGIC;
--        RST   		 : in STD_LOGIC;
--		address		 : in STD_LOGIC_VECTOR( 11 DOWNTO 0 );
--		dataBus		 		: INOUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
--		MemWrite 		: IN 	STD_LOGIC;
--		MemRead         : IN  STD_LOGIC;
----        Quotient	 : out STD_LOGIC_VECTOR(N-1 downto 0);
----        Residue		 : out STD_LOGIC_VECTOR(N-1 downto 0);
--        DIVFG		 : out STD_LOGIC
--    );
--end component;

component  Interrupt_Controller IS
	PORT(	clock	 		: IN 	STD_LOGIC;
			reset_outer_signals	 	: OUT 	STD_LOGIC;---?
			address		 	: IN 	STD_LOGIC_VECTOR( 11 DOWNTO 0 ); 
			dataBus		 		: INOUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			MemRead	 		: IN 	STD_LOGIC;
			MemWrite	 	: IN 	STD_LOGIC;
			IRQ	 			: IN 	STD_LOGIC_VECTOR(6 DOWNTO 0);
			RST				: IN 	STD_LOGIC;
			GIE	 			: IN 	STD_LOGIC;
			INT_A	 		: IN 	STD_LOGIC;
			INT_R		: OUT 	STD_LOGIC );	
		
END component;

 component PLL port(
	  areset		: IN STD_LOGIC  := '0';
	   inclk0		: IN STD_LOGIC  := '0';
		   c0		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC );
end component;
	 
    signal PLLclock : std_logic ;


	SIGNAL AddresBus : STD_LOGIC_VECTOR( 11 DOWNTO 0 );
	SIGNAL dataBus : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL HEX0_TEMP,HEX1_TEMP,HEX2_TEMP,HEX3_TEMP,HEX4_TEMP,HEX5_TEMP : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL 	ALU_result_out, read_data_1_out, read_data_2_out, write_data_out : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL 	Branch_out, Zero_out, Memwrite_out,MemRead_out,
	        Regwrite_out :STD_LOGIC ;
	SIGNAL	Set_BTIFG : STD_LOGIC;
	SIGNAL	DIVFG : STD_LOGIC;
	SIGNAL	Dividend,Divisor : STD_LOGIC_VECTOR(31 downto 0); -- ,Quotient,Residue
	SIGNAL	reset : STD_LOGIC;
	SIGNAL  GIE, INT_A, INT_R: STD_LOGIC;
	SIGNAL	Button_0,Button_1,Button_2,Button_3 : STD_LOGIC;
	SIGNAL	PC									: STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL	Instruction_out						: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	
BEGIN

	

	mips_core : MIPS
	GENERIC MAP(sim		=> sim ) ---8:Modelsim, 10:Quartus
	PORT MAP(reset				=> reset,
			clock				=> PLLclock,
			PC					=> PC,
			DataBus	            => DataBus,
			AddresBus           => AddresBus,
			ALU_result_out      => ALU_result_out,
			read_data_1_out     => read_data_1_out,
			read_data_2_out     => read_data_2_out,
			write_data_out      => write_data_out,
			Instruction_out     => Instruction_out,
			Branch_out          => Branch_out,
			Zero_out            => Zero_out,
			Memwrite_out        => Memwrite_out,
			MemRead_out         => MemRead_out,
			GIE					=> GIE,
			INT_A				=> INT_A,
			INT_R				=> INT_R
			);

	GPIO_CORE : GPIO
	PORT MAP(clock => PLLclock,
			 reset => reset,
			 address => AddresBus(11 DOWNTO 0) ,
			 dataBus => dataBus,
			 MemRead => MemRead_out,
			 MemWrite => MemWrite_out,
			 PORT_LEDR => LEDS,
			 PORT_HEX0			=> HEX0_TEMP,
			 PORT_HEX1			=> HEX1_TEMP,
			 PORT_HEX2			=> HEX2_TEMP,
			 PORT_HEX3			=> HEX3_TEMP,
			 PORT_HEX4			=> HEX4_TEMP,
			 PORT_HEX5			=> HEX5_TEMP,
			 PORT_SW				=> SW_IN			 
	
	);
			
	HEX0CONV : Display_HEX
	PORT MAP (
		data				=> HEX0_TEMP(3 downto 0),
		segment				=> HEX_0);
			
	HEX1CONV : Display_HEX
	PORT MAP (
		data				=> HEX1_TEMP(3 downto 0),
		segment				=> HEX_1);
			
	HEX2CONV : Display_HEX
	PORT MAP (
		data				=> HEX2_TEMP(3 downto 0),
		segment				=> HEX_2);
			
	HEX3CONV : Display_HEX
	PORT MAP (
		data				=> HEX3_TEMP(3 downto 0),
		segment				=> HEX_3);
			
	HEX4CONV : Display_HEX
	PORT MAP (
		data				=> HEX4_TEMP(3 downto 0),
		segment				=> HEX_4);
			
	HEX5CONV : Display_HEX
	PORT MAP (
		data				=> HEX5_TEMP(3 downto 0),
		segment				=> HEX_5);	
		

	BasicTimer : basic_timer
	PORT MAP(	
			clock		 	=> PLLclock,
			reset		 	=> reset,
			address		 	=> AddresBus(11 DOWNTO 2),
			dataBus			=> dataBus,
			MemRead 		=> MemRead_out,
			MemWrite 		=> MemWrite_out,
			Set_BTIFG 		=> Set_BTIFG,
			PWM				=> PWMout
			);
	
--	MulAcc: MUL_accelerator  
--		Port MAP( 
--				clk			=> PLLclock,
--				RST   		=> reset,
--				address		=> AddresBus,
--				dataBus		=> dataBus,
--				MemWrite 	=> MemWrite_out,
--				MemRead     => MemRead_Out,
----				Quotient	=> Quotient,
----				Residue		=> Residue,
--			    DIVFG		=> DIVFG
--		);
	
	InteCon: Interrupt_Controller 
		PORT MAP(	clock	 		=> PLLclock,
				reset_outer_signals	=> reset,
				address		 	=> AddresBus,
				dataBus		 	=> dataBus,
				MemRead	 		=> MemRead_out,
				MemWrite	 	=> MemWrite_out,
				IRQ(0)			=> '0',--UART
				IRQ(1)			=> '0',--UART
				IRQ(2)			=> Set_BTIFG,
				IRQ(3)			=> Button_1,
				IRQ(4)			=> Button_2,
				IRQ(5)			=> Button_3,
				IRQ(6)			=>	'0', --DIVFG,
				RST				=> Button_0,
				GIE	 			=> GIE,
				INT_A	 		=> INT_A,
				INT_R			=> INT_R);	

	
	PLL_clk: PLL 
	port MAP(
		inclk0		=> clock,
		c0		=> PLLclock );	

--	PLLclock <= clock; ---for Modelsim
		
	Button_0 <= NOT(KEY_0);
	Button_1 <= NOT(KEY_1);
	Button_2 <= NOT(KEY_2);
	Button_3 <= NOT(KEY_3);

end MCU_ARC;