LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
---------------------------------------------------------------------------
ENTITY FMEAS_MIN IS
	GENERIC (
		time_window : unsigned (19 DOWNTO 0) := X"FFFFF"
	);
	PORT (
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		freq_in : IN STD_LOGIC;
		timer_reset : OUT STD_LOGIC;
		edge_count_out : OUT STD_LOGIC_VECTOR (15 DOWNTO 0));
END FMEAS_MIN;
---------------------------------------------------------------------------
ARCHITECTURE behavior OF FMEAS_MIN IS
	SIGNAL edge_counter : unsigned (15 DOWNTO 0);
	-- SIGNAL timer : unsigned (19 DOWNTO 0);
	SIGNAL reset_edge_counter : STD_LOGIC;
BEGIN

	----------------------------------------------------------
	-- a process counting the edges of the measurable input
	-- occuring during the measure time window
	----------------------------------------------------------
	L_EDGE_COUNTER : PROCESS (freq_in, reset, reset_edge_counter)
	BEGIN
		IF (reset = '1') THEN
			edge_counter <= (OTHERS => '0');
		ELSIF (reset_edge_counter = '1') THEN
			edge_counter <= (OTHERS => '0');
		ELSIF (rising_edge(freq_in)) THEN
			edge_counter <= edge_counter + 1;
		END IF;
	END PROCESS;

	----------------------------------------------------------
	-- a process for defining a measure time window
	----------------------------------------------------------
	L_MEASURE_TIMER : PROCESS (clk, reset)
		VARIABLE timer : unsigned (19 DOWNTO 0);
	BEGIN
		IF (reset = '1') THEN
			timer := (OTHERS => '0');
			edge_count_out <= (OTHERS => '0');
			reset_edge_counter <= '0';
		ELSIF (rising_edge(clk)) THEN
			reset_edge_counter <= '0';
			timer_reset <= '0';
			timer := timer + 1;
			IF (timer = time_window) THEN
				edge_count_out <= STD_LOGIC_VECTOR(edge_counter);
				reset_edge_counter <= '1';
				timer := (OTHERS => '0');
			END IF;

			IF timer = 0 THEN
				timer_reset <= '1';
			END IF;
		END IF;
	END PROCESS;
END behavior;