library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

entity p_move is
    port(
        key_signal : in std_logic_vector(4 downto 0);-- 分别指示上下左右 0 W 1 S 2 A 3 D, 4 开火
		  q_x, q_y : buffer integer;
		  clk, rst : in std_logic;
		  p_x, p_y : in integer
    );
end entity;

architecture bhv of p_move is
	
	signal t_x, t_y : integer;

	begin
	
		process(rst, clk)

		begin
		
			if(rst = '0') then
				t_x <= p_x;
				t_y <= p_y;
			
			elsif(rising_edge(clk)) then
		
				if(key_signal(0)='1') then 
					t_y <= q_y - 1;
				elsif(key_signal(1)='1') then
				   t_y <= q_y + 1;
				end if;
				
				if(key_signal(2)='1') then
					t_x <= q_x - 1;
				elsif (key_signal(3)='1') then
					t_x <= q_x + 1;
				end if;
					
			end if;
				
		end process;
		
		q_x <= t_x;
		q_y <= t_y;
		
	end;