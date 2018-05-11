library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

entity battlev is
    port(
        sys_clk: in std_logic;
		my_clk: in std_logic;
        reset: in std_logic;
        ps2_data: in std_logic;
        ps2_clk: in std_logic;
		--t_x: out std_logic_vector(10 downto 0) := "00000000000";
		--t_y: out std_logic_vector(10 downto 0) := "00000000000";
		keyt : buffer std_logic_vector(4 downto 0);
		a_x, a_y : in integer;
		b_x, b_y : buffer integer;
		--cx_0, cx_1, cx_2 : out integer;
		  
		-- type myVec is array(2 downto 0) of std_logic_vector(6 downto 0);
		outx0: out std_logic_vector(6 downto 0);
		outx1: out std_logic_vector(6 downto 0);
		outx2: out std_logic_vector(6 downto 0);
		outy0: out std_logic_vector(6 downto 0);
		outy1: out std_logic_vector(6 downto 0);
		outy2: out std_logic_vector(6 downto 0)
    );
	 
	 function encode_number(x : in std_logic_vector) return std_logic_vector is
	 begin
		case x is
			when "0000" => return "1111110";
			when "0001" => return "1100000";
			when "0010" => return "1011101";
			when "0011" => return "1100001";
			when "0100" => return "1100011";
			when "0101" => return "0111011";
			when "0110" => return "0110111";
			when "0111" => return "1101000";
			when "1000" => return "1111111";
			when "1001" => return "1101011";
			when others => return "0000000";
		end case;
	 end function encode_number;
	 
end entity;

architecture bhv of battlev is
	
	component Input_Module is
		 port(
			  sys_clk: in std_logic;
			  reset: in std_logic;
			  ps2_data: in std_logic;
			  ps2_clk: in std_logic;
			  player_one: out std_logic_vector(4 downto 0);-- 分别指示上下左右 0 W 1 S 2 A 3 D, 4 开火
			  player_two: out std_logic_vector(4 downto 0);-- 同上
			  enter: out std_logic
		 );
	end component Input_Module;
	
	component p_move is
		 port(
			  key_signal : in std_logic_vector(4 downto 0);-- 分别指示上下左右 0 W 1 S 2 A 3 D, 4 开火
			  q_x, q_y : buffer integer;
			  clk, rst : in std_logic;
			  p_x, p_y : in integer
		 );
	end component p_move;
	
	signal keyout : std_logic_vector(4 downto 0);
	
		--signal a_x : std_logic_vector(10 downto 0) := "00000000000";
		--signal a_y : std_logic_vector(10 downto 0) := "00000000000";
		--signal b_x, b_y : std_logic_vector(10 downto 0);
	
	signal cx0, cx1, cx2 : integer; 
	
	begin

		Input_pp : Input_Module port map(sys_clk, reset, ps2_data, ps2_clk, keyout);
		keyt <= "00100";
		Peo_move : p_move port map(keyout, b_x, b_y, my_clk, reset, 100, 100);
		
		-- t_x <= a_x;
		-- t_y <= a_y;
		
		--process(b_x, b_y)
		--begin
			--a_x <= b_x;
			--a_y <= b_y;
		--end process;
		
		cx0 <= b_x - b_x / 10 * 10;
		cx1 <= b_x / 10 - b_x / 100 * 10;
		cx2 <= b_x / 100 - b_x / 1000 * 100;
		
		--cx_0 <= cx0;
		--cx_1 <= cx1;
		--cx_2 <= cx2;
		
		--keyt <= keyout;
		
		outx0 <= encode_number(conv_std_logic_vector(cx0, 4));
		outx1 <= encode_number(conv_std_logic_vector(cx1, 4));
		outx2 <= encode_number(conv_std_logic_vector(cx2, 4));
		
	end;