library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.types.all;

entity Renderer is
    port(
        req_x: in integer range 0 to 639; -- VGA请求像素的坐标
        req_y: in integer range 0 to 479;
        bullet_array: in BULLETS;
        player_array: in PLAYERS;
        barrier_array: in BARRIERS;
        which_player: in integer range 0 to 1; -- 指定玩家的主视角
        res_r, res_g, res_b: out std_logic_vector(2 downto 0) -- 返回的rgb值
    );
end entity;

architecture bhv of Renderer is
    type Pixel is record
        r: std_logic_vector(2 downto 0);
        g: std_logic_vector(2 downto 0);
        b: std_logic_vector(2 downto 0);
        valid: boolean; -- 指示该像素是否有效
    end record;

    constant PLAYER_ONE_PIXEL: Pixel := (r => "111", g => "000", b => "000", valid => true);
    constant PLAYER_TWO_PIXEL: Pixel := (r => "000", g => "000", b => "111", valid => true);
    constant false_pixel: Pixel := (r => "000", g => "000", b => "000", valid => false);
    constant len_of_player: std_logic_vector(5 downto 0) := "101000";

    signal game_x, game_y: std_logic_vector(15 downto 0); -- 全局坐标
    signal center_x, center_y: std_logic_vector(15 downto 0); -- 当前视野的中心坐标
    constant SCREEN_HEI: std_logic_vector(15 downto 0) := "0000000111100000"; -- 480
    constant SCREEN_WID: std_logic_vector(15 downto 0) := "0000001010000000"; -- 640
    constant HALF_SCREEN_WID: std_logic_vector(15 downto 0) := "0000000101000000";
    constant HALF_SCREEN_HEI: std_logic_vector(15 downto 0) := "0000000011110000";
    constant GAME_WID: std_logic_vector(15 downto 0) := "0000101000000000"; -- 2560
    constant GAME_HEI: std_logic_vector(15 downto 0) := "0000011110000000"; -- 1920
    signal player_pixel: Pixel; -- 选手像素
    signal barrier_pixel: Pixel; -- 障碍物像素
    signal bullet_pixel: Pixel; -- 子弹像素

    begin
        center_x <= HALF_SCREEN_WID when player_array(which_player).x < HALF_SCREEN_WID else
                    (GAME_WID - HALF_SCREEN_WID) when player_array(which_player).x > (GAME_WID - HALF_SCREEN_WID) else
                    player_array(which_player).x;
        center_y <= HALF_SCREEN_HEI when player_array(which_player).y < HALF_SCREEN_HEI else
                    GAME_HEI - HALF_SCREEN_HEI when player_array(which_player).y > GAME_HEI - HALF_SCREEN_HEI else
                    player_array(which_player).y;
        game_x <= std_logic_vector(to_unsigned(req_X, 16)) + center_x - HALF_SCREEN_WID;
        game_y <= std_logic_vector(to_unsigned(req_y, 16)) + center_y - HALF_SCREEN_HEI;
        res_r <= player_pixel.r when player_pixel.valid else
                 "000";
        res_g <= player_pixel.g when player_pixel.valid else
                 "000";
        res_b <= player_pixel.b when player_pixel.valid else
                 "000";


        process(game_x, game_y, player_array)
        begin
            if game_x >= player_array(0).x and game_x < player_array(0).x + len_of_player and game_y >= player_array(0).y and game_y < player_array(0).y + len_of_player then
                player_pixel <= PLAYER_ONE_PIXEL;
            elsif game_x >= player_array(1).x and game_x < player_array(1).x + len_of_player and game_y >= player_array(1).y and game_y < player_array(1).y + len_of_player then
                player_pixel <= PLAYER_TWO_PIXEL;
            else
                player_pixel <= (r => "000", g => "000", b => "000", valid => false);
            end if;
        end process;
    end architecture;