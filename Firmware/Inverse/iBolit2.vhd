-- Copyright (C) 1991-2013 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- iBolit2 Diagnostics Cartridge Firmware v1.00
-- Created by Wierzbowsky [RBSC]
-- (c) RBSC 2024
-- Inverse blinking logic
-- Last modified: 30.11.2024

library ieee;
use ieee.std_logic_1164.all;
library altera;
use altera.altera_syn_attributes.all;
library altera_mf;
use altera_mf.altera_mf_components.all;

-- Pin assignment
entity iBolit2 is
	port
	(
		OUT_D0 : out std_logic;
		OUT_D1 : out std_logic;
		OUT_D2 : out std_logic;
		OUT_D3 : out std_logic;
		OUT_D4 : out std_logic;
		OUT_D5 : out std_logic;
		OUT_D6 : out std_logic;
		OUT_D7 : out std_logic;
		IN_CLK1 : in std_logic;
		IN_CLK2 : in std_logic;
		OUT_A0 : out std_logic;
		OUT_A1 : out std_logic;
		OUT_A2 : out std_logic;
		OUT_A3 : out std_logic;
		OUT_A4 : out std_logic;
		OUT_A5 : out std_logic;
		OUT_A6 : out std_logic;
		OUT_A7 : out std_logic;
		OUT_WR : out std_logic;
		OUT_RD : out std_logic;
		OUT_A8 : out std_logic;
		OUT_A9 : out std_logic;
		OUT_A10 : out std_logic;
		OUT_A11 : out std_logic;
		OUT_A12 : out std_logic;
		OUT_A13 : out std_logic;
		OUT_A14 : out std_logic;
		OUT_A15 : out std_logic;
		OUT_INT : out std_logic;
		OUT_RST : out std_logic;
		OUT_CS1 : out std_logic;
		OUT_CS2 : out std_logic;
		OUT_CS12 : out std_logic;
		OUT_SLTSEL : out std_logic;
		OUT_RFSH : out std_logic;
		OUT_WAIT : out std_logic;
		OUT_M1 : out std_logic;
		OUT_IORQ : out std_logic;
		OUT_MERQ : out std_logic;
		OUT_BUSDIR : out std_logic;
		OUT_CLK : out std_logic;
		IN_CS1 : in std_logic;
		IN_CS12 : in std_logic;
		IN_WAIT : in std_logic;
		IN_CS2 : in std_logic;
		IN_SLTSEL : in std_logic;
		IN_RFSH : in std_logic;
		IN_INT : in std_logic;
		IN_M1 : in std_logic;
		IN_IORQ : in std_logic;
		IN_WR : in std_logic;
		IN_RST : in std_logic;
		IN_BUSDIR : in std_logic;
		IN_MERQ : in std_logic;
		IN_RD : in std_logic;
		IN_A15 : in std_logic;
		IN_A9 : in std_logic;
		IN_A11 : in std_logic;
		IN_A7 : in std_logic;
		IN_A12 : in std_logic;
		IN_A10 : in std_logic;
		IN_A6 : in std_logic;
		IN_A8 : in std_logic;
		IN_A13 : in std_logic;
		IN_A14 : in std_logic;
		IN_A1 : in std_logic;
		IN_A3 : in std_logic;
		IN_A5 : in std_logic;
		IN_A0 : in std_logic;
		IN_A4 : in std_logic;
		IN_D0 : in std_logic;
		IN_D1 : in std_logic;
		IN_A2 : in std_logic;
		IN_D3 : in std_logic;
		IN_D5 : in std_logic;
		IN_D7 : in std_logic;
		IN_D2 : in std_logic;
		IN_D4 : in std_logic;
		IN_D6 : in std_logic;
		IN_SWITCH : in std_logic
	);

end iBolit2;

