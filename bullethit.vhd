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
		bullet_in : in BULLETS;
		bullet_out: out BULLETS;
		is_hit  : out std_logic;
		dir_hit : out std_logic);
end entity;

architecture bullethit_beh of bullethit is
	
	signal wx : std_logic_vector(4 downto 0) := PLY_X;
	signal wy : std_logic_vector(4 downto 0) := PLY_Y;
	
begin
	process(rst, clk) 
		variable cnt : integer;
		variable bx, by : std_logic_vector(15 downto 0);
	begin
		if (rst = '1') then
		
			is_hit <= '0';
			dir_hit <= '0';
			bullet_out <= bullet_in;
			cnt := 0;
			
		elsif (rising_edge(clk)) then
			
			if (cnt < 50) then
				cnt := cnt + 1;
			end if;
			
			case cnt is
				
				when 1=>
				
					for i in 0 to bullet_in'length - 1 loop
						
						bx := bullet_in(i).x;
						by := bullet_in(i).y;
						
						if((y <= by) and (by <= y + wy) and (x <= bx) and (bx <= x + wx)) then
							is_hit <= '1';
							dir_hit <= not bullet_in(i).dir;
							bullet_out(i).in_screen <= '0';
						end if;
						
					end loop;
				
				when others=>
					
				
			end case;
			
		end if;
	end process;
	
end architecture bullethit_beh;

