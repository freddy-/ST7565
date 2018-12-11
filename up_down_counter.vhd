----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:59:46 01/25/2018 
-- Design Name: 
-- Module Name:    up_down_counter - Behavioral 
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

entity up_down_counter is
	generic(
		g_OUTPUT_WIDTH : in positive
	);

    Port ( i_CLK : in  STD_LOGIC;
           i_UP : in  STD_LOGIC;
           i_DOWN : in  STD_LOGIC;
           o_VALUE : out  STD_LOGIC_VECTOR(g_OUTPUT_WIDTH - 1 downto 0) := (others => '0');
           o_NEW_VALUE : out STD_LOGIC := '0'
    );

end up_down_counter;

architecture Behavioral of up_down_counter is
	type t_UP_DOWN_STATE is (s_IDLE, s_INCREMENT, s_DECREMENT, s_PRESSED, s_UPDATE_OUTPUT);
	signal r_FSM_STATE : t_UP_DOWN_STATE := s_IDLE;
	signal r_COUNTER : STD_LOGIC_VECTOR(g_OUTPUT_WIDTH - 1 downto 0) := (others => '0');
begin

	process(i_CLK)
	begin
		if(rising_edge(i_CLK)) then
			case r_FSM_STATE is

				when s_IDLE => 
					-- verificar qual o comando, up ou down
					if(i_UP = '1' and i_DOWN = '0') then
						-- mover para o estado de incrementar
						r_FSM_STATE <= s_INCREMENT;
					elsif (i_UP = '0' and i_DOWN = '1') then 
						-- mover para o estado de decrementar
						r_FSM_STATE <= s_DECREMENT;
					else 
						r_FSM_STATE <= s_IDLE;
					end if;

				when s_INCREMENT =>
					r_COUNTER <= r_COUNTER + 1;
					r_FSM_STATE <= s_UPDATE_OUTPUT;

				when s_DECREMENT =>
					r_COUNTER <= r_COUNTER - 1;
					r_FSM_STATE <= s_UPDATE_OUTPUT;

				when s_UPDATE_OUTPUT =>
					o_VALUE <= r_COUNTER;
					o_NEW_VALUE <= '1';
					r_FSM_STATE <= s_PRESSED;

				when s_PRESSED =>
					o_NEW_VALUE <= '0';
					-- enquanto qqr botao estiver pressionado, nao sair deste estado
					if(i_UP = '1' or i_DOWN = '1') then
						r_FSM_STATE <= s_PRESSED;
					else
						r_FSM_STATE <= s_IDLE;
					end if;
			end case;
		end if;
	end process;

end Behavioral;

