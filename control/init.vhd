library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.types.all;

entity init is
	port(
		rst, clk : in std_logic;
		bullets : out BULLETS;
		barriers: out BARRIERS;
		players : out PLAYERS);
end entity;

architecture init_beh of init is

	type STATE is (init_bullets, init_barriers, init_players, init_final);
	signal cnt : integer;
	signal cur : STATE;
	
begin

	process(rst, clk) 
	begin
		if(rst = '1') then
			cnt <= 0;
			cur <= init_bullets;
			
		elsif (rising_edge(clk)) then
			
			case cur is
				
				when init_bullets =>
					cnt <= cnt + 1;
					if(cnt > 9) then cnt <= 0; cur <= init_barriers; end if;
					case cnt is
						when others =>
							bullets(cnt).x <= "0000000000000000";
							bullets(cnt).y <= "0000000000000000";
							bullets(cnt).in_screen <= '0';
					end case;
				
				when init_barriers =>
					cnt <= cnt + 1;
					if(cnt > 19) then cnt <= 0; cur <= init_players; end if;
					case cnt is
						when 2 => 
							barriers(cnt).ax <= "0000000100000000";
							barriers(cnt).ay <= "0000000010000000";
							barriers(cnt).bx <= "0000010000000000";
							barriers(cnt).by <= "0000000100000000";
						when others =>
							barriers(cnt).ax <= "0000000000000000";
							barriers(cnt).ay <= "0000000000000000";
							barriers(cnt).bx <= "0000000000000000";
							barriers(cnt).by <= "0000000000000000";
					end case;
				
				when init_players =>
				
					players(0).x <= "0001000000000000";
					players(0).y <= "0000001100110000";
					players(0).xs.spd <= "0000000000000000";
					players(0).xs.dir <= '0';
					players(0).xs.acc <= "0000000000000000";
					players(0).ys.spd <= "0000000000000000";
					players(0).ys.dir <= '1';
					players(0).ys.acc <= "0000000000000001";
					players(0).life <= "0011";
					
					players(1).x <= "0001001000100000";
					players(1).y <= "0000001100110000";
					players(1).xs.spd <= "0000000000000000";
					players(1).xs.dir <= '0';
					players(1).xs.acc <= "0000000000000000";
					players(1).ys.spd <= "0000000000000000";
					players(1).ys.dir <= '1';
					players(1).ys.acc <= "0000000000000001";
					players(1).life <= "0011";
					
					cur <= init_final;
					cnt <= 0;
							
				when init_final =>
					cur <= init_final;
					
				when others=>
					cur <= init_bullets;
				
			end case;
			
		end if;
	end process;
end architecture init_beh;

