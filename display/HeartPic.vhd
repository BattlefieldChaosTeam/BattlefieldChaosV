-- Read from rom and return rgb value to render
-- heart : 40 * 44
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use work.types.all;

entity readHeart is
	port(
		ply1_life, ply2_life: in integer range 0 to 3;
		pic_x: in integer range 0 to 639; --传入的是640*480坐标系的坐标
		pic_y: in integer range 0 to 479
		player_num : in std_logic;
		pixel_out: out Pixel;
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
signal judge_valid : in std_logic;
begin
	u : heart port map(address => addr, clock => clk, q => rgba);

	addrInt <= pic_y * 40 + pic_x when (0 <= pic_y and pic_y < 44 and 0 <= pic_x and pic_x < 40 and ply1_life >= 1) else
				pic_y * 40 + (pic_x - 40) when (0 <= pic_y and pic_y < 44 and 40 <= pic_x and pic_x < 80 and ply1_life >= 2) else
				pic_y * 40 + (pic_x - 80) when (0 <= pic_y and pic_y < 44 and 80 <= pic_x and pic_x < 120 and ply1_life >= 3) else
				pic_y * 40 + (pic_x - 600) when (0 <= pic_y and pic_y < 44 and 600 <= pic_x and pic_x < 640 and ply2_life >= 3) else
				pic_y * 40 + (pic_x - 560) when (0 <= pic_y and pic_y < 44 and 560 <= pic_x and pic_x < 600 and ply2_life >= 2) else
				pic_y * 40 + (pic_x - 520) when (0 <= pic_y and pic_y < 44 and 520 <= pic_x and pic_x < 560 and ply2_life >= 1) else
				2000;

	addr <= conv_std_logic_vector(addrInt, 11);

	pixel_out.r(2) <= rgba(9); pixel_out.r(1) <= rgba(8); pixel_out.r(0) <= rgba(7);
	pixel_out.g(2) <= rgba(6); pixel_out.g(1) <= rgba(5); pixel_out.g(0) <= rgba(4);
	pixel_out.b(2) <= rgba(3); pixel_out.b(1) <= rgba(2); pixel_out.b(0) <= rgba(1);
	pixel_out.valid <= false when(rgba(0) = '0' or addrInt = 2000) else
						true;
end architecture;