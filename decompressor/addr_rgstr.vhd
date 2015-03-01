library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- k-bits register
-- used in group-copy mode to store the index of the first bit of the target group
-- when inc_addr = 1, the register increments by k to address a series of adjacent groups 

entity addr_rgstr is
generic(k: integer := 5);
port(clk: in std_logic;
   rst: in std_logic;
   ld: in std_logic;
   inc_addr: in std_logic;
   d: in std_logic_vector(k-1 downto 0); 	  
   q: out std_logic_vector(k-1 downto 0));
end addr_rgstr;

architecture addr_rgstr_arch of addr_rgstr is

signal temp: std_logic_vector(k-1 downto 0) := (others => '0');

begin

rgstr_proc: process (clk)
begin

if (rising_edge(clk)) then
    if (rst = '1') then
      q <= (others =>'0');
    else
		  if (ld = '1') then
				if (inc_addr = '1') then
				  q <= temp;
					temp <= temp + std_logic_vector(to_unsigned(k, k));
		    else
		      q <= std_logic_vector(to_unsigned(to_integer(unsigned(d))*k, k));
		      temp <= std_logic_vector(to_unsigned(to_integer(unsigned(d))*k, k)) + std_logic_vector(to_unsigned(k, k));
		    end if;
		  end if;
	 end if;
end if;
  
end process;		

end addr_rgstr_arch;
