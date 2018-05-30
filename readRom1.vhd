-- Read from rom and return rgb value to render
-- player1 : 27*40
-- player2 : 25*35
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use work.types.all;

entity readRom1 is
	port(
		player_x, player_y : in integer range 0 to 1000; --玩家的左上角坐标
		cur_x, cur_y : in integer range 0 to 1000; --当前请求像素点的坐标
		player_num : in std_logic; --玩家编号
		rout, gout, bout : out std_logic_vector(2 downto 0);
		tsp: out std_logic; --transparent, 0为透明
		clk : in std_logic --25M的时钟
	);
end entity readRom1;

architecture bhv_readRom of readRom1 is

	component onetotwo IS
	port
	(
		address		: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
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

signal addr1_2 : std_logic_vector(10 downto 0) := (others => '0');
signal addr2_2 : std_logic_vector(9 downto 0) := (others => '0');

signal rgba1_2 : std_logic_vector(9 downto 0);	--输出结果
signal rgba2_2 : std_logic_vector(9 downto 0);

signal addrInt1_2 : integer range 0 to 2000 := 0;
signal addrInt2_2 : integer range 0 to 1000 := 0;

begin
	u2 : onetotwo port map(address => addr1_2, clock => clk, q => rgba1_2); --player1 枪口向左
	u4 : twototwo port map(address => addr2_2, clock => clk, q => rgba2_2); --player2 枪口向左
	
	addrInt1_2 <= (cur_y - player_y) * 27 + (cur_x - player_x);
	addr1_2 <= conv_std_logic_vector(addrInt1_2, 11);
	
	addrInt2_2 <= (cur_y - player_y) * 25 + (cur_x - player_x);
	addr2_2 <= conv_std_logic_vector(addrInt2_2, 10);
	
	process(player_num)
	begin
		--rgba1_2 <= rgba1_1;
		if(player_num = '0') then --0号玩家
			rout(2) <= rgba1_2(9); rout(1) <= rgba1_2(8); rout(0) <= rgba1_2(7);
			gout(2) <= rgba1_2(6); gout(1) <= rgba1_2(5); gout(0) <= rgba1_2(4);
			bout(2) <= rgba1_2(3); bout(1) <= rgba1_2(2); bout(0) <= rgba1_2(1);
			tsp <= rgba1_2(0);
		else
			rout(2) <= rgba2_2(9); rout(1) <= rgba2_2(8); rout(0) <= rgba2_2(7);
			gout(2) <= rgba2_2(6); gout(1) <= rgba2_2(5); gout(0) <= rgba2_2(4);
			bout(2) <= rgba2_2(3); bout(1) <= rgba2_2(2); bout(0) <= rgba2_2(1);
			tsp <= rgba2_2(0);
		end if;
	end process;
end architecture bhv_readRom;