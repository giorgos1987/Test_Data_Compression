library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- single-bit mode: diaxeirizomaste kathe bit tou buffer ksexwrista
-- group-copy mode: ta bits tou idiou group dieuthunsiodotountai parallhla

entity buffer_n is
generic(n: integer:= 31; k: integer:= 5);
port(clk: in std_logic;
   rst: in std_logic;
   is_grp: in std_logic;
   set_buf: in std_logic;
   den: in std_logic;
   ts: in std_logic;
   data_code: in std_logic_vector(k-1 downto 0);
   sel: in std_logic_vector(n-1 downto 0);
   buf_out: out std_logic_vector(n-1 downto 0));
end buffer_n;

architecture buffer_n_arch of buffer_n is

component dff is
port(clk: in std_logic;
   rst: in std_logic;
   ld: in std_logic;
   d: in std_logic; 	  
   q: out std_logic);
end component dff;

signal en,dff_en,dff_in,dff_out: std_logic_vector(n-1 downto 0) := (others => '0');
signal i: integer := 0;

begin

-- multiple D-flip flop instantiation
F: for i in 0 to n-1 generate
   begin
        U_0 : dff port map(clk => clk,
               rst => rst,
               ld => dff_en(i),
               d => dff_in(i),
               q => dff_out(i));
   end generate F;

buffer_proc: process(clk,sel,en,den,ts)
begin

  for i in 0 to n-1 loop
  
    if (i mod k = 0) then
      en(i) <= sel(i);
    else
      en(i) <= sel(i) or (is_grp and sel(i-(i mod k)));
    end if;

    dff_en(i) <= den and (set_buf or en(i)); 
    
	   if (is_grp = '1') then
        dff_in(i) <= data_code(i mod k);
      else
        if (set_buf = '1') then
          if (en(i) = '1') then
            if (data_code = "11111") then
              dff_in(i) <= not ts;
            else
              dff_in(i) <= ts;
            end if;
          else
            dff_in(i) <= not ts;
          end if;
		else
			dff_in(i) <= not ts;
        end if;
     end if;
	 
  end loop;
  
  if (falling_edge(clk)) then
      buf_out <= dff_out;
  end if;

end process;
   
end buffer_n_arch;
