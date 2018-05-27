library ieee;

use ieee.std_logic_1164.all;

entity Naive_render is
    port(
        req_x: in integer range 0 to 639;
        req_y: in integer range 0 to 479;
        res_r, res_g, res_b: out std_logic_vector(2 downto 0);
		  rgb_whole : out std_logic_vector(2 downto 0);
		  clk_25M : in std_logic
    );
end entity;

architecture bhv of Naive_render is

	component readRom is
		port(
			player_x, player_y : in integer range 0 to 1000; --玩家的左上角坐标
			cur_x, cur_y : in integer range 0 to 1000; --当前请求像素点的坐标
			player_dir : in std_logic; --玩家的方向，0表示枪口向左，1表示枪口向右
			player_num : in std_logic; --玩家编号
			rout, gout, bout : out std_logic_vector(2 downto 0);
			clk : in std_logic --25M的时钟
		);
	end component readRom;

	signal rgb_tep : std_logic_vector(2 downto 0);
	signal r_tep, g_tep, b_tep : std_logic_vector(2 downto 0);
	
   begin
	rgb_whole <= rgb_tep;
	u1 : readRom port map(200, 200, req_x, req_y, '0', '1', r_tep, g_tep, b_tep, clk_25M);
	process(req_x, req_y)
	  begin
		if (req_x >= 0 and req_x < 47 and req_y >= 0 and req_y < 39) then
			 res_r <= r_tep;
			 res_g <= g_tep;
			 res_b <= b_tep;
			 --res_r <= "000";
			 --res_g <= "111";
			 --res_b <= "000";
		elsif (req_x >= 200 and req_x < 247 and req_y >= 200 and req_y < 239) then
			 res_r <= r_tep;
			 res_g <= g_tep;
			 res_b <= b_tep;
			 if(r_tep = "111" and g_tep = "111" and b_tep = "110") then
				res_r <= "000";
				res_g <= "000";
				res_b <= "111";
			 else
				res_r <= r_tep;
				res_g <= g_tep;
				res_b <= b_tep; 
			 end if;
			 --res_r(2) <= rgb_tep(2);
			 --res_g(2) <= rgb_tep(1);
			 --res_b(2) <= rgb_tep(0);
			 ---res_r(1) <= '0';
			 --res_r(0) <= '0';
			 --res_g(1) <= '0';
			 --res_g(0) <= '0';
			 --res_b(1) <= '0';
			 --res_b(0) <= '0';
			 --res_r <= "100";
			 --res_g <= "100";
			 --res_b <= "100";
		elsif (req_x >= 400 and req_x < 447 and req_y >= 200 and req_y < 239) then
			 res_r <= "000";
			 res_g <= "111";
			 res_b <= "000";
		else
			 res_r <= "000";
			 res_g <= "000";
			 res_b <= "111";
		end if;
	  end process;
end architecture;