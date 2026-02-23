library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsm is
    generic (
        CLKQ : integer := 1;
        B : real := 0.5;
        L : real := 0.5;
        SEQUENCE : std_logic_vector(2 downto 0) := "101"
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        data_in : in std_logic_vector(7 downto 0);
        LEDS : out std_logic_vector(5 downto 0);  -- bargraph nb détections
        LEDS_POSI : out std_logic_vector(7 downto 0); -- positions chevauchements
        SEG : out std_logic_vector(7 downto 0);
        AN : out std_logic_vector(3 downto 0);
        buzzer_out : out std_logic;
        LED_out : out std_logic
    );
end fsm;

architecture Behavioral of fsm is
    type state_type is (wai, BEEP_ON, BEEP_OFF, DONE);
    signal current_state, next_state : state_type := wai;
    signal digit_ov : unsigned(3 downto 0) := (others => '0'); -- pour 7seg
    signal count_det : integer range 0 to 6 := 0; -- nb total de détections
    signal count_ov : integer range 0 to 6 := 0; -- nb de chevauchements
    signal timer : integer range 0 to CLKQ := 0;
    signal beeps_left : integer range 0 to 6 := 0;
    signal leds_pattern : std_logic_vector(5 downto 0) := (others => '0');
    signal leds_pos : std_logic_vector(7 downto 0) := (others => '0');
    type int_array is array (0 to 5) of integer;
    signal ov_pos_start : int_array := (others => 0);
begin

    -- 72segments : nombre de chevauchements (count_ov)
    digit_ov <= to_unsigned(count_ov, 4);

    process (digit_ov)
    begin
        case digit_ov is -- --------pgfedcba--------
            when "0000" => SEG <= "01000000"; -- 0
            when "0001" => SEG <= "01111001"; -- 1
            when "0010" => SEG <= "00100100"; -- 2
            when "0011" => SEG <= "00110000"; -- 3
            when "0100" => SEG <= "00011001"; -- 4
            when "0101" => SEG <= "00010010"; -- 5
            when "0110" => SEG <= "00000010"; -- 6
            when "0111" => SEG <= "01111000"; -- 7
            when "1000" => SEG <= "00000000"; -- 8
            when "1001" => SEG <= "00010000"; -- 9
            when others => SEG <= "11111111"; -- éteint
        end case;
    end process;

    -- Sorties directes
    AN <= "110"; -- un seul digit actif
    LEDS <= leds_pattern; -- 6 LEDs = nb détections
    LEDS_POSI <= leds_pos; -- 8 LEDs = positions chevauchements
    buzzer_out <= '1' when current_state = BEEP_ON else '0';
    LED_out <= '1' when current_state = BEEP_ON else '0';

    -- LEDs de position : ALL chevauchements (multi?bits one?hot)
    process (ov_pos_start, count_ov)
        variable tmp : std_logic_vector(7 downto 0);
    begin
        tmp := (others => '0');

        -- jusqu'à 6 chevauchements possibles
        for i in 0 to 5 loop
            if i < count_ov then
                case ov_pos_start(i) is
                    when 0 => tmp(0) := '1';
                    when 1 => tmp(1) := '1';
                    when 2 => tmp(2) := '1';
                    when 3 => tmp(3) := '1';
                    when 4 => tmp(4) := '1';
                    when 5 => tmp(5) := '1';
                    when 6 => tmp(6) := '1';
                    when 7 => tmp(7) := '1';
                    when others => null;
                end case;
            end if;
        end loop;
        leds_pos <= tmp;
    end process;

    -- Bargraph LEDS : nombre total de détections (count_det)
    process (count_det)
    begin
        case count_det is
            when 0 => leds_pattern <= "000000";
            when 1 => leds_pattern <= "000001";
            when 2 => leds_pattern <= "000011";
            when 3 => leds_pattern <= "000111";
            when 4 => leds_pattern <= "001111";
            when 5 => leds_pattern <= "011111";
            when others => leds_pattern <= "111111"; -- 6 ou plus
        end case;
    end process;

    -- FSM combinatoire : next_state
    process(current_state, count_det, timer, beeps_left)
    begin
        next_state <= current_state;
        case current_state is
            when wai =>
                if count_det > 0 then
                    next_state <= BEEP_ON;
                end if;
            when BEEP_ON =>
                if timer = CLKQ then
                    next_state <= BEEP_OFF;
                end if;
            when BEEP_OFF =>
                if timer = CLKQ then
                    if beeps_left > 0 then
                        beeps_left <= beeps_left - 1;
                    end if;
                    next_state <= BEEP_ON;
                end if;
            when DONE =>
                next_state <= wai;
        end case;
    end process;

    -- FSM séquentielle
    process(clk, rst)
    begin
        if rst = '1' then
            current_state <= wai;
            timer <= 0;
            beeps_left <= 0;
        elsif rising_edge(clk) then
            current_state <= next_state;

            if current_state = BEEP_ON or current_state = BEEP_OFF then
                if timer = CLKQ then
                    timer <= timer + 1;
                else
                    timer <= 0;
                end if;
            end if;
        end if;
    end process;

    -- Compter les chevauchements et mémoriser positions
    process(data_in)
        variable pos : int_array;
        variable nb_det : integer := 0;
        variable nb_ov : integer := 0;
    begin
        nb_det := 0;

        -- 6 fenêtres de longueur 3 avec protection d'index (0..5)
        if data_in(7 downto 5) = SEQUENCE then
            pos(nb_det) := 5;
            if nb_det < 5 then
                nb_det := nb_det + 1;
            end if;
        end if;

        if data_in(6 downto 4) = SEQUENCE then
            pos(nb_det) := 4;
            if nb_det < 5 then
                nb_det := nb_det + 1;
            end if;
        end if;

        if data_in(5 downto 3) = SEQUENCE then
            pos(nb_det) := 3;
            if nb_det < 5 then
                nb_det := nb_det + 1;
            end if;
        end if;

        if data_in(4 downto 2) = SEQUENCE then
            pos(nb_det) := 2;
            if nb_det < 5 then
                nb_det := nb_det + 1;
            end if;
        end if;

        -- Compter tous les chevauchements et mémoriser positions
        nb_ov := 0;
        for i in 0 to 4 loop
            if pos(i) <= pos(i+1) + 2 and pos(i+1) >= pos(i)-2 and pos(i+1) < pos(i) then
                nb_ov := nb_ov + 1;
            end if;
        end loop;
    end process;

end Behavioral;