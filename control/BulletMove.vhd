library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.types.all;

-- 子弹移动，需要另外给出新加入的子弹和去除的子弹
entity BulletMove is
	port(
	clk, rst: in std_logic;
	firing: in std_logic; --上一次输入开火了
	lastBullets : in BULLETS; --传进来的子弹状态
	nextBullets : out BULLETS --传出去的子弹状态
	);
end entity BulletMove;

architecture bhv of BulletMove is 
	constant bullet_speed : std_logic_vector(15 downto 0) := "0000000000000101"; --子弹的长度，速度5和宽度
	constant bullet_length : std_logic_vector(15 downto 0) := "0000000000010100"; --20
	constant bullet_width : std_logic_vector(15 downto 0) := "0000000000001111"; --15
	constant vga_length : std_logic_vector(15 downto 0) := "0000001010000000"; --640
	constant vga_width : std_logic_vector(15 downto 0) := "0000000111100000"; --480
	signal bullet_tep : BULLETS;
begin
	process(clk, rst)
	begin
		if(rst = '1') then
			for i in 0 to 21 loop
				nextBullets(i).in_screen <= '0';
				nextBullets(i).x <= (others => '0');
				nextBullets(i).y <= (others => '0');
			end loop;
		elsif rising_edge(clk) then
			bullet_tep <= lastBullets;
			for i in 0 to 21 loop --更新坐标
				if(bullet_tep(i).direction = '1') then
					bullet_tep(i).x <= bullet_tep(i).x + bullet_speed;
				else
					if(bullet_tep(i).x >= bullet_speed) then
						bullet_tep(i).x <= bullet_tep(i).x - bullet_speed;
					else bullet_tep(i).x <= "0000000000000000";
					end if;
				end if;
			end loop;
			
			for i in 0 to 21 loop --更新是否在图中
				if(bullet_tep(i).in_screen = '1') then
					if(bullet_tep(i).direction = '0' and bullet_tep(i).x <= "0000000000000000") then
						bullet_tep(i).in_screen <= '0';
					elsif(bullet_tep(i).direction = '1' and bullet_tep(i).x >= vga_width) then
						bullet_tep(i).in_screen <= '0';
					end if;
				end if;
			end loop;
			
			for i in 0 to 21 loop --更新输出
				nextBullets(i).direction <= bullet_tep(i).direction;
				nextBullets(i).in_screen <= bullet_tep(i).in_screen;
				if(bullet_tep(i).in_screen = '1') then
					nextBullets(i).x <= bullet_tep(i).x;
					nextBullets(i).y <= bullet_tep(i).y;
				end if;
			end loop;
		end if;
	end process;
end bhv;
