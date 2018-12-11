----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:38:23 09/26/2018 
-- Design Name: 
-- Module Name:    spi_clk_div - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clk_divider is
	GENERIC (
		N : integer
	);
	PORT(
		-- entrada
		i_CLK: in std_logic; -- 29.498MHZ
		i_ENABLE_CLK_DIV: in std_logic;

		-- saida
		o_CLK: out std_logic := '1' -- 2MHz
	);
end clk_divider;

architecture Behavioral of clk_divider is
	-- pulsos de saida
	signal r_SLOW_CLK : std_logic := '0';

	-- contador do 'divisor' de clock
	signal r_CLK_DIV_CNT : natural range 0 to N := 0;

	-- limite do contador divisor de clock
	constant c_CLK_DIV_MAX : natural range 0 to N := N;
begin

	process (i_CLK)
	begin
	
		if (rising_edge(i_CLK)) then
			-- cria um sinal de clk enable a cada 2 mhz, este sinal deve durar um ciclo de clk do sistema
			-- este processo incrementa um contador a cada clk do sistema
			-- quando o valor do contado chegar ao valor definido, o sinal r_SLOW_CLK recebe '1'
			-- quando o valor for diferente do definido, o valor de r_SLOW_CLK é '0'
			if (i_ENABLE_CLK_DIV = '1') then
				if (r_CLK_DIV_CNT = c_CLK_DIV_MAX) then
					r_CLK_DIV_CNT <= 0;
					r_SLOW_CLK <= '1';
				else
					r_CLK_DIV_CNT <= r_CLK_DIV_CNT + 1;
					r_SLOW_CLK <= '0';
				end if ;
			else
				r_CLK_DIV_CNT <= 0;
			end if ;

		end if ;
	end process;

	o_CLK <= r_SLOW_CLK;

end Behavioral;

