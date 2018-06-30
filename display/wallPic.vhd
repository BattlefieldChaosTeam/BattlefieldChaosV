-- 障碍物的纹理信息
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.types.all;


entity wallPic is 
	port(
		pix_x: in integer range 0 to 2559;
		pix_y: in integer range 0 to 1919;
		barrier_array: in BARRIERS; --传入障碍物
		pixel_out: out Pixel; --输出像素坐标
		clk: in std_logic
	);
end entity wallPic;

architecture bhv_wallPic of wallPic is

	component wall IS
		port
		(
			address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			clock		: IN STD_LOGIC  := '1';
			q		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
		);
	end component;

	signal myBarriers: BARRIERS;
	
	signal barrier_idx : integer range 0 to 19;
	signal addr : std_logic_vector(7 downto 0) := (others => '0');
	signal rgba : std_logic_vector(9 downto 0);
	signal addrInt: integer range 0 to 2000;
	signal realx: integer range 0 to 20;
	signal wallx : integer := 300; 
	signal wally : integer := 300;
	function check_barrier(
		barrier_x, barrier_y: integer
	)
	return integer is --返回请求坐标点对应的障碍物下标
	begin
		check_loop: for i in myBarriers'range loop
			if conv_integer(myBarriers(i).ax) <= barrier_x and barrier_x < conv_integer(myBarriers(i).bx) 
			and conv_integer(myBarriers(i).ay) <= barrier_y and barrier_y < conv_integer(myBarriers(i).by) then
				return i;
			end if;
		end loop;
		return 19;
	end function;

begin
	myBarriers <= barrier_array;
	u1 : wall port map(address => addr, clock => clk, q => rgba);
	process(pix_x, pix_y)
	begin
		barrier_idx <= check_barrier(pix_x, pix_y);

		if(barrier_idx >= 19) then
			pixel_out.valid <= false;
		else
			wallx <= conv_integer(myBarriers(barrier_idx).ax);
			wally <= conv_integer(myBarriers(barrier_idx).ay);
			realx <= pix_x - wallx - ((pix_x - wallx) mod 20) * 20; --每20个像素点图像开始循环
			addrInt <= (pix_y - wally) * 20 + realx + 2; --坐标点的int地址
			addr <= conv_std_logic_vector(addrInt, 8);

			--将读取的像素进行显示
			pixel_out.r(2) <= rgba(9); pixel_out.r(1) <= rgba(8); pixel_out.r(0) <= rgba(7);
			pixel_out.g(2) <= rgba(6); pixel_out.g(1) <= rgba(5); pixel_out.g(0) <= rgba(4);
			pixel_out.b(2) <= rgba(3); pixel_out.b(1) <= rgba(2); pixel_out.b(0) <= rgba(1);
			if rgba(0) = '0' then
					pixel_out.valid <= false;
			else
				pixel_out.valid <= true;
			end if;
		end if;
	end process;
end architecture bhv_wallPic;
