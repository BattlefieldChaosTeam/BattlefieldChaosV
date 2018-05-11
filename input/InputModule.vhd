library ieee;

use ieee.std_logic_1164.all;

entity Input_Module is
    port(
        sys_clk: in std_logic;
        reset: in std_logic;
        ps2_data: in std_logic;
        ps2_clk: in std_logic;
        player_one: out std_logic_vector(4 downto 0);-- 分别指示上下左右 0 W 1 S 2 A 3 D, 4 开火
        player_two: out std_logic_vector(4 downto 0);-- 同上
        enter: out std_logic
    );
end entity;

architecture bhv of Input_Module is
    component Key_Board is
        port(
            sys_clk, reset, ps2_clk, data: in std_logic;
            scan_code: out std_logic_vector(7 downto 0)
        );
    end component;

    signal scan_code: std_logic_vector(7 downto 0);

    type state_t is (init, E0, F0, E0F0);
    signal state: state_t := init;

    begin
        my_keyboard: Key_Board port map(
            sys_clk => sys_clk,
            reset => (not reset),
            data => ps2_data,
            ps2_clk => ps2_clk,
            scan_code => scan_code
        );

        process(sys_clk)
        begin
            if rising_edge(sys_clk) then
                case scan_code is
                    when "11100000" => -- E0
                        if state = init then
                            state <= E0;
                        else
                            state <= init;
                        end if;
                    when "11110000" => -- F0
                        if state = init then
                            state <= F0;
                        elsif state = E0 then
                            state <= E0F0;
                        else
                            state <= init;
                        end if;
                    when "00011101" => -- 1D W
                        if state = init then
                            player_one(0) <= '1';
                        elsif state = F0 then
                            player_one(0) <= '0';
                        end if;
                        state <= init;
                    when "00011011" => -- 1B S
                        if state = init then
                            player_one(1) <= '1';
                        elsif state = F0 then
                            player_one(1) <= '0';
                        end if;
                        state <= init;
                    when "00011100" => -- 1C A
                        if state = init then
                            player_one(2) <= '1';
                        elsif state = F0 then
                            player_one(2) <= '0';
                        end if;
                        state <= init;
                    when "00100011" => -- 23 D
                        if state = init then
                            player_one(3) <= '1';
                        elsif state = F0 then
                            player_one(3) <= '0';
                        end if;
                        state <= init;
                    when "00111011" => -- 3B J
                        if state = init then
                            player_one(4) <= '1';
                        elsif state = F0 then
                            player_one(4) <= '0';
                        end if;
                        state <= init;
                    when "01110101" => -- 75 UP
                        if state = E0 then
                            player_two(0) <= '1';
                        elsif state = E0F0 then
                            player_two(0) <= '0';
                        end if;
                        state <= init;
                    when "01110010" => -- 72 DOWN
                        if state = E0 then
                            player_two(1) <= '1';
                        elsif state = E0F0 then
                            player_two(1) <= '0';
                        end if;
                        state <= init;
                    when "01101011" => -- 6B LEFT
                        if state = E0 then
                            player_two(2) <= '1';
                        elsif state = E0F0 then
                            player_two(2) <= '0';
                        end if;
                        state <= init;
                    when "01110100" => -- 74 RIGHT
                        if state = E0 then
                            player_two(3) <= '1';
                        elsif state = E0F0 then
                            player_two(3) <= '0';
                        end if;
                        state <= init;
                    when "00010100" => -- 14 right ctrl
                        if state = E0 then
                            player_two(4) <= '1';
                        elsif state = E0F0 then
                            player_two(4) <= '0';
                        end if;
                        state <= init;
                    when "01011010" => -- 5A enter
                        if state = init then
                            enter <= '1';
                        elsif state = F0 then
                            enter <= '0';
                        end if;
                        state <= init;
                    when "00000000" => -- no scan_code, do nothing
                        null;
                    when others =>
                        state <= init;
                end case;
            end if;
        end process;
    end architecture;