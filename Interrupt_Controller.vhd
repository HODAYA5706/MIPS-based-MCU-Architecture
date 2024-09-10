LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY  Interrupt_Controller IS
	PORT(	clock	 		: IN 	STD_LOGIC;
			reset_outer_signals	 	: OUT 	STD_LOGIC;
			address		 	: IN 	STD_LOGIC_VECTOR( 11 DOWNTO 0 ); 
			dataBus		 		: INOUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			MemRead	 		: IN 	STD_LOGIC;
			MemWrite	 	: IN 	STD_LOGIC;
			IRQ	 			: IN 	STD_LOGIC_VECTOR(6 DOWNTO 0);
			RST				: IN 	STD_LOGIC;
			GIE	 			: IN 	STD_LOGIC;
			INT_A	 		: IN 	STD_LOGIC;
			INT_R		: OUT 	STD_LOGIC );	
		
END Interrupt_Controller;


ARCHITECTURE int_con_arc OF Interrupt_Controller IS

	COMPONENT BidirPin
		GENERIC( WIDTH: INTEGER:=32 );   
		PORT(   Dout: 	IN 		STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
				en:		IN 		STD_LOGIC;
				Din:	OUT		STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
				IOpin: 	INOUT 	STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0)
		);
	END COMPONENT;
	
	SIGNAL TO_THE_BUS,DataFromBus : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL IFG_REGISTER, IE_REGISTER, TYPE_OUT : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal CS : STD_LOGIC_VECTOR(2 DOWNTO 0);
	signal BUS_EN : STD_LOGIC;
	SIGNAL IRQ_IMM : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL CLEAR_IRQ_IMM : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL IFG_TEMP, TYPE_IN_USE : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL reset_first_latch, reset_second_latch, clr_rst : STD_LOGIC;
	SIGNAL reset : STD_LOGIC;
	
	BEGIN

