-- Ifetch module (provides the PC and instruction 
--memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY Ifetch IS
	GENERIC(sim					:integer:=10); ---8:Modelsim, 10:Quartus
	PORT(	SIGNAL Instruction 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	SIGNAL PC_plus_4_out 	: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        	SIGNAL Add_result 		: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			SIGNAL beq 				: IN 	STD_LOGIC;
			SIGNAL bne				: IN	STD_LOGIC;
        	SIGNAL Zero 			: IN 	STD_LOGIC;
			SIGNAL Jump				: IN 	STD_LOGIC; ---output of control
			SIGNAL Jr				: IN 	STD_LOGIC; ---output of control
			SIGNAL JampAddr		 	: IN	STD_LOGIC_VECTOR( 7 DOWNTO 0 ); ---output of the execute
			SIGNAL read_data_1		: IN	STD_LOGIC_VECTOR( 31 DOWNTO 0 ); ---output of decode
      		SIGNAL PC_out 			: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			SIGNAL read_data_DM		: IN STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	SIGNAL clock, reset 	: IN 	STD_LOGIC ;
			signal PC_EN            : IN    STD_LOGIC ;
			SIGNAL NEXT_PC_OUT      : OUT    STD_LOGIC_VECTOR( 7 DOWNTO 0 )
			);
END Ifetch;

ARCHITECTURE behavior OF Ifetch IS
	SIGNAL PC, PC_plus_4 	 : STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL next_PC,data_for_pc : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL Mem_Addr : STD_LOGIC_VECTOR( sim-1 DOWNTO 0 );
	SIGNAL done_em_jal,done_em_jal_temp: STD_LOGIC;
BEGIN
						--ROM for Instruction Memory


sim_mode : if (sim = 8) generate

	inst_memory: altsyncram
		
		GENERIC MAP (
			operation_mode => "ROM",
			width_a => 32,
			widthad_a => sim,
			lpm_type => "altsyncram",
			outdata_reg_a => "UNREGISTERED",
			init_file => "C:\Users\hoday\final_project\PROJECT\FINAL_TEST\LEVEL2\ITCM.hex",
			intended_device_family => "Cyclone"
		)
		PORT MAP (
			clock0     => clock,
			address_a 	=> Mem_Addr, 
			q_a 			=> Instruction );
end generate;	


Q_mode : if (sim = 10) generate

	inst_memory: altsyncram
		
		GENERIC MAP (
			operation_mode => "ROM",
			width_a => 32,
			widthad_a => sim,
			numwords_a => 1024,
			lpm_hint => "ENABLE_RUNTIME_MOD = YES,INSTANCE_NAME = ITCM",
			lpm_type => "altsyncram",
			outdata_reg_a => "UNREGISTERED",
			init_file => "C:\Users\hoday\final_project\PROJECT\FINAL_TEST\LEVEL2\ITCM.hex",
			intended_device_family => "Cyclone"
		)
		PORT MAP (
			clock0     => clock,
			address_a 	=> Mem_Addr, 
			q_a 			=> Instruction );
end generate;			
		
					-- Instructions always start on word address - not byte
		PC(1 DOWNTO 0) <= "00";
					-- copy output signals - allows read inside module
		PC_out 			<= PC;
		PC_plus_4_out 	<= PC_plus_4;
						-- send address to inst. memory address register
		Mem_Addr <= Next_PC WHEN sim=8 ELSE
					Next_PC & B"00";
						-- Adder to increment PC by 4        
      	PC_plus_4( 9 DOWNTO 2 )  <= PC( 9 DOWNTO 2 ) + 1;
       	PC_plus_4( 1 DOWNTO 0 )  <= "00";
						-- Mux to select Branch Address or PC + 4        
		Next_PC  <= X"00" WHEN Reset = '1' ELSE
			Add_result  WHEN ((beq = '1'  AND Zero = '1') OR (bne = '1' AND Zero /= '1'))
			ELSE JampAddr WHEN Jump='1' AND Jr='0'
			ELSE read_data_1(7 DOWNTO 0) WHEN Jump='0' AND Jr ='1'
			ELSE read_data_DM(9 DOWNTO 2) WHEN done_em_jal_temp='1' 
			ELSE PC_plus_4( 9 DOWNTO 2 );
		Next_PC_OUT <= Next_PC;	
		
		done_em_jal_temp<= '1' WHEN Jump='1' AND Jr ='1' ELSE '0';
		data_for_pc <= read_data_DM(9 DOWNTO 2) WHEN Jump='1' AND Jr ='1' ELSE unaffected;
		PROCESS
			BEGIN
				WAIT UNTIL ( clock'EVENT ) AND ( clock = '1' );
				done_em_jal<= done_em_jal_temp;
		END PROCESS;
		
		PROCESS
			BEGIN
				WAIT UNTIL ( clock'EVENT ) AND ( clock = '1' );
				IF reset = '1' THEN
						PC( 9 DOWNTO 2) <= "00000000" ; 
				ELSIF (PC_EN = '1') THEN
						IF done_em_jal='0' THEN
							PC( 9 DOWNTO 2 ) <= next_PC;
						ELSE
							PC( 9 DOWNTO 2 )<= data_for_pc;
						END IF;
				END IF;
		END PROCESS;
END behavior;


