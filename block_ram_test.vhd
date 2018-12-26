--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:58:26 12/20/2018
-- Design Name:   
-- Module Name:   F:/DEV/FPGA/projetos/ST7565/block_ram_test.vhd
-- Project Name:  ST7565
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: clk_divider
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

LIBRARY UNISIM;
use UNISIM.VComponents.all;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

library UNIMACRO;  
use UNIMACRO.Vcomponents.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY block_ram_test IS
END block_ram_test;
 
ARCHITECTURE behavior OF block_ram_test IS 
 
  -- bram signals
  signal regAddress : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
  signal regDataOut : STD_LOGIC_VECTOR(7 downto 0);
  signal regDataIn  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
  signal regRead    : STD_LOGIC;
  signal regWrite   : STD_LOGIC;
  signal writeEn    : STD_LOGIC_VECTOR(0 downto 0);

   --Inputs
   signal i_CLK : std_logic := '0';
   signal i_ENABLE_CLK_DIV : std_logic := '0';

   -- Clock period definitions
   constant i_CLK_period : time := 10 ns;
   constant o_CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
  BRAM_SDP_MACRO_inst : BRAM_SDP_MACRO
  generic map (
       BRAM_SIZE => "9Kb",
       DEVICE => "SPARTAN6",
       WRITE_WIDTH => 8, 
       READ_WIDTH => 8,
       DO_REG => 0,
       INIT_FILE => "NONE",
       SIM_COLLISION_CHECK => "ALL"   
   
       --Register initialization omitted--  
       )
   
  port map (
       DO => regDataIn,
       DI => regDataOut,
       RDADDR => regAddress,
       RDCLK => i_CLK,
       RDEN => regRead,
       REGCE => '0',
       RST => '0',
       WE => writeEn,
       WRADDR => regAddress,
       WRCLK => i_CLK,
       WREN => regWrite
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
      wait for 100 ns;	

      wait for i_CLK_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
