-- judge whether the player has lost one life
-- judge the y coordinate of player is larger than the y coordinate of the bottom barrier
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.types.all;     

entity judgeDead is 
	port(
		rst, clk: in std_logic;
		in_player: in PLAYER;
		pdl: out std_logic_vector(3 downto 0);
		pdx, pdy: out std_logic_vector(15 downto 0);
		gameOver: out std_logic
		);
end entity judgeDead;

architecture bhv_judgeDead of judgeDead is

	constant BOUNDY: std_logic_vector(15 downto 0) := "0011110000000000"; -- 1920
begin
	
	process(clk, rst)
	begin
		if(rst = '1') then gameOver <= '0';
		
		elsif(rising_edge(clk)) then
			pdl <= in_player.life;
			pdy <= in_player.y;
			pdx <= in_player.x;
			
			if(in_player.y > BOUNDY) then
				pdl <= in_player.life - "0001";
				if(in_player.life = "0001") then
					gameOver <= '1';
				else gameOver <= '0';
				end if;
				pdx <= "0001001000100000";
				pdy <= "0000001100110000";
			end if;
			
		end if;
	end process;

end architecture bhv_judgeDead;