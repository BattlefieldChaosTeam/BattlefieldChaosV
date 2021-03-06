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
        game_state: in GAMESTATE;
        which_player: in integer range 0 to 1; -- 指定玩家的主视角
        res_r, res_g, res_b: out std_logic_vector(2 downto 0); -- 返回的rgb值
        clk_25M: in std_logic -- 25M时钟
    );
end entity;

architecture bhv of Renderer is
    constant len_of_bullet: std_logic_vector(3 downto 0) := "1010";

    signal game_x, game_y: std_logic_vector(15 downto 0); -- 全局坐标
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
    signal game_state_pixel: Pixel; -- 游戏开始、结束像素

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

    component BulletPic is
        port(
            pix_x: in integer range 0 to 2559;
            pix_y: in integer range 0 to 1919; -- pix_x, pix_y为请求的像素
            bullet_in : in BULLETS;
            pixel_out: out Pixel; -- 输出像素
            clk : in std_logic --25M的时钟
        );
    end component;

    component wallPic is
        port(
            pix_x: in integer range 0 to 2559;
            pix_y: in integer range 0 to 1919;
            barrier_array: in BARRIERS;
            pixel_out: out Pixel;
            clk: in std_logic
        );
    end component;

    component logoPic is
        port(
            pix_x, pix_y : in integer range 0 to 1000;
            state: in std_logic_vector(2 downto 0);
            ply_num : in integer range 0 to 1; --玩家编号，0为A，1为B
            pixel_out: out Pixel;
            clk : in std_logic
        );
    end component;

    begin
        process(clk_25M, player_array)
        variable center_x, center_y: std_logic_vector(15 downto 0); -- 当前视野的中心坐标
        begin
            if rising_edge(clk_25M) then
                if player_array(which_player).x < HALF_SCREEN_WID then
                    center_x := HALF_SCREEN_WID;
                elsif player_array(which_player).x > (GAME_WID - HALF_SCREEN_WID) then
                    center_x := (GAME_WID - HALF_SCREEN_WID);
                else
                    center_x := player_array(which_player).x;
                end if;

                if player_array(which_player).y < HALF_SCREEN_HEI then
                    center_y := HALF_SCREEN_HEI;
                elsif player_array(which_player).y > GAME_HEI - HALF_SCREEN_HEI then
                    center_y := GAME_HEI - HALF_SCREEN_HEI;
                else
                    center_y := player_array(which_player).y;
                end if;

                game_x <= std_logic_vector(to_unsigned(req_x, 16)) + center_x - HALF_SCREEN_WID;
                game_y <= std_logic_vector(to_unsigned(req_y, 16)) + center_y - HALF_SCREEN_HEI;
            end if;
        end process;


        process(clk_25M, heart_pixel, player_pixel, bullet_pixel, barrier_pixel)
        begin
            if rising_edge(clk_25M) then
                if game_state_pixel.valid then
                    res_r <= game_state_pixel.r;
                    res_g <= game_state_pixel.g;
                    res_b <= game_state_pixel.b;
                elsif heart_pixel.valid then
                    res_r <= heart_pixel.r;
                    res_g <= heart_pixel.g;
                    res_b <= heart_pixel.b;
                elsif player_pixel.valid then
                    res_r <= player_pixel.r;
                    res_g <= player_pixel.g;
                    res_b <= player_pixel.b;
                elsif bullet_pixel.valid then
                    res_r <= bullet_pixel.r;
                    res_g <= bullet_pixel.g;
                    res_b <= bullet_pixel.b;
                elsif barrier_pixel.valid then
                    res_r <= barrier_pixel.r;
                    res_g <= barrier_pixel.g;
                    res_b <= barrier_pixel.b;
                else
                    res_r <= "000";
                    res_g <= "011";
                    res_b <= "101";
                end if;
            end if;
        end process;

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

        process(clk_25M, player_array)
        begin
            if player_array(0).xs.dir = '0' then
                player_one_pixel <= left_player_one_pix;
            else
                player_one_pixel <= right_player_one_pix;
            end if;
            
            if player_array(1).xs.dir = '0' then
                player_two_pixel <= left_player_two_pix;
            else
                player_two_pixel <= right_player_two_pix;
            end if;

            if player_one_pixel.valid then
                player_pixel <= player_one_pixel;
            else
                player_pixel <= player_two_pixel;
            end if;
        end process;

        my_heart_pic: HeartPic port map(
            ply1_life => player_array(0).life,
            ply2_life => player_array(1).life,
            pic_x => req_x,
            pic_y => req_y,
            pixel_out => heart_pixel,
            clk => clk_25M
        );

        my_bullet_pic: BulletPic port map(
            pix_x => to_integer(unsigned(game_x)),
            pix_y => to_integer(unsigned(game_y)),
            bullet_in => bullet_array,
            pixel_out => bullet_pixel,
            clk => clk_25M
        );

        my_wall_pic: wallPic port map(
            pix_x => to_integer(unsigned(game_x)),
            pix_y => to_integer(unsigned(game_y)),
            barrier_array => barrier_array,
            pixel_out => barrier_pixel,
            clk => clk_25M
        );

        my_logo_pic: logoPic port map(
            pix_x => req_x,
            pix_y => req_y,
            state => game_state.s,
            ply_num => which_player,
            clk => clk_25M,
            pixel_out => game_state_pixel
        );
    end architecture;