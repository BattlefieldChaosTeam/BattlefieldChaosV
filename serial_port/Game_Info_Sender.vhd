library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.types.all;

entity Game_Info_Sender is
    port(
        clk: in std_logic; -- 11M时钟
        player_array: in PLAYERS;
        bullet_array: in BULLETS;
        bullet_data: out std_logic;
        player_data: out std_logic;
        head_clk: in std_logic -- 这个信号为0时代表帧头
    );
end entity;

architecture bhv of Game_Info_Sender is
    signal cur_bullet: integer range 0 to 21 := 0; -- 当前正在发送的子弹编号为cur_bullet - 1，0开始帧，21结束帧
    signal cur_bullet_bit: integer range 0 to 35 := 0; -- 当前正在发送的子弹数据的比特，0开始位，34校验位，35结束位
    signal cur_player: integer range 0 to 3 := 0;
    signal cur_player_bit: integer range 0 to 36 := 0; -- 玩家信息还要多两位，用于生命值
    signal bullet_cache: BULLETS;
    signal player_cache: PLAYERS;
    signal bullet_odd: std_logic; -- 子弹校验位
    signal player_odd: std_logic; -- 玩家校验位

    function xor_vector(vector: std_logic_vector)
    return std_logic is
        variable ret: std_logic := '0';
    begin
        for i in vector'range loop
            ret := ret xor vector(i);
        end loop;
        return ret;
    end function;

    begin
        process(cur_bullet, bullet_cache) -- 生成子弹信息校验位
        begin
            if cur_bullet > 0 and cur_bullet < 21 then
                bullet_odd <= xor_vector(bullet_cache(cur_bullet - 1).x & bullet_cache(cur_bullet - 1).y);
            else
                bullet_odd <= '0';
            end if;
        end process;

        process(cur_player, player_cache) -- 生成玩家信息校验位
        begin
            if cur_player > 0 and cur_player < 3 then
                player_odd <= xor_vector(player_cache(cur_player - 1).x & player_cache(cur_player - 1).y);
            else
                player_odd <= '0';
            end if;
        end process;

        process(clk, bullet_array, bullet_cache, head_clk) -- 子弹信息发送
        begin
            if head_clk = '0' then
                cur_bullet <= 0;
                cur_bullet_bit <= 0;
            elsif rising_edge(clk) then
                if cur_bullet = 0 then -- 开始帧
                    if cur_bullet_bit >= 0 and cur_bullet_bit <= 34 then -- 开始位到校验位全是0
                        bullet_data <= '0';
                        cur_bullet_bit <= cur_bullet_bit + 1;
                    else
                        bullet_data <= '1';
                        cur_bullet_bit <= 0;
                        cur_bullet <= cur_bullet + 1;
                        bullet_cache <= bullet_array;
                    end if;
                elsif cur_bullet > 0 and cur_bullet <= 20 then -- 信息帧
                    if cur_bullet_bit = 0 then -- 开始位
                        bullet_data <= '0';
                    elsif cur_bullet_bit > 0 and cur_bullet_bit < 34 then -- 数据位
                        if cur_bullet_bit < 17 then
                            bullet_data <= bullet_cache(cur_bullet - 1).x(cur_bullet_bit - 1);
                        elsif cur_bullet_bit < 33 then
                            bullet_data <= bullet_cache(cur_bullet - 1).y(cur_bullet_bit - 1 - 16);
                        else
                            bullet_data <= bullet_cache(cur_bullet - 1).in_screen;
                        end if;    
                    elsif cur_bullet_bit = 34 then
                        bullet_data <= bullet_odd;
                    else
                        bullet_data <= '1';
                    end if;

                    if cur_bullet_bit = 35 then
                        cur_bullet_bit <= 0;
                        cur_bullet <= cur_bullet + 1;
                    else
                        cur_bullet_bit <= cur_bullet_bit + 1;
                    end if;
                else -- 结束帧
                    if cur_bullet_bit = 0 then -- 开始位为0
                        bullet_data <= '0';
                    else
                        bullet_data <= '1';
                    end if;

                    if cur_bullet_bit /= 35 then
                        cur_bullet_bit <= cur_bullet_bit + 1;
                    end if;
                end if;
            end if;
        end process;

        process(clk, player_array, player_cache, head_clk) -- 玩家信息发送进程
        begin
            if head_clk = '0' then
                cur_player <= 0;
                cur_player_bit <= 0;
            elsif rising_edge(clk) then
                if cur_player = 0 then -- 开始帧
                    if cur_player_bit >= 0 and cur_player_bit <= 35 then
                        player_data <= '0';
                        cur_player_bit <= cur_player_bit + 1;
                    else
                        player_data <= '1';
                        cur_player_bit <= 0;
                        cur_player <= cur_player + 1;
                        player_cache <= player_array;
                    end if;
                elsif cur_player > 0 and cur_player <= 2 then -- 信息帧
                    if cur_player_bit = 0 then
                        player_data <= '0';
                    elsif cur_player_bit > 0 and cur_player_bit < 33 then
                        if cur_player_bit < 17 then
                            player_data <= player_cache(cur_player - 1).x(cur_player_bit - 1);
                        else
                            player_data <= player_cache(cur_player - 1).y(cur_player_bit - 1 - 16);
                        end if;
                    elsif cur_player_bit < 35 then
                        player_data <= player_cache(cur_player - 1).life(cur_player_bit - 33);
                    elsif cur_player_bit = 35 then
                        player_data <= player_odd;
                    else
                        player_data <= '1';
                    end if;

                    if cur_player_bit = 36 then
                        cur_player_bit <= 0;
                        cur_player <= cur_player + 1;
                    else
                        cur_player_bit <= cur_player_bit + 1;
                    end if;

                else -- 结束帧
                    if cur_player_bit = 0 or cur_player_bit = 35 then
                        player_data <= '0';
                    else
                        player_data <= '1';
                    end if;

                    if cur_player_bit /= 36 then
                        cur_player_bit <= cur_player_bit + 1;
                    end if;
                end if;
            end if;
        end process;
    end architecture;