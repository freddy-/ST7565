----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:29:11 01/21/2018 
-- Design Name: 
-- Module Name:    debouncer - Behavioral 
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

entity debouncer is
    Port ( i_clk : in  STD_LOGIC;
           i_raw : in  STD_LOGIC;
           o_clean : out  STD_LOGIC);
end debouncer;

architecture Behavioral of debouncer is
	signal r_counter : std_logic_vector(7 downto 0) := (others => '0');
	signal r_output : std_logic := '0';
begin

	process(i_clk)
	begin
		if (rising_edge(i_clk)) then
			r_counter <= r_counter(6 downto 0) & (not i_raw);

			if (r_counter = X"FF") then 
				r_output <= '1';
			elsif (r_counter = X"00") then 
				r_output <= '0';
			else 
				r_output <= r_output;
			end if ;

		end if ;
	end process;

	o_clean <= r_output;

end Behavioral;

