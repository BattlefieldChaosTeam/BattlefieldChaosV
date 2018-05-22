library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.types.all;

entity bullethit is
	port(
		rst, clk : in std_logic;
		x, y : in std_logic_vector(15 downto 0);
		bmap : in BULLETS;
		is_hit  : out std_logic;
		dir_hit : out std_logic);
end entity;

architecture bullethit_beh of bullethit is
	signal out_hit, dirout_hit : std_logic;
	
	signal wx : std_logic_vector(15 downto 0) := "0000000000001010";
	signal wy : std_logic_vector(15 downto 0) := "0000000000001010";
	
begin
	process(rst, clk) 
	variable cnt : integer;
	variable bx, by : std_logic_vector(15 downto 0);
	begin
		if (rst = '0') then -- async reset
			out_hit <= '0';
			dirout_hit <= '0';
			cnt := 19;
			
		elsif (rising_edge(clk)) then -- working
			
			if (cnt = 19) then
				cnt := 0; -- begin
				out_hit <= '0';
				dir_hit <= '0';
			else
				cnt := cnt + 1; -- next pending
			end if;
			
			bx := bmap(cnt).x;
			by := bmap(cnt).y;
			
			if((y <= by) and (by <= y + wy)) then
				if(x - wx <= bx and bx <= x) then out_hit <= '1'; dir_hit <= '0';
				elsif(x <= bx and bx <= x + wx) then out_hit <= '1'; dir_hit <= '1';
				end if;
			end if;
			
		end if;
	end process;
	
	is_hit <= out_hit;
	dir_hit <= dirout_hit;
end architecture bullethit_beh;

