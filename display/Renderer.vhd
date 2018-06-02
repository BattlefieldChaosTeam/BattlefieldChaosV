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
        res_r, res_g, res_b: out std_logic_vector(2 downto 0); -- 返回的rgb值
        clk_25M: in std_logic -- 25M时钟
    );
end entity;

architecture bhv of Renderer is
    constant len_of_bullet: std_logic_vector(3 downto 0) := "1010";

    signal game_x, game_y: std_logic_vector(15 downto 0); -- 全局坐标
    signal center_x, center_y: std_logic_vector(15 downto 0); -- 当前视野的中心坐标
    constant SCREEN_HEI: std_logic_vector(15 downto 0) := "0000000111100000"; -- 480
    constant SCREEN_WID: std_logic_vector(15 downto 0) := "0000001010000000"; -- 640
    constant HALF_SCREEN_WID: std_logic_vector(15 downto 0) := "0000000101000000";
    constant HALF_SCREEN_HEI: std_logic_vector(15 downto 0) := "0000000011110000";
    constant GAME_WID: std_logic_vector(15 downto 0) := "0000101000000000"; -- 2560
    constant GAME_HEI: std_logic_vector(15 downto 0) := "0000011110000000"; -- 1920
    signal player_pixel: Pixel; -- 选手像素
    signal player_one_pixel: Pixel;
    signal player_two_pixel: Pixel;
    signal barrier_pixel: Pixel; -- 障碍物像素
    signal bullet_pixel: Pixel; -- 子弹像素

    function check_for_barrier(
        x: std_logic_vector(15 downto 0);
        y: std_logic_vector(15 downto 0)
    )
    return boolean is
    begin
        check_loop: for i in 0 to barrier_array'length - 1 loop
            if x >= barrier_array(i).ax and x < barrier_array(i).bx and y >= barrier_array(i).ay and y < barrier_array(i).by then
                return true;
            end if;
        end loop;
        return false;
    end function;

    component LeftPlayerPic is
        port(
            player_x, pix_x: in integer range 0 to 2559;
            player_y, pix_y: in integer range 0 to 1919;
            player_num : std_logic; --玩家编号
            pixel_out: out Pixel; -- 输出像素
            clk : in std_logic --25M的时钟
        );
    end component;

    signal left_player_one_pix: Pixel;
    signal left_player_two_pix: Pixel;

    component RightPlayerPic is
        port(
            player_x, pix_x: in integer range 0 to 2559;
            player_y, pix_y: in integer range 0 to 1919;
            player_num : in std_logic; --玩家编号
            pixel_out: out Pixel; -- 输出像素
            clk : in std_logic --25M的时钟
        );
    end component;

    signal right_player_one_pix: Pixel;
    signal right_player_two_pix: Pixel;

    component HeartPic is
        port(
            ply1_life, ply2_life: in std_logic_vector(3 downto 0);
            pic_x: in integer range 0 to 639; --传入的是640*480坐标系的坐标
            pic_y: in integer range 0 to 479;
            pixel_out: out Pixel;
            clk : in std_logic --25M的时钟
        );
    end component;

    signal heart_pixel: Pixel;
    
    type BulletPixels is array(0 to 20) of Pixel;
    signal my_bullet_pixels: BulletPixels;

    component BulletPic is
        port(
            bullet_x, pix_x: in integer range 0 to 2559;
            bullet_y, pix_y: in integer range 0 to 1919;
            bullet_dir : in std_logic; --0表示向左，1表示向右
            pixel_out: out Pixel; -- 输出像素
            clk : in std_logic --25M的时钟
        );
    end component;

    function check_for_bullet(
        my_bullet_pixels: BulletPixels
    )
    return Pixel is
    begin
        chek_loop: for i in 0 to bullet_array'length - 1 loop
            if my_bullet_pixels(i).valid then
                return my_bullet_pixels(i);
            end if;
        end loop;
        return my_bullet_pixels(0);
    end function;

    begin
        center_x <= HALF_SCREEN_WID when player_array(which_player).x < HALF_SCREEN_WID else
                    (GAME_WID - HALF_SCREEN_WID) when player_array(which_player).x > (GAME_WID - HALF_SCREEN_WID) else
                    player_array(which_player).x;
        center_y <= HALF_SCREEN_HEI when player_array(which_player).y < HALF_SCREEN_HEI else
                    GAME_HEI - HALF_SCREEN_HEI when player_array(which_player).y > GAME_HEI - HALF_SCREEN_HEI else
                    player_array(which_player).y;
        game_x <= std_logic_vector(to_unsigned(req_x, 16)) + center_x - HALF_SCREEN_WID;
        game_y <= std_logic_vector(to_unsigned(req_y, 16)) + center_y - HALF_SCREEN_HEI;
        res_r <= heart_pixel.r when heart_pixel.valid else
                 player_pixel.r when player_pixel.valid else
                 bullet_pixel.r when bullet_pixel.valid else
                 barrier_pixel.r when barrier_pixel.valid else
                 "000";
        res_g <= heart_pixel.g when heart_pixel.valid else
                 player_pixel.g when player_pixel.valid else
                 bullet_pixel.g when bullet_pixel.valid else
                 barrier_pixel.g when barrier_pixel.valid else
                 "000";
        res_b <= heart_pixel.b when heart_pixel.valid else
                 player_pixel.b when player_pixel.valid else
                 bullet_pixel.b when bullet_pixel.valid else
                 barrier_pixel.b when barrier_pixel.valid else
                 "000";

        my_left_player_one: LeftPlayerPic port map(
            player_x => to_integer(unsigned(player_array(0).x)),
            player_y => to_integer(unsigned(player_array(0).y)),
            pix_x => to_integer(unsigned(game_x)),
            pix_y => to_integer(unsigned(game_y)),
            player_num => '0',
            pixel_out => left_player_one_pix,
            clk => clk_25M
        );

        my_left_player_two: LeftPlayerPic port map(
            player_x => to_integer(unsigned(player_array(1).x)),
            player_y => to_integer(unsigned(player_array(1).y)),
            pix_x => to_integer(unsigned(game_x)),
            pix_y => to_integer(unsigned(game_y)),
            player_num => '1',
            pixel_out => left_player_two_pix,
            clk => clk_25M
        );

        my_right_player_one: RightPlayerPic port map(
            player_x => to_integer(unsigned(player_array(0).x)),
            player_y => to_integer(unsigned(player_array(0).y)),
            pix_x => to_integer(unsigned(game_x)),
            pix_y => to_integer(unsigned(game_y)),
            player_num => '0',
            pixel_out => right_player_one_pix,
            clk => clk_25M
        );

        my_right_player_two: RightPlayerPic port map(
            player_x => to_integer(unsigned(player_array(1).x)),
            player_y => to_integer(unsigned(player_array(1).y)),
            pix_x => to_integer(unsigned(game_x)),
            pix_y => to_integer(unsigned(game_y)),
            player_num => '1',
            pixel_out => right_player_two_pix,
            clk => clk_25M
        );

        player_one_pixel <= left_player_one_pix when player_array(0).xs.dir = '0' else
                            right_player_one_pix;
        player_two_pixel <= left_player_two_pix when player_array(1).xs.dir = '0' else
                            right_player_two_pix;
        player_pixel <= player_one_pixel when  player_one_pixel.valid else
                        player_two_pixel;

        my_heart_pic: HeartPic port map(
            ply1_life => player_array(0).life,
            ply2_life => player_array(1).life,
            pic_x => req_x,
            pic_y => req_y,
            pixel_out => heart_pixel,
            clk => clk_25M
        );

        g_my_bullet_pics: for i in 0 to 20 generate
            my_bullet_pic: BulletPic port map(
                bullet_x => to_integer(unsigned(bullet_array(i).x)),
                bullet_y => to_integer(unsigned(bullet_array(i).y)),
                pix_x => to_integer(unsigned(game_x)),
                pix_y => to_integer(unsigned(game_y)),
                bullet_dir => bullet_array(i).dir,
                pixel_out => my_bullet_pixels(i),
                clk => clk_25M
            );
        end generate;

        process(game_x, game_y, bullet_array)
        begin
            bullet_pixel <= check_for_bullet(my_bullet_pixels);
        end process;

        process(game_x, game_y, barrier_array)
        begin
            if check_for_barrier(game_x, game_y) then
                barrier_pixel <= (r => "111", g => "111", b => "111", valid => true);
            else
                barrier_pixel <= (r => "000", g => "000", b => "000", valid => false);
            end if;
        end process;
    end architecture;