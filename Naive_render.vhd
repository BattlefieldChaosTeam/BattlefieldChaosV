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

	component readRom0 is
		port(
			player_x, player_y : in integer range 0 to 1000; --玩家的左上角坐标
			cur_x, cur_y : in integer range 0 to 1000; --当前请求像素点的坐标
			player_num : in std_logic; --玩家编号
			rout, gout, bout : out std_logic_vector(2 downto 0);
			tsp : out std_logic;
			clk : in std_logic --25M的时钟
		);
	end component readRom0;

	component readRom1 is
	port(
		player_x, player_y : in integer range 0 to 1000; --玩家的左上角坐标
		cur_x, cur_y : in integer range 0 to 1000; --当前请求像素点的坐标
		player_num : in std_logic; --玩家编号
		rout, gout, bout : out std_logic_vector(2 downto 0);
		tsp : out std_logic;
		clk : in std_logic --25M的时钟
	);
	end component readRom1;
	
	component readHeart is
	port(
		player_x, player_y : in integer range 0 to 1000; --左上角坐标
		cur_x, cur_y : in integer range 0 to 1000; --当前请求像素点的坐标
		rout, gout, bout : out std_logic_vector(2 downto 0);
		tsp: out std_logic; --transparent, 0为透明
		clk : in std_logic --25M的时钟
	);
	end component readHeart;


	signal r_tep1_1, g_tep1_1, b_tep1_1 : std_logic_vector(2 downto 0);
	signal r_tep2_1, g_tep2_1, b_tep2_1 : std_logic_vector(2 downto 0);
	signal r_tep1_2, g_tep1_2, b_tep1_2 : std_logic_vector(2 downto 0);
	signal r_tep2_2, g_tep2_2, b_tep2_2 : std_logic_vector(2 downto 0);
	
	signal r_heart, g_heart, b_heart : std_logic_vector(2 downto 0);
	
	signal tsp_tep1_1, tsp_tep1_2, tsp_tep2_1, tsp_tep2_2, tsp_heart : std_logic;
	
	
   begin

	u1 : readRom0 port map(0, 0, req_x, req_y, '0', r_tep1_1, g_tep1_1, b_tep1_1, tsp_tep1_1, clk_25M);
	u2 : readRom1 port map(0, 50, req_x, req_y, '0', r_tep1_2, g_tep1_2, b_tep1_2, tsp_tep1_2, clk_25M);
	u3 : readRom0 port map(0, 100, req_x, req_y, '1', r_tep2_1, g_tep2_1, b_tep2_1, tsp_tep2_1, clk_25M);
	u4 : readRom1 port map(0, 150, req_x, req_y, '1', r_tep2_2, g_tep2_2, b_tep2_2, tsp_tep2_2, clk_25M);
	
	u5 : readHeart port map(0, 200, req_x, req_y, r_heart, g_heart, b_heart, tsp_heart, clk_25M);
	
	process(req_x, req_y)
	  begin
		if (req_x >= 0 and req_x < 27 and req_y >= 0 and req_y < 40) then
			if(tsp_tep1_1 = '0') then
				res_r <= "000";
			   res_g <= "111";
			   res_b <= "000";
			else
			   res_r <= r_tep1_1;
			   res_g <= g_tep1_1;
			   res_b <= b_tep1_1;
			end if;
			 --res_r <= "000";
			 --res_g <= "111";
			 --res_b <= "000";
		elsif (req_x >= 0 and req_x < 27 and req_y >= 50 and req_y < 90) then
			if(tsp_tep1_2 = '0') then
				res_r <= "000";
			   res_g <= "111";
			   res_b <= "000";
			else
			   res_r <= r_tep1_2;
			   res_g <= g_tep1_2;
			   res_b <= b_tep1_2;
			end if;
		elsif (req_x >= 0 and req_x < 27 and req_y >= 100 and req_y < 135) then
			if(tsp_tep2_1 = '0') then
				res_r <= "000";
			   res_g <= "111";
			   res_b <= "000";
			else
			   res_r <= r_tep2_1;
			   res_g <= g_tep2_1;
			   res_b <= b_tep2_1;
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
		elsif (req_x >= 0 and req_x < 27 and req_y >= 150 and req_y < 185) then
			if(tsp_tep2_2 = '0') then
				res_r <= "000";
			   res_g <= "111";
			   res_b <= "000";
			else
			   res_r <= r_tep2_2;
			   res_g <= g_tep2_2;
			   res_b <= b_tep2_2;
			end if;
		elsif (req_x >= 0 and req_x < 40 and req_y >= 200 and req_y < 244) then
			if(tsp_heart = '0') then
				res_r <= "000";
			   res_g <= "111";
			   res_b <= "000";
			else
			   res_r <= r_heart;
			   res_g <= g_heart;
			   res_b <= b_heart;
			end if;
		else
			 res_r <= "000";
			 res_g <= "000";
			 res_b <= "111";
		end if;
	  end process;
end architecture;