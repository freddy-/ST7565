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
library UNISIM;
use UNISIM.VComponents.all;

library UNIMACRO;  
use UNIMACRO.Vcomponents.all;

entity ST7565 is
  Port ( 
  	i_CLK : in  STD_LOGIC;

  	-- TODO inserir portas para acessar o framebuffer para escrita

  	o_SLOW_CLK_DBG: out std_logic;
  	o_INIT_DONE_DBG: out std_logic;
  	o_SPI_FINISHED_DBG: out std_logic;
  	o_SLOW_CLK_ENABLE_DBG: out std_logic;

		o_LCD_CLK: out std_logic := '0';
		o_LCD_MOSI: out std_logic := '0';
		o_LCD_CS: out std_logic := '1';
		o_LCD_DC: out std_logic := '1';
		o_LCD_RESET: out std_logic := '0'
	);
end ST7565;

architecture Behavioral of ST7565 is

	type t_FSM_STATE is (s_RESET, s_INIT, s_IDLE, s_PREPARE_NEXT_DATA, s_PREPARE_SEND, s_SEND, s_SENDING, s_SEND_DONE, s_FINISHED, s_PREPARE_PATTERN, s_NEXT_PAGE, s_WAIT, s_WAITING, s_CS_LOW, s_CS_HIGH, s_WAIT_RESET);
	signal r_FSM_SEND : t_FSM_STATE := s_IDLE;
	signal r_FSM_SEND_NEXT_STATE : t_FSM_STATE := s_IDLE;
	signal r_FSM_DISPLAY : t_FSM_STATE := s_RESET;
	signal r_FSM_DISPLAY_NEXT_STATE : t_FSM_STATE;

	type ARR is array (0 to 11) of std_logic_vector(7 downto 0);
	signal r_command : ARR;	
	signal r_data : std_logic_vector(7 downto 0);

	signal r_spi_data : std_logic_vector (7 downto 0) := (others => '0');
	signal r_init_done : std_logic := '0';

	signal r_spi_start_send : std_logic := '0'; -- quando true o modulo SPI inicia o envio dos dados
	signal r_spi_finished : std_logic := '0'; -- quando true indica que o modulo SPI terminou de enviar os dados
	signal r_spi_sending : std_logic := '0'; -- quando true indica que o modulo SPI está transmitindo
	signal r_continuous_mode : std_logic := '0'; -- quando true o array r_command será enviado em sequencia sem mudar a linha CS

	signal r_slow_clk : std_logic;
	signal r_enable_clk_div : std_logic := '0';
	signal r_reset_delay_cntr : integer range 0 to 141 := 0;

	signal r_column_idx : integer range 0 to 128 := 0;
	signal r_page_idx : integer range 0 to 8 := 1;
	signal r_pattern_counter : integer range 0 to 3 := 0;
	signal r_pattern_type : std_logic := '0';

	signal r_start_send : std_logic := '0';
	signal r_is_command : std_logic := '0';
	signal r_send_done : std_logic;

	signal r_bytes_sended : integer range 0 to 12 := 0;
	signal r_bytes_to_send : integer range 0 to 12 := 0;

  -- bram signals
  signal r_writeAddress : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
  signal r_readAddress : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
  signal r_bramDataOut : STD_LOGIC_VECTOR(7 downto 0);
  signal r_bramDataIn  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
  signal r_enWritePort   : STD_LOGIC;

