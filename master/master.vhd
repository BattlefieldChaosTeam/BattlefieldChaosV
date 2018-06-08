library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.types.all;

entity master is
	port(
		  M100clk: in std_logic;
		  reset: in std_logic;
		  ps2_data: in std_logic;
		  ps2_clk: in std_logic;
		  hs, vs: out std_logic; -- 行同步，场同步信号
          r, g, b: out std_logic_vector(2 downto 0); -- 颜色输出
		  cur_out: out std_logic_vector(6 downto 0);
		  ply1_out: out std_logic_vector(6 downto 0);
		  ply2_out : out std_logic_vector(6 downto 0);
		  
		  M11clk: in std_logic; -- Serial Port Clk
		  M11clkout: out std_logic; -- Serial Port Clk out
		  Serialkeyboard_in: in std_logic; -- Serial Port Keyboard Input
		  Serialinfo_bullet, Serialinfo_player, Serialinfo_headclk: out std_logic
		  );
	
	function encode_number(x : in std_logic_vector) return std_logic_vector is
	 begin
		case x is
			when "0000" => return "1111110";
			when "0001" => return "1100000";
			when "0010" => return "1011101";
			when "0011" => return "1111001";
			when "0100" => return "1100011";
			when "0101" => return "0111011";
			when "0110" => return "0110111";
			when "0111" => return "1101000";
			when "1000" => return "1111111";
			when "1001" => return "1101011";
			when others => return "0000000";
		end case;
	 end function encode_number;
end entity;

architecture bhv of master is

	component Renderer is
		 port(
			  req_x: in integer range 0 to 639; -- VGA请求像素的坐标
			  req_y: in integer range 0 to 479;
			  bullet_array: in BULLETS;
			  player_array: in PLAYERS;
			  barrier_array: in BARRIERS;
			  which_player: in integer range 0 to 1; -- 指定玩家的主视角
			  res_r, res_g, res_b: out std_logic_vector(2 downto 0); -- 返回的rgb值
			  clk_25M: in std_logic -- 25M时钟
		 );
	end component Renderer;
	
	component Screen is
		 port(
			  clk_25M: in std_logic; -- 25MHz时钟
			  req_x: out integer range 0 to 639; -- 向渲染模块请求的坐标
			  req_y: out integer range 0 to 479;
			  res_r, res_g, res_b: in std_logic_vector(2 downto 0); -- 渲染模块输出的rgb值
			  hs, vs: out std_logic; -- 行同步，场同步信号
			  r, g, b: out std_logic_vector(2 downto 0) -- 颜色输出
		 );
	end component;

	component logic_controller is
		port(
			rst, clk: in std_logic;
			player_one_input: in std_logic_vector(4 downto 0);
			player_two_input: in std_logic_vector(4 downto 0);
			enter_one: in std_logic;
			enter_two: in std_logic;
			bullets_output: out BULLETS;
			players_output: out PLAYERS;
			barriers_output:out BARRIERS;
			curs:out std_logic_vector(2 downto 0);
			xout : out std_logic_vector(15 downto 0);
			gamestate_output: out GAMESTATE
		);
	end component logic_controller;
	
	component Input_Module is
		 port(
			  sys_clk: in std_logic;
			  ps2_data: in std_logic;
			  ps2_clk: in std_logic;
			  player_one: out std_logic_vector(4 downto 0);-- 分别指示上下左右 0 W 1 S 2 A 3 D, 4 开火
			  player_two: out std_logic_vector(4 downto 0);-- 同上
			  enter: out std_logic -- daiceshi !
		 );
	end component Input_Module;
	
	component slowclk is
		port(
		clk: in std_logic;
		key_in : in std_logic_vector(4 downto 0);
		key_out:out std_logic_vector(4 downto 0)
		);
	end component slowclk;
	
	component genClk is
		port(
		M100clk : in std_logic;
		M25clk  :out std_logic
		);
	end component genClk;
	
	component Keyboard_Receiver is
		 port(
			  clk: in std_logic; -- 需要接串口时钟
			  data: in std_logic; -- 串口数据
			  player_input: out std_logic_vector(4 downto 0);
			  head_clk: in std_logic
		 );
	end component;
	
	component Game_Info_Sender is
		 port(
			  clk: in std_logic; -- 11M时钟
			  player_array: in PLAYERS;
			  bullet_array: in BULLETS;
			  bullet_data: out std_logic;
			  player_data: out std_logic;
			  head_clk: in std_logic
		 );
	end component;
	
	signal M25clk : std_logic;
	signal p1_keyboard, p2_keyboard, nouse_keyboard: std_logic_vector(4 downto 0);
	signal p1_slow, p2_slow : std_logic_vector(4 downto 0);
	signal req_x, req_y : integer;
	signal res_r, res_g, res_b : std_logic_vector(2 downto 0);
	signal ctrl_rst, ctrl_clk : std_logic;
	signal key_enter : std_logic;
	
	signal bullets_out : BULLETS;
	signal players_out : PLAYERS;
	signal barriers_out: BARRIERS;
	signal curstate:  std_logic_vector(2 downto 0);
	signal xout : std_logic_vector(15 downto 0);
	signal clk_slow : std_logic;
	signal clk_slow4 : std_logic_vector(4 downto 0);
	
	signal Serialinfo_Clk : std_logic;
	signal Serialkeyboard_Clk : std_logic;

	signal my_head_clk: std_logic;
	signal my_head_cnt: integer range 0 to 5000 := 0;

	signal dumb_game_state: GAMESTATE;
	
begin

	-- generate head_clk
	process(M11clk)
	begin
		if rising_edge(M11clk) then
			if my_head_cnt = 5000 then
				my_head_clk <= '0';
				my_head_cnt <= 0;
			else
				my_head_clk <= '1';
				my_head_cnt <= my_head_cnt + 1;
			end if;
		end if;
	end process;
	Serialinfo_headclk <= my_head_clk;

	-- Input Module
	IP: Input_Module port map(M100clk, ps2_data, ps2_clk, p1_keyboard, nouse_keyboard, key_enter);
	SCLK: slowclk port map(M100clk, p1_keyboard, p1_slow);
	SCLK2:slowclk port map(M100clk, p2_keyboard, p2_slow);
	
	-- Logic Control Module
	LC: logic_controller port map(rst => reset,
								  clk => M100clk,
								  player_one_input => p1_slow,
								  player_two_input => p2_slow,
								  enter_one => key_enter,
								  enter_two => p2_keyboard(0),
								  bullets_output => bullets_out,
								  players_output => players_out,
								  barriers_output => barriers_out,
								  curs => curstate,
								  xout => xout,
								  gamestate_output => dumb_game_state);
	
	-- Display Module
	GK: genClk port map(M100clk, M25clk);
	SCR: Screen port map(M25clk, req_x, req_y, res_r, res_g, res_b, hs, vs, r, g, b);
	RD: Renderer port map(req_x, req_y, bullets_out, players_out, barriers_out, 0, res_r, res_g, res_b, M25clk);
	
	-- Port Module
	Serialinfo_Clk <= M11clk;
	Serialkeyboard_Clk <= M11clk;
	M11clkout <= M11clk;
	KR: Keyboard_Receiver port map(clk => Serialinfo_Clk, data => Serialkeyboard_in, player_input => p2_keyboard, head_clk => my_head_clk);
	GIS: Game_Info_Sender port map(
				clk => Serialinfo_Clk, 
				player_array => players_out,
				bullet_array => bullets_out,
				bullet_data => Serialinfo_bullet, 
				player_data => Serialinfo_player,
				head_clk => my_head_clk);
	
	cur_out <= encode_number("0000");
	ply1_out <= encode_number(p1_keyboard(3 downto 0));
	ply2_out <= encode_number(xout(3 downto 0));
	
end architecture;