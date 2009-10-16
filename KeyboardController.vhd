----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:10:55 07/16/2009 
-- Design Name: 
-- Module Name:    KeyboardController - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity KeyboardController is
    Port ( Clock : in STD_LOGIC;
	        KeyboardClock : in  STD_LOGIC;
           KeyboardData : in  STD_LOGIC;
           LeftPaddleDirection : buffer  integer;
           RightPaddleDirection : buffer  integer
	);
end KeyboardController;

architecture Behavioral of KeyboardController is

signal bitCount : integer range 0 to 100 := 0;
signal scancodeReady : STD_LOGIC := '0';
signal scancode : STD_LOGIC_VECTOR(7 downto 0);
signal breakReceived : STD_LOGIC := '0';

constant keyboardA : STD_LOGIC_VECTOR(7 downto 0) := "00011100";
constant keyboardY : STD_LOGIC_VECTOR(7 downto 0) := "00011010";
constant keyboardK : STD_LOGIC_VECTOR(7 downto 0) := "01000010";
constant keyboardM : STD_LOGIC_VECTOR(7 downto 0) := "00111010";

begin

	keksfabrik : process(KeyboardClock)
	begin
		if falling_edge(KeyboardClock) then
			if bitCount = 0 and KeyboardData = '0' then --keyboard wants to send data
				scancodeReady <= '0';
				bitCount <= bitCount + 1;
			elsif bitCount > 0 and bitCount < 9 then -- shift one bit into the scancode from the left
				scancode <= KeyboardData & scancode(7 downto 1);
				bitCount <= bitCount + 1;
			elsif bitCount = 9 then -- parity bit
				bitCount <= bitCount + 1;
			elsif bitCount = 10 then -- end of message
				scancodeReady <= '1';
				bitCount <= 0;
			end if;
		end if;
	end process keksfabrik;
	
	kruemelfabrik : process(scancodeReady, scancode)
	begin
		if scancodeReady'event and scancodeReady = '1' then
			-- breakcode breaks the current scancode
			if breakReceived = '1' then 
				breakReceived <= '0';
				if scancode = keyboardA or scancode = keyboardY then
					LeftPaddleDirection <= 0;
				elsif scancode = keyboardK or scancode = keyboardM then
					RightPaddleDirection <= 0;
				end if;
			elsif breakReceived = '0' then
				-- scancode processing
				if scancode = "11110000" then -- mark break for next scancode
					breakReceived <= '1';
				end if;
				
				if scancode = keyboardA then
					LeftPaddleDirection <= -1;
				elsif scancode = keyboardY then
					LeftPaddleDirection <= 1;
				elsif scancode = keyboardK then
					RightPaddleDirection <= -1;
				elsif scancode = keyboardM then
					RightPaddleDirection <= 1;
				end if;
			end if;
		end if;
	end process kruemelfabrik;
end Behavioral;

