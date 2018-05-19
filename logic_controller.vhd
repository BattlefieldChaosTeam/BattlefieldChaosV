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
		players_output: out PLAYERS
	);
end entity logic_controller;

architecture logic_controller_bhv of logic_controller is

	component bulletMove is
	port(
		bulletMoveEnabled : in std_logic;
		clk, rst: in std_logic;
		lastBullets : in BULLETS; --the state of input bullets
		nextBullets : out BULLETS --the state of output bullets
	);
	end component bulletMove;
	
	component control 
	port(
		control_enable : in std_logic;
		rst, clk : in std_logic;
		p : PLAYER;
		key_signal : in std_logic_vector(4 downto 0);
		x , y : out std_logic_vector(15 downto 0)
	);
	end component control;

	type STATE is (start, init, bullet_move, player_modify, update_coor); 
--After update_coor reached, the information can be sent to vga controller
--caution : the end of game
	signal cur_state: STATE := start;
	constant init_bullets : BULLETS; 
	constant init_players : PLAYERS; --init is to be determined
	signal input_player1, input_player2 : std_logic_vector(4 downto 0);
	signal cur_bullets, next_bullets : BULLETS;
	signal cur_players, next_players : PLAYERS;
	signal enable_bulletMove : std_logic := '0';
	signal enable_player1Control, enable_player2Control : std_logic := '0';
	variable rising_count : integer range 0 to 1000 := 0;
begin
	input_player1 <= player_one_input;
	input_player2 <= player_two_input;
	PH_MOVEBULLET : bulletMove port map(enable_bulletMove, clk, rst, cur_bullets, next_bullets);
	PH_MODIFY_PLAYER_ONE : control port map(enable_player1Control, clk, rst, cur_players(0), input_player1, next_players(0).x, next_players(0).y);
	PH_MODIFY_PLAYER_TWO : control port map(enable_player2Control, clk, rst, cur_players(1), input_player2, next_players(1).x, next_players(1).y);
	process(clk, rst)
	begin
		if(rst = '1') then -- to be added
			cur_state <= start;
			
		elsif(rising_edge(clk)) then
		rising_count := rising_count + 1;
			case cur_state is
				when start => 
					if(enter = '1') then 
					--init information (to be added)
						cur_state <= init;
					else 
						next_bullets <= init_bullets;
						next_players <= init_players;
						cur_state <= update_coor;
					end if;
				when init =>
					rising_count := 0;
					enable_bulletMove <= '1';
					if(rising_count > 10) then cur_state <= bullet_move; --wait
					end if;
				when bullet_move => --move the bullets
					enable_bulletMove <= '0';
					enable_player1Control <= '1';
					enable_player2Control <= '1';
					if(rising_count > 50) then
						cur_state <= player_modify;
					end if;
				when player_modify => --update player information
					enable_player1Control <= '0';
					enable_player2Control <= '0';
					if(rising_count > 60) then
						cur_state <= update_coor;
					end if;
				when update_coor =>  --update coordinate information
					bullets_output <= next_bullets;
					players_output <= next_players;
					cur_bullets <= next_bullets;
					cur_players <= next_players;
					cur_state <= start;
				when others => 
					cur_state <= init;
			end case;		
		end if;
	end process;
end logic_controller_bhv; 
