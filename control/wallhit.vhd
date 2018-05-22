library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.types.all;                                                

entity wallhit is
	port(
		rst, clk : in std_logic;
		x, y : in std_logic_vector(15 downto 0);
		wmap : in BARRIERS;
		l, r, u, d : out std_logic);
end entity;

architecture wallhit_beh of wallhit is
	
	constant wx : std_logic_vector(15 downto 0) := "0000000000001010";
	constant wy : std_logic_vector(15 downto 0) := "0000000000001010";
	
begin

	process(rst, clk) 
	variable cnt : integer;
	variable ax, ay : std_logic_vector(15 downto 0);
	variable bx, by : std_logic_vector(15 downto 0);
	
	begin
		if (rst = '0') then -- async reset
			cnt := 9;
			l <= '0';
			r <= '0';
			u <= '0';
			d <= '0';
			
		elsif (rising_edge(clk)) then -- working : need 9 clks to stable
			
			if(cnt = 9) then
				cnt := 0; -- begin
			else
				cnt := cnt + 1; -- next pending
			end if;
			
			ax := wmap(cnt).ax;
			ay := wmap(cnt).ay;
			bx := wmap(cnt).bx;
			by := wmap(cnt).by;
			
			if(ax <= x and x <= bx and (not y + wy <= ay) and (not by <= y)) then u <= '1'; end if;
			if(ax <= x + wx and x + wx <= bx and (not y + wy <= ay) and (not by <= y)) then d <= '1'; end if;
			if(ay <= y and y <= by and (not x + wx <= ax) and (not bx <= x)) then l <= '1'; end if;
			if(ay <= y + wy and y + wy <= by and (not x + wx <= ax) and (not bx <= x)) then r <= '1'; end if;
		end if;
	end process;
	
end architecture wallhit_beh;

