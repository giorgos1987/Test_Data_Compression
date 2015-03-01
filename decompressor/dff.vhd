library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity dff is
port(clk: in std_logic;
	 rst: in std_logic;
	 ld: in std_logic;
	 d: in std_logic; 	  
	 q: out std_logic);
end dff;

architecture dff_arch of dff is
begin
dff_proc: process (clk)
    begin
		if (rising_edge(clk)) then 
			if (rst = '1') then
				q <= '0';
			elsif (ld = '1') then
				q <= d;
			end if;
		end if;
	end process;
end dff_arch;