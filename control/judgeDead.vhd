-- 判断玩家是否丢失了一条性命

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.types.all;     

entity judgeDead is 
	port(
		rst, clk: in std_logic;
		in_player: in PLAYER; --传入玩家信息
		pdl: out std_logic_vector(3 downto 0); --传出玩家的生命
		pdx, pdy: out std_logic_vector(15 downto 0); --传出玩家的坐标
		gameOver: out std_logic --传出游戏是否已经结束
		);
end entity judgeDead;

architecture bhv_judgeDead of judgeDead is

	constant BOUNDY: std_logic_vector(15 downto 0) := "0011110000000000"; -- 1920 最底下的坐标
begin
	
	process(clk, rst)
	begin
		if(rst = '1') then gameOver <= '0';
		
		elsif(rising_edge(clk)) then
			pdl <= in_player.life;
			pdy <= in_player.y;
			pdx <= in_player.x;
			
			if(in_player.y > BOUNDY) then --如果玩家掉出
				pdl <= in_player.life - "0001";
				if(in_player.life = "0001") then --判断是否还剩下生命
					gameOver <= '1';
				else gameOver <= '0';
				end if;
				--如果玩家死亡，更新坐标
				pdx <= "0001001000100000";
				pdy <= "0000001100110000";
			end if;
			
		end if;
	end process;

end architecture bhv_judgeDead;