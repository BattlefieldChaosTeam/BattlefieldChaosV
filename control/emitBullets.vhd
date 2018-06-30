-- 子弹发射模块 Player emit bullets

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.types.all;

entity emitBullets is
	port(
		rst, clk : in std_logic; 
		emitPlayer1, emitPlayer2 : in std_logic; -- 玩家1和2有没有发射子弹
		players: in PLAYERS; -- 得到玩家的信息
		lem1 : out integer;  --判断玩家上次操作有没有发射子弹
		lem2 : out integer;
		lastBullets : in BULLETS; --传进来的子弹信息
		nextBullets : out BULLETS --穿出去的子弹信息
	);
end entity emitBullets;

architecture bhv_emitBullets of emitBullets is
	constant hply : std_logic_vector(3 downto 0) := "1001";
	constant clst : integer := 120;
begin
	process(clk, rst)
	
	variable slct_idx : integer range 0 to 21; 
	variable cnt : integer range 0 to 100003 := 0;
	begin
		
		if(rst = '1') then
			
			cnt := 0;
			
		elsif(rising_edge(clk)) then
		
			if(cnt > 100000) then 
				cnt := 100000;
			else
				cnt := cnt + 1;
			end if;
			
			case cnt is
				when 1=> 
					for i in 0 to 20 loop --复制子弹信息
						nextBullets(i).x <= lastBullets(i).x;
						nextBullets(i).y <= lastBullets(i).y;
						nextBullets(i).dir <= lastBullets(i).dir;
						nextBullets(i).in_screen <= lastBullets(i).in_screen;
					end loop;
				
				when 30=>
					slct_idx := 21;
					
					if(players(0).lem = 0) then --根据玩家上次有没有发射子弹，更新玩家这次能否发射子弹
						lem1 <= 0;
					else
						lem1 <= players(0).lem - 1;
					end if;
					
					if(players(1).lem = 0) then
						lem2 <= 0;
					else 
						lem2 <= players(1).lem - 1;
					end if;
				
				when 50=>
					if((players(0).lem = 0) and (emitPlayer1 = '1')) then --如果玩家0上次没有发射这次发射
						lem1 <= clst;  
						for i in 0 to 20 loop
							if(lastBullets(i).in_screen = '0') then --选择上次不在屏幕中的子弹进行更新
								slct_idx := i;
								exit;
							end if;
						end loop;
					end if;
				
				when 80=>
					if(slct_idx <= 20) then --如果这次操作要发射新的子弹
						if(players(0).xs.dir = '1' ) then nextBullets(slct_idx).x <= (players(0).x + PLY_X);
							else nextBullets(slct_idx).x <= (players(0).x - PLY_X); end if;
						nextBullets(slct_idx).y <= players(0).y + hply;
						nextBullets(slct_idx).dir <= players(0).xs.dir;
						nextBullets(slct_idx).in_screen <= '1';
					end if;
				
				when 100=>
					slct_idx := 21;
				
				when 120=>
					if((players(1).lem = 0) and  (emitPlayer2 = '1')) then --玩家1，和玩家0基本相同
						lem2 <= clst;
						for i in 0 to 20 loop
							if(lastBullets(i).in_screen = '0') then 
								slct_idx := i;
								exit;
							end if;
						end loop;
					end if;
				
				when 140=>
					if(slct_idx <= 20) then
						if(players(1).xs.dir = '1' ) then nextBullets(slct_idx).x <= (players(1).x + PLY_X);
							else nextBullets(slct_idx).x <= (players(1).x - PLY_X); end if;
						nextBullets(slct_idx).y <= players(1).y + hply;
						nextBullets(slct_idx).dir <= players(1).xs.dir;
						nextBullets(slct_idx).in_screen <= '1';
					end if;
				
				when others=>
					
			end case;
			
		end if;
	end process;
end architecture bhv_emitBullets;