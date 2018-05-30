-- Read from rom and return rgb value to render
-- heart : 40 * 44
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use work.types.all;

entity readHeart is
	port(
		player_x, player_y : in integer range 0 to 1000; --玩家的左上角坐标
		cur_x, cur_y : in integer range 0 to 1000; --当前请求像素点的坐标
		rout, gout, bout : out std_logic_vector(2 downto 0);
		tsp: out std_logic; --transparent, 0为透明
		clk : in std_logic --25M的时钟
	);
end entity readHeart;

architecture bhv_readHeart of readHeart is

	component heart IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
	);
	END component heart;


signal addr : std_logic_vector(10 downto 0) := (others => '0');

signal rgba : std_logic_vector(9 downto 0);	--输出结果

signal addrInt : integer range 0 to 3000 := 0;

begin
	u : heart port map(address => addr, clock => clk, q => rgba);
	
	addrInt <= (cur_y - player_y) * 40 + (cur_x - player_x);
	addr <= conv_std_logic_vector(addrInt, 11);

	rout(2) <= rgba(9); rout(1) <= rgba(8); rout(0) <= rgba(7);
	gout(2) <= rgba(6); gout(1) <= rgba(5); gout(0) <= rgba(4);
	bout(2) <= rgba(3); bout(1) <= rgba(2); bout(0) <= rgba(1);
	tsp <= rgba(0);
	
end architecture;