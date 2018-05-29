library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.types.all;

entity xytrans is
	port(
		players_in : in PLAYERS;
		players_out: out PLAYERS);
end entity;

architecture xytrans_beh of xytrans is

begin
	
	players_out(0).x <= "000" & players_in(0).x(15 downto 3);
	players_out(0).y <= "000" & players_in(0).y(15 downto 3);
	players_out(1).x <= "000" & players_in(1).x(15 downto 3);
	players_out(1).y <= "000" & players_in(1).y(15 downto 3);
	
	players_out(0).xs <= players_in(0).xs;
	players_out(0).ys <= players_in(0).ys;
	players_out(1).xs <= players_in(1).xs;
	players_out(1).ys <= players_in(1).ys;
	
	players_out(0).life <= players_in(0).life;
	players_out(1).life <= players_in(1).life;

end architecture xytrans_beh;
