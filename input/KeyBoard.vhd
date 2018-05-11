library ieee;

use ieee.std_logic_1164.all;

entity Key_Board is
    port(
        sys_clk, reset, ps2_clk, data: in std_logic;
        scan_code: out std_logic_vector(7 downto 0)
    );
end entity;

architecture bhv of Key_Board is
    signal code_cache: std_logic_vector(7 downto 0);
    signal p_clk_sample1: std_logic := '0';-- 键盘时钟采样
    signal p_clk_sample2: std_logic := '0';
    signal odd: std_logic;-- 奇偶校验
    signal read_bit_ok: std_logic;-- 指示是否能读入数据

    type state_t is (start, d0, d1, d2, d3, d4, d5, d6, d7, parity, finish);
    signal state: state_t := start;

    begin
        odd <= code_cache(0) xor code_cache(1) xor code_cache(2) xor code_cache(3)
            xor code_cache(4) xor code_cache(5) xor code_cache(6) xor code_cache(7);

        p_clk_sample1 <= ps2_clk when rising_edge(sys_clk);
        p_clk_sample2 <= p_clk_sample1 when rising_edge(sys_clk);
        read_bit_ok <= p_clk_sample2 and (not p_clk_sample1);

        process(sys_clk, reset, read_bit_ok)
        begin
            if reset = '1' then
                state <= start;
                scan_code <= (others => '0');
            elsif rising_edge(sys_clk)then
                scan_code <= (others => '0');
                if read_bit_ok = '1' then
                    case state is
                        when start =>
                            if data = '0' then
                                state <= d0;
                            end if;
                        when d0 =>
                            code_cache(0) <= data;
                            state <= d1;
                        when d1 =>
                            code_cache(1) <= data;
                            state <= d2;
                        when d2 =>
                            code_cache(2) <= data;
                            state <= d3;
                        when d3 =>
                            code_cache(3) <= data;
                            state <= d4;
                        when d4 => 
                            code_cache(4) <= data;
                            state <= d5;
                        when d5 =>
                            code_cache(5) <= data;
                            state <= d6;
                        when d6 =>
                            code_cache(6) <= data;
                            state <= d7;
                        when d7 =>
                            code_cache(7) <= data;
                            state <= parity;
                        when parity =>
                            if (odd xor data) = '1' then
                                state <= finish;
                            else
                                state <= start;
                            end if;
                        when finish =>
                            if data = '1' then
                                scan_code <= code_cache;
                            end if;
                            state <= start;
                    end case;
                end if;
            end if;
        end process;
    end architecture;
                    