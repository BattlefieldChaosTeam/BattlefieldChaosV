-- 读取向左的玩家图像信息
-- player1 : 27*40
-- player2 : 25*35
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.types.all;

entity LeftPlayerPic is
	port(
		player_x, pix_x: in integer range 0 to 2559; --玩家的坐标和请求的坐标
		player_y, pix_y: in integer range 0 to 1919;
		player_num : in std_logic; --玩家编号
		pixel_out: out Pixel; -- 输出像素
		clk : in std_logic --25M的时钟
	);
end entity;

architecture bhv_readRom of LeftPlayerPic is

	component onetotwo IS
	port
	(
		address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
	);
	end component onetotwo;
	
	component twototwo IS
		port
		(
			address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
			clock		: IN STD_LOGIC  := '1';
			q		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
		);
	end component twototwo;

--地址
signal addr1_2 : std_logic_vector(9 downto 0) := (others => '0');
signal addr2_2 : std_logic_vector(9 downto 0) := (others => '0');

--rgb值
signal rgba1_2 : std_logic_vector(9 downto 0);	--输出结果
signal rgba2_2 : std_logic_vector(9 downto 0);

signal addrInt1_2 : integer range 0 to 2000 := 0;
signal addrInt2_2 : integer range 0 to 1000 := 0;

begin
	u2 : onetotwo port map(address => addr1_2, clock => clk, q => rgba1_2); --player1 枪口向左
	u4 : twototwo port map(address => addr2_2, clock => clk, q => rgba2_2); --player2 枪口向左

	--地址的转换	
	addrInt1_2 <= (pix_y - player_y) * conv_integer(unsigned(PLY_X)) + (pix_x - player_x);
	addr1_2 <= conv_std_logic_vector(addrInt1_2, 10);
	
	addrInt2_2 <= (pix_y - player_y) * conv_integer(unsigned(PLY_X)) + (pix_x - player_x);
	addr2_2 <= conv_std_logic_vector(addrInt2_2, 10);

	--判断玩家是否在请求的坐标范围之内	
	pixel_out.valid <= false when pix_x - player_x >= conv_integer(unsigned(PLY_X)) or pix_x < player_x or pix_y - player_y >= conv_integer(unsigned(PLY_Y)) or pix_y < player_y else
					   false when player_num = '0' and rgba1_2(0) = '0' else
					   false when player_num = '1' and rgba2_2(0) = '0' else
					   true;

	--将读取到的信息复制给输出的像素
	pixel_out.r <= rgba1_2(9 downto 7) when player_num = '0' else
				   rgba2_2(9 downto 7);
	pixel_out.g <= rgba1_2(6 downto 4) when player_num = '0' else
				   rgba2_2(6 downto 4);
    pixel_out.b <= rgba1_2(3 downto 1) when player_num = '0' else
		           rgba2_2(3 downto 1);
end architecture bhv_readRom;