library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.types.all;

entity nextpos is
	port(
		rst, clk : in std_logic;
		p : PLAYER;
		x , y : out std_logic_vector(15 downto 0));
end entity;

architecture nextpos_beh of nextpos is
	
begin
	
	process(rst, clk)
	variable cnt : integer := 50;
	begin
	
		x <= p.x + p.xs.spd;
		y <= p.y + p.ys.spd;
	
	end process;
	
end architecture nextpos_beh;

