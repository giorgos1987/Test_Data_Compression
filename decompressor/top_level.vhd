library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- To drive N scan chains, we use only c tester channels. In the best case, we can achieve compression by a factor of N/c 
-- using only one tester clock cycle per slice.

entity top_level is
generic(n: integer:= 31; k: integer:= 5); -- n: number of scan chains, c = ceil(log(n+1)+2): number of test channels
port(clk: in std_logic;
	 rst: in std_logic;
	 decomp_in: in std_logic_vector(k+1 downto 0);    -- scan slice c-bits = 2-bits control code + k-bits data code
	 decomp_out: out std_logic_vector(n-1 downto 0));
end top_level;

architecture top_level_arch of top_level is

component addr_rgstr is
generic(k: integer := 5);
port(clk: in std_logic;
	 rst: in std_logic;
	 ld: in std_logic;
	 inc_addr: in std_logic;
	 d: in std_logic_vector(k-1 downto 0); 	  
	 q: out std_logic_vector(k-1 downto 0));
end component addr_rgstr;

component addr_decoder is
generic (n: integer:= 31; k: integer:= 5);
port (is_grp: in std_logic;
	  inK_data_code: in std_logic_vector(k-1 downto 0);
	  inK_addr_reg: in std_logic_vector(k-1 downto 0);
	  outN: out std_logic_vector(n-1 downto 0));
end component addr_decoder;

component buffer_n is
generic(n: integer:= 31; k: integer:= 5);
port(clk: in std_logic;
	 rst: in std_logic;
	 is_grp: in std_logic;
	 set_buf: in std_logic;
	 den: in std_logic;
	 ts: in std_logic;
	 sel: in std_logic_vector(n-1 downto 0);
	 data_code: in std_logic_vector(k-1 downto 0);
	 buf_out: out std_logic_vector(n-1 downto 0));
end component buffer_n;

component fsm is
generic(n: integer := 31);
port(clk: in std_logic;
	 control: in std_logic_vector(1 downto 0);
	 rst: in std_logic;
	 is_grp: out std_logic;
	 inc_addr: out std_logic;
	 set_buf: out std_logic;
	 den: out std_logic;
	 ts: out std_logic; 
	 v: out std_logic);
end component fsm;

signal data_code,addr_reg_out: std_logic_vector(k-1 downto 0);
signal dec_out: std_logic_vector(n-1 downto 0);
signal control: std_logic_vector(1 downto 0);
signal is_grp,inc_addr,set_buf,den,ts,v: std_logic;

begin

U_1: addr_rgstr port map(clk => clk,
						 rst => rst,
						 ld => is_grp,
						 inc_addr => inc_addr,
						 d => data_code,
						 q => addr_reg_out);
					
U_2: addr_decoder port map(is_grp => is_grp,
						   inK_data_code => data_code,
						   inK_addr_reg => addr_reg_out,
						   outN => dec_out);
				
U_3: buffer_n port map(clk => clk,
					   rst => rst,
					   is_grp => is_grp,
					   set_buf => set_buf,
					   den => den,
					   ts => ts,
					   sel => dec_out,
					   data_code => data_code,
					   buf_out => decomp_out);
					   
U_4: fsm port map(clk => clk,
				  control => control,
				  rst => rst,
				  is_grp => is_grp,
				  inc_addr => inc_addr,
				  set_buf => set_buf,
				  den => den,
				  ts => ts,
				  v => v);					   
					   
data_code <= decomp_in(k-1 downto 0);
control <= decomp_in(k+1 downto k);
					   
end top_level_arch;