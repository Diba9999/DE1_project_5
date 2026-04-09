library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_debounce is
-- Testbench nemá žádné porty
end tb_debounce;

architecture Behavioral of tb_debounce is

    component debounce is
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               btn1 : in STD_LOGIC;
               btn2 : in STD_LOGIC;
               btn3 : in STD_LOGIC;
               btn4 : in STD_LOGIC;
               btn1_state : out STD_LOGIC;
               btn2_state : out STD_LOGIC;
               btn3_state : out STD_LOGIC;
               btn4_state : out STD_LOGIC
               );
    end component;

    signal clk  : std_logic := '0';
    signal rst  : std_logic := '0';
    signal btn1 : std_logic := '0';
    signal btn2 : std_logic := '0';
    signal btn3 : std_logic := '0';
    signal btn4 : std_logic := '0';

    signal btn1_state : std_logic;
    signal btn2_state : std_logic;
    signal btn3_state : std_logic;
    signal btn4_state : std_logic;

    constant clk_period : time := 10 ns;

begin

    uut: debounce PORT MAP (
          clk => clk,
          rst => rst,
          btn1 => btn1,
          btn2 => btn2,
          btn3 => btn3,
          btn4 => btn4,
          btn1_state => btn1_state,
          btn2_state => btn2_state,
          btn3_state => btn3_state,
          btn4_state => btn4_state
        );

    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Simulační proces (stimulus)
    stim_proc: process
    begin
        -- Čas: 0 ns
        rst <= '1';
        btn1 <= '0'; btn2 <= '0'; btn3 <= '0'; btn4 <= '0';
        wait for 50 ns; 
        
        -- Čas: 100 ns
        rst <= '0';
        wait for 50 ns;
        
        -- Čas: 100 ns -> Stisk BTN1 (se zákmity)
        btn1 <= '1'; wait for 15 ns;  -- 115 ns
        btn1 <= '0'; wait for 20 ns;  -- 135 ns
        btn1 <= '1'; wait for 10 ns;  -- 145 ns
        btn1 <= '0'; wait for 15 ns;  -- 160 ns
        btn1 <= '1';                  -- 160 ns (ustáleno do HIGH)
        
        wait for 140 ns;              -- Posun času na 300 ns
        
        -- Čas: 300 ns -> Stisk BTN2 a BTN3 (současně, se zákmity)
        btn2 <= '1'; btn3 <= '1'; wait for 12 ns; -- 312 ns
        btn2 <= '0'; btn3 <= '0'; wait for 18 ns; -- 330 ns
        btn2 <= '1'; btn3 <= '1'; wait for 15 ns; -- 345 ns
        btn2 <= '0'; btn3 <= '0'; wait for 10 ns; -- 355 ns
        btn2 <= '1'; btn3 <= '1';                 -- 355 ns (ustáleno do HIGH)
        
        wait for 145 ns;              -- Posun času na 500 ns
        
        -- Čas: 500 ns -> Uvolnění BTN1 (se zákmity)
        btn1 <= '0'; wait for 15 ns;  -- 515 ns
        btn1 <= '1'; wait for 10 ns;  -- 525 ns
        btn1 <= '0'; wait for 20 ns;  -- 545 ns
        btn1 <= '1'; wait for 15 ns;  -- 560 ns
        btn1 <= '0';                  -- 560 ns (definitivně uvolněno)
        
        wait for 40 ns;               -- Posun času na přesných 600 ns
        
        -- ==========================================
        -- Čas: 600 ns -> Uvolnění BTN2
        -- ==========================================
        btn2 <= '0'; 
        
        wait for 20 ns;               -- Posun času na přesných 620 ns
        
        -- ==========================================
        -- Čas: 620 ns -> Uvolnění BTN3 (20 ns zpoždění)
        -- ==========================================
        btn3 <= '0';
        
        wait for 80 ns;               -- Posun času na 700 ns
        
        -- Čas: 700 ns -> Čistý stisk BTN4 pro kontrolu nezávislosti
        btn4 <= '1';
        wait for 150 ns;              -- 850 ns
        btn4 <= '0';
        
        -- Zastavení simulace
        wait;
    end process;

end Behavioral;