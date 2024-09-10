LIBRARY ieee;
USE ieee.std_logic_1164.all;

-------------------------------------
ENTITY Display_HEX IS
  PORT (data		: in STD_LOGIC_VECTOR (3 DOWNTO 0);
		segment   		: out STD_LOGIC_VECTOR (6 downto 0));
END Display_HEX;
--------------------------------------------------------------
ARCHITECTURE dfl OF Display_HEX IS
BEGIN
	-- Perform Operation according FN bits of ALUFN 
	process(data)
	BEGIN
		if data="0000" then			--0
			segment <= 	"1000000";
		elsif data="0001" then		--1
			segment <= 	"1111001";
		elsif data="0010" then		--2
			segment <= 	"0100100";	
		elsif data="0011" then		--3
			segment <= 	"0110000";
		elsif data="0100" then		--4
			segment <= 	"0011001";
		elsif data="0101" then		--5
			segment <= 	"0010010";
		elsif data="0110" then		--6
			segment <= 	"0000010";
		elsif data="0111" then		--7
			segment <= 	"1111000";
		elsif data="1000" then		--8
			segment <= 	"0000000";	
		elsif data="1001" then		--9
			segment <= 	"0010000";
		elsif data="1010" then		--A
			segment <= 	"0001000";
		elsif data="1011" then		--B
			segment <= 	"0000011";
		elsif data="1100" then		--C
			segment <= 	"1000110";
		elsif data="1101" then		--D
			segment <= 	"0100001";
		elsif data="1110" then		--E
			segment <= 	"0000110";
		elsif data="1111" then		--F
			segment <= 	"0001110";
		else
			segment <= 	"1111111";
		end if;
	end process;
	

END dfl;