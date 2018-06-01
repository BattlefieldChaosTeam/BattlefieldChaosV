-- Read from rom and return rgb value to render
-- player1 : 27*40
-- player2 : 25*35
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.types.all;

entity LeftPlayerPic is
	port(
		player_x, pix_x: in integer range 0 to 2559;
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

signal addr1_2 : std_logic_vector(9 downto 0) := (others => '0');
signal addr2_2 : std_logic_vector(9 downto 0) := (others => '0');

signal rgba1_2 : std_logic_vector(9 downto 0);	--输出结果
signal rgba2_2 : std_logic_vector(9 downto 0);

signal addrInt1_2 : integer range 0 to 2000 := 0;
signal addrInt2_2 : integer range 0 to 1000 := 0;

begin
	u2 : onetotwo port map(address => addr1_2, clock => clk, q => rgba1_2); --player1 枪口向左
	u4 : twototwo port map(address => addr2_2, clock => clk, q => rgba2_2); --player2 枪口向左
	
	addrInt1_2 <= (pix_y - player_y) * conv_integer(unsigned(PLY_X)) + (pix_x - player_x);
	addr1_2 <= conv_std_logic_vector(addrInt1_2, 10);
	
	addrInt2_2 <= (pix_y - player_y) * conv_integer(unsigned(PLY_X)) + (pix_x - player_x);
	addr2_2 <= conv_std_logic_vector(addrInt2_2, 10);
	
	process(player_num, rgba1_2, rgba2_2, addrInt1_2, addrInt2_2)
	begin
		if pix_x - player_x >= conv_integer(unsigned(PLY_X)) or pix_x < player_x or pix_y - player_y >= conv_integer(unsigned(PLY_Y)) or pix_y < player_y then
			pixel_out.valid <= false;
		elsif(player_num = '0') then --0号玩家
			pixel_out.r(2) <= rgba1_2(9); pixel_out.r(1) <= rgba1_2(8); pixel_out.r(0) <= rgba1_2(7);
			pixel_out.g(2) <= rgba1_2(6); pixel_out.g(1) <= rgba1_2(5); pixel_out.g(0) <= rgba1_2(4);
			pixel_out.b(2) <= rgba1_2(3); pixel_out.b(1) <= rgba1_2(2); pixel_out.b(0) <= rgba1_2(1);
			if rgba1_2(0) = '0' then
				pixel_out.valid <= false;
			else
				pixel_out.valid <= true;
			end if;
		else
			pixel_out.r(2) <= rgba2_2(9); pixel_out.r(1) <= rgba2_2(8); pixel_out.r(0) <= rgba2_2(7);
			pixel_out.g(2) <= rgba2_2(6); pixel_out.g(1) <= rgba2_2(5); pixel_out.g(0) <= rgba2_2(4);
			pixel_out.b(2) <= rgba2_2(3); pixel_out.b(1) <= rgba2_2(2); pixel_out.b(0) <= rgba2_2(1);
			if rgba2_2(0) = '0' then
				pixel_out.valid <= false;
			else
				pixel_out.valid <= true;
			end if;
		end if;
	end process;
end architecture bhv_readRom;