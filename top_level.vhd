LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY top_level IS
    GENERIC (
        time_window : unsigned (19 DOWNTO 0) := X"FFFFF";
        threshold_frequency : STD_LOGIC_VECTOR (15 DOWNTO 0) := X"F0F0";
        alarm_output_threshold : integer := 10
    );
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        freq_input : IN STD_LOGIC;
        alarm : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE rtl OF top_level IS
    SIGNAL freq_count : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL timer_reset : STD_LOGIC;
BEGIN
    frequency_counter : ENTITY work.FMEAS_MIN
        GENERIC MAP(time_window => time_window)
        PORT MAP(
            clk => clk,
            reset => reset,
            freq_in => freq_input,
            timer_reset => timer_reset,
            edge_count_out => freq_count
        );

    alarm_manager : ENTITY work.FMEAS_Alarm
        GENERIC MAP(
            threshold_frequency => threshold_frequency,
            alarm_output_threshold => alarm_output_threshold
        )
        PORT MAP(
            clk => clk,
            reset => reset,
            frequency_count => freq_count,
            timer_reset => timer_reset,
            alarm => alarm
        );
END ARCHITECTURE;