architecture Blinker of iBolit2 is
	-- Built-in oscillator 5.5mhz
	component Oscillator
		port
		( 
			osc : out std_logic;
			oscena : in std_logic
		); 
	end component;
	
	-- Constants to create the frequencies needed:
	-- Formula is: (5 MHz / 100 Hz * 50% duty cycle)
	-- So for 100 Hz: 25000000 / 100 * 0.5 = 125000
	constant c_CNT_100HZ : natural := 125000/5;
	--constant c_CNT_50HZ  : natural := 250000/5;
	constant c_CNT_10HZ  : natural := 1250000/5;
	constant c_CNT_1HZ   : natural := 12500000/5;
	signal r_CNT_10HZ  : natural range 0 to c_CNT_10HZ;
	signal r_CNT_100HZ : natural range 0 to c_CNT_100HZ;
	signal r_CNT_1HZ   : natural range 0 to c_CNT_1HZ;
	signal Trigger100Hz : std_logic := '0';
	signal Trigger10Hz : std_logic := '0';
	signal Trigger1Hz : std_logic := '0';
	signal ButtonDownCounter: natural range 0 to c_CNT_1HZ;
	
	signal BlinkerMode  : natural range 0 to 3;
	--signal ButtonDown : std_logic := '0';
	--signal ButtonDownCount : natural range 0 to 9999;
	
	--	Blinker modes
	--	0 = inverse indication at 100Hz
  	--	1 = inverse indication at 10Hz
	--	3 = high signals only at 1Hz
	--	4 = low signals only at 1Hz

	signal INT_OSC : std_logic;
	signal OSC_ENA : std_logic;
	
