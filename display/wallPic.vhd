-- bullet 20 * 10
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
		pixel_out: out Pixel;
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


	type inBarrier is record
		ax, ay, bx, by : std_logic_vector(15 downto 0);
	end record inBarrier;
	
	type inBarriers is array (0 to 10) of inBarrier;
	signal myBarriers: inBarriers;
	
	signal barrier_idx : integer range 0 to 11;
	signal addr : std_logic_vector(7 downto 0) := (others => '0');
	signal rgba : std_logic_vector(9 downto 0);
	signal addrInt: integer range 0 to 2000;
	signal realx: integer range 0 to 20;
	signal wallx : integer := 300; 
	signal wally : integer := 300;
	function check_barrier(
		barrier_x, barrier_y: integer
	)
	return integer is --返回对应的障碍物下标
	begin
		check_loop: for i in 0 to 9 loop
			if conv_integer(myBarriers(i).ax) <= barrier_x and barrier_x < conv_integer(myBarriers(i).bx) 
			and conv_integer(myBarriers(i).ay) <= barrier_y and barrier_y < conv_integer(myBarriers(i).by) then
				return i;
			end if;
		end loop;
		return 11;
	end function;

begin
	myBarriers(0).ax <= "0000000111110100";
	myBarriers(0).bx <= "0000001001101100";
	myBarriers(0).ay <= "0000000111110100";
	myBarriers(0).by <= "0000000111111110";
	myBarriers(1).ax <= "0000001101011100";
	myBarriers(1).bx <= "0000001111010100";
	myBarriers(1).ay <= "0000000111110100";
	myBarriers(1).by <= "0000000111111110";
	myBarriers(2).ax <= "0000001010101000";
	myBarriers(2).bx <= "0000001100100000";
	myBarriers(2).ay <= "0000001001001110";
	myBarriers(2).by <= "0000001001011000";
	myBarriers(3).ax <= "0000001100100000";
	myBarriers(3).bx <= "0000001101011100";
	myBarriers(3).ay <= "0000001010101000";
	myBarriers(3).by <= "0000001010110010";
	myBarriers(4).ax <= "0000010000010000";
	myBarriers(4).bx <= "0000010010001000";
	myBarriers(4).ay <= "0000001010101000";
	myBarriers(4).by <= "0000001010110010";
	myBarriers(5).ax <= "0000001000110000";
	myBarriers(5).bx <= "0000001011100100";
	myBarriers(5).ay <= "0000001100000010";
	myBarriers(5).by <= "0000001100001100";
	myBarriers(6).ax <= "0000001110011000";
	myBarriers(6).bx <= "0000001111010100";
	myBarriers(6).ay <= "0000001100000010";
	myBarriers(6).by <= "0000001100001100";
	myBarriers(7).ax <= "0000001100000010";
	myBarriers(7).bx <= "0000001101111010";
	myBarriers(7).ay <= "0000001101011100";
	myBarriers(7).by <= "0000001101100110";
	myBarriers(8).ax <= "0000010001001100";
	myBarriers(8).bx <= "0000010011000100";
	myBarriers(8).ay <= "0000001101011100";
	myBarriers(8).by <= "0000001101100110";
	myBarriers(9).ax <= "0000001110011000";
	myBarriers(9).bx <= "0000010000010000";
	myBarriers(9).ay <= "0000001110110110";
	myBarriers(9).by <= "0000001111000000";

	
--		addrInt <= (cur_y - player_y) * 20 + (cur_x - player_x) + 2;
--	addr <= conv_std_logic_vector(addrInt, 9);
	
	u1 : wall port map(address => addr, clock => clk, q => rgba);
	process(pix_x, pix_y)
	begin
		barrier_idx <= check_barrier(pix_x, pix_y);

		if(barrier_idx >= 11) then
			pixel_out.valid <= false;
		else
			wallx <= conv_integer(myBarriers(barrier_idx).ax);
			wally <= conv_integer(myBarriers(barrier_idx).ay);
			realx <= pix_x - wallx - ((pix_x - wallx) mod 20) * 20;
			addrInt <= (pix_y - wally) * 20 + realx + 2;
			addr <= conv_std_logic_vector(addrInt, 8);
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
