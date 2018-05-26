library ieee;

use ieee.std_logic_1164.all;
use work.types.all;

entity Game_Info_Receiver is
    port(
        sys_clk: in std_logic; -- 系统时钟，请给25M的时钟
        clk: in std_logic; -- 此时钟为杜邦线传来的时钟
        player_data: in std_logic;
        bullet_data: in std_logic;
        rec_players: out PLAYERS;
        rec_bullets: out BULLETS;
        head_clk: in std_logic
    );
end entity;

architecture bhv of Game_Info_Receiver is
    signal clk_sample1: std_logic := '0';
    signal clk_sample2: std_logic := '0';
    signal read_bit_ok: std_logic := '0';

    signal player_cache: PLAYERS;
    signal bullet_cache: BULLETS;
    signal cur_bullet_frame: integer range 0 to 21:= 0; -- 当前正在发送的子弹编号为cur_bullet_frame - 1，0开始帧，21结束帧
    signal cur_bullet_bit: integer range 0 to 35 := 0; -- 当前正在发送的子弹数据的比特，0开始位，34校验位，35结束位
    signal cur_player_frame: integer range 0 to 3 := 0;
    signal cur_player_bit: integer range 0 to 36 := 0; -- 玩家信息还要多两位，用于生命值，0开始位，35校验位，36结束位
    signal bullet_odd: std_logic;
    signal player_odd: std_logic;
    signal bullet_extra_frame: std_logic_vector(31 downto 0); -- 存储开始帧和结束帧，同步用
    signal player_extra_frame: std_logic_vector(33 downto 0);

    function xor_vector(vector: std_logic_vector)
    return std_logic is
        variable ret: std_logic := '0';
    begin
        for i in vector'range loop
            ret := ret xor vector(i);
        end loop;
        return ret;
    end function;

    function or_vector(vector: std_logic_vector)
    return std_logic is
        variable ret: std_logic := '0';
    begin
        for i in vector'range loop
            ret := ret or vector(i);
        end loop;
        return ret;
    end function;

    function and_vector(vector: std_logic_vector)
    return std_logic is
        variable ret: std_logic := '1';
    begin
        for i in vector'range loop
            ret := ret and vector(i);
        end loop;
        return ret;
    end function;

    begin
        clk_sample1 <= clk when rising_edge(sys_clk);
        clk_sample2 <= clk_sample1 when rising_edge(sys_clk);
        read_bit_ok <= clk_sample1 and (not clk_sample2);

        process(cur_bullet_frame, bullet_cache) -- 生成子弹信息校验位
        begin
            if cur_bullet_frame > 0 and cur_bullet_frame < 21 then
                bullet_odd <= xor_vector(bullet_cache(cur_bullet_frame - 1).x & bullet_cache(cur_bullet_frame - 1).y);
            else
                bullet_odd <= '0';
            end if;
        end process;

        process(cur_player_frame, player_cache) -- 生成玩家信息校验位
        begin
            if cur_player_frame > 0 and cur_player_frame < 3 then
                player_odd <= xor_vector(player_cache(cur_player_frame - 1).x & player_cache(cur_player_frame - 1).y);
            else
                player_odd <= '0';
            end if;
        end process;

        process(sys_clk) -- 子弹信息接收
        begin
            if rising_edge(sys_clk) then
                if read_bit_ok = '1' then
                    if head_clk = '0' then
                        cur_bullet_frame <= 0;
                        cur_bullet_bit <= 0;
                        rec_bullets <= bullet_cache;
                    else
                        if cur_bullet_frame = 0 then -- 开始帧
                            if cur_bullet_bit = 0 then -- 开始位
                                if bullet_data = '0' then
                                    cur_bullet_bit <= cur_bullet_bit + 1;
                                else
                                    cur_bullet_bit <= 0;
                                end if;
                            elsif cur_bullet_bit > 0 and cur_bullet_bit < 34 then
                                bullet_extra_frame(cur_bullet_bit - 1) <= bullet_data;
                                cur_bullet_bit <= cur_bullet_bit + 1;
                            elsif cur_bullet_bit = 34 then -- 校验位
                                if bullet_data = xor_vector(bullet_extra_frame) then
                                    cur_bullet_bit <= cur_bullet_bit + 1;
                                else
                                    cur_bullet_bit <= 0;
                                end if;
                            else -- 结束位
                                if bullet_data = '0' then
                                    cur_bullet_bit <= 0;
                                else
                                    if or_vector(bullet_extra_frame) = '0' then -- 合格的开始帧
                                        cur_bullet_frame <= cur_bullet_frame + 1;
                                    else
                                        cur_bullet_frame <= 0;
                                    end if;
                                    cur_bullet_bit <= 0;
                                end if;
                            end if;
                        elsif cur_bullet_frame > 0 and cur_bullet_frame < 21 then -- 信息帧
                            if cur_bullet_bit = 0 then -- 开始位
                                if bullet_data = '0' then
                                    cur_bullet_bit <= cur_bullet_bit + 1;
                                else
                                        cur_bullet_frame <= 0;
                                    cur_bullet_bit <= 0;
                                end if;
                            elsif cur_bullet_bit > 0 and cur_bullet_bit < 34 then -- 数据位
                                if cur_bullet_bit < 17 then
                                    bullet_cache(cur_bullet_frame - 1).x(cur_bullet_bit - 1) <= bullet_data;
                                elsif cur_bullet_bit < 33 then
                                    bullet_cache(cur_bullet_frame - 1).y(cur_bullet_bit - 1 - 16) <= bullet_data;
                                else
                                    bullet_cache(cur_bullet_frame - 1).in_screen <= bullet_data;
                                end if;
                                cur_bullet_bit <= cur_bullet_bit + 1;
                            elsif cur_bullet_bit = 34 then -- 校验位
                                if bullet_data /= bullet_odd then -- 出错直接全部作废，妥否？
                                        cur_bullet_frame <= 0;
                                    cur_bullet_bit <= 0;
                                else
                                    cur_bullet_bit <= cur_bullet_bit + 1;
                                end if;
                            elsif cur_bullet_bit = 35 then -- 结束位
                                if bullet_data = '1' then
                                    cur_bullet_frame <= cur_bullet_frame + 1;
                                    cur_bullet_bit <= 0;
                                else
                                    cur_bullet_bit <= 0;
                                    cur_bullet_frame <= 0;
                                end if;
                            end if;
                        else -- 结束帧
                            if cur_bullet_bit = 0 then -- 开始位
                                if bullet_data = '0' then
                                    cur_bullet_bit <= cur_bullet_bit + 1;
                                else
                                        cur_bullet_frame <= 0;
                                    cur_bullet_bit <= 0;
                                end if;
                            elsif cur_bullet_bit > 0 and cur_bullet_bit < 34 then -- 数据位
                                bullet_extra_frame(cur_bullet_bit - 1) <= bullet_data;
                                cur_bullet_bit <= cur_bullet_bit + 1;
                                elsif cur_bullet_bit = 34 then -- 校验位
                                if bullet_data = xor_vector(bullet_extra_frame) then
                                    cur_bullet_bit <= cur_bullet_bit + 1;
                                else
                                    cur_bullet_bit <= 0;
                                    cur_bullet_frame <= 0;
                                end if;
                            else -- 结束位
                                if bullet_data = '1' and and_vector(bullet_extra_frame) = '1' then -- 结束帧检查
                                    cur_bullet_bit <= 0;
                                    cur_bullet_frame <= 0;
                                else
                                    cur_bullet_bit <= 0;
                                    cur_bullet_frame <= 0;
                                end if;
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end process;

        process(sys_clk) -- 玩家信息接收
        begin
            if rising_edge(sys_clk) then
                if read_bit_ok = '1' then
                    if cur_player_frame = 0 then -- 开始帧
                        if cur_player_bit = 0 then -- 开始位
                            if player_data = '0' then
                                cur_player_bit <= cur_player_bit + 1;
                            else
                                cur_player_bit <= 0;
                            end if;
                        elsif cur_player_bit > 0 and cur_player_bit < 35 then
                            player_extra_frame(cur_player_bit - 1) <= player_data;
                            cur_player_bit <= cur_player_bit + 1;
                        elsif cur_player_bit = 35 then -- 校验位
                            if player_data = xor_vector(player_extra_frame) then
                                cur_player_bit <= cur_player_bit + 1;
                            else
                                cur_player_bit <= 0;
                            end if;
                        else -- 结束位
                            if player_data = '0' then
                                cur_player_bit <= 0;
                            else
                                if or_vector(player_extra_frame) = '0' then -- 合格的开始帧
                                    cur_player_frame <= cur_player_frame + 1;
                                else
                                    cur_player_frame <= 0;
                                end if;
                                cur_player_bit <= 0;
                            end if;
                        end if;
                    elsif cur_player_frame > 0 and cur_player_frame < 3 then -- 信息帧
                        if cur_player_bit = 0 then -- 开始位
                            if player_data = '0' then
                                cur_player_bit <= cur_player_bit + 1;
                            else
                                cur_player_frame <= 0;
                                cur_player_bit <= 0;
                            end if;
                        elsif cur_player_bit > 0 and cur_player_bit < 35 then -- 数据位
                            if cur_player_bit < 17 then
                                player_cache(cur_player_frame - 1).x(cur_player_bit - 1) <= player_data;
                            elsif cur_player_bit < 33 then
                                player_cache(cur_player_frame - 1).y(cur_player_bit - 1 - 16) <= player_data;
                            else
                                player_cache(cur_player_frame - 1).life(cur_player_bit - 1 - 32) <= player_data;
                            end if;
                            cur_player_bit <= cur_player_bit + 1;
                        elsif cur_player_bit = 35 then -- 校验位
                            if player_data /= player_odd then -- 出错直接全部作废，妥否？
                                cur_player_frame <= 0;
                                cur_player_bit <= 0;
                            else
                                cur_player_bit <= cur_player_bit + 1;
                            end if;
                        elsif cur_player_bit = 36 then -- 结束位
                            if player_data = '1' then
                                cur_player_frame <= cur_player_frame + 1;
                                cur_player_bit <= 0;
                            else
                                cur_player_bit <= 0;
                                cur_player_frame <= 0;
                            end if;
                        end if;
                    else -- 结束帧
                        if cur_player_bit = 0 then -- 开始位
                            if player_data = '0' then
                                cur_player_bit <= cur_player_bit + 1;
                            else
                                cur_player_frame <= 0;
                                cur_player_bit <= 0;
                            end if;
                        elsif cur_player_bit > 0 and cur_player_bit < 35 then -- 数据位
                            player_extra_frame(cur_player_bit - 1) <= player_data;
                            cur_player_bit <= cur_player_bit + 1;
                            elsif cur_player_bit = 35 then -- 校验位
                            if player_data = xor_vector(player_extra_frame) then
                                cur_player_bit <= cur_player_bit + 1;
                            else
                                cur_player_bit <= 0;
                                cur_player_frame <= 0;
                            end if;
                        else -- 结束位
                            if player_data = '1' and and_vector(player_extra_frame) = '1' then -- 结束帧检查
                                cur_player_bit <= 0;
                                cur_player_frame <= 0;
                                rec_players <= player_cache; -- 将接收到的信息输出
                            else
                                cur_player_bit <= 0;
                                cur_player_frame <= 0;
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end process;
    end architecture;