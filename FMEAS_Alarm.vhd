LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY FMEAS_Alarm IS
    GENERIC (
        threshold_frequency : STD_LOGIC_VECTOR (15 DOWNTO 0) := X"F0F0";
        alarm_output_threshold : integer := 10
    );
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        frequency_count : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        timer_reset : IN STD_LOGIC;
        alarm : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE main OF FMEAS_Alarm IS
    TYPE state IS (standby, one, two, three, four, five);
    SIGNAL pr_state, nx_state : state;
    SIGNAL alarm_signal : STD_LOGIC;

    -- CONSTANT threshold : INTEGER := 10;
BEGIN

    PROCESS (reset, clk)
    BEGIN
        IF (reset = '1') THEN
            pr_state <= standby;
        ELSIF (clk'EVENT AND clk = '1') THEN
            pr_state <= nx_state;
        END IF;
    END PROCESS;

    PROCESS (frequency_count, timer_reset)
    BEGIN
        IF timer_reset = '1' THEN
            CASE pr_state IS
                WHEN standby =>
                    IF (frequency_count >= threshold_frequency) THEN
                        nx_state <= one;
                    ELSE
                        nx_state <= standby;
                    END IF;
                WHEN one =>
                    IF (frequency_count >= threshold_frequency) THEN
                        nx_state <= two;
                    ELSE
                        nx_state <= standby;
                    END IF;
                WHEN two =>
                    IF (frequency_count >= threshold_frequency) THEN
                        nx_state <= three;
                    ELSE
                        nx_state <= standby;
                    END IF;
                WHEN three =>
                    IF (frequency_count >= threshold_frequency) THEN
                        nx_state <= four;
                    ELSE
                        nx_state <= standby;
                    END IF;
                WHEN four =>
                    IF (frequency_count >= threshold_frequency) THEN
                        nx_state <= five;
                    ELSE
                        nx_state <= standby;
                    END IF;

                WHEN five =>
                    nx_state <= standby;
            END CASE;
        END IF;
    END PROCESS;

    alarm_signal <= '1' WHEN pr_state = five ELSE
        '0';

    PROCESS (clk)
        VARIABLE clock_count : INTEGER := 0;
        VARIABLE start_count : STD_LOGIC := '0';
    BEGIN
        IF clk'EVENT AND clk = '1' THEN

            IF start_count = '0' THEN
                alarm <= '0';
            END IF;

            IF alarm_signal = '1' THEN
                start_count := '1';
            END IF;

            IF start_count = '1' THEN
                clock_count := clock_count + 1;
                alarm <= '1';
            END IF;

            IF clock_count >= alarm_output_threshold THEN
                start_count := '0';
                clock_count := 0;
                alarm <= '0';
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;