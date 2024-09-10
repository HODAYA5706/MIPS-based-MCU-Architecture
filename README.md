# MIPS based MCU Architecture 

## Project Overview 
This project presents the implementation of a standard single-cycle MIPS CPU ,
designed and tested for the Altera DE10 FPGA board.
The CPU is designed using VHDL and integrates core MIPS features along with GPIO, 
Basic Timer and Interrupt Controller.
![Screenshot 2024-09-10 223051](https://github.com/user-attachments/assets/2c764503-e966-4fa0-bb97-94e83f017d29)

### CPU Peripherals
- GPIO : allows the CPU to interact with external devices(LEDS/SW...).
![Screenshot 2024-09-10 180403](https://github.com/user-attachments/assets/70013394-daed-48da-8bac-e20686d4992d)
- Interrupt Controller : handles the prioritization and management of external interrupts,
  allowing the CPU to respond to events and execute the relevent interrupt servise routines.
![Screenshot 2024-09-10 222147](https://github.com/user-attachments/assets/713faa58-c0d3-46d1-93b4-7920b1f412e5)
- Basic Timer : A hardware timer component that generate time intervals for functions like PWM signal generation and periodic interrupts.
![Screenshot 2024-09-10 222914](https://github.com/user-attachments/assets/726b6571-8836-4313-88fe-1ee5cee22233)
