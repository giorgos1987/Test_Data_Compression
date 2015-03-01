library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- in group-copy mode (is_grp=1) receives input from address register
-- in single-bit mode (is_grp=0) receives input from data code

entity addr_decoder is
generic (n: integer:= 31; k: integer:= 5);
port (is_grp: in std_logic;
    inK_data_code: in std_logic_vector(k-1 downto 0);
    inK_addr_reg: in std_logic_vector(k-1 downto 0);
    outN: out std_logic_vector(n-1 downto 0));
end addr_decoder;

architecture addr_decoder_arch of addr_decoder is

begin

decode_proc: process(inK_addr_reg,inK_data_code,is_grp)
begin
    
    outN(n-1 downto 0) <= (others => '0');
    
    case is_grp is
       -- activates specific group's first bit, pointed by address register   
      when '1' => outN(to_integer(unsigned(inK_addr_reg))) <= '1'; 
       -- activates specific bit, pointed by data code
      when '0' => if (inK_data_code(k-1 downto 0) = "11111" ) then
                    outN(n-1 downto 0) <= (others => '1');
                  else
                    outN(to_integer(unsigned(inK_data_code))) <= '1';
                  end if;
      when others => outN(n-1 downto 0) <= (others => '0');
    end case;

end process;

end addr_decoder_arch;