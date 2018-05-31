-- 键盘串口通讯模块--发送器
library ieee;

use ieee.std_logic_1164.all;

entity Keyboard_Sender is
    port(
        sys_clk: in std_logic; -- 100M时钟
        clk: in std_logic;
        player_input: in std_logic_vector(4 downto 0);
        data: out std_logic;
        head_clk: in std_logic
    );
end entity;

architecture bhv of Keyboard_Sender is
    type state_t is (start, D0, D1, D2, D3, D4, parity, finish); -- 分别对应开始位，数据位，奇偶校验位和结束位
    signal state: state_t := start;
    signal sample_input: std_logic_vector(4 downto 0);
    signal odd: std_logic;
    signal sample_clk1: std_logic;
    signal sample_clk2: std_logic;
    signal read_bit_ok: std_logic;

    begin
        odd <= sample_input(0) xor sample_input(1) xor sample_input(2) xor sample_input(3) xor sample_input(4);
        sample_clk1 <= clk when rising_edge(sys_clk);
        sample_clk2 <= sample_clk1 when rising_edge(sys_clk);
        read_bit_ok <= sample_clk1 and (not sample_clk2);

        process(sys_clk)
        begin
            if rising_edge(sys_clk) then
                if head_clk = '0' then
                    state <= start;
                elsif read_bit_ok = '1' then
                    case state is
                        when start =>
                            sample_input <= player_input; -- 将数据采样
                            data <= '0';
                            state <= D0;
                        when D0 =>
                            data <= sample_input(0);
                            state <= D1;
                        when D1 =>
                            data <= sample_input(1);
                            state <= D2;
                        when D2 =>
                            data <= sample_input(2);
                            state <= D3;
                        when D3 =>
                            data <= sample_input(3);
                            state <= D4;
                        when D4 =>
                            data <= sample_input(4);
                            state <= parity;
                        when parity =>
                            data <= odd;
                            state <= finish;
                        when finish =>
                            data <= '1';
                        when others =>
                            data <= '1';
                            state <= finish;
                    end case;
                end if;
            end if;
        end process;
    end architecture;