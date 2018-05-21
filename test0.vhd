library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.types.all;

entity test0 is
	port(
		  sys_clk: in std_logic;
		  M100clk: in std_logic;
		  my_clk: in std_logic;
		  reset: in std_logic;
		  ps2_data: in std_logic;
		  ps2_clk: in std_logic;
		  hs, vs: out std_logic; -- 行同步，场同步信号
        r, g, b: out std_logic_vector(2 downto 0) -- 颜色输出
		  );
end entity;

architecture test0_beh of test0 is

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
			  clk_100M: in std_logic; -- 100MHz时钟
			  req_x: out integer range 0 to 639; -- 向渲染模块请求的坐标
			  req_y: out integer range 0 to 479;
			  res_r, res_g, res_b: in std_logic_vector(2 downto 0); -- 渲染模块输出的rgb值
			  hs, vs: out std_logic; -- 行同步，场同步信号
			  r, g, b: out std_logic_vector(2 downto 0) -- 颜色输出
		 );
	end component Screen;

	component logic_controller is
		port(
			rst, clk: in std_logic;
			player_one_input: in std_logic_vector(4 downto 0);
			player_two_input: in std_logic_vector(4 downto 0);
			enter: in std_logic;
			bullets_output: out BULLETS;
			players_output: out PLAYERS;
			barriers_output:out BARRIERS
		);
	end component logic_controller;
	
	component Input_Module is
		 port(
			  sys_clk: in std_logic;
			  reset: in std_logic;
			  ps2_data: in std_logic;
			  ps2_clk: in std_logic;
			  player_one: out std_logic_vector(4 downto 0);-- 分别指示上下左右 0 W 1 S 2 A 3 D, 4 开火
			  player_two: out std_logic_vector(4 downto 0);-- 同上
			  enter: out std_logic -- daiceshi !
		 );
	end component Input_Module;
	
	signal p1_keyboard, p2_keyboard : std_logic_vector(4 downto 0);
	signal req_x, req_y : integer;
	signal res_r, res_g, res_b : std_logic_vector(2 downto 0);
	signal ctrl_rst, ctrl_clk : std_logic;
	signal key_enter : std_logic;
	
	signal bullets_out : BULLETS;
	signal players_out : PLAYERS;
	signal barriers_out: BARRIERS;
	
begin

	IP: Input_Module port map(M100clk, reset, ps2_data, ps2_clk, p1_keyboard, p2_keyboard, key_enter);
	LC: logic_controller port map(ctrl_rst, ctrl_clk, p1_keyboard, p2_keyboard, '1', bullets_out, players_out, barriers_out);
	SCR: Screen port map(M100clk, req_x, req_y, res_r, res_g, res_b, hs, vs, r, g, b);
	RD: Renderer port map(req_x, req_y, bullets_out, players_out, barriers_out, 0, res_r, res_g, res_b);
	
end architecture test0_beh;