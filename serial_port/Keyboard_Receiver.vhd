-- 键盘串口通讯模块--接收器
library ieee;

use ieee.std_logic_1164.all;

entity Keyboard_Receiver is
    port(
        clk: in std_logic; -- 需要接串口时钟
        data: in std_logic; -- 串口数据
        player_input: out std_logic_vector(4 downto 0);
        head_clk: in std_logic
    );
end entity;

architecture bhv of Keyboard_Receiver is
    type state_t is (start, D0, D1, D2, D3, D4, parity, finish); -- 分别对应采样，开始位，数据位，奇偶校验位和结束位
    signal state: state_t := start;
    signal input_cache: std_logic_vector(4 downto 0);
    signal odd: std_logic;

    begin
        odd <= input_cache(0) xor input_cache(1) xor input_cache(2) xor input_cache(3) xor input_cache(4);

        process(clk)
        begin
            if rising_edge(clk) then
                case state is
                    when start =>
                        if data = '0' then
                            state <= D0;
                        end if;
                    when D0 =>
                        input_cache(0) <= data;
                        state <= D1;
                    when D1 =>
                        input_cache(1) <= data;
                        state <= D2;
                    when D2 =>
                        input_cache(2) <= data;
                        state <= D3;
                    when D3 =>
                        input_cache(3) <= data;
                        state <= D4;
                    when D4 =>
                        input_cache(4) <= data;
                        state <= parity;
                    when parity =>
                        if odd = data then
                            state <= finish;
                        else
                            state <= start;
                        end if;
                    when finish =>
                        if data = '0' then
                            player_input <= input_cache;
                        end if;
                        state <= start;
                    when others =>
                        state <= finish;
                end case;
            end if;
        end process;
    end architecture;