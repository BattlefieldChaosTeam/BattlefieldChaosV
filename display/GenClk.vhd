library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.types.all;

entity genClk is
	port(
	M100clk : in std_logic;
	M25clk  :out std_logic
	);
end entity genClk;

architecture genClk_beh of genClk is
	signal clk_50M, clk_25M : std_logic;
begin
	M25clk <= clk_25M;
	process(M100clk)
	begin
		if rising_edge(M100clk) then clk_50M <= not clk_50M; end if;
	end process;

	process(clk_50M) -- 分频得到25M
	begin
		if rising_edge(clk_50M) then clk_25M <= not clk_25M; end if;
	end process;

end architecture genClk_beh;
