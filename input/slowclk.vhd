library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.types.all;

entity slowclk is
	port(
	clk: in std_logic;
	key_in : in std_logic_vector(4 downto 0);
	key_out:out std_logic_vector(4 downto 0)
	);
end entity slowclk;

architecture slowclk_beh of slowclk is
signal key: std_logic_vector(4 downto 0);
begin

	key_out <= key;
	
	process(clk)
		variable cnt: integer := 0;
	begin
		if(rising_edge(clk)) then
			if(cnt = 10000000) then
				key <= key_in;
				cnt := 0;
			elsif(cnt = 125000) then
				key(4) <= '0';
				cnt := cnt + 1;
			else
				cnt := cnt + 1;
			end if;
		end if;
	end process;
	
end architecture slowclk_beh;
