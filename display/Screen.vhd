library ieee;

use ieee.std_logic_1164.all;

entity Screen is
    port(
        clk_100M: in std_logic; -- 100MHz时钟
        req_x: out integer range 0 to 639; -- 向渲染模块请求的坐标
        req_y: out integer range 0 to 479;
        res_r, res_g, res_b: in std_logic_vector(2 downto 0); -- 渲染模块输出的rgb值
        hs, vs: out std_logic; -- 行同步，场同步信号
        r, g, b: out std_logic_vector(2 downto 0) -- 颜色输出
    );
end entity;

architecture bhv of Screen is
    signal clk_25M: std_logic;
    signal clk_50M: std_logic;
    signal cur_x: integer range 0 to 799 := 0;
    signal cur_y: integer range 0 to 524 := 0;

    begin
        process(clk_100M)
        begin
            if rising_edge(clk_100M) then
                clk_50M <= not clk_50M;
            end if;
        end process;

        process(clk_50M) -- 分频得到25M
        begin
            if rising_edge(clk_50M) then
                clk_25M <= not clk_25M;
            end if;
        end process;

        process(clk_25M)
        begin
            if rising_edge(clk_25M) then
                if cur_x = 799 then
                    cur_x <= 0;
                else
                    cur_x <= cur_x + 1;
                end if;
            end if;
        end process;

        process(clk_25M)
        begin
            if rising_edge(clk_25M) then
                if cur_x = 799 then
                    if cur_y = 524 then
                        cur_y <= 0;
                    else
                        cur_y <= cur_y + 1;
                    end if;
                end if;
            end if;
        end process;

        process(clk_25M)
        begin
            if rising_edge(clk_25M) then
                if cur_x >= 656 and cur_x < 752 then
                    hs <= '0';
                else
                    hs <= '1';
                end if;
            end if;
        end process;

        process(clk_25M)
        begin
            if rising_edge(clk_25M) then
                if cur_y >= 490 and cur_y < 492 then
                    vs <= '0';
                else
                    vs <= '1';
                end if;
            end if;
        end process;

        process(clk_25M, cur_x, cur_y, res_r, res_g, res_b)
        begin
            if cur_x < 640 and cur_y < 480 then
                req_x <= cur_x;
                req_y <= cur_y;
                r <= res_r;
                g <= res_g;
                b <= res_b;
            else
                req_x <= 0;
                req_y <= 0;
                r <= "000";
                g <= "000";
                b <= "000";
            end if;
        end process;

    end architecture;