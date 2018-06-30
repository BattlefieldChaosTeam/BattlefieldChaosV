-- 读取朝右的玩家像素信息
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.types.all;

entity RightPlayerPic is
	port(
		player_x, pix_x: in integer range 0 to 2559;
		player_y, pix_y: in integer range 0 to 1919;
		player_num : in std_logic; --玩家编号
		pixel_out: out Pixel; -- 输出像素
		clk : in std_logic --25M的时钟
	);
end entity;

architecture bhv_readRom of RightPlayerPic is
	
	component onetoone IS
	port
	(
		address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
	);
	end component onetoone;

	
	component twotoone IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
	);
	end component twotoone;


signal addr1_1 : std_logic_vector(9 downto 0) := (others => '0');
signal addr2_1 : std_logic_vector(9 downto 0) := (others => '0');

signal rgba1_1 : std_logic_vector(9 downto 0);	--输出结果
signal rgba2_1 : std_logic_vector(9 downto 0);

signal addrInt1_1 : integer range 0 to 2000 := 0;
signal addrInt2_1 : integer range 0 to 1000 := 0;

begin
	u1 : onetoone port map(address => addr1_1, clock => clk, q => rgba1_1);--player1 枪口向右
	u3 : twotoone port map(address => addr2_1, clock => clk, q => rgba2_1); --player2 枪口向右

	--转换地址
	addrInt1_1 <= (pix_y - player_y) * conv_integer(unsigned(PLY_X)) + (pix_x - player_x);
	addr1_1 <= conv_std_logic_vector(addrInt1_1, 10);

	addrInt2_1 <= (pix_y - player_y) * conv_integer(unsigned(PLY_X)) + (pix_x - player_x);
	addr2_1 <= conv_std_logic_vector(addrInt2_1, 10);

	--判断像素点是否有效	
	pixel_out.valid <= false when pix_x - player_x >= conv_integer(unsigned(PLY_X)) or pix_x < player_x or pix_y - player_y >= conv_integer(unsigned(PLY_Y)) or pix_y < player_y else
					   false when player_num = '0' and rgba1_1(0) = '0' else
					   false when player_num = '1' and rgba2_1(0) = '0' else
					   true;

	--将读取到的信息进行复制
	pixel_out.r <= rgba1_1(9 downto 7) when player_num = '0' else
				   rgba2_1(9 downto 7);
	pixel_out.g <= rgba1_1(6 downto 4) when player_num = '0' else
				   rgba2_1(6 downto 4);
	pixel_out.b <= rgba1_1(3 downto 1) when player_num = '0' else
	               rgba2_1(3 downto 1);
end architecture bhv_readRom;