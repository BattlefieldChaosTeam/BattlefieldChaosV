library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.types.all;

-- 子弹移动模块
entity BulletMove is
	port(
	rst, clk: in std_logic;
	lastBullets : in BULLETS; --传进来的子弹状态
	nextBullets : out BULLETS --传出去的子弹状态
	);
end entity BulletMove;

architecture bhv of BulletMove is 
	constant bullet_speed : std_logic_vector(15 downto 0) := "0000000000000001"; --子弹的长度，速度5和宽度
	constant bullet_length : std_logic_vector(15 downto 0) := "0000000000010100"; --20
	constant bullet_width : std_logic_vector(15 downto 0) := "0000000000001111"; --15
	constant vga_length : std_logic_vector(15 downto 0) := "0000101000000000"; -- 2560
	constant vga_width : std_logic_vector(15 downto 0) := "0000011110000000"; -- 1920
	signal bullet_tep : BULLETS;
	type BULX is array (0 to 20) of std_logic_vector(15 downto 0);
	signal bulletx: BULX;
begin
	process(clk, rst)
	variable cnt : integer;
	begin
		if(rst = '1') then --如果要reset，将所有的状态还原
		
			for i in 0 to 20 loop
				nextBullets(i).in_screen <= '0';
				nextBullets(i).x <= (others => '0');
				nextBullets(i).y <= (others => '0');
			end loop;
			cnt := 0;
			
		elsif rising_edge(clk) then
			
			if(cnt < 1000) then cnt := cnt + 1; end if;
			
			case cnt is
				when 1=> 
					bullet_tep <= lastBullets;
					
				when 100=>
					for i in 0 to 20 loop --根据子弹的速度更新坐标
						if(bullet_tep(i).dir = '1') then
							bulletx(i) <= bullet_tep(i).x + bullet_speed;
						else
							if(bullet_tep(i).x >= bullet_speed) then
								bulletx(i) <= bullet_tep(i).x - bullet_speed;
							else bulletx(i) <= "0000000000000000";
							end if;
						end if;
					end loop;
				
				when 300=>
					for i in 0 to 20 loop
						bullet_tep(i).x <= bulletx(i);
					end loop;
				
				when 500=>
					for i in 0 to 20 loop --更新是否在图中
						if(bullet_tep(i).in_screen = '1') then
							if(bullet_tep(i).dir = '0' and bullet_tep(i).x <= "0000000000000000") then
								bullet_tep(i).in_screen <= '0';
							elsif(bullet_tep(i).dir = '1' and bullet_tep(i).x >= vga_width) then
								bullet_tep(i).in_screen <= '0';
							end if;
						end if;
					end loop;	
				
				when 700=> --将子弹的状态输出
					nextBullets <= bullet_tep;
					--for i in 0 to 20 loop --更新输出
					--	nextBullets(i).dir <= bullet_tep(i).dir;
					--	nextBullets(i).in_screen <= bullet_tep(i).in_screen;
					--	if(bullet_tep(i).in_screen = '1') then
					--		nextBullets(i).x <= bullet_tep(i).x;
					--		nextBullets(i).y <= bullet_tep(i).y;
					--	end if;
					--end loop;
				
				when others=>
					
			end case;

		end if;
	end process;
end bhv;
