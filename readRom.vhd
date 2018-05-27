-- Read from rom and return rgb value to render
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use work.types.all;

entity readRom is
	port(
		player_x, player_y : in integer range 0 to 1000; --玩家的左上角坐标
		cur_x, cur_y : in integer range 0 to 1000; --当前请求像素点的坐标
		player_dir : in std_logic; --玩家的方向，0表示枪口向左，1表示枪口向右
		player_num : in std_logic; --玩家编号
		rout, gout, bout : out std_logic_vector(2 downto 0);
		clk : in std_logic --25M的时钟
	);
end entity readRom;

architecture bhv_readRom of readRom is
	
	component onetoone IS
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
			clock		: IN STD_LOGIC  := '1';
			q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END component onetoone;

	component onetotwo IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
	END component onetotwo;

signal addr1_1 : std_logic_vector(10 downto 0) := (others => '0');
signal addr1_2 : std_logic_vector(10 downto 0) := (others => '0');
signal rgb1_1 : std_logic_vector(7 downto 0);	--输出结果
signal rgb1_2 : std_logic_vector(7 downto 0);	--输出结果
signal addrInt1_1 : integer range 0 to 2000 := 0;
signal addrInt1_2 : integer range 0 to 2000 := 0;

begin
	u1 : onetoone port map(address => addr1_1, clock => clk, q => rgb1_1);
	u2 : onetotwo port map(address => addr1_2, clock => clk, q => rgb1_2);
	
	addrInt1_1 <= (cur_y - player_y) * 47 + (cur_x - player_x);
	addr1_1 <= conv_std_logic_vector(addrInt1_1, 11); --左上角显示
	addrInt1_2 <= (cur_y - player_y) * 47 + (cur_x - player_x);
	addr1_2 <= conv_std_logic_vector(addrInt1_2, 11); --左上角显示
	
	process(player_dir, player_num)
	begin
		if(player_num = '1') then
			if(player_dir = '1') then
				rout(2) <= rgb1_1(7); rout(1) <= rgb1_1(6); rout(0) <= rgb1_1(5);
				gout(2) <= rgb1_1(4); gout(1) <= rgb1_1(3); gout(0) <= rgb1_1(2);
				bout(2) <= rgb1_1(1); bout(1) <= rgb1_1(0); bout(0) <= '0';
			else
				rout(2) <= rgb1_2(7); rout(1) <= rgb1_2(6); rout(0) <= rgb1_2(5);
				gout(2) <= rgb1_2(4); gout(1) <= rgb1_2(3); gout(0) <= rgb1_2(2);
				bout(2) <= rgb1_2(1); bout(1) <= rgb1_2(0); bout(0) <= '0';
			end if;
		end if;
	end process;
end architecture bhv_readRom;