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
	
		if(rising_edge(clk)) then 
	
			if(p.xs.dir = '0') then
				x <= p.x - p.xs.spd;
			else
				x <= p.x + p.xs.spd;
			end if;
			
			if(p.ys.dir = '0') then
				y <= p.y - p.ys.spd;
			else 
				y <= p.y + p.ys.spd;
			end if;
		
		end if;
	
	end process;
	
end architecture nextpos_beh;

