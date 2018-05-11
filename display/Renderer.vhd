library ieee;

use ieee.std_logic_1164.all;

entity Renderer is
    port(
        req_x: in integer range 0 to 639;
        req_y: in integer range 0 to 479;
        res_r, res_g, res_b: out std_logic_vector(2 downto 0)
    );
end entity;

architecture bhv of Renderer is
    begin
        process(req_x, req_y)
        begin
            if req_x < 300 then
                res_r <= "000";
                res_g <= "111";
                res_b <= "000";
            elsif req_x < 500 then
                res_r <= "111";
                res_g <= "000";
                res_b <= "000";
            else
                res_r <= "000";
                res_g <= "000";
                res_b <= "111";
            end if;
        end process;
    end architecture;