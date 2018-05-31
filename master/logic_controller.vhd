-- Give bullet and player information to vga output
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.types.all;

entity logic_controller is
	port(
		rst, clk: in std_logic;
		player_one_input: in std_logic_vector(4 downto 0);
		player_two_input: in std_logic_vector(4 downto 0);
		enter: in std_logic;
		bullets_output: out BULLETS;
		players_output: out PLAYERS;
		barriers_output:out BARRIERS;
		curs:out std_logic_vector(2 downto 0);
		xout : out std_logic_vector(15 downto 0)
	);
end entity logic_controller;

architecture logic_controller_bhv of logic_controller is
	
	component speedmod is
		port(
			rst, clk : in std_logic;
			p : PLAYER;
			is_hit, dir_hit : in std_logic;
			l, r, u, d, t : in std_logic;
			key_signal : in std_logic_vector(4 downto 0);-- 分别指示上下左右 0 W 1 S 2 A 3 D, 4 开火
			xs , ys : buffer SPDSET);
	end component speedmod;
	
	component nextpos is
	port(
		rst, clk : in std_logic;
		p : PLAYER;
		x , y : out std_logic_vector(15 downto 0));
	end component nextpos;
	
	component init is
	port(
		rst, clk : in std_logic;
		bullets : out BULLETS;
		barriers: out BARRIERS;
		players : out PLAYERS);
	end component init;
	
	component wallhit is
	port(
		rst, clk : in std_logic;
		x, y : in std_logic_vector(15 downto 0);
		wmap : in BARRIERS;
		l, r, u, d, t : out std_logic);
	end component;
	
	component xytrans is
	port(
		players_in : in PLAYERS;
		players_out: out PLAYERS);
	end component;
	
	component emitBullets is
	port(
		rst, clk : in std_logic;
		emitPlayer1, emitPlayer2 : in std_logic; -- whether player 1 and 2 emit bullet in the last operation
		players: in PLAYERS; -- mainly to get the position of the player
		lastBullets : in BULLETS;
		nextBullets : out BULLETS);
	end component;
	
	component BulletMove is
		port(
		rst, clk: in std_logic;
		lastBullets : in BULLETS; --传进来的子弹状态
		nextBullets : out BULLETS); --传出去的子弹状态
	end component;
	
	component bullethit is
		port(
			rst, clk : in std_logic;
			x, y : in std_logic_vector(15 downto 0);
			bullet_in : in BULLETS;
			bullet_out: out BULLETS;
			is_hit  : out std_logic;
			dir_hit : out std_logic);
	end component;
	
	signal bullets, bullets_init, bullets_nxt, bullets_shot, bullets_hit1, bullets_hit2: BULLETS;
	signal barriers, barriers_init : BARRIERS;
	signal players, players_init, players_tmp: PLAYERS;

	type STATE is (start, init_state, p1work);
--After update_coor reached, the information can be sent to vga controller
--caution : the end of game

	signal cur_state: STATE := start;
	
	-- Enable 
	signal init_enable : std_logic;
	signal p1move_enable, p2move_enable : std_logic;
	signal p1spdm_enable, p2spdm_enable : std_logic;
	signal emit_enable, shot_enable : std_logic;
	signal wallhit_enable, wallhit2_enable: std_logic;
	signal bulhit1_enable, bulhit2_enable: std_logic;
	
	-- Bullet Hit Module
	signal ishit1, dirhit1, ishit2, dirhit2 : std_logic;
	signal ishit1_t, dirhit1_t, ishit2_t, dirhit2_t : std_logic;
	
	-- Wall Hit Module
	signal walll, wallr, wallu, walld, wallt : std_logic;
	signal wl, wr, wu, wd, wt : std_logic;
	signal walll2, wallr2, wallu2, walld2, wallt2 : std_logic;
	signal wl2, wr2, wu2, wd2, wt2 : std_logic;
	
	-- Next Position Module
	signal p1_nxt_x, p1_nxt_y : std_logic_vector(15 downto 0);
	signal p2_nxt_x, p2_nxt_y : std_logic_vector(15 downto 0);
	
	-- Speed Modify Module
	signal p1_nxt_xspd, p1_nxt_yspd : SPDSET;
	signal p2_nxt_xspd, p2_nxt_yspd : SPDSET;
	
	signal tpbit : std_logic;
	signal tpbit1 : std_logic;
	signal tpbit2 : std_logic;
	
