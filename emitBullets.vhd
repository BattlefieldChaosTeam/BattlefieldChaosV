-- Emit bullets
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.types.all;

entity emitBullets is
	port(
	emit1 : in std_logic; --player 1 emit bullet
	emit2 : in std_logic; --player 2 emit bullet
	lastBullets : in BULLETS;
	nextBullets : out BULLETS
	);
end entity emitBullets;


architecture bhv_emitBullets of emitBullets is 
begin

end architecture bhv_emitBullets