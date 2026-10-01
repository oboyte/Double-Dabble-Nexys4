library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 

entity display_module is 
    port (  bit_reg : in std_logic_vector(11 downto 0); 
            an : out std_logic_vector(3 downto 0); 
            seg : out std_logic_vector(6 downto 0); 
            clk : std_logic ); 
end entity; 
    
architecture Behavioral of display_module is 
    signal bcd_reg : unsigned(15 downto 0) := (others => '0'); 
    signal binary_reg : unsigned(11 downto 0) := (others => '0'); 
    signal iteration : integer := 0; 
    constant max_iteration : integer := 12; 
    signal bcd_finish : boolean := false; 
    signal seg_finish : boolean := false; 
    signal seg_num : integer := 0; 
    signal bcd_digit : std_logic_vector(3 downto 0); 
begin -- Bit to BCD, double dabble 
    process (clk) 
    variable temp_bcd : unsigned(15 downto 0) := (others => '0'); 
begin 
    if (rising_edge(clk)) then 
        if (iteration = max_iteration) then 
            bcd_finish <= true; 
        else 
            iteration <= iteration + 1; 
        end if; 
        
        
        if (iteration = 0) then -- Sett start kondisjonene for binary_reg og bcd_reg 
            binary_reg <= unsigned(bit_reg); 
            bcd_reg <= (others=>'0');
        elsif not (bcd_finish) then 
            temp_bcd := bcd_reg; 
            if (temp_bcd(3 downto 0) >= 5) then 
                temp_bcd(3 downto 0) := temp_bcd(3 downto 0) + 3; 
            end if; 
            if (temp_bcd(7 downto 4) >= 5) then 
                temp_bcd(7 downto 4) := temp_bcd(7 downto 4) + 3; 
            end if; 
            if (temp_bcd(11 downto 8) >= 5) then 
                temp_bcd(11 downto 8) := temp_bcd(11 downto 8) + 3; 
            end if; 
            if (temp_bcd(15 downto 12) >= 5) then 
                temp_bcd(15 downto 12) := temp_bcd(15 downto 12) + 3; 
            end if; 
        
            binary_reg <= shift_left(binary_reg, 1); 
            bcd_reg <= temp_bcd(14 downto 0) & binary_reg(11); 
        else
            if (seg_finish) then -- Er prosessen ferdig å displaye alle tallene?
                seg_finish <= false; 
                bcd_finish <= false; 
                iteration <= 0;
            else 
                if(seg_num = 0) then 
                    an(3 downto 0) <= "1110"; 
                    bcd_digit <= std_logic_vector(bcd_reg(3 downto 0));
                    seg_num <= 1;
                elsif(seg_num = 1) then 
                    an(3 downto 0) <= "1101"; 
                    bcd_digit <= std_logic_vector(bcd_reg(7 downto 4));
                    seg_num <= 2;
                elsif(seg_num = 2) then 
                    an(3 downto 0) <= "1011"; 
                    bcd_digit <= std_logic_vector(bcd_reg(11 downto 8));
                    seg_num <= 3;
                else an(3 downto 0) <= "0111"; 
                    bcd_digit <= std_logic_vector(bcd_reg(15 downto 12));
                    seg_num <= 0;
                    seg_finish <= true; 
                end if;
            end if;
        end if;
         

    end if; 
end process; 

with bcd_digit select 
    seg <= 
        "1000000" when "0000", -- 0 
        "1111001" when "0001", -- 1 
        "0100100" when "0010", -- 2 
        "0110000" when "0011", -- 3 
        "0011001" when "0100", -- 4 
        "0010010" when "0101", -- 5 
        "0000010" when "0110", -- 6 
        "1111000" when "0111", -- 7 
        "0000000" when "1000", -- 8 
        "0011000" when "1001", -- 9 
        "1111111" when others; 

end Behavioral;
