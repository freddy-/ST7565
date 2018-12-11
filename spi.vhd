----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:08:54 09/09/2018 
-- Design Name: 
-- Module Name:    spi - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--		Módulo SPI básico. Envia o conteudo da entrada i_DATA MSB first.
--  	A transmissão inicia apenas quando i_START está em nivel lógico alto 
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spi is
	PORT(
		-- entradas
		i_CLK: in std_logic; -- 29.498MHZ
		i_DATA: in std_logic_vector(7 downto 0);
		i_START: in std_logic;

		-- saidas
		o_SPI_CLK: out std_logic := '1'; -- 2MHz
		o_DATA: out std_logic := '0';
		o_FINISHED: out std_logic := '1';
		o_SENDING: out std_logic := '0'
	);
end spi;

architecture Behavioral of spi is
	-- estados da finite state machine
	type t_STATE is (s_IDLE, s_SENDING, s_FINISHED, s_INCREMENT_COUNTER, s_START_CLK_DIV);
	signal r_FSM_STATE : t_STATE := s_IDLE;

	-- contador, conta os bits a serem transmitidos
	signal r_COUNTER : natural range 0 to 7 := 0;

	-- dados a serem transmitidos
	signal r_DATA : std_logic_vector(7 downto 0) := (others => '0');

	-- flag que indica se o divisor de clock deve iniciar
	signal r_START_CLK_DIV : std_logic := '0';

	-- clk do SPI
	signal r_SLOW_CLK : std_logic := '0';

begin

  -- gera um sinal de clk enable de 2MHZ
	slow_clk : entity work.clk_divider
	GENERIC MAP ( 
		N => 7 
	)
	PORT MAP (
		i_CLK => i_CLK,
		i_ENABLE_CLK_DIV => r_START_CLK_DIV,
		o_CLK => r_SLOW_CLK
	);

	process (i_CLK)
	begin
		if (rising_edge(i_CLK)) then
			case r_FSM_STATE is
				when s_IDLE =>
					if (i_START = '1') then
						r_DATA <= i_DATA;
						r_FSM_STATE <= s_START_CLK_DIV;
						r_COUNTER <= 7;
						r_START_CLK_DIV <= '0';
						o_FINISHED <= '0';
						o_SENDING <= '1';
					else
						r_FSM_STATE <= s_IDLE;
					end if;

				when s_START_CLK_DIV =>
						r_FSM_STATE <= s_SENDING;
						r_START_CLK_DIV <= '1';

				when others =>
					null;
			end case;

			if (r_SLOW_CLK = '1') then 
				case r_FSM_STATE is
					when s_SENDING =>
						o_SPI_CLK <= '0';
						o_DATA <= r_DATA(r_COUNTER);
						r_FSM_STATE <= s_INCREMENT_COUNTER;

					when s_INCREMENT_COUNTER =>
						o_SPI_CLK <= '1';
						r_COUNTER <= r_COUNTER - 1;
						if(r_COUNTER > 0) then
							r_FSM_STATE <= s_SENDING;
						else 
							r_FSM_STATE <= s_FINISHED;
						end if;

					when s_FINISHED =>
						r_DATA <= (others => '0');
						o_FINISHED <= '1';
						o_SENDING <= '0';
						o_SPI_CLK <= '1';

						if (i_START = '1') then
							r_FSM_STATE <= s_FINISHED;
						else							
							r_FSM_STATE <= s_IDLE;
						end if ;

					when others =>
						null;

				end case;
			end if;
		end if ;
	end process;

end Behavioral;

