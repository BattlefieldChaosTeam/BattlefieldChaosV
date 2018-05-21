library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;
use work.types.all;

package package_state is
	type STATE is record
		players : PLAYERS;
		bullets : BULLETS;
		barriers: BARRIERS;
		
	end record STATE;
	
end package_state;