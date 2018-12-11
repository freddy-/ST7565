----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:38:25 01/21/2018 
-- Design Name: 
-- Module Name:    clkDiv - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity clkDiv is
	generic(
		g_COUNTER_WIDTH : in positive := 16
	);

    Port ( i_clk : in  STD_LOGIC;
           o_slowClk : out  STD_LOGIC);
end clkDiv;

architecture Behavioral of clkDiv is
	signal r_counter : std_logic_vector(g_COUNTER_WIDTH - 1 downto 0) := (others => '0');
	signal r_slowClk : std_logic := '0';
begin

	process(i_clk)
	begin
		if(rising_edge(i_clk)) then
			-- incrementa o contador
			r_counter <= r_counter + 1;

			-- joga o ultimo bit do contador pra saida
			r_slowClk <= r_counter(r_counter'left);

		end if;
	end process;

	o_slowClk <= r_slowClk;

end Behavioral;

