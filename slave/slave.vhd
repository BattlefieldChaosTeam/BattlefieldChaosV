library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.types.all;

entity slave is
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
		  M11clk: in std_logic;
		  Serial_player_in, Serial_bullet_in, Serial_headclk: in std_logic;
		  Serial_keyboard_out: out std_logic;
		  head_clk: in std_logic
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

architecture bhv of slave is

	component Renderer is
		 port(
			  req_x: in integer range 0 to 639; -- VGA请求像素的坐标
			  req_y: in integer range 0 to 479;
			  bullet_array: in BULLETS;
			  player_array: in PLAYERS;
			  barrier_array: in BARRIERS;
			  which_player: in integer range 0 to 1; -- 指定玩家的主视角
			  res_r, res_g, res_b: out std_logic_vector(2 downto 0) -- 返回的rgb值
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
	end component Screen;

	component logic_controller is
		port(
			barriers:out BARRIERS
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
	
	component genClk is
		port(
		M100clk : in std_logic;
		M25clk  : out std_logic
		);
	end component genClk;
	
	component Game_Info_Receiver is
		 port(
			  sys_clk: in std_logic; -- 系统时钟，请给25M的时钟
			  clk: in std_logic; -- 此时钟为杜邦线传来的时钟
			  player_data: in std_logic;
			  bullet_data: in std_logic;
			  rec_players: out PLAYERS;
			  rec_bullets: out BULLETS;
			  head_clk: in std_logic
		 );
	end component;
	
	component Keyboard_Sender is
		 port(
			  sys_clk: in std_logic; -- 100M
			  clk: in std_logic;
			  player_input: in std_logic_vector(4 downto 0);
			  data: out std_logic;
			  head_clk: in std_logic
		 );
	end component;
	
	signal p1_keyboard, p2_keyboard, nouse_keyboard : std_logic_vector(4 downto 0);
	signal p1_slow, p2_slow : std_logic_vector(4 downto 0);
	signal req_x, req_y : integer;
	signal res_r, res_g, res_b : std_logic_vector(2 downto 0);
	signal ctrl_rst, ctrl_clk : std_logic;
	signal key_enter : std_logic;
	
	signal bullets_out : BULLETS;
	signal players_out : PLAYERS;
	signal barriers_out: BARRIERS;
	
	signal M25clk : std_logic;
	
begin
	-- Input Module
	IP: Input_Module port map(M100clk, ps2_data, ps2_clk, p2_keyboard, nouse_keyboard, key_enter);
	
	-- Barriers Generate
	LC: logic_controller port map(barriers_out);
	
	-- Display
	GK: genClk port map(M100clk, M25clk);
	SCR: Screen port map(M25clk, req_x, req_y, res_r, res_g, res_b, hs, vs, r, g, b);
	RD: Renderer port map(req_x, req_y, bullets_out, players_out, barriers_out, 1, res_r, res_g, res_b);
	
	-- Serial Port
	GIR: Game_Info_Receiver port map(M25clk, M11clk, Serial_player_in, Serial_bullet_in, players_out, bullets_out, Serial_headclk);
	KS: Keyboard_Sender port map(M100clk, M11clk, p2_keyboard, Serial_keyboard_out, Serial_headclk);
	
end architecture;