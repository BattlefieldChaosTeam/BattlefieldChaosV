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
	barriers(0).bx <= "0000001100100000";
	barriers(0).ay <= "0000000111110100";
	barriers(0).by <= "0000000111111110";
	barriers(1).ax <= "0000000111000010";
	barriers(1).bx <= "0000001000010010";
	barriers(1).ay <= "0000001001101100";
	barriers(1).by <= "0000001001110110";
	barriers(2).ax <= "0000001100010110";
	barriers(2).bx <= "0000001111101000";
	barriers(2).ay <= "0000001001100010";
	barriers(2).by <= "0000001001101100";
	barriers(3).ax <= "0000001001011000";
	barriers(3).bx <= "0000001100101010";
	barriers(3).ay <= "0000001010101000";
	barriers(3).by <= "0000001010110010";
	barriers(4).ax <= "0000010011100010";
	barriers(4).bx <= "0000010101000110";
	barriers(4).ay <= "0000001010000000";
	barriers(4).by <= "0000001010001010";
	barriers(5).ax <= "0000010001001100";
	barriers(5).bx <= "0000010011001110";
	barriers(5).ay <= "0000001011100100";
	barriers(5).by <= "0000001011101110";
	barriers(6).ax <= "0000001010101000";
	barriers(6).bx <= "0000001100100000";
	barriers(6).ay <= "0000001100001100";
	barriers(6).by <= "0000001100010110";
	barriers(7).ax <= "0000001100001100";
	barriers(7).bx <= "0000010001100000";
	barriers(7).ay <= "0000001101011100";
	barriers(7).by <= "0000001101100110";
	barriers(8).ax <= "0000000111110100";
	barriers(8).bx <= "0000001011100100";
	barriers(8).ay <= "0000001110011000";
	barriers(8).by <= "0000001110100010";
	barriers(9).ax <= "0000010001111110";
	barriers(9).bx <= "0000010110001100";
	barriers(9).ay <= "0000001110101100";
	barriers(9).by <= "0000001110110110";
	barriers(10).ax <= "0000000101011110";
	barriers(10).bx <= "0000000111100000";
	barriers(10).ay <= "0000010001001100";
	barriers(10).by <= "0000010001010110";
	barriers(11).ax <= "0000001011101110";
	barriers(11).bx <= "0000001110110110";
	barriers(11).ay <= "0000010000010000";
	barriers(11).by <= "0000010000011010";
	barriers(12).ax <= "0000010000011010";
	barriers(12).bx <= "0000010100011110";
	barriers(12).ay <= "0000010001001100";
	barriers(12).by <= "0000010001010110";
	barriers(13).ax <= "0000001001011000";
	barriers(13).bx <= "0000001101010010";
	barriers(13).ay <= "0000010010001000";
	barriers(13).by <= "0000010010010010";
	barriers(14).ax <= "0000001101111010";
	barriers(14).bx <= "0000010001001100";
	barriers(14).ay <= "0000010011000100";
	barriers(14).by <= "0000010011001110";
	barriers(15).ax <= "0000000111110100";
	barriers(15).bx <= "0000001001011000";
	barriers(15).ay <= "0000010100111100";
	barriers(15).by <= "0000010101000110";
	barriers(16).ax <= "0000001010111100";
	barriers(16).bx <= "0000001100100000";
	barriers(16).ay <= "0000010100101000";
	barriers(16).by <= "0000010100110010";
	barriers(17).ax <= "0000010010110000";
	barriers(17).bx <= "0000010100010100";
	barriers(17).ay <= "0000010100010100";
	barriers(17).by <= "0000010100011110";


end logic_controller_bhv; 