begin

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
		i_ENABLE_CLK_DIV => r_enable_clk_div,
		o_CLK => r_slow_clk
	);



  framebuffer : BRAM_SDP_MACRO
  generic map (
		BRAM_SIZE => "9Kb",
		DEVICE => "SPARTAN6",
		WRITE_WIDTH => 8, 
		READ_WIDTH => 8,
		DO_REG => 0,
		INIT_FILE => "NONE",
		SIM_COLLISION_CHECK => "ALL",

		INIT_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_01 => X"7cfcfcfcfcfcfcfcfcfcfcfcfcfcfcfcfcfcf8f0e0c080000000000000000000",
		INIT_02 => X"0c1c3c7cfcfcfcfcfcfcfcfcfcfcfcfcfcfcfcfcfcfcfcfc7c3c1c0c040c1c3c",
		INIT_03 => X"0000000000000000000000000000000000000000000000000000000000000004",
		INIT_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_05 => X"00000103070f1f3f7ffffffffffffffffffffffffffffffffefcf8f0e0c08000",
		INIT_06 => X"00000000000103070f1f3f7fffffffff7f3f1f0f070301000000000000000000",
		INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_09 => X"0000000080c0e0f0f8fcffffffffffffffffffffffffffffffff7f3f1f0f0703",
		INIT_0A => X"0000000000000000000000000001010000000000000000000000000000000000",
		INIT_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_0D => X"f8fcfeffffffffffffffffffffffffffffff7f3f1f0f07030100000000000000",
		INIT_0E => X"0000000000000000000000000000000000000000000000000000000080c0e0f0",
		INIT_0F => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_10 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_11 => X"1f3f7ffffffffffffffffffffffffffffffffefcf8f0e0c08000000000000000",
		INIT_12 => X"000000000000000000000000000000000000000000000000000000000103070f",
		INIT_13 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_14 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_15 => X"000000000103070f1f3ffffffffffffffffffffffffffffffffffefcf8f0e0c0",
		INIT_16 => X"0000000000000000000000000080800000000000000000000000000000000000",
		INIT_17 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_18 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_19 => X"000080c0e0f0f8fcfeffffffffffffffffffffffffffffff7f3f1f0f07030100",
		INIT_1A => X"000000000080c0e0f0f8fcfefffffffffefcf8f0e0c080000000000000000000",
		INIT_1B => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_1C => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_1D => X"3e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f1f0f070301000000000000000000",
		INIT_1E => X"30383c3e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3e3c38302030383c",
		INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000020"
	)   
  port map (
		DO => r_bramDataOut,
		DI => r_bramDataIn,
		RDADDR => r_readAddress,
		RDCLK => i_CLK,
		RDEN => '1',
		REGCE => '0',
		RST => '0',
		WE => "1",
		WRADDR => r_writeAddress,
		WRCLK => i_CLK,
		WREN => r_enWritePort
	);



	--=============================================================================
	-- Begin of p_send_data
	-- Processo que envia os dados da memoria(r_command) para o display
	--=============================================================================
	p_send_data : process (i_CLK)
	begin
		if (rising_edge(i_CLK)) then		
			case r_FSM_SEND is

				when s_IDLE =>
					r_send_done <= '0';
					if (r_start_send = '1') then
						r_FSM_SEND <= s_CS_LOW;
						
						if (r_is_command = '1') then
							o_LCD_DC <= '0';
						else
							o_LCD_DC <= '1';
						end if ;
					end if ;
					
				when s_PREPARE_NEXT_DATA =>
					if (r_is_command = '1') then
						if (r_bytes_sended = r_bytes_to_send) then
							r_FSM_SEND <= s_WAIT;
							r_FSM_SEND_NEXT_STATE <= s_CS_HIGH;
						else
							r_spi_data <= r_command(r_bytes_sended);						
							r_spi_start_send <= '1';
							r_bytes_sended <= r_bytes_sended + 1;
							r_FSM_SEND <= s_SENDING;
						end if ;
					else
							r_spi_data <= r_data;						
							r_spi_start_send <= '1';
							r_FSM_SEND <= s_SENDING;
					end if ;


				when s_SENDING =>
					r_spi_start_send <= '0';
					if (r_spi_finished = '1') then -- tem um problema com esta flag, ela sempre começa em TRUE, msm quando nao enviamos nenhum dado ainda
						if (r_continuous_mode = '1') then
							r_FSM_SEND <= s_PREPARE_NEXT_DATA;
						else
							-- aqui devemos dar um toggle no CS (está em LOW -> wait -> HIGH -> wait -> LOW -> wait -> proximo byte)
							r_FSM_SEND <= s_WAIT;
							r_FSM_SEND_NEXT_STATE <= s_CS_HIGH;
						end if;
					end if ;

				when s_CS_HIGH =>
					o_LCD_CS <= '1';
					r_FSM_SEND <= s_WAIT;

					if (r_bytes_sended = r_bytes_to_send or r_is_command = '0') then
						r_FSM_SEND_NEXT_STATE <= s_FINISHED;
					else
						r_FSM_SEND_NEXT_STATE <= s_CS_LOW;
					end if;

				when s_CS_LOW =>
					o_LCD_CS <= '0';
					r_FSM_SEND <= s_WAIT;
					r_FSM_SEND_NEXT_STATE <= s_PREPARE_NEXT_DATA;

				when s_FINISHED =>
					o_LCD_DC <= '1';
					r_bytes_sended <= 0;
					r_send_done <= '1';
					r_FSM_SEND <= s_IDLE;

				when s_WAIT =>
					r_enable_clk_div <= '1';
					r_FSM_SEND <= s_WAITING;	

				when s_WAITING =>
					if (r_slow_clk = '1') then
						r_enable_clk_div <= '0';
						r_FSM_SEND <= r_FSM_SEND_NEXT_STATE;
					end if;

				when others =>
					null;

			end case;
		end if;
	end process p_send_data;



	--=============================================================================
	-- Begin of p_display_control
	-- Processo que executa a inicialização do display e exibe padrões
	--=============================================================================
	p_display_control : process (i_CLK)
	begin
		if (rising_edge(i_CLK)) then						
				case r_FSM_DISPLAY is

					when s_RESET =>
						o_LCD_RESET <= '0';
						r_FSM_DISPLAY <= s_WAIT_RESET;

					when s_WAIT_RESET =>
						r_reset_delay_cntr <= r_reset_delay_cntr + 1;
						if (r_reset_delay_cntr = 140) then				
							o_LCD_RESET <= '1';
							r_FSM_DISPLAY <= s_INIT;
						end if ;

					when s_INIT =>
						r_command(0) <= X"A2";
						r_command(1) <= X"A1";
						r_command(2) <= X"C0";
						r_command(3) <= X"25";
						r_command(4) <= X"81";
						r_command(5) <= X"1B";
						r_command(6) <= X"2F";
						r_command(7) <= X"AF";
						r_command(8) <= X"40";
						r_command(9) <= X"B0";
						r_command(10) <= X"10";
						r_command(11) <= X"00";

						r_is_command <= '1';
						r_bytes_to_send <= 12;
						r_start_send <= '1';
						r_FSM_DISPLAY <= s_SENDING;		

					when s_PREPARE_PATTERN =>
					-- apos inicializar o display
					-- devemos percorrer os endereços de memoria enviando os dados a serem exibidos
					-- e também enviando os dados de NEXT_PAGE
					-- isso deverá ficar num loop
					-- o endereço de memoria partirá de 0 até 1023
					-- a cada 128 envios, será necessário pular para a próxima página

            r_data <= r_bramDataOut;
						r_is_command <= '0';

            if (r_column_idx = 128) then
							r_continuous_mode <= '0';

							if (r_FSM_SEND = s_IDLE) then
            		r_column_idx <= 0;
              	r_FSM_DISPLAY <= s_NEXT_PAGE;
							else
              	r_FSM_DISPLAY <= s_SENDING;
							end if ;
            else
            	r_readAddress <= std_logic_vector(unsigned(r_readAddress) + 1);
            	r_column_idx <= r_column_idx + 1;
							r_start_send <= '1';
							r_continuous_mode <= '1';
              r_FSM_DISPLAY <= s_SENDING;
            end if ;

          when s_NEXT_PAGE =>
          	if (r_page_idx = 8) then          	
							--r_readAddress <= (others => '0');
							--r_page_idx <= 0;

	          	--r_command(0) <= X"40";
	          	--r_command(1) <= X"B0";
	          	--r_command(2) <= X"10";
	          	--r_command(3) <= X"00";

							--r_is_command <= '1';
							--r_bytes_to_send <= 4;
							--r_start_send <= '1';
	            --r_FSM_DISPLAY <= s_SENDING;
	            r_FSM_DISPLAY <= s_FINISHED;

          	else
	          	r_page_idx <= r_page_idx + 1;

	          	r_command(0) <= X"B" & std_logic_vector(to_unsigned(r_page_idx, 4));
	          	r_command(1) <= X"10";
	          	r_command(2) <= X"00";

							r_is_command <= '1';
							r_bytes_to_send <= 3;
							r_start_send <= '1';
	            r_FSM_DISPLAY <= s_SENDING;
          	end if ;

          when s_SENDING =>
						r_start_send <= '0';
						-- só pode preparar o proximo byte se o anterior já começou a enviar, e o anterior do anterior já terminou de enviar
						if (r_continuous_mode = '1' and r_spi_start_send = '1') then
            	r_FSM_DISPLAY <= s_PREPARE_PATTERN;
						end if ;

          	if (r_send_done = '1') then
            	r_FSM_DISPLAY <= s_PREPARE_PATTERN; 
          	end if ;

					when others =>
						null;

				end case;
			end if;
	end process p_display_control;



	o_SLOW_CLK_ENABLE_DBG <= r_enable_clk_div;
	o_SLOW_CLK_DBG <= r_slow_clk;
	-- o_INIT_DONE_DBG <= r_init_done;
	o_SPI_FINISHED_DBG <= r_spi_finished;

end Behavioral;