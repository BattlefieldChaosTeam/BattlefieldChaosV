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
		enter_one: in std_logic;
		enter_two: in std_logic; -- APPENDING
		bullets_output: out BULLETS;
		players_output: out PLAYERS;
		barriers_output:out BARRIERS;
		curs:out std_logic_vector(2 downto 0);
		xout : out std_logic_vector(15 downto 0);
		gamestate_output: out GAMESTATE -- APPENDING
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
			lem1 : out integer;
			lem2 : out integer;
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
	
	component judgeDead is 
		port(
			rst, clk: in std_logic;
			in_player: in PLAYER;
			pdl: out std_logic_vector(3 downto 0);
			pdx, pdy: out std_logic_vector(15 downto 0);
			gameOver: out std_logic
			);
	end component judgeDead;
	
	signal bullets, bullets_init, bullets_nxt, bullets_shot, bullets_hit1, bullets_hit2: BULLETS;
	signal barriers, barriers_init : BARRIERS;
	signal players, players_init, players_tmp: PLAYERS;

	type STATE is (start, p1wait, p2wait, p1init, p1work, p1win, p1lose);
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
	signal jdead1_enable, jdead2_enable: std_logic;
	
	-- Emit Bullet Module
	signal lem1, lem2: integer;
	
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
	
	-- Judge Dead Module
	signal gameover1, gameover2: std_logic;
	signal pdl1, pdl2: std_logic_vector(3 downto 0);
	signal pdy1, pdy2: std_logic_vector(15 downto 0);
	signal pdx1, pdx2: std_logic_vector(15 downto 0);
	
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
	
	BULLETSHOT: emitBullets port map(emit_enable, clk, player_one_input(4), player_two_input(4), players_tmp, lem1, lem2, bullets, bullets_nxt);
	
	BULLETMOVING: BulletMove port map(shot_enable, clk, bullets, bullets_shot);
	
	BULLETHIT1: bullethit port map(bulhit1_enable, clk, players_tmp(0).x, players_tmp(0).y, bullets, bullets_hit1, ishit1_t, dirhit1_t);
	BULLETHIT2: bullethit port map(bulhit2_enable, clk, players_tmp(1).x, players_tmp(1).y, bullets, bullets_hit2, ishit2_t, dirhit2_t);
	
	JD1: judgeDead port map(jdead1_enable, clk, players(0), pdl1, pdx1, pdy1, gameover1);
	JD2: judgeDead port map(jdead2_enable, clk, players(1), pdl2, pdx2, pdy2, gameover2);
	
	bullets_output <= bullets;
	barriers_output <= barriers;
	players_output <= players_tmp;

	xout <= "000000000000"&players(0).life;
	curs <= players(1).life(2 downto 0);
	
	process(clk, rst)
	variable rising_count : integer := 0;
	begin
		if(rst = '0') then -- to be added
			
			cur_state <= start;
			gamestate_output.s <= "000"; -- Initial : Wait for A(master) & B(slave)
			
			rising_count := 0;
			
			init_enable <= '1';
			p1move_enable <= '1';  p2move_enable <= '1';
			p1spdm_enable <= '1';  p2spdm_enable <= '1';
			wallhit_enable <= '1'; wallhit2_enable <= '1';
			bulhit1_enable <= '1'; bulhit2_enable <= '1';
			emit_enable <= '1';    shot_enable <= '1';
			jdead1_enable <= '1';  jdead2_enable <= '1'; 
			
		elsif(rising_edge(clk)) then
		
			case cur_state is
			
				when start =>
					
					if(enter_one = '1') then 
						cur_state <= p2wait;
						gamestate_output.s <= "010"; -- Initial : Wait for B
					elsif(enter_two = '1') then
						cur_state <= p1wait;
						gamestate_output.s <= "001"; -- Initial : Wait for A
					end if;
				
				when p1wait =>
					
					if(enter_two = '1') then
						cur_state <= p1init;
						gamestate_output.s <= "011"; -- About To Start : Few Seconds before start
					end if;
				
				when p2wait =>
					
					if(enter_one = '1') then
						cur_state <= p1init;
						gamestate_output.s <= "011"; -- About To Start : Few Seconds before start
					end if;
				
				when p1init =>
					
					rising_count := rising_count + 1;
					
					if(rising_count = 20000000) then -- 2sec to start
						rising_count := 0;
						
						cur_state <= p1work;
						gamestate_output.s <= "100"; -- Gamemode
						
					end if;
					
					case rising_count is
					
						when 1=> 
							init_enable <= '0';
							p1move_enable <= '1';  p2move_enable <= '1';
							p1spdm_enable <= '1';  p2spdm_enable <= '1';
							wallhit_enable <= '1'; wallhit2_enable <= '1';
							bulhit1_enable <= '1'; bulhit2_enable <= '1';
							emit_enable <= '1';    shot_enable <= '1';
							jdead1_enable <= '1';  jdead2_enable <= '1'; 
						
						when 50000=>
							bullets <= bullets_init;
							barriers <= barriers_init;
							players <= players_init;
						
						when 60000=>
							players(0).lem <= 0;
							players(1).lem <= 0;
						
						when 70000=>
							barriers(0).ax <= "0000000111110100";
							barriers(0).bx <= "0000001100100000";
							barriers(0).ay <= "0000000111110100";
							barriers(0).by <= "0000000111111110";
							barriers(1).ax <= "0000000111000010";
							barriers(1).bx <= "0000001000010010";
							barriers(1).ay <= "0000001001101100";
							barriers(1).by <= "0000001001110110";
							barriers(2).ax <= "0000001100010110";
							barriers(2).bx <= "0000001111101000";
							barriers(2).ay <= "0000001001100010";
							barriers(2).by <= "0000001001101100";
							barriers(3).ax <= "0000001001011000";
							barriers(3).bx <= "0000001100101010";
							barriers(3).ay <= "0000001010101000";
							barriers(3).by <= "0000001010110010";
							barriers(4).ax <= "0000010011100010";
							barriers(4).bx <= "0000010101000110";
							barriers(4).ay <= "0000001010000000";
							barriers(4).by <= "0000001010001010";
							barriers(5).ax <= "0000010001001100";
							barriers(5).bx <= "0000010011001110";
							barriers(5).ay <= "0000001011100100";
							barriers(5).by <= "0000001011101110";
							barriers(6).ax <= "0000001010101000";
							barriers(6).bx <= "0000001100100000";
							barriers(6).ay <= "0000001100001100";
							barriers(6).by <= "0000001100010110";
							barriers(7).ax <= "0000001100001100";
							barriers(7).bx <= "0000010001100000";
							barriers(7).ay <= "0000001101011100";
							barriers(7).by <= "0000001101100110";
							barriers(8).ax <= "0000000111110100";
							barriers(8).bx <= "0000001011100100";
							barriers(8).ay <= "0000001110011000";
							barriers(8).by <= "0000001110100010";
							barriers(9).ax <= "0000010001111110";
							barriers(9).bx <= "0000010110001100";
							barriers(9).ay <= "0000001110101100";
							barriers(9).by <= "0000001110110110";
							barriers(10).ax <= "0000000101011110";
							barriers(10).bx <= "0000000111100000";
							barriers(10).ay <= "0000010001001100";
							barriers(10).by <= "0000010001010110";
							barriers(11).ax <= "0000001011101110";
							barriers(11).bx <= "0000001110110110";
							barriers(11).ay <= "0000010000010000";
							barriers(11).by <= "0000010000011010";
							barriers(12).ax <= "0000010000011010";
							barriers(12).bx <= "0000010100011110";
							barriers(12).ay <= "0000010001001100";
							barriers(12).by <= "0000010001010110";
							barriers(13).ax <= "0000001001011000";
							barriers(13).bx <= "0000001101010010";
							barriers(13).ay <= "0000010010001000";
							barriers(13).by <= "0000010010010010";
							barriers(14).ax <= "0000001101111010";
							barriers(14).bx <= "0000010001001100";
							barriers(14).ay <= "0000010011000100";
							barriers(14).by <= "0000010011001110";
							barriers(15).ax <= "0000000111110100";
							barriers(15).bx <= "0000001001011000";
							barriers(15).ay <= "0000010100111100";
							barriers(15).by <= "0000010101000110";
							barriers(16).ax <= "0000001010111100";
							barriers(16).bx <= "0000001100100000";
							barriers(16).ay <= "0000010100101000";
							barriers(16).by <= "0000010100110010";
							barriers(17).ax <= "0000010010110000";
							barriers(17).bx <= "0000010100010100";
							barriers(17).ay <= "0000010100010100";
							barriers(17).by <= "0000010100011110";

						when 95000=>
						
						when others=>
							
					end case;
				
				when p1work =>
					
					rising_count := rising_count + 1;
					if(rising_count = 125000) then
						rising_count := 0;
						
						cur_state <= p1work;
						gamestate_output.s <= "100"; -- Gamemode
					end if;
					
					case rising_count is
						
						when 1=> -- Wall Hit Module
						
							init_enable <= '1';
							p1move_enable <= '1';  p2move_enable <= '1';
							p1spdm_enable <= '1';  p2spdm_enable <= '1';
							wallhit_enable <= '0'; wallhit2_enable <= '0';
							bulhit1_enable <= '1'; bulhit2_enable <= '1';
							emit_enable <= '1';    shot_enable <= '1';
							jdead1_enable <= '1';  jdead2_enable <= '1'; 
						
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
							jdead1_enable <= '1';  jdead2_enable <= '1'; 
						
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
							jdead1_enable <= '1';  jdead2_enable <= '1'; 
						
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
							jdead1_enable <= '1';  jdead2_enable <= '1'; 
						
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
							jdead1_enable <= '1';  jdead2_enable <= '1'; 
						
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
							jdead1_enable <= '1';  jdead2_enable <= '1'; 
						
						when 55000=> -- Emit Bullets Module Set
						
							bullets <= bullets_nxt;
							players(0).lem <= lem1;
							players(1).lem <= lem2;
						
						when 60000=> -- Bullets Move Module
						
							init_enable <= '1';
							p1move_enable <= '1';  p2move_enable <= '1';
							p1spdm_enable <= '1';  p2spdm_enable <= '1';
							wallhit_enable <= '1'; wallhit2_enable <= '1';
							bulhit1_enable <= '1'; bulhit2_enable <= '1';
							emit_enable <= '1';    shot_enable <= '0';
							jdead1_enable <= '1';  jdead2_enable <= '1'; 
						
						when 65000=> -- Bullets Move Module Set
						
							bullets <= bullets_shot;
							
						when 70000=> -- Judging Dead Module
							init_enable <= '1';
							p1move_enable <= '1';  p2move_enable <= '1';
							p1spdm_enable <= '1';  p2spdm_enable <= '1';
							wallhit_enable <= '1'; wallhit2_enable <= '1';
							bulhit1_enable <= '1'; bulhit2_enable <= '1';
							emit_enable <= '1';    shot_enable <= '1';
							jdead1_enable <= '0';  jdead2_enable <= '0'; 
						
						when 75000=> -- Judging Dead Module Set
							
							players(0).life <= pdl1;
							players(1).life <= pdl2;
							players(0).x <= pdx1;
							players(1).x <= pdx2;
							players(0).y <= pdy1;
							players(1).y <= pdy2;
							
							if(players(0).life = "0000") then
								cur_state <= p1lose;
								gamestate_output.s <= "110"; -- Final : This play lose; Opponent Win
							elsif(players(1).life = "0000") then
								cur_state <= p1win;
								gamestate_output.s <= "101"; -- Final : This play win; Opponent lose
							end if;
								
						when 80000=> -- Ending Module
						
							init_enable <= '1';
							p1move_enable <= '1';  p2move_enable <= '1';
							p1spdm_enable <= '1';  p2spdm_enable <= '1';
							wallhit_enable <= '1'; wallhit2_enable <= '1';
							bulhit1_enable <= '1'; bulhit2_enable <= '1';
							emit_enable <= '1';    shot_enable <= '1';
							jdead1_enable <= '1';  jdead2_enable <= '1'; 
							
						
						when others=>
					
					end case;
				
				when p1lose=>
					
					cur_state <= p1lose;
					gamestate_output.s <= "110"; -- Final : This play lose; Opponent Win
					
					if(enter_one = '1') then
						cur_state <= start;
						gamestate_output.s <= "000"; 
					end if;
				
				when p1win=>
					
					cur_state <= p1win;
					gamestate_output.s <= "101"; -- Final : This play win; Opponent lose
					
					if(enter_one = '1') then
						cur_state <= start;
						gamestate_output.s <= "000"; 
					end if;
				
				when others=>
					rising_count := 0;
					cur_state <= p1work;
					gamestate_output.s <= "100"; -- Gamemode
					
			end case;
			
		end if;
	end process;
end logic_controller_bhv; 