-------------------- BUS connection ------------------------------------------

	BiDirPin_INTERRUPS: BidirPin
	GENERIC MAP ( 32 )
	PORT MAP (	Dout 		=> TO_THE_BUS,
    	    	en			=> BUS_EN,
				Din			=> DataFromBus,
				IOpin 		=> dataBus );
				
	
	WITH address SELECT
	CS <= "001" WHEN "100000111100",--IE
		  "010" WHEN "100000111101",--IFG
		  "100" WHEN "100000111110",--TYPE
		  "000" WHEN OTHERS;
	
	BUS_EN <= '1' WHEN (INT_A = '0' OR (MemRead = '1' and (CS(0) = '1' or CS(1) = '1' or CS(2) = '1'))) ELSE '0';
	TO_THE_BUS <= X"000000" & TYPE_OUT WHEN (INT_A = '0' OR (CS(2) = '1' AND MemRead = '1')) ELSE
			X"000000" & IFG_REGISTER WHEN (CS(1) = '1' AND MemRead = '1') ELSE
			X"000000" & IE_REGISTER WHEN (CS(0) = '1' AND MemRead = '1') ELSE
			(OTHERS => '0');				
				
	

	INT_R <= ((IFG_REGISTER(0) OR IFG_REGISTER(1) OR IFG_REGISTER(2) OR IFG_REGISTER(3) 
				OR IFG_REGISTER(4) OR IFG_REGISTER(5) OR IFG_REGISTER(6) OR IFG_REGISTER(7)) AND GIE);
				

	
	PROCESS(reset, IRQ(2), CLEAR_IRQ_IMM(2))--BT interrupt
		BEGIN
			IF reset = '1' THEN
				IRQ_IMM(2) <= '0';
			ELSIF CLEAR_IRQ_IMM(2) = '1' THEN
				   IRQ_IMM(2) <= '0';
			ELSIF (( IRQ(2)'EVENT ) AND ( IRQ(2) = '1')) THEN
				   IRQ_IMM(2) <= '1';
			END IF;
	END PROCESS;
	
	PROCESS(reset, IRQ(3), CLEAR_IRQ_IMM(3))--key1 interrupt
		BEGIN
			IF reset = '1' THEN
				IRQ_IMM(3) <= '0';
			ELSIF CLEAR_IRQ_IMM(3) = '1' THEN
				   IRQ_IMM(3) <= '0';
			ELSIF (( IRQ(3)'EVENT ) AND ( IRQ(3) = '1')) THEN
				   IRQ_IMM(3) <= '1';
			END IF;
	END PROCESS;
	
	PROCESS(reset, IRQ(4), CLEAR_IRQ_IMM(4))--key2 interrupt
		BEGIN
			IF reset = '1' THEN
				IRQ_IMM(4) <= '0';
			ELSIF CLEAR_IRQ_IMM(4) = '1' THEN
				   IRQ_IMM(4) <= '0';
			ELSIF (( IRQ(4)'EVENT ) AND ( IRQ(4) = '1')) THEN
				   IRQ_IMM(4) <= '1';
			END IF;
	END PROCESS;
	
	PROCESS(reset, IRQ(5), CLEAR_IRQ_IMM(5))--key3 interrupt
		BEGIN
			IF reset = '1' THEN
				IRQ_IMM(5) <= '0';
			ELSIF CLEAR_IRQ_IMM(5) = '1' THEN
				   IRQ_IMM(5) <= '0';
			ELSIF (( IRQ(5)'EVENT ) AND ( IRQ(5) = '1')) THEN
				   IRQ_IMM(5) <= '1';
			END IF;
	END PROCESS;
	
--	PROCESS(reset, IRQ(6), CLEAR_IRQ_IMM(6))--DIV
--		BEGIN
--			IF reset = '1' THEN
--				IRQ_IMM(6) <= '0';
--			ELSIF CLEAR_IRQ_IMM(6) = '1' THEN
--				   IRQ_IMM(6) <= '0';
--			ELSIF (( IRQ(6)'EVENT ) AND ( IRQ(6) = '1')) THEN
--				   IRQ_IMM(6) <= '1';
--			END IF;
--	END PROCESS;

	
	
	--is determined by interrupt recived
	TYPE_IN_USE <= X"00" WHEN reset_second_latch = '1' ELSE --reset
					X"10" WHEN IFG_REGISTER(2) = '1' ELSE -- basic timer
					X"14" WHEN IFG_REGISTER(3) = '1' ELSE --key1
					X"18" WHEN IFG_REGISTER(4) = '1' ELSE --key2
					X"1C" WHEN IFG_REGISTER(5) = '1' ELSE --key3
--					X"20" WHEN IFG_REGISTER(6) = '1' ELSE --DIV
					X"00";
						 
						 
	------------------------
	--clears interuupts
	------------------------
	--cleared both by user and by hardware when interrupt happened
	CLEAR_IRQ_IMM(2) <= '1' WHEN (TYPE_OUT = X"10" AND INT_A = '0') OR 
	(CS(1) = '1' AND MemWrite = '1' AND DataFromBus(2) = '0') ELSE '0';
--	CLEAR_IRQ_IMM(6) <= '1' WHEN (TYPE_OUT = X"20" AND INT_A = '0') OR 
--	(CS(1) = '1' AND MemWrite = '1' AND DataFromBus(6) = '0') ELSE '0';
	
	--cleared only by user
	CLEAR_IRQ_IMM(3) <= '1' WHEN (CS(1) = '1' AND MemWrite = '1' AND DataFromBus(3) = '0') ELSE '0';--keys are reset by software
	CLEAR_IRQ_IMM(4) <= '1' WHEN (CS(1) = '1' AND MemWrite = '1' AND DataFromBus(4) = '0') ELSE '0';
	CLEAR_IRQ_IMM(5) <= '1' WHEN (CS(1) = '1' AND MemWrite = '1' AND DataFromBus(5) = '0') ELSE '0';


	
	
	
						   
	PROCESS (reset, clock) --IE register
	BEGIN
		IF reset = '1' THEN
			IE_REGISTER <= "00000000";
		ELSIF (( clock'EVENT ) AND ( clock = '1')) THEN
			IF (CS(0) = '1' AND MemWrite = '1') THEN
				IE_REGISTER <= DataFromBus(7 DOWNTO 0);
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS (reset, clock) --TYPE_OUT register
	BEGIN
		IF reset = '1' THEN
			TYPE_OUT <= X"00";
		ELSIF (( clock'EVENT ) AND ( clock = '1')) THEN
				TYPE_OUT <= TYPE_IN_USE;
		END IF;
	END PROCESS;
	
	
	PROCESS(reset, RST, clr_rst)--reset process
		BEGIN
			IF clr_rst = '1' THEN
				   reset_first_latch <= '0';
			ELSIF (( RST'EVENT ) AND ( RST = '1')) THEN
				   reset_first_latch <= '1';
			END IF;
	END PROCESS;
	
	--IFG set only when irq and ie is 1
	IFG_TEMP <= IRQ_IMM AND IE_REGISTER;
	
	PROCESS (clock) --IFG process
		BEGIN
			IF (( clock'EVENT ) AND ( clock = '0')) THEN 
				reset_second_latch <= reset_first_latch;
				IF reset = '1' THEN
					IFG_REGISTER <= "00000000";
				ELSIF (CS(1) = '1' AND MemWrite = '1') THEN 
					IFG_REGISTER <= DataFromBus(7 DOWNTO 0);
				ELSE 
					IFG_REGISTER <= IFG_TEMP;
				END IF;
			END IF;
	END PROCESS;
	
	--reset clears when second latch is 1
	clr_rst <= '1' WHEN reset_second_latch = '1' ELSE '0';
	--reset everything on first latch
	reset <= '1' WHEN reset_first_latch = '1' ELSE '0';
	reset_outer_signals <= reset;
	

	
END int_con_arc;