begin
	
	GEN:Oscillator port map (INT_OSC, OSC_ENA);
	OSC_ENA <= '1';

	----------------------------------------------------------------
	-- Main LED Blinker
	-- Signal assignment based on mode and triggers
	----------------------------------------------------------------

	Trigger1Hz <= '1' when r_CNT_1HZ = 0 and IN_SWITCH = '1' else '0';
	Trigger10Hz <= '1' when r_CNT_10HZ = 0 and IN_SWITCH = '1' else '0';
	Trigger100Hz <= '1' when r_CNT_100HZ = 0 and IN_SWITCH = '1' else '0';
	
	OUT_A0 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_A0 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A0 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A0 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_A0 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A0 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A0 = '0');
	OUT_A1 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_A1 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A1 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A1 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_A1 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A1 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A1 = '0');
	OUT_A2 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_A2 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A2 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A2 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_A2 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A2 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A2 = '0');
	OUT_A3 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_A3 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A3 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A3 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_A3 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A3 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A3 = '0');
	OUT_A4 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_A4 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A4 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A4 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_A4 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A4 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A4 = '0');
	OUT_A5 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_A5 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A5 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A5 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_A5 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A5 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A5 = '0');
	OUT_A6 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_A6 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A6 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A6 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_A6 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A6 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A6 = '0');
	OUT_A7 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_A7 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A7 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A7 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_A7 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A7 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A7 = '0');
	OUT_A8 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_A8 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A8 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A8 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_A8 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A8 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A8 = '0');
	OUT_A9 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_A9 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A9 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A9 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_A9 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A9 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A9 = '0');
	OUT_A10 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_A10 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A10 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A10 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_A10 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A10 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A10 = '0');
	OUT_A11 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_A11 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A11 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A11 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_A11 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A11 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A11 = '0');
	OUT_A12 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_A12 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A12 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A12 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_A12 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A12 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A12 = '0');
	OUT_A13 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_A13 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A13 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A13 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_A13 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A13 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A13 = '0');
	OUT_A14 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_A14 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A14 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A14 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_A14 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A14 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A14 = '0');
	OUT_A15 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_A15 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A15 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A15 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_A15 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_A15 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_A15 = '0');

	OUT_D0 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_D0 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_D0 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_D0 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_D0 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_D0 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_D0 = '0');
	OUT_D1 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_D1 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_D1 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_D1 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_D1 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_D1 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_D1 = '0');
	OUT_D2 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_D2 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_D2 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_D2 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_D2 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_D2 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_D2 = '0');
	OUT_D3 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_D3 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_D3 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_D3 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_D3 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_D3 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_D3 = '0');
	OUT_D4 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_D4 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_D4 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_D4 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_D4 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_D4 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_D4 = '0');
	OUT_D5 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_D5 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_D5 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_D5 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_D5 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_D5 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_D5 = '0');
	OUT_D6 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_D6 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_D6 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_D6 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_D6 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_D6 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_D6 = '0');
	OUT_D7 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_D7 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_D7 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_D7 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_D7 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_D7 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_D7 = '0');

	OUT_CLK <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_CLK1 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_CLK1 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_CLK1 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_CLK1 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_CLK1 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_CLK1 = '0');
	OUT_RD <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_RD = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_RD = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_RD = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_RD = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_RD = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_RD = '0');
	OUT_WR <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_WR = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_WR = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_WR = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_WR = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_WR = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_WR = '0');
	OUT_INT <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_INT = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_INT = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_INT = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_INT = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_INT = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_INT = '0');
	OUT_RST <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_RST = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_RST = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_RST = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_RST = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_RST = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_RST = '0');

	OUT_CS1 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_CS1 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_CS1 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_CS1 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_CS1 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_CS1 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_CS1 = '0');
	OUT_CS2 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_CS2 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_CS2 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_CS2 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_CS2 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_CS2 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_CS2 = '0');
	OUT_CS12 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_CS12 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_CS12 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_CS12 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_CS12 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_CS12 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_CS12 = '0');
	OUT_SLTSEL <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_SLTSEL = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_SLTSEL = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_SLTSEL = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_SLTSEL = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_SLTSEL = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_SLTSEL = '0');
	OUT_RFSH <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_RFSH = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_RFSH = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_RFSH = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_RFSH = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_RFSH = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_RFSH = '0');
	OUT_WAIT <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_WAIT = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_WAIT = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_WAIT = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_WAIT = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_WAIT = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_WAIT = '0');
	OUT_M1 <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_M1 = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_M1 = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_M1 = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_M1 = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_M1 = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_M1 = '0');
	OUT_IORQ <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_IORQ = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_IORQ = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_IORQ = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_IORQ = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_IORQ = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_IORQ = '0');
	OUT_MERQ <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_MERQ = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_MERQ = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_MERQ = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_MERQ = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_MERQ = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_MERQ = '0');
	OUT_BUSDIR <= '1' when (IN_SWITCH = '0' and BlinkerMode = 3) or (Trigger1Hz = '1' and BlinkerMode = 2 and IN_BUSDIR = '1') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_BUSDIR = '1') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_BUSDIR = '1') else
		'0' when (IN_SWITCH = '0' and BlinkerMode < 3) or (Trigger1Hz = '1' and BlinkerMode = 3 and IN_BUSDIR = '0') or (Trigger100Hz = '1' and BlinkerMode = 0 and IN_BUSDIR = '0') or (Trigger10Hz = '1' and BlinkerMode = 1 and IN_BUSDIR = '0');
 
	
	----------------------------------------------------------------
	-- Counters for frequencies depending on internal clock
	----------------------------------------------------------------

	process (INT_OSC, IN_SWITCH)
	begin
		if (rising_edge(INT_OSC) and IN_SWITCH = '1') then
			r_CNT_1HZ <= r_CNT_1HZ + 1;
			r_CNT_10HZ <= r_CNT_10HZ + 1;
			r_CNT_100HZ <= r_CNT_100HZ + 1;
		elsif (rising_edge(INT_OSC) and IN_SWITCH = '0') then
			r_CNT_100HZ <= 0;
			r_CNT_10HZ <= 0;
			r_CNT_1HZ <= 0;
		end if;
	end process;


	----------------------------------------------------------------
	-- Button detection with timer (debouncer) and mode switch
	----------------------------------------------------------------

	process(INT_OSC, ButtonDownCounter, IN_SWITCH)
	begin
		if (IN_SWITCH = '1') then 
			ButtonDownCounter <= 0;
		elsif (INT_OSC'event and INT_OSC = '1') then
			ButtonDownCounter <= ButtonDownCounter + 1;
			if ButtonDownCounter = c_CNT_1HZ - 1 then
				ButtonDownCounter <= 0;
				if (BlinkerMode = 3) then
					BlinkerMode <= 0;
				else
					BlinkerMode <= BlinkerMode + 1;
				end if;
			end if;
		end if;
	end process;
	
end Blinker;

