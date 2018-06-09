-- Read from rom and return rgb value to render
-- logo : 320 * 51
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use work.types.all;

entity logoPic is
	port(
		pix_x, pix_y : in integer range 0 to 1000;
		state: in std_logic_vector(2 downto 0);
		ply_num : in integer range 0 to 1; --玩家编号，0为A，1为B
		pixel_out: out Pixel;
		clk : in std_logic
	);
end entity logoPic;

architecture bhv_logoPic of logoPic is

	component logo IS
	PORT
		(
			address		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			clock		: IN STD_LOGIC  := '1';
			q		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
		);
	END component logo;

signal addrLogo : std_logic_vector(15 downto 0) := (others => '0');
signal rgbaLogo : std_logic_vector(9 downto 0);
signal addrLogoInt : integer range 0 to 70000 := 0;

begin
	u1 : logo port map(address => addrLogo, clock => clk, q => rgbaLogo);


	addrLogoInt <= (pix_y - 150) * 280 + (pix_x - 180) when (180 <= pix_x and pix_x < 460 and 150 <= pix_y and pix_y < 190) else
						(pix_y - 230) * 280 + (pix_x - 180) + 280 * 40 when (180 <= pix_x and pix_x < 460 and 230 <= pix_y and pix_y < 270 and (state = "000" or (state = "001" and ply_num = 0) or (state = "010" and ply_num = 1))) else
						(pix_y - 230) * 280 + (pix_x - 180) + 280 * 40 * 2 when (180 <= pix_x and pix_x < 460 and 230 <= pix_y and pix_y < 270 and ((state = "001" and ply_num = 1) or (state = "010" and ply_num = 0))) else
						(pix_y - 230) * 280 + (pix_x - 180) + 280 * 40 * 3 when (180 <= pix_x and pix_x < 460 and 230 <= pix_y and pix_y < 270 and state = "101" and ply_num = 0) else
						(pix_y - 230) * 280 + (pix_x - 180) + 280 * 40 * 4 when (180 <= pix_x and pix_x < 460 and 230 <= pix_y and pix_y < 270 and state = "110" and ply_num = 0) else
						(pix_y - 230) * 280 + (pix_x - 180) + 280 * 40 * 3 when (180 <= pix_x and pix_x < 460 and 230 <= pix_y and pix_y < 270 and state = "110" and ply_num = 1) else
						(pix_y - 230) * 280 + (pix_x - 180) + 280 * 40 * 4 when (180 <= pix_x and pix_x < 460 and 230 <= pix_y and pix_y < 270 and state = "101" and ply_num = 1) else
					   70000;
	addrLogo <= conv_std_logic_vector(addrLogoInt, 16);
	
	pixel_out.r(2) <= rgbaLogo(9); pixel_out.r(1) <= rgbaLogo(8); pixel_out.r(0) <= rgbaLogo(7);
	pixel_out.g(2) <= rgbaLogo(6); pixel_out.g(1) <= rgbaLogo(5); pixel_out.g(0) <= rgbaLogo(4);
	pixel_out.b(2) <= rgbaLogo(3); pixel_out.b(1) <= rgbaLogo(2); pixel_out.b(0) <= rgbaLogo(1);
	pixel_out.valid <= false when (rgbaLogo(0) = '0' or addrLogoInt = 70000 or state = "100")
									 else true;

end architecture;