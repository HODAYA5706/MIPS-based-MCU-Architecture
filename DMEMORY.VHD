						--  Dmemory module (implements the data
						--  memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY dmemory IS
	GENERIC(sim					:integer:=10); ---8:Modelsim, 10:Quartus 
	PORT(	read_data_DM 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	address 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ADRESS_BUS			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	   		MemRead, Memwrite 	: IN 	STD_LOGIC;
			INTER_CLK           : IN    STD_LOGIC_VECTOR( 3 DOWNTO 0 );
            clock,reset			: IN 	STD_LOGIC
			);
END dmemory;

ARCHITECTURE behavior OF dmemory IS
SIGNAL write_clock,ack : STD_LOGIC;
SIGNAL address_mem : STD_LOGIC_VECTOR(sim-1 DOWNTO 0);
SIGNAL address_temp : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL Memwrite_dmem : STD_LOGIC ;
BEGIN
	
	Memwrite_dmem <= Memwrite when address_temp(11)='0' else '0';
	sim_mode : if (sim = 8) generate

		data_memory : altsyncram
		GENERIC MAP  (
			operation_mode => "SINGLE_PORT",
			width_a => 32,
			widthad_a => sim,
			lpm_type => "altsyncram",
			outdata_reg_a => "UNREGISTERED",
			init_file => "C:\Users\hoday\final_project\PROJECT\FINAL_TEST\LEVEL2\DTCM.hex",
			intended_device_family => "Cyclone"
		)
		PORT MAP (
			wren_a => Memwrite_dmem,
			clock0 => write_clock,
			address_a => address_mem,
			data_a => write_data,
			q_a => read_data_DM	);
	end generate;


	Q_mode : if (sim = 10) generate

		data_memory : altsyncram
		GENERIC MAP  (
			operation_mode => "SINGLE_PORT",
			width_a => 32,
			widthad_a => sim,
			numwords_a => 1024,
			lpm_hint => "ENABLE_RUNTIME_MOD = YES,INSTANCE_NAME = DTCM",
			lpm_type => "altsyncram",
			outdata_reg_a => "UNREGISTERED",
			init_file => "C:\Users\hoday\final_project\PROJECT\FINAL_TEST\LEVEL2\DTCM.hex",
			intended_device_family => "Cyclone"
		)
		PORT MAP (
			wren_a => Memwrite_dmem,
			clock0 => write_clock,
			address_a => address_mem,
			data_a => write_data,
			q_a => read_data_DM	);
	end generate;
			
		
		
-- Load memory address register with write clock
		write_clock <= NOT clock;


		address_temp <= ADRESS_BUS when INTER_CLK = "0010" else address;
		address_mem <= address_temp(9 DOWNTO 2) when sim = 8  else
						address_temp(9 DOWNTO 2) & B"00" ;
					
END behavior;
