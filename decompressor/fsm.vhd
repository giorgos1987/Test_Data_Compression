library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity fsm is
generic(n: integer := 8);
port(clk: in std_logic;
   control: in std_logic_vector(1 downto 0); -- 2-bit control code
   rst: in std_logic;
   is_grp: out std_logic; -- group-copy mode
   inc_addr: out std_logic; -- auksanei ton kataxwrhth dieu8unsewn kata k
   set_buf: out std_logic; -- energopoieitai an control code = 00/01
   den: out std_logic; -- energopoieitai otan ta dedomena tou buffer prokeitai n'allaksoun
   ts: out std_logic; -- target symbol (deutero bit tou control code)
   v: out std_logic); -- h diadikasia apokwdikopoihshs oloklhrw8hke kai to periexomeno tou buffer olis8ainei stis scan alusides
end fsm;

architecture fsm_arch of fsm is

type STATETYPE is (S0,S1,S2);
signal current_state: STATETYPE;

begin
state_proc:process (clk)
  begin
    
    if (rising_edge(clk)) then
      if (rst = '1') then
        current_state <= S0;
      else
        case current_state is
        when S0 => if (control = "00" or control = "01") then
                    current_state <= S1;
                  end if;
    when S1 => if (control = "00" or control = "01") then
            current_state <= S1;
          elsif (control = "11") then
            current_state <= S2;
          end if;
    when S2 => if (control = "00" or control = "01") then
            current_state <= S1;
          elsif (control = "10") then
            current_state <= S1;
          else
            current_state <= S2;
          end if;
    when others => current_state <= S0;
    end case;
  end if;
   end if;
end process;

actions_proc: process (clk)
begin
case current_state is
    
      when S0 => if (control = "00" or control = "01") then -- new slice
            is_grp <= '0';
            inc_addr <= '0';
            set_buf <= '1';
            den <= '1';
            ts <= not control(0); 
            v <= '0';
			
		else -- control = "11"
			is_grp <= '0';
            inc_addr <= '0';
            set_buf <= '0';
            den <= '0';
			ts <= not control(0);
            v <= '0';
        end if;
                 
      when S1 => if (control = "00" or control = "01") then  
            is_grp <= '0';
            inc_addr <= '0';
            set_buf <= '1';
            den <= '1';
            ts <= not control(0); 
            v <= '1';

          else -- control = "11"
            is_grp <= '1';
            inc_addr <= '0';
            set_buf <= '0';
            den <= '0'; -- we will enter the first cycle of group-copy mode
			ts <= not control(0);
            v <= '0';
          end if;
  
      when S2 => if (control = "00" or control = "01") then
            is_grp <= '0';
            inc_addr <= '0';
            set_buf <= '1';
            den <= '1';
            ts <= not control(0); 
            v <= '1';
                
          else -- control = "11"
            is_grp <= '1';
            --copy the value of the data code to the group specified by the address register,then increment the address register by K
            inc_addr <= '1';
            set_buf <= '0';
            den <= '1';
			ts <= not control(0);
            v <= '0';
          end if;
        
	  when others => is_grp <= '0';
					 inc_addr <= '0';
                     set_buf <= '0';
                     den <= '0';
                     ts <= not control(0); 
                     v <= '0';
		
      end case;
end process;

end fsm_arch;
