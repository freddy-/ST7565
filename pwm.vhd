----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:41:47 01/29/2018 
-- Design Name: 
-- Module Name:    pwm - Behavioral 
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
use IEEE.numeric_std.all;

entity pwm is
	generic (
		g_DUTY_WIDTH : natural := 9
	);
    port ( 
    	i_CLK : in  STD_LOGIC;
    	i_DUTYCICLE : in std_logic_vector(g_DUTY_WIDTH - 1 downto 0);
        o_VALUE : out  STD_LOGIC :=  '0'
    );
end pwm;

architecture Behavioral of pwm is
	signal r_counter : std_logic_vector(g_DUTY_WIDTH - 1 downto 0) := (others => '0');
	signal r_clk_prescaler_counter : std_logic_vector(4 downto 0) := (others => '0');
	signal r_clk_prescaled : std_logic := '0';
begin

	-- processo do divisor de clk
	process(i_CLK)
	begin
		if(rising_edge(i_CLK)) then
			if(r_clk_prescaler_counter = 29) then
				r_clk_prescaler_counter <= (others => '0');
			else
				r_clk_prescaler_counter <= r_clk_prescaler_counter + 1;
			end if;

			if(r_clk_prescaler_counter = 29) then
				r_clk_prescaled <= '1';
			else 
				r_clk_prescaled <= '0';
			end if;

		end if;
	end process;
	

	-- processo do contador
	process(r_clk_prescaled)
	begin
		if(rising_edge(r_clk_prescaled)) then
			r_counter <= r_counter + 1;
		end if;
	end process;

	-- processo do comparador
	process(r_clk_prescaled)
	begin
		if(rising_edge(r_clk_prescaled)) then
			if(i_DUTYCICLE > r_counter) then
				o_VALUE <= '1';
			else
				o_VALUE <= '0';
			end if;
		end if;
	end process;

end Behavioral;

