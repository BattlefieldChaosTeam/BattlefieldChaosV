library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.types.all;
		
entity statePic is
	port(
		pix_x: in integer range 0 to 639;
		pix_y: in integer range 0 to 439;
		player_num: in std_logic; --0鐜╁A,1鐜╁B
		state: in std_logic_vector(2 downto 0);
		clk: in std_logic;
		pixel_out: out Pixel
	);
end entity statePic;

architecture statePic_bhv of statePic is

	component logo IS
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
			clock		: IN STD_LOGIC  := '1';
			q		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
		);
	END component logo;
	
	component win IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
	);
	END component win;

	component lose IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
	);
	END component lose;

	component holdon IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
	);
	END component holdon;
	
	component ensure IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
	);
	END component ensure;
	
	
	
signal addrLogo : std_logic_vector(13 downto 0) := (others => '0');
signal addrWin : std_logic_vector(13 downto 0) := (others => '0');
signal addrLose : std_logic_vector(13 downto 0) := (others => '0');
signal addrHold : std_logic_vector(13 downto 0) := (others => '0');
signal addrEnsure : std_logic_vector(13 downto 0) := (others => '0');

signal addrLogoInt : integer range 0 to 20000 := 0;
signal addrWinInt : integer range 0 to 20000 := 0;
signal addrLoseInt : integer range 0 to 20000 := 0;
signal addrHoldInt : integer range 0 to 20000 := 0; --绛夊緟瀵规柟寮€濮?
signal addrEnsureInt : integer range 0 to 20000 := 0; --鎸夐敭纭寮€濮?

signal rgbaLogo : std_logic_vector(9 downto 0);
signal rgbaWin : std_logic_vector(9 downto 0);
signal rgbaLose : std_logic_vector(9 downto 0);
signal rgbaHold : std_logic_vector(9 downto 0);
signal rgbaEnsure : std_logic_vector(9 downto 0);

constant logo_x : integer := 160;
constant logo_y : integer := 150;
constant char_x : integer := 160;
constant char_y : integer := 300;

begin 
	u1 : logo port map(address => addrLogo, clock => clk, q => rgbaLogo);
	u2 : logo port map(address => addrWin, clock => clk, q => rgbaWin);
	u3 : logo port map(address => addrLose, clock => clk, q => rgbaLose);
	u4 : logo port map(address => addrHold, clock => clk, q => rgbaHold);
	u5 : logo port map(address => addrEnsure, clock => clk, q => rgbaEnsure);
	
	process(pix_x, pix_y, clk, state)
	begin
		addrLogoInt <= (pix_y - logo_y) * 320 + (pix_x - logo_x);
		addrWinInt <= (pix_y - char_y) * 320 + (pix_x - char_x);
		addrLoseInt <= addrWinInt;
		addrHoldInt <= addrWinInt;
		addrEnsureInt <= addrWinInt;

		if(160 <= pix_x and pix_x < 480 and 150 <= pix_y and pix_y < 201) then
			pixel_out.r(2) <= '1'; pixel_out.r(1) <= '1'; pixel_out.r(0) <= '1';
			pixel_out.g(2) <= '0'; pixel_out.g(1) <= '0'; pixel_out.g(0) <= '0';
			pixel_out.b(2) <= '0'; pixel_out.b(1) <= '0'; pixel_out.b(0) <= '0';
			
			pixel_out.r(2) <= rgbaLogo(9); pixel_out.r(1) <= rgbaLogo(8); pixel_out.r(0) <= rgbaLogo(7);
			pixel_out.g(2) <= rgbaLogo(6); pixel_out.g(1) <= rgbaLogo(5); pixel_out.g(0) <= rgbaLogo(4);
			pixel_out.b(2) <= rgbaLogo(3); pixel_out.b(1) <= rgbaLogo(2); pixel_out.b(0) <= rgbaLogo(1);
			if rgbaLogo(0) = '0' then
				pixel_out.valid <= false;
			else
				pixel_out.valid <= true;
			end if;
		elsif(160 <= pix_x and pix_x < 480 and 300 <= pix_y and pix_y < 351) then
			if (state = "000" or (state = "001" and player_num = '0') or (state = "010" and player_num = '1')) then
				pixel_out.r(2) <= rgbaEnsure(9); pixel_out.r(1) <= rgbaEnsure(8); pixel_out.r(0) <= rgbaEnsure(7);
				pixel_out.g(2) <= rgbaEnsure(6); pixel_out.g(1) <= rgbaEnsure(5); pixel_out.g(0) <= rgbaEnsure(4);
				pixel_out.b(2) <= rgbaEnsure(3); pixel_out.b(1) <= rgbaEnsure(2); pixel_out.b(0) <= rgbaEnsure(1);
				if rgbaEnsure(0) = '0' then
					pixel_out.valid <= false;
				else
					pixel_out.valid <= true;
				end if;
			elsif (state = "001" and player_num = '1') or (state = "010" and player_num = '0') then --绛夊緟瀵规墜
				pixel_out.r(2) <= rgbaHold(9); pixel_out.r(1) <= rgbaHold(8); pixel_out.r(0) <= rgbaHold(7);
				pixel_out.g(2) <= rgbaHold(6); pixel_out.g(1) <= rgbaHold(5); pixel_out.g(0) <= rgbaHold(4);
				pixel_out.b(2) <= rgbaHold(3); pixel_out.b(1) <= rgbaHold(2); pixel_out.b(0) <= rgbaHold(1);
				if rgbaHold(0) = '0' then
					pixel_out.valid <= false;
				else
					pixel_out.valid <= true;
				end if;
			elsif (state = "101") then
				pixel_out.r(2) <= rgbaWin(9); pixel_out.r(1) <= rgbaWin(8); pixel_out.r(0) <= rgbaWin(7);
				pixel_out.g(2) <= rgbaWin(6); pixel_out.g(1) <= rgbaWin(5); pixel_out.g(0) <= rgbaWin(4);
				pixel_out.b(2) <= rgbaWin(3); pixel_out.b(1) <= rgbaWin(2); pixel_out.b(0) <= rgbaWin(1);
				if rgbaWin(0) = '0' then
					pixel_out.valid <= false;
				else
					pixel_out.valid <= true;
				end if;
			elsif (state = "110") then
				pixel_out.r(2) <= rgbaLose(9); pixel_out.r(1) <= rgbaLose(8); pixel_out.r(0) <= rgbaLose(7);
				pixel_out.g(2) <= rgbaLose(6); pixel_out.g(1) <= rgbaLose(5); pixel_out.g(0) <= rgbaLose(4);
				pixel_out.b(2) <= rgbaLose(3); pixel_out.b(1) <= rgbaLose(2); pixel_out.b(0) <= rgbaLose(1);
				if rgbaLose(0) = '0' then
					pixel_out.valid <= false;
				else
					pixel_out.valid <= true;
				end if;
			end if;
		else pixel_out.valid <= false;
		end if;
	end process;
end architecture;
