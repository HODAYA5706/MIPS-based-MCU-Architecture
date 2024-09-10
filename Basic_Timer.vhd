LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY  basic_timer IS
	PORT(	clock		 	: IN 	STD_LOGIC;
			reset		 	: IN 	STD_LOGIC;
			address		 	: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			dataBus		 		: INOUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			MemRead 		: IN 	STD_LOGIC;
			MemWrite 		: IN 	STD_LOGIC;
			Set_BTIFG		: OUT 	STD_LOGIC;
			PWM				: OUT   STD_LOGIC
			);
END basic_timer;


ARCHITECTURE timer_arc OF basic_timer IS

	COMPONENT BidirPin
		GENERIC( WIDTH: INTEGER:=16 );
		PORT(   Dout: 	IN 		STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
				en:		IN 		STD_LOGIC;
				Din:	OUT		STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
				IOpin: 	INOUT 	STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0)
		);
	END COMPONENT;
	
	SIGNAL BTCTL              							: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL BTCNT,CCR0,CCR1, CCR0_latch, CCR1_latch, REG_CONTENT, DataFromBus, BTCNT_temp : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL read_reg_en									: STD_LOGIC;
	SIGNAL clock_2, clock_4, clock_8, CLOCK_CHOSER		: STD_LOGIC;
	SIGNAL CHIP_SELECTOR								: STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL PWM_temp, BTCNT_chang_from_bus				: STD_LOGIC;

	
BEGIN
	
	BiDirPin_Timer: BidirPin
	GENERIC MAP ( 32 )
	PORT MAP (	Dout 		=> REG_CONTENT,
    	    	en			=> read_reg_en,
				Din			=> DataFromBus,
				IOpin 		=> dataBus );
		  
	
	CLOCK_CHOSER <= clock WHEN BTCTL(4 DOWNTO 3) = "00" ELSE
						clock_2 WHEN BTCTL(4 DOWNTO 3) = "01" ELSE
						clock_4 WHEN BTCTL(4 DOWNTO 3) = "10" ELSE
						clock_8 WHEN BTCTL(4 DOWNTO 3) = "11" ELSE
						clock;
		
	
	PROCESS (reset, clock)--BTCTL process
	BEGIN
		IF reset = '1' THEN
			BTCTL <= "00100000";--EN=0 (of BTCNT)
		ELSIF falling_edge(clock) THEN
			IF (MemWrite = '1' AND CHIP_SELECTOR(0) = '1') THEN
				BTCTL <= DataFromBus(7 DOWNTO 0);
			END IF;
		END IF;
	END PROCESS;
	
	
	PROCESS (reset, clock)--BTCNT + PWM PROCESS
		BEGIN
			IF reset = '1' THEN
				BTCNT <= X"00000000";
--				BTCNT_chang_from_bus <= '0';
			ELSIF falling_edge(clock) THEN
				IF (BTCTL(5) = '1' AND (MemWrite = '1' AND CHIP_SELECTOR(1) = '1')) THEN
					BTCNT <= DataFromBus;
--					BTCNT_chang_from_bus <= '1';
				ELSIF BTCTL(5) = '0' AND BTCNT_temp = BTCNT + 1 THEN
					BTCNT <= BTCNT_temp;
--					BTCNT_chang_from_bus <= '0';
				END IF;
			END IF;
	END PROCESS;
	
	PROCESS (CLOCK_CHOSER, reset, CCR0_latch, CCR1_latch)
		BEGIN
--			IF reset = '1' THEN
--				PWM_temp <= '0';
			IF (CLOCK_CHOSER'EVENT) AND (CLOCK_CHOSER='0') THEN
				IF BTCTL(5) = '0' THEN
					BTCNT_temp <= BTCNT + 1;
					IF BTCTL(6) = '1' and (BTCNT(31 downto 0) < CCR1_latch(31 downto 0))THEN
						PWM_temp <= BTCTL(7);
					ELSIF BTCTL(6) = '1' and BTCNT(31 downto 0) = CCR1_latch(31 downto 0) THEN
						PWM_temp <= NOT PWM_temp;
					ELSIF BTCTL(6) = '1' and BTCNT(31 downto 0) = CCR0_latch(31 downto 0) THEN
						PWM_temp <= NOT PWM_temp;
						BTCNT_temp <= X"00000000";
					END IF;
				END IF;
			END IF;
	END PROCESS;

	
	PWM <= PWM_temp;
	
	PROCESS (reset, clock)--CCR0 process
	BEGIN
		IF reset = '1' THEN
			CCR0 <= X"00000000";
		ELSIF falling_edge(clock) THEN
			IF (MemWrite = '1' AND CHIP_SELECTOR(2) = '1') THEN
				CCR0 <= DataFromBus;
			END IF;
		END IF;
	END PROCESS;


	PROCESS (reset, clock)--CCR1 process
	BEGIN
		IF reset = '1' THEN
			CCR1 <= X"00000000";
		ELSIF falling_edge(clock) THEN
			IF (MemWrite = '1' AND CHIP_SELECTOR(3) = '1') THEN
				CCR1 <= DataFromBus;
			END IF;
		END IF;
	END PROCESS;
	
	
	WITH BTCTL(2 DOWNTO 0) SELECT
		Set_BTIFG <= BTCNT(0) WHEN "000",
					 BTCNT(3) WHEN "001",
					 BTCNT(7) WHEN "010",
					 BTCNT(11) WHEN "011",
					 BTCNT(15) WHEN "100",
					 BTCNT(19) WHEN "101",
					 BTCNT(23) WHEN "110",
					 BTCNT(25) WHEN "111",
					 '0' WHEN OTHERS;
		  
	
	PROCESS (reset, clock)--clock diver 2
	BEGIN
		IF reset = '1' THEN
			clock_2 <= '0';
		ELSIF falling_edge(clock) THEN
			clock_2 <= NOT clock_2;
		END IF;
	END PROCESS;
	
	PROCESS (reset, clock_2)--clock diver 4
	BEGIN
		IF reset = '1' THEN
			clock_4 <= '0';
		ELSIF falling_edge(clock_2) THEN
			clock_4 <= NOT clock_4;
		END IF;
	END PROCESS;
	
	PROCESS (reset, clock_4)--clock diver 8
	BEGIN
		IF reset = '1' THEN
			clock_8 <= '0';
		ELSIF falling_edge(clock_4) THEN
			clock_8 <= NOT clock_8;
		END IF;
	END PROCESS;
							
				
	
	PROCESS (reset, clock)--CCR1 latch
	BEGIN
		IF reset = '1' THEN
			CCR1_latch <= X"00000000";
		ELSIF rising_edge(clock) THEN
			CCR1_latch <= CCR1;
		END IF;
	END PROCESS;
	
	PROCESS (reset, clock)--CCR0 latch
	BEGIN
		IF reset = '1' THEN
			CCR0_latch <= X"00000000";
		ELSIF rising_edge(clock) THEN
			CCR0_latch <= CCR0;
		END IF;
	END PROCESS;

	read_reg_en <= '1' WHEN (MemRead = '1' AND (CHIP_SELECTOR(0) = '1' or CHIP_SELECTOR(1) = '1' or 
	CHIP_SELECTOR(2) = '1' or CHIP_SELECTOR(3) = '1')) ELSE '0'; ---read when addres is one of basic time registers
	--REG CONTENT SIGNAL CONTAINS THE REQUAIRED REGISTER TO BE READ CONTENT
	REG_CONTENT <= 	X"000000" & BTCTL WHEN (MemRead = '1' AND CHIP_SELECTOR(0) = '1') ELSE
					BTCNT WHEN (MemRead = '1' AND CHIP_SELECTOR(1) = '1') ELSE 
					CCR0 WHEN (MemRead = '1' AND CHIP_SELECTOR(2) = '1') ELSE 
					CCR1 WHEN (MemRead = '1' AND CHIP_SELECTOR(3) = '1') ELSE 
					(OTHERS => '0');
					
	WITH address SELECT--address is address bus bits 2-11
	CHIP_SELECTOR <= "0001" WHEN "1000000111",--BTCTL
		  "0010" WHEN "1000001000",--BTCNT
		  "0100" WHEN "1000001001",--CCR0
		  "1000" WHEN "1000001010",--CCR1
		  "0000" WHEN OTHERS;

				
END timer_arc;