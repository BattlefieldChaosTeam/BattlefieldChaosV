-- Give bullet and player information to vga output
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.types.all;

entity logic_controller is
	port(
		barriers:out BARRIERS
	);
end entity logic_controller;

architecture logic_controller_bhv of logic_controller is
begin

	barriers(2).ax <= "0000000100000000";
	barriers(2).ay <= "0000001000000000";
	barriers(2).bx <= "0000010000000000";
	barriers(2).by <= "0000001000001000";

	barriers(3).ax <= "0000000010000000";
	barriers(3).bx <= "0000000111110100";
	barriers(3).ay <= "0000000110010110";
	barriers(3).by <= "0000000110011110";

	barriers(4).ax <= "0000001000001000";
	barriers(4).bx <= "0000001001011000";
	barriers(4).ay <= "0000000101101110";
	barriers(4).by <= "0000000101110110";

end logic_controller_bhv; 
