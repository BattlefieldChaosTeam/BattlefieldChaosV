library ieee;

use ieee.std_logic_1164.all;

entity keyclk is
	port(
		clk_in : in std_logic;
		clk_out : out std_logic
	);
end entity keyclk;

architecture keyclkbeh of keyclk is
	signal clk : std_logic := '0';
begin
	process (clk_in) is
		variable counter : integer := 0;
	begin
		if rising_edge(clk_in) then
			counter := counter + 1;
			if counter = 100000 then
				counter := 0;
				clk <= not clk;
			end if;
		end if;
	end process;
	clk_out <= clk;
end architecture keyclkbeh;