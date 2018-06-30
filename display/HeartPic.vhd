-- 显示玩家生命值（爱心形状）
-- heart : 40 * 44
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.types.all;

entity HeartPic is
	port(
		ply1_life, ply2_life: in std_logic_vector(3 downto 0); --玩家1和2的生命
		pic_x: in integer range 0 to 639; --传入的是640*480坐标系的坐标
		pic_y: in integer range 0 to 479;
		pixel_out: out Pixel; --传出的是像素点的坐标
		clk : in std_logic --25M的时钟
	);
end entity HeartPic;

architecture bhv_readHeart of HeartPic is

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

signal ply1_life_int: integer range 0 to 3;
signal ply2_life_int: integer range 0 to 3;

begin
	ply1_life_int <= conv_integer(unsigned(ply1_life));
	ply2_life_int <= conv_integer(unsigned(ply2_life));
	u : heart port map(address => addr, clock => clk, q => rgba);

	--根据坐标、玩家的生命以及请求点坐标计算请求的地址
	addrInt <= pic_y * 40 + pic_x when (0 <= pic_y and pic_y < 44 and 0 <= pic_x and pic_x < 40 and ply1_life_int >= 1) else
				pic_y * 40 + (pic_x - 40) when (0 <= pic_y and pic_y < 44 and 40 <= pic_x and pic_x < 80 and ply1_life_int >= 2) else
				pic_y * 40 + (pic_x - 80) when (0 <= pic_y and pic_y < 44 and 80 <= pic_x and pic_x < 120 and ply1_life_int >= 3) else
				pic_y * 40 + (pic_x - 600) when (0 <= pic_y and pic_y < 44 and 600 <= pic_x and pic_x < 640 and ply2_life_int >= 3) else
				pic_y * 40 + (pic_x - 560) when (0 <= pic_y and pic_y < 44 and 560 <= pic_x and pic_x < 600 and ply2_life_int >= 2) else
				pic_y * 40 + (pic_x - 520) when (0 <= pic_y and pic_y < 44 and 520 <= pic_x and pic_x < 560 and ply2_life_int >= 1) else
				2000;

	addr <= conv_std_logic_vector(addrInt, 11);

	pixel_out.r(2) <= rgba(9); pixel_out.r(1) <= rgba(8); pixel_out.r(0) <= rgba(7);
	pixel_out.g(2) <= rgba(6); pixel_out.g(1) <= rgba(5); pixel_out.g(0) <= rgba(4);
	pixel_out.b(2) <= rgba(3); pixel_out.b(1) <= rgba(2); pixel_out.b(0) <= rgba(1);
	pixel_out.valid <= false when(rgba(0) = '0' or addrInt = 2000) else --如果为透明或者越界，不予显示
						true;
end architecture;