library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package types is
	--type SINGLECOOR is array(3 downto 0) of integer;
	type BULLET is record
		x, y: std_logic_vector(15 downto 0);
		direction: std_logic; --0 represents left, 1 right
		in_screen: std_logic; --0 represents not in screen, 1 represents in screen
	end record BULLET;
	
	type SPDSET is record
		spd, acc : std_logic_vector(15 downto 0);
		dir : std_logic;
	end record SPDSET;
	
	type PLAYER is record 
		x, y: std_logic_vector(15 downto 0);
		xs, ys : SPDSET; 
		life: integer range 0 to 3; -- life
	end record PLAYER;
	
	type BARRIER is record
		ax, ay, bx, by : std_logic_vector(15 downto 0);
	end record BARRIER;
	
	type BARRIERS is array (0 to 10) of BARRIER;
	
	type BULLETS is array (0 to 20) of BULLET;
	
	type PLAYERS is array (0 to 1) of PLAYER;
	
end types;
