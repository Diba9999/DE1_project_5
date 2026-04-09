library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_color_fsm is
-- Testbench nemá žádné porty
end tb_color_fsm;

architecture Behavioral of tb_color_fsm is

    -- Deklarace testovaného modulu (DUT - Device Under Test)
    component color_fsm
        Port ( clk          : in  STD_LOGIC;
               rst          : in  STD_LOGIC;
               en           : in  STD_LOGIC;
               up           : in  STD_LOGIC;
               down         : in  STD_LOGIC;
               mode_speed   : in  STD_LOGIC;
               mode_brig    : in  STD_LOGIC;
               color_input  : in  STD_LOGIC_VECTOR (3 downto 0);
               brig         : out STD_LOGIC_VECTOR (3 downto 0);
               speed        : out STD_LOGIC_VECTOR (3 downto 0);
               red          : out STD_LOGIC_VECTOR (7 downto 0);
               green        : out STD_LOGIC_VECTOR (7 downto 0);
               blue         : out STD_LOGIC_VECTOR (7 downto 0)
             );
    end component;

    -- Signály pro propojení s DUT
    signal clk          : STD_LOGIC := '0';
    signal rst          : STD_LOGIC := '0';
    signal en           : STD_LOGIC := '0';
    signal up           : STD_LOGIC := '0';
    signal down         : STD_LOGIC := '0';
    signal mode_speed   : STD_LOGIC := '0';
    signal mode_brig    : STD_LOGIC := '0';
    signal color_input  : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
    
    signal brig         : STD_LOGIC_VECTOR (3 downto 0);
    signal speed        : STD_LOGIC_VECTOR (3 downto 0);
    signal red          : STD_LOGIC_VECTOR (7 downto 0);
    signal green        : STD_LOGIC_VECTOR (7 downto 0);
    signal blue         : STD_LOGIC_VECTOR (7 downto 0);

    -- Definice periody hodin pro 100 MHz
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instanciace testovaného modulu
    uut: color_fsm Port map (
          clk          => clk,
          rst          => rst,
          en           => en,
          up           => up,
          down         => down,
          mode_speed   => mode_speed,
          mode_brig    => mode_brig,
          color_input  => color_input,
          brig         => brig,
          speed        => speed,
          red          => red,
          green        => green,
          blue         => blue
        );

    -- Generování hodinového signálu (100 MHz)
    clk_process :process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Hlavní simulační proces
    stim_proc: process
    begin		
        -- 1. Fáze: Inicializace a Reset
        rst <= '1';
        wait for 50 ns;
        rst <= '0';
        wait for 50 ns;
        
        -- Povolení funkce (Enable)
        en <= '1';
        wait for 50 ns;

        -- 2. Fáze: Testování změny jasu (výchozí stav je SET_BRIGHTNESS, hodnota je 6)
        -- Nasimulujeme stisk tlačítka UP (přesně na 1 takt)
        up <= '1'; wait for CLK_PERIOD; up <= '0'; 
        wait for 100 ns; -- Očekáváme brig = 7
        
        up <= '1'; wait for CLK_PERIOD; up <= '0'; 
        wait for 100 ns; -- Očekáváme brig = 8

        -- Nasimulujeme stisk tlačítka DOWN
        down <= '1'; wait for CLK_PERIOD; down <= '0'; 
        wait for 100 ns; -- Očekáváme návrat brig = 7

        -- 3. Fáze: Přepnutí do režimu rychlosti
        mode_speed <= '1'; wait for CLK_PERIOD; mode_speed <= '0';
        wait for 100 ns;

        -- 4. Fáze: Testování pauzy (snížení rychlosti z výchozích 5 na 0)
        for i in 1 to 5 loop
            down <= '1'; wait for CLK_PERIOD; down <= '0';
            wait for 50 ns;
        end loop;
        -- Nyní by speed měl být 0 (PAUZA)
        
        wait for 500 ns; -- Chvíli počkáme, abychom v průbězích viděli, že počítadlo stojí
        
        -- 5. Fáze: Znovuspuštění na nejvyšší rychlost (speed = 1 -> 1 sekunda na duhu)
        up <= '1'; wait for CLK_PERIOD; up <= '0'; 
        wait for 100 ns;


        -- 6. Fáze: Očekávání na přechod barvy
        -- Při rychlosti "1" trvá 1 krok 130 718 taktů (cca 1,3 milisekundy v simulaci)
        -- Počkáme tedy 1.5 ms, abychom v simulaci bezpečně viděli, že červená klesne na FE a zelená stoupne na 01
        wait for 1.5 ms;
        
        -- Změníme jas, abychom viděli okamžitý dopad na ztlumenou barvu
        mode_brig <= '1'; wait for CLK_PERIOD; mode_brig <= '0'; wait for 50 ns;
        down <= '1'; wait for CLK_PERIOD; down <= '0'; -- brig klesne na 6
        
        wait for 1 ms;

        -- Konec simulace (zastaví proces)
        report "Simulace dokoncena." severity note;
        wait;
    end process;

end Behavioral;