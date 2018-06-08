library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package types is
	--type SINGLECOOR is std_logic_vector(15 downto 0);
	type BULLET is record
		x, y: std_logic_vector(15 downto 0);
		dir: std_logic; --0 represents left, 1 right
		in_screen: std_logic;
	end record BULLET;
	
	type SPDSET is record
		spd, acc : std_logic_vector(15 downto 0);
		dir : std_logic;
		lst : std_logic_vector(15 downto 0);
		lst2: std_logic_vector(15 downto 0);
		hgd : std_logic;
	end record SPDSET;
	
	type PLAYER is record 
		x, y: std_logic_vector(15 downto 0);
		xs, ys : SPDSET; 
		life: std_logic_vector(3 downto 0); -- life
	end record PLAYER;
	
	type BARRIER is record
		ax, ay, bx, by : std_logic_vector(15 downto 0);
	end record BARRIER;
	
	type BARRIERS is array (0 to 10) of BARRIER;
	
	type BULLETS is array (0 to 20) of BULLET;
	
	type PLAYERS is array (0 to 1) of PLAYER;
	
	constant PLY_X : std_logic_vector(4 downto 0) := "10100"; -- 20
	constant PLY_Y : std_logic_vector(4 downto 0) := "11110"; -- 30
	constant BLT_L : std_logic_vector(4 downto 0) := "00110";

	type Pixel is record
		r: std_logic_vector(2 downto 0);
		g: std_logic_vector(2 downto 0);
		b: std_logic_vector(2 downto 0);
		valid: boolean; -- 指示该像素是否有效
	end record;
	
	type GAMESTATE is record
		s: std_logic_vector(2 downto 0);
	end record; 
		-- "000" Initial : Wait for A(master) & B(slave)
		-- "001" Initial : Wait for A
		-- "010" Initial : Wait for B
		-- "011" About To Start : Few Seconds before start
		-- "100" Gamemode
		-- "101" Final : This play win; Opponent lose
		-- "110" Final : This play lose; Opponent Win
	
end types;