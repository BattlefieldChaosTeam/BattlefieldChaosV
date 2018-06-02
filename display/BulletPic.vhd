-- Read from rom and return rgb value to render
-- bullet: 20 * 16
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.types.all;

entity BulletPic is
	port(
		bullet_x, pix_x: in integer range 0 to 2559;
		bullet_y, pix_y: in integer range 0 to 1919;
		bullet_dir : in std_logic; --0表示向左，1表示向右
		pixel_out: out Pixel; -- 输出像素
		clk : in std_logic --25M的时钟
	);
end entity;

architecture bhv_bulletPic of BulletPic is

COMPONENT bulletL IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
	);
END COMPONENT;

COMPONENT bulletR IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
	);
END COMPONENT;

signal addrL : std_logic_vector(8 downto 0) := (others => '0');
signal addrR : std_logic_vector(8 downto 0) := (others => '0');

signal rgbaR : std_logic_vector(9 downto 0);	--输出结果
signal rgbaL : std_logic_vector(9 downto 0);

signal addrIntL : integer range 0 to 2000 := 0;
signal addrIntR : integer range 0 to 1000 := 0;

begin
	u1 : bulletL port map(address => addrL, clock => clk, q => rgbaL);--player1 枪口向右
	u2 : bulletR port map(address => addrR, clock => clk, q => rgbaR); --player2 枪口向右

	addrIntL <= (pix_y - bullet_y) * 20 + (pix_x - bullet_x);
	addrL <= conv_std_logic_vector(addrIntL, 9);

	addrIntR <= (pix_y - bullet_y) * 20 + (pix_x - bullet_x);
	addrR <= conv_std_logic_vector(addrIntR, 9);
	
	process(bullet_dir, pix_x, pix_y, bullet_x, bullet_y)
	begin
		if pix_x - bullet_x >= 20 or pix_x < bullet_x or pix_y - bullet_y >= 16 or pix_y < bullet_y then
			pixel_out.valid <= false;
		elsif(bullet_dir = '0') then --左
			pixel_out.r(2) <= rgbaL(9); pixel_out.r(1) <= rgbaL(8); pixel_out.r(0) <= rgbaL(7);
			pixel_out.g(2) <= rgbaL(6); pixel_out.g(1) <= rgbaL(5); pixel_out.g(0) <= rgbaL(4);
			pixel_out.b(2) <= rgbaL(3); pixel_out.b(1) <= rgbaL(2); pixel_out.b(0) <= rgbaL(1);
			if rgbaL(0) = '0' then
				pixel_out.valid <= false;
			else
				pixel_out.valid <= true;
			end if;
		else
			pixel_out.r(2) <= rgbaR(9); pixel_out.r(1) <= rgbaR(8); pixel_out.r(0) <= rgbaR(7);
			pixel_out.g(2) <= rgbaR(6); pixel_out.g(1) <= rgbaR(5); pixel_out.g(0) <= rgbaR(4);
			pixel_out.b(2) <= rgbaR(3); pixel_out.b(1) <= rgbaR(2); pixel_out.b(0) <= rgbaR(1);
			if rgbaR(0) = '0' then
				pixel_out.valid <= false;
			else
				pixel_out.valid <= true;
			end if;
		end if;
	end process;
end architecture bhv_bulletPic;
