	component int_osc is
		port (
			clkout : out std_logic;        -- clk
			oscena : in  std_logic := 'X'  -- oscena
		);
	end component int_osc;

	u0 : component int_osc
		port map (
			clkout => CONNECTED_TO_clkout, -- clkout.clk
			oscena => CONNECTED_TO_oscena  -- oscena.oscena
		);

