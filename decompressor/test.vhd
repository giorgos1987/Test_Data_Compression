library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity test is
end test;

architecture test_arch of test is

-- component declaration for the unit under test
component top_level is
generic(n: integer:= 31; k: integer:= 5); -- n: number of scan chains, c = ceil(log(n+1)+2): number of test channels
port(clk: in std_logic;
	 rst: in std_logic;
	 decomp_in: in std_logic_vector(k+1 downto 0);    -- scan slice c-bits = 2-bits control code + k-bits data code
	 decomp_out: out std_logic_vector(n-1 downto 0));
end component top_level;


constant scan_chains: integer:= 31;
constant datacode_width: integer:= 5;

-- declare inputs/outputs and initialize them
signal test_clk: std_logic := '0';
signal test_rst: std_logic := '0';
signal test_in: std_logic_vector(datacode_width+1 downto 0);
signal test_out: std_logic_vector(scan_chains-1 downto 0);

file file_vectors : text;
file file_results : text;

-- clock period definitions
constant clk_period : time := 1 ns;

begin

-- Instantiate the Unit Under Test (UUT)
   uut: top_level generic map(n => scan_chains,
							  k => datacode_width)
				  port map(clk => test_clk,
						   rst => test_rst,
						   decomp_in => test_in,
						   decomp_out => test_out);

-- This procedure reads the file encodedData.txt which is located in the simulation project area
-- The result is written to the output_results.txt file, located in the same directory
process
    variable v_iline: line;
    variable v_oline: line;
    variable v_slice: std_logic_vector(datacode_width+1 downto 0);
     
  begin
 
    file_open(file_vectors, "encodedData.txt",  read_mode);
    file_open(file_results, "output_results.txt", write_mode);
 
    while not endfile(file_vectors) loop
      readline(file_vectors, v_iline);
      read(v_iline, v_slice);  
      test_in <= v_slice; -- Pass the variable to a signal
 
      wait until (rising_edge(test_clk));
 
      write(v_oline, test_out, right, scan_chains);
      writeline(file_results, v_oline);
    end loop;
 
    file_close(file_vectors);
    file_close(file_results);
     
    wait;
  end process;

end test_arch;