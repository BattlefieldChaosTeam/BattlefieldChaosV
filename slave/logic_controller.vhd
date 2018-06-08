-- Give bullet and player information to vga output
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.types.all;

entity logic_controller is
	port(
		barriers:out BARRIERS
	);
end entity logic_controller;

architecture logic_controller_bhv of logic_controller is
begin

	barriers(0).ax <= "0000000111110100";
	barriers(0).bx <= "0000001001101100";
	barriers(0).ay <= "0000000111110100";
	barriers(0).by <= "0000000111111110";
	barriers(1).ax <= "0000001101011100";
	barriers(1).bx <= "0000001111010100";
	barriers(1).ay <= "0000000111110100";
	barriers(1).by <= "0000000111111110";
	barriers(2).ax <= "0000001010101000";
	barriers(2).bx <= "0000001100100000";
	barriers(2).ay <= "0000001001001110";
	barriers(2).by <= "0000001001011000";
	barriers(3).ax <= "0000001100100000";
	barriers(3).bx <= "0000001101011100";
	barriers(3).ay <= "0000001010101000";
	barriers(3).by <= "0000001010110010";
	barriers(4).ax <= "0000010000010000";
	barriers(4).bx <= "0000010010001000";
	barriers(4).ay <= "0000001010101000";
	barriers(4).by <= "0000001010110010";
	barriers(5).ax <= "0000001000110000";
	barriers(5).bx <= "0000001011100100";
	barriers(5).ay <= "0000001100000010";
	barriers(5).by <= "0000001100001100";
	barriers(6).ax <= "0000001110011000";
	barriers(6).bx <= "0000001111010100";
	barriers(6).ay <= "0000001100000010";
	barriers(6).by <= "0000001100001100";
	barriers(7).ax <= "0000001100000010";
	barriers(7).bx <= "0000001101111010";
	barriers(7).ay <= "0000001101011100";
	barriers(7).by <= "0000001101100110";
	barriers(8).ax <= "0000010001001100";
	barriers(8).bx <= "0000010011000100";
	barriers(8).ay <= "0000001101011100";
	barriers(8).by <= "0000001101100110";
	barriers(9).ax <= "0000001110011000";
	barriers(9).bx <= "0000010000010000";
	barriers(9).ay <= "0000001110110110";
	barriers(9).by <= "0000001111000000";

end logic_controller_bhv; 