begin
	
	PINIT: init port map(init_enable, clk, bullets_init, barriers_init, players_init);
	
	P1MOVE: nextpos port map(p1move_enable, clk, players(0), p1_nxt_x, p1_nxt_y);
	P2MOVE: nextpos port map(p2move_enable, clk, players(1), p2_nxt_x, p2_nxt_y);
	
	P1SPEMOD: speedmod port map(p1spdm_enable, clk, players(0), ishit1, dirhit1, wl, wr, wu, wd, wt, player_one_input, p1_nxt_xspd, p1_nxt_yspd);
	P2SPEMOD: speedmod port map(p2spdm_enable, clk, players(1), ishit2, dirhit2, wl2,wr2,wu2,wd2,wt2,player_two_input, p2_nxt_xspd, p2_nxt_yspd);
	
	P1WALLHIT: wallhit port map(wallhit_enable, clk, players_tmp(0).x, players_tmp(0).y, barriers, walll, wallr, wallu, walld, wallt);
	P2WALLHIT: wallhit port map(wallhit2_enable,clk, players_tmp(1).x, players_tmp(1).y, barriers, walll2,wallr2,wallu2,walld2,wallt2);
	
	XYTRANSITION: xytrans port map(players, players_tmp);
	
	BULLETSHOT: emitBullets port map(emit_enable, clk, player_one_input(4), player_two_input(4), players_tmp, bullets, bullets_nxt);
	
	BULLETMOVING: BulletMove port map(shot_enable, clk, bullets, bullets_shot);
	
	BULLETHIT1: bullethit port map(bulhit1_enable, clk, players_tmp(0).x, players_tmp(0).y, bullets, bullets_hit1, ishit1_t, dirhit1_t);
	BULLETHIT2: bullethit port map(bulhit2_enable, clk, players_tmp(1).x, players_tmp(1).y, bullets, bullets_hit2, ishit2_t, dirhit2_t);
	
	bullets_output <= bullets;
	barriers_output <= barriers;
	players_output <= players_tmp;
	
	--tpbit <= '1' when players(0).y + PLY_Y >= barriers(2).ay else '0';
	--tpbit1<= '1' when not (players(0).x + PLY_X <= barriers(2).ax) else '0';
	--tpbit2<= '1' when not (players(0).x > barriers(2).bx) else '0';
	--xout <= "0000000000000"&tpbit&tpbit1&tpbit2;
	xout <= "0000000000000"&players_tmp(1).y(3)&players_tmp(1).y(2)&players_tmp(1).y(1);
	--if(y <= ay and y + wy + pls >= ay and (not x + wx <= ax) and (not x > bx))
	
	process(clk, rst)
	variable rising_count : integer := 0;
	begin
		if(rst = '0') then -- to be added
			
			curs <= "000";
			
			cur_state <= init_state;
			rising_count := 0;
			
			init_enable <= '1';
			p1move_enable <= '1';  p2move_enable <= '1';
			p1spdm_enable <= '1';  p2spdm_enable <= '1';
			wallhit_enable <= '1'; wallhit2_enable <= '1';
			bulhit1_enable <= '1'; bulhit2_enable <= '1';
			emit_enable <= '1';    shot_enable <= '1';
			
		elsif(rising_edge(clk)) then
		
			case cur_state is
				
				when init_state =>
					
					rising_count := rising_count + 1;
					if(rising_count = 125000) then
						rising_count := 0;
						cur_state <= p1work;
					end if;
					
					case rising_count is
						when 1=> 
							init_enable <= '0';
							p1move_enable <= '1';  p2move_enable <= '1';
							p1spdm_enable <= '1';  p2spdm_enable <= '1';
							wallhit_enable <= '1'; wallhit2_enable <= '1';
							bulhit1_enable <= '1'; bulhit2_enable <= '1';
							emit_enable <= '1';    shot_enable <= '1';
						
						when 50000=>
							bullets <= bullets_init;
							barriers <= barriers_init;
							players <= players_init;
						
						when 70000=>
							barriers(2).ax <= "0000000100000000";
							barriers(2).ay <= "0000001000000000";
							barriers(2).bx <= "0000010000000000";
							barriers(2).by <= "0000001000001000";

						when 80000=>
							barriers(3).ax <= "0000000010000000";
							barriers(3).bx <= "0000000111110100";
							barriers(3).ay <= "0000000110010110";
							barriers(3).by <= "0000000110011110";
						
						when 90000=>
							barriers(4).ax <= "0000001000001000";
							barriers(4).bx <= "0000001001011000";
							barriers(4).ay <= "0000000101101110";
							barriers(4).by <= "0000000101110110";
						
						when 95000=>
							players(0).x <= "0001000000000000";
							players(0).y <= "0000111101110000";
							players(1).x <= "0001000100100000";
							players(1).y <= "0000101110110000";
						
						when others=>
							
					end case;
				
				when p1work =>
					
					rising_count := rising_count + 1;
					if(rising_count = 125000) then
						rising_count := 0;
						cur_state <= p1work;
					end if;
					
					case rising_count is
						
						when 1=> -- Wall Hit Module
						
							init_enable <= '1';
							p1move_enable <= '1';  p2move_enable <= '1';
							p1spdm_enable <= '1';  p2spdm_enable <= '1';
							wallhit_enable <= '0'; wallhit2_enable <= '0';
							bulhit1_enable <= '1'; bulhit2_enable <= '1';
							emit_enable <= '1';    shot_enable <= '1';
						
						when 5000=> -- Wall Hit Module Set
						
							wl <= walll; wl2 <= walll2;
							wr <= wallr; wr2 <= wallr2;
							wu <= wallu; wu2 <= wallu2;
							wd <= walld; wd2 <= walld2;
							wt <= wallt; wt2 <= wallt2;
						
						when 7000=> -- Bullet Hit1 Module 
							
							init_enable <= '1';
							p1move_enable <= '1';  p2move_enable <= '1';
							p1spdm_enable <= '1';  p2spdm_enable <= '1';
							wallhit_enable <= '1'; wallhit2_enable <= '1';
							bulhit1_enable <= '0'; bulhit2_enable <= '1';
							emit_enable <= '1';    shot_enable <= '1';
						
						when 8000=> -- Bullet Hit1 Module Set
							
							ishit1  <= ishit1_t;
							dirhit1 <= dirhit1_t;
							bullets <= bullets_hit1;
						
						when 9000=> -- Bullet Hit2 Module 
							
							init_enable <= '1';
							p1move_enable <= '1';  p2move_enable <= '1';
							p1spdm_enable <= '1';  p2spdm_enable <= '1';
							wallhit_enable <= '1'; wallhit2_enable <= '1';
							bulhit1_enable <= '1'; bulhit2_enable <= '0';
							emit_enable <= '1';    shot_enable <= '1';
						
						when 10000=> -- Bullet Hit2 Module Set
							
							ishit2  <= ishit2_t;
							dirhit2 <= dirhit2_t;
							bullets <= bullets_hit2;
					
						when 11000=> -- Speed Modify Module
						
							init_enable <= '1';
							p1move_enable <= '1';  p2move_enable <= '1';
							p1spdm_enable <= '0';  p2spdm_enable <= '0';
							wallhit_enable <= '1'; wallhit2_enable <= '1';
							bulhit1_enable <= '1'; bulhit2_enable <= '1';
							emit_enable <= '1';    shot_enable <= '1';
						
						when 20000=> -- Speed Modify Module Set
						
							players(0).xs <= p1_nxt_xspd;
							players(0).ys <= p1_nxt_yspd;
							players(1).xs <= p2_nxt_xspd;
							players(1).ys <= p2_nxt_yspd;
						
						when 30000=> -- Next Postion (Moving) Module
						
							init_enable <= '1';
							p1move_enable <= '0';  p2move_enable <= '0';
							p1spdm_enable <= '1';  p2spdm_enable <= '1';
							wallhit_enable <= '1'; wallhit2_enable <= '1';
							bulhit1_enable <= '1'; bulhit2_enable <= '1';
							emit_enable <= '1';    shot_enable <= '1';
						
						when 40000=> --  Next Postion (Moving) Module Set
						
							players(0).x <= p1_nxt_x;
							players(0).y <= p1_nxt_y;
							players(1).x <= p2_nxt_x;
							players(1).y <= p2_nxt_y;
							
						when 50000=> -- Emit Bullets Module
						
							init_enable <= '1';
							p1move_enable <= '1';  p2move_enable <= '1';
							p1spdm_enable <= '1';  p2spdm_enable <= '1';
							wallhit_enable <= '1'; wallhit2_enable <= '1';
							bulhit1_enable <= '1'; bulhit2_enable <= '1';
							emit_enable <= '0';    shot_enable <= '1';
						
						when 55000=> -- Emit Bullets Module Set
						
							bullets <= bullets_nxt;
						
						when 60000=> -- Bullets Move Module
						
							init_enable <= '1';
							p1move_enable <= '1';  p2move_enable <= '1';
							p1spdm_enable <= '1';  p2spdm_enable <= '1';
							wallhit_enable <= '1'; wallhit2_enable <= '1';
							bulhit1_enable <= '1'; bulhit2_enable <= '1';
							emit_enable <= '1';    shot_enable <= '0';
						
						when 65000=> -- Bullets Move Module Set
						
							bullets <= bullets_shot;
							
						when 70000=> -- Ending Module
						
							init_enable <= '1';
							p1move_enable <= '1';  p2move_enable <= '1';
							p1spdm_enable <= '1';  p2spdm_enable <= '1';
							wallhit_enable <= '1'; wallhit2_enable <= '1';
							bulhit1_enable <= '1'; bulhit2_enable <= '1';
							emit_enable <= '1';    shot_enable <= '1';
						
						when others=>
					
					end case;
				
				when others=>
					rising_count := 0;
					cur_state <= p1work;
					
			end case;
			
		end if;
	end process;
end logic_controller_bhv; 
