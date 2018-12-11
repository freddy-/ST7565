----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:14:29 11/11/2018 
-- Design Name: 
-- Module Name:    ST7565 - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ST7565 is
  Port ( 
  	i_CLK : in  STD_LOGIC;

  	o_SLOW_CLK_DBG: out std_logic;
  	o_INIT_DONE_DBG: out std_logic;

		o_LCD_CLK: out std_logic := '0';
		o_LCD_MOSI: out std_logic := '0';
		o_LCD_CS: out std_logic := '1';
		o_LCD_DC: out std_logic;
		o_LCD_RESET: out std_logic := '0'
	);
end ST7565;

architecture Behavioral of ST7565 is

	type t_FSM_STATE is (s_RESET, s_INIT, s_WAIT, s_IDLE, s_PREPARE_NEXT_DATA, s_PREPARE_SEND, s_SEND, s_SENDING, s_SEND_DONE, s_FINISHED, s_PREPARE_PATTERN, s_NEXT_PAGE, s_DRAW_DONE);
	signal r_FSM_SEND_STATE : t_FSM_STATE := s_IDLE;
	signal r_FSM_DISPLAY : t_FSM_STATE := s_RESET;

	-- ao invés de 12 o array deverá ter 128 elementos
	-- renomear para r_buffer
	type ARR is array (0 to 11) of std_logic_vector(7 downto 0);
	signal r_data : ARR;	

	signal r_spi_data : std_logic_vector (7 downto 0) := (others => '0');
	signal r_init_done : std_logic := '0';

	signal r_spi_start_send : std_logic := '0'; -- quando true o modulo SPI inicia o envio dos dados
	signal r_spi_finished : std_logic := '0'; -- quando true indica que o modulo SPI terminou de enviar os dados
	signal r_spi_sending : std_logic := '0'; -- quando true indica que o modulo SPI está transmitindo

	signal r_slow_clk : std_logic;

	signal r_column_idx : integer range 0 to 128 := 0;
	signal r_page_idx : integer range 0 to 8 := 0;
	signal r_pattern_counter : integer range 0 to 3 := 0;
	signal r_pattern_type : std_logic := '0';

	signal r_start_send : std_logic := '0';
	signal r_is_command : std_logic := '0';
	signal r_send_done : std_logic;

	signal r_bytes_sended : integer range 0 to 12 := 0;
	signal r_bytes_to_send : integer range 0 to 12 := 0;

begin

	-- instanciar um BRAM_SDP_MACRO
	-- ele será o frame buffer completo
	-- criar processo que fica lendo do framebuffer o tempo todo e enviando ao display




	spi_master : entity work.spi
	PORT MAP(
		i_CLK => i_CLK,
    i_DATA => r_spi_data,
    i_START => r_spi_start_send,
    o_SPI_CLK => o_LCD_CLK,
    o_DATA => o_LCD_MOSI,
    o_FINISHED => r_spi_finished,
    o_SENDING => r_spi_sending
	);

	slow_clk : entity work.clk_divider
	GENERIC MAP ( 
		N => 140 
	)
	PORT MAP (
		i_CLK => i_CLK,
		i_ENABLE_CLK_DIV => '1',
		o_CLK => r_slow_clk
	);

	--=============================================================================
	-- Begin of p_send_data
	-- Processo que envia os dados da memoria(r_data) para o display
	--=============================================================================
	-- read: i_CLK, r_slow_clk, r_data, r_start_send, r_bytes_to_send, r_is_command
	-- write: o_LCD_CS, o_LCD_DC, r_spi_data, r_spi_start_send
	-- r/w: r_FSM_SEND_STATE, r_bytes_sended
	p_send_data : process (i_CLK)
	begin
		if (rising_edge(i_CLK)) then
			if (r_slow_clk = '1') then
				case r_FSM_SEND_STATE is

					when s_IDLE =>
						r_send_done <= '0';
						if (r_start_send = '1') then
							r_FSM_SEND_STATE <= s_PREPARE_NEXT_DATA;
							
							if (r_is_command = '1') then
								o_LCD_DC <= '0';
							else
								o_LCD_DC <= '1';
							end if ;
						end if ;

					when s_PREPARE_NEXT_DATA =>
						if (r_bytes_sended = r_bytes_to_send) then
							r_FSM_SEND_STATE <= s_FINISHED;
						else
							r_spi_data <= r_data(r_bytes_sended);
							r_bytes_sended <= r_bytes_sended + 1;
							r_FSM_SEND_STATE <= s_PREPARE_SEND;
						end if ;

					when s_PREPARE_SEND =>
						o_LCD_CS <= '0';
						r_FSM_SEND_STATE <= s_SEND;

					when s_SEND =>
						r_spi_start_send <= '1';
						r_FSM_SEND_STATE <= s_SENDING;

					when s_SENDING =>
						r_spi_start_send <= '0';
						if (r_spi_finished = '1') then
							r_FSM_SEND_STATE <= s_SEND_DONE;
						end if ;

					when s_SEND_DONE =>
						o_LCD_CS <= '1';
						r_FSM_SEND_STATE <= s_PREPARE_NEXT_DATA;						

					when s_FINISHED =>
						r_bytes_sended <= 0;
						r_send_done <= '1';
						r_FSM_SEND_STATE <= s_IDLE;

					when others =>
						null;

				end case;
			end if;
		end if;
	end process p_send_data;



	--=============================================================================
	-- Begin of p_init
	-- Processo que executa a inicialização do display e exibe padrões
	--=============================================================================
	-- read: i_CLK, r_slow_clk, r_send_done
	-- write: o_LCD_RESET, s_INIT, r_bytes_to_send, r_start_send, r_data
	-- r/w: r_FSM_DISPLAY, r_init_done
	p_init : process (i_CLK)
	begin
		if (rising_edge(i_CLK)) then
			if (r_slow_clk = '1') then
				
				case r_FSM_DISPLAY is
					when s_RESET =>
						o_LCD_RESET <= '0';
						r_FSM_DISPLAY <= s_INIT;

					when s_INIT =>
						r_is_command <= '1';
						r_data(0) <= X"A2";
						r_data(1) <= X"A1";
						r_data(2) <= X"C0";
						r_data(3) <= X"25";
						r_data(4) <= X"81";
						r_data(5) <= X"1B";
						r_data(6) <= X"2F";
						r_data(7) <= X"AF";
						r_data(8) <= X"40";
						r_data(9) <= X"B0";
						r_data(10) <= X"10";
						r_data(11) <= X"00";

						r_bytes_to_send <= 12;
						r_start_send <= '1';
						r_FSM_DISPLAY <= s_WAIT;

						o_LCD_RESET <= '1';
						
					when s_WAIT =>
						r_start_send <= '0';
						if (r_send_done = '1') then
							r_FSM_DISPLAY <= s_IDLE;
						end if ;

					when s_IDLE =>
						r_FSM_DISPLAY <= s_PREPARE_PATTERN;


					when s_PREPARE_PATTERN =>
						 if (r_pattern_counter = 3) then
              r_pattern_counter <= 0;
              r_pattern_type <= not r_pattern_type;
            else 
              r_pattern_counter <= r_pattern_counter + 1;
            end if ;

            if (r_pattern_type = '1') then
              r_data(0) <= X"F0";
            else
              r_data(0) <= X"0F";
            end if ;

						r_is_command <= '0';
						r_bytes_to_send <= 1;

            if (r_column_idx = 128) then
            	r_column_idx <= 0;
              r_pattern_counter <= 0;
              r_FSM_DISPLAY <= s_NEXT_PAGE;
            else
            	r_column_idx <= r_column_idx + 1;
							r_start_send <= '1';
              r_FSM_DISPLAY <= s_SENDING;
            end if ;

          when s_NEXT_PAGE =>
          	if (r_page_idx = 8) then
            	r_FSM_DISPLAY <= s_DRAW_DONE;
          	else
	          	r_page_idx <= r_page_idx + 1;

	          	r_data(0) <= X"B" & std_logic_vector(to_unsigned(r_page_idx, 4));
	          	r_data(1) <= X"10";
	          	r_data(2) <= X"00";

							r_is_command <= '1';
							r_bytes_to_send <= 3;
							r_start_send <= '1';
	            r_FSM_DISPLAY <= s_SENDING;
          	end if ;

          when s_SENDING =>
						r_start_send <= '0';
            if (r_send_done = '1') then
              r_FSM_DISPLAY <= s_PREPARE_PATTERN; 
            end if ;

					when s_DRAW_DONE =>
            r_FSM_DISPLAY <= s_DRAW_DONE;


					when others =>
						null;

				end case;

			end if;
		end if;
	end process p_init;




	-- o_SLOW_CLK_DBG <= r_slow_clk;
	-- o_INIT_DONE_DBG <= r_init_done;

end Behavioral;