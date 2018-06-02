library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.types.all;

entity speedmod is
	port(
		rst, clk : in std_logic;
		p : PLAYER;
		is_hit, dir_hit : in std_logic;
		l, r, u, d, t : in std_logic;
		key_signal : in std_logic_vector(4 downto 0);-- 分别指示上下左右 0 W 1 S 2 A 3 D, 4 开火
		xs , ys : buffer SPDSET);
end entity;

architecture speedmod_beh of speedmod is
	
	constant jsp: std_logic_vector(15 downto 0) := "0000000000010010";
	constant dsp: std_logic_vector(15 downto 0) := "0000000000000010";
	constant jac: std_logic_vector(15 downto 0) := "0000000000000001";
	constant dac: std_logic_vector(15 downto 0) := "0000000000000001";
	constant mlst: std_logic_vector(15 downto 0) := "0000000000100000";
	constant glst: std_logic_vector(15 downto 0) := "0000000000000011";
	constant tlst: std_logic_vector(15 downto 0) := "0000000000000001";
	constant mxspd: std_logic_vector(15 downto 0) := "0000000000000100";
	
	constant conspd : std_logic_vector(15 downto 0) := "0000000000000100";
	constant conacc : std_logic_vector(15 downto 0) := "0000000000100000";
	
	constant wlkspd : std_logic_vector(15 downto 0) := "0000000000000001";
	constant wlkacc : std_logic_vector(15 downto 0) := "0000000000000001";
	
	constant zerospd: std_logic_vector(15 downto 0) := "0000000000000000";
	
begin
	
	-- x speed
	
	process(rst, clk)
	variable cnt : integer := 50;
	begin
	
		if(rst = '1') then
		
			xs <= p.xs;
			ys <= p.ys;
			cnt := 0;
			
		elsif (rising_edge(clk)) then
			
			if(cnt < 50) then
				cnt := cnt + 1;
			end if;
			
			-- X PART
			
			if(is_hit = '1') then -- hit : forced move
			
				xs.spd <= conspd;
				xs.dir <= not dir_hit;
				xs.lst <= conacc;
			
			else -- not hit : free move
				
				case cnt is
				
					when 1 => -- lst : imba
						
						if(p.xs.lst > 0) then
							xs.spd <= conspd;
							xs.lst <= p.xs.lst - "1";
							xs.dir <= p.xs.dir;
						else
							if(key_signal(2) = '1') then -- move left
								xs.spd <= wlkspd;
								xs.dir <= '0';
								xs.lst <= wlkacc;
							elsif(key_signal(3) = '1') then -- move right
								xs.spd <= wlkspd;
								xs.dir <= '1';
								xs.lst <= wlkacc;
							else
								xs.spd <= zerospd;
								xs.lst <= zerospd;
							end if;
							
						end if;
						
					
					when 7 => -- key : dir may change
						
						
					
					when 15 => -- wall : block
						
					
					when others =>
						
						if(cnt > 50) then cnt := 49; end if;
						
					end case;
					
				end if;
				
			
			-- Y PART
			
			case cnt is
				
				when 1 => -- all condition
					
					if(t = '1') then 
						
						ys <= p.ys;
						
					else 
					
						if(p.ys.dir = '0') then -- up
							
							if(p.ys.lst > 0) then -- keep speed
								
								ys.spd <= p.ys.spd; ys.dir <= '0'; ys.acc <= jac; 
								if(p.ys.lst > tlst) then ys.lst <= p.ys.lst - tlst; else ys.lst <= zerospd; ys.lst2 <= glst; end if;
								
							elsif(p.ys.spd > 0) then -- slow down
								
								if(p.ys.lst2 > tlst) then
									ys.lst2 <= p.ys.lst2 - tlst;
									ys.spd <= p.ys.spd;
								else
									if(p.ys.spd >= jac) then ys.spd <= p.ys.spd - jac; else ys.spd <= zerospd; end if;
									ys.lst2 <= glst;
								end if;
								
								ys.dir <= '0'; ys.acc <= jac;
							
							else -- top at sky
								
								ys.spd <= zerospd; ys.dir <= '1'; ys.acc <= dac; 
								
							end if;
								
						else -- down
							
							if(d = '1') then
								
								if(key_signal(0) = '1') then -- up
									ys.spd <= jsp; ys.dir <= '0'; ys.acc <= jac; ys.lst <= mlst;
								elsif(key_signal(1) = '1') then -- down
									ys.spd <= dsp; ys.dir <= '1'; ys.acc <= dac; 
								else -- hold
									ys.spd <= zerospd; ys.dir <= '1'; ys.acc <= dac;
								end if;
							
							else -- free drop
								
								if(p.ys.spd >= mxspd) then ys.spd <= mxspd; 
								else 
									if(p.ys.lst > tlst) then
										ys.lst <= p.ys.lst - tlst;
										ys.spd <= p.ys.spd;
									else
										ys.spd <= p.ys.spd + dac; 
										ys.lst <= glst;
									end if;
								end if;
								ys.dir <= '1'; ys.acc <= dac;
							
							end if;
							
						end if;
					
					end if;
			
				when others=>
					
			end case;
				
			end if;
	
	end process;
	
end architecture speedmod_beh;

