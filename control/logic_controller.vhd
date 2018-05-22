-- Give bullet and player information to vga output
library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

entity logic_controller is
	port(
		rst, clk: in std_logic;
		player_one_input: in std_logic_vector(4 downto 0);
		player_two_input: in std_logic_vector(4 downto 0);
		enter: in std_logic;
		bullets_output: out BULLETS;
		players_output: out PLAYERS;
		barriers_output:out BARRIERS
	);
end entity logic_controller;

architecture logic_controller_bhv of logic_controller is
	
	component speedmod is
		port(
			rst, clk : in std_logic;
			p : PLAYER;
			is_hit, dir_hit : in std_logic;
			l, r, u, d : in std_logic;
			key_signal : in std_logic_vector(4 downto 0);-- 分别指示上下左右 0 W 1 S 2 A 3 D, 4 开火
			xs , ys : buffer SPDSET);
	end component speedmod;
	
	component nextpos is
	port(
		rst, clk : in std_logic;
		p : PLAYER;
		x , y : out std_logic_vector(15 downto 0));
	end component nextpos;
	
	signal bullets : BULLETS;
	signal barriers: BARRIERS;
	signal player1, player2: PLAYER;
	signal players: PLAYERS;

	type STATE is (start, init_bar, init_bul, init_p, p1_spdm, p1_spdm_g, p1_mov, p1_mov_g);
--After update_coor reached, the information can be sent to vga controller
--caution : the end of game

	signal cur_state: STATE := start;
	
	signal p1move_enable, p1spdm_enable : std_logic;
	
	signal p1_nxt_x, p1_nxt_y : std_logic_vector(15 downto 0);
	signal p1_nxt_xspd, p1_nxt_yspd : SPDSET;
	
begin

	P1MOVE: nextpos port map(p1move_enable, clk, player1, p1_nxt_x, p1_nxt_y);
	P1SPEMOD: speedmod port map(p1spdm_enable, clk, player1, '0', '0', '0', '0', '0', '1', player_one_input, p1_nxt_xspd, p1_nxt_yspd);
	
	bullets_output <= bullets;
	barriers_output <= barriers;
	players_output <= players;
	
	players(0) <= player1;
	players(1).x <= "0000000000000000";
	players(1).y <= "0000000000000000";
	
	process(clk, rst)
	variable rising_count : integer range 0 to 1000 := 0;
	variable cnt : integer range 0 to 100 := 0;
	begin
		if(rst = '1') then -- to be added
			
			cur_state <= init_bar;
			cnt := 0;
			rising_count := 0;
			p1move_enable <= '1';
			p1spdm_enable <= '1';
			
		elsif(rising_edge(clk)) then
		
		rising_count := rising_count + 1;
		
			case cur_state is
			
				when init_bar => 
					
					case cnt is
						
						when 1 => 
							barriers(cnt).ax <= "0000000100000000";
							barriers(cnt).ay <= "0000000010000000";
							barriers(cnt).bx <= "0000010000000000";
							barriers(cnt).by <= "0000000100000000";							
					
						when 10 =>
							cur_state <= init_bul;
							cnt := 0;
							
						when others =>
					
							barriers(cnt).ax <= "0000000000000000";
							barriers(cnt).ay <= "0000000000000000";
							barriers(cnt).bx <= "0000000000000000";
							barriers(cnt).by <= "0000000000000000";									
						
					end case;
				
					cnt := cnt + 1;
				
				when init_bul=>
					
					case cnt is
						
						when 20 =>
							cur_state <= init_p;
							cnt := 0;
						
						when others =>
							bullets(cnt).x <= "0000000000000000";
							bullets(cnt).y <= "0000000000000000";
							bullets(cnt).in_screen <= '0';
						
					end case;
					
					cnt := cnt + 1;
				
				when init_p =>
					
							player1.x <= "0000001000000000";
							player1.y <= "0000000010000001";
							player1.xs.spd <= "0000000000000000";
							player1.xs.dir <= '0';
							player1.xs.acc <= "0000000000000000";
							player1.ys.spd <= "0000000000000000";
							player1.ys.dir <= '1';
							player1.ys.acc <= "0000000000010000";
							
							cur_state <= p1_spdm;
							
							rising_count := 0;
					
				when p1_spdm =>
				
					p1spdm_enable <= '0';
					p1move_enable <= '1';
					if(rising_count >= 50) then cur_state <= p1_spdm_g; end if;
					
				when p1_spdm_g =>
					
					p1spdm_enable <= '1';
					p1move_enable <= '1';
					
					player1.xs <= p1_nxt_xspd;
					player1.ys <= p1_nxt_yspd;
					
					if(rising_count >= 55) then cur_state <= p1_mov; end if;
					
				when p1_mov =>
					
					p1spdm_enable <= '1';
					p1move_enable <= '0';
					
					if(rising_count >= 60) then cur_state <= p1_mov_g; end if;
					
				when p1_mov_g =>
					
					player1.x <= p1_nxt_x;
					player2.y <= p1_nxt_y;
					
					if(rising_count >= 70) then cur_state <= p1_spdm; rising_count := 0; end if;
					
				when others => 
				
					cur_state <= p1_spdm;
					
			end case;		
		end if;
	end process;
end logic_controller_bhv; 
