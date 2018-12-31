--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:34:41 11/13/2018
-- Design Name:   
-- Module Name:   F:/DEV/FPGA/projetos/ST7565/ST7565_tb.vhd
-- Project Name:  ST7565
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ST7565
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY ST7565_tb IS
END ST7565_tb;
 
ARCHITECTURE behavior OF ST7565_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ST7565
    PORT(
         i_CLK : IN  std_logic;
         o_SLOW_CLK_DBG : OUT std_logic;
         o_INIT_DONE_DBG : OUT std_logic;
         o_SPI_FINISHED_DBG : OUT std_logic;
         o_SLOW_CLK_ENABLE_DBG: out std_logic;
         o_LCD_CLK : OUT  std_logic;
         o_LCD_MOSI : OUT  std_logic;
         o_LCD_CS : OUT  std_logic;
         o_LCD_DC : OUT  std_logic;
         o_LCD_RESET : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal i_CLK : std_logic := '0';

 	--Outputs
   signal o_SLOW_CLK_DBG : std_logic;
   signal o_INIT_DONE_DBG : std_logic;
   signal o_SPI_FINISHED_DBG : std_logic;
   signal o_SLOW_CLK_ENABLE_DBG: std_logic;
   signal o_LCD_CLK : std_logic;
   signal o_LCD_MOSI : std_logic;
   signal o_LCD_CS : std_logic;
   signal o_LCD_DC : std_logic;
   signal o_LCD_RESET : std_logic;

   -- Clock period definitions
   constant i_CLK_period : time := 33.9 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ST7565 PORT MAP (
          i_CLK => i_CLK,
          o_SLOW_CLK_DBG => o_SLOW_CLK_DBG,
          o_INIT_DONE_DBG => o_INIT_DONE_DBG,
          o_SPI_FINISHED_DBG => o_SPI_FINISHED_DBG,
          o_SLOW_CLK_ENABLE_DBG => o_SLOW_CLK_ENABLE_DBG,
          o_LCD_CLK => o_LCD_CLK,
          o_LCD_MOSI => o_LCD_MOSI,
          o_LCD_CS => o_LCD_CS,
          o_LCD_DC => o_LCD_DC,
          o_LCD_RESET => o_LCD_RESET
        );

   -- Clock process definitions
   i_CLK_process :process
   begin
		i_CLK <= '0';
		wait for i_CLK_period/2;
		i_CLK <= '1';
		wait for i_CLK_period/2;
   end process;
 
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 10000 ns;	

      -- insert stimulus here 

      wait;
   end process;

END;
