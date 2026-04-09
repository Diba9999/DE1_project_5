library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_pwm_driver is
-- Testbench nemá porty
end tb_pwm_driver;

architecture sim of tb_pwm_driver is

    -- Parametry simulace
    constant pwm_bits_tb : integer := 8;
    constant CLK_PERIOD  : time := 10 ns; -- 100 MHz

    -- Signály pro propojení s komponentou
    signal clk_tb   : std_logic := '0';
    signal en_tb    : std_logic := '1';
    signal rst_tb   : std_logic := '0';
    signal red_tb   : std_logic_vector(7 downto 0) := (others => '0');
    signal green_tb : std_logic_vector(7 downto 0) := (others => '0');
    signal blue_tb  : std_logic_vector(7 downto 0) := (others => '0');
    
    signal led_r_tb : std_logic;
    signal led_g_tb : std_logic;
    signal led_b_tb : std_logic;

begin

    -- Instanciace testované jednotky (UUT)
    uut: entity work.pwm_driver
        generic map (
            pwm_bits => pwm_bits_tb
        )
        port map (
            clk   => clk_tb,
            en    => en_tb,
            rst   => rst_tb,
            red   => red_tb,
            green => green_tb,
            blue  => blue_tb,
            led_r => led_r_tb,
            led_g => led_g_tb,
            led_b => led_b_tb
        );

    -- Generátor hodin (Clock process)
    clk_process : process
    begin
        while now < 1 ms loop -- Omezení délky simulace
            clk_tb <= '0';
            wait for CLK_PERIOD / 2;
            clk_tb <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Stimulační proces
    stim_proc: process
    begin		
        -- 1. Reset systému
        rst_tb <= '1';
        wait for 50 ns;
        rst_tb <= '0';
        wait for 20 ns;

        -- 2. Test různých intenzit (vstupy jsou 8-bitové)
        -- Červená: 25% (cca 64), Zelená: 50% (128), Modrá: 75% (192)
        red_tb   <= std_logic_vector(to_unsigned(64, 8));
        green_tb <= std_logic_vector(to_unsigned(128, 8));
        blue_tb  <= std_logic_vector(to_unsigned(192, 8));
        
        -- Počkáme několik celých PWM cyklů (2^8 * 10ns = 2560 ns na cyklus)
        wait for 100 ns;

        -- 3. Test extrémních hodnot
        -- Červená: 0% (Vypnuto), Zelená: 100% (Skoro stále svítí), Modrá: 1 (Minimum)
        red_tb   <= x"00";
        green_tb <= x"FF";
        blue_tb  <= x"01";
        
        wait for 100 ns;

        -- 4. Test Resetu uprostřed běhu
        rst_tb <= '1';
        wait for 100 ns;
        rst_tb <= '0';

        -- Ukončení simulace
        report "Simulace dokoncena";
        wait;
    end process;

end sim;