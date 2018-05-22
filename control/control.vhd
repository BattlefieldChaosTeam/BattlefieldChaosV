library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.types.all;

entity control is
	port(
		rst, clk : in std_logic;
		p : PLAYER;
		key_signal : in std_logic_vector(4 downto 0);
		x , y : out std_logic_vector(15 downto 0));
end entity;

architecture control_beh of control is
	
	component wallhit is
	port(
		rst, clk : in std_logic;
		x, y : in std_logic_vector(15 downto 0);
		wmap : in BARRIERS;
		l, r, u, d : out std_logic);
	end component wallhit;
	
	component bullethit is
	port(
		rst, clk : in std_logic;
		x, y : in std_logic_vector(15 downto 0);
		bmap : in BULLETS;
		is_hit  : out std_logic;
		dir_hit : out std_logic);
	end component bullethit;
	
	component speedmod is
	port(
		rst, clk : in std_logic;
		p : PLAYER;
		is_hit, dir_hit : in std_logic;
		l, r, u, d : in std_logic;
		key_signal : in std_logic_vector(4 downto 0);-- 分别指示上下左右 0 W 1 S 2 A 3 D, 4 开火
		xs , ys : out SPDSET);
	end component speedmod;
	
	component nextpos is
	port(
		rst, clk : in std_logic;
		p : PLAYER;
		x , y : out std_logic_vector(15 downto 0));
	end component nextpos;
	
	signal pick0, pick1, pick2, pick3 : std_logic;
	signal is_hit, dir_hit : std_logic;
	signal wl, wr, wu, wd :  std_logic;
	signal nxs, nys : SPDSET;
	signal curp : PLAYER;
	signal wmap : BARRIERS;
	signal bmap : BULLETS;
	signal px, py : std_logic_vector(15 downto 0);
	signal nxtx, nxty : std_logic_vector(15 downto 0);
	
begin
	
	WALLHIT_C   : wallhit port map(pick0, clk, px, py, wmap, wl, wr, wu, wd);
	BULLETHIT_C : bullethit port map(pick1, clk, px, py, bmap, is_hit, dir_hit);
	SPEEDMOD_C  : speedmod port map(pick2, clk, curp, is_hit, dir_hit, wl, wr, wu, wd, key_signal, nxs, nys);
	NEXTPOS_C   : nextpos port map(pick3, clk, curp, nxtx, nxty);
	
	process(rst, clk)
	variable cnt : integer := 50;
	begin
	
	end process;
	
end architecture control_beh;

