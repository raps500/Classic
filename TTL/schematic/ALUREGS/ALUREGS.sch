EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A3 16535 11693
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L TTL:74LS189 U?
U 1 1 609E9ADC
P 4100 1600
F 0 "U?" H 4350 2400 50  0000 C CNN
F 1 "74LS189" H 4350 2300 50  0000 C CNN
F 2 "" H 4100 1600 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS189" H 4100 1600 50  0001 C CNN
	1    4100 1600
	1    0    0    -1  
$EndComp
Wire Wire Line
	3100 1200 3600 1200
Wire Wire Line
	3600 1300 3100 1300
Wire Wire Line
	3100 1400 3600 1400
Wire Wire Line
	5050 1300 4600 1300
Wire Wire Line
	4600 1200 5050 1200
Wire Wire Line
	3100 1100 3600 1100
Wire Wire Line
	5050 1400 4600 1400
Entry Wire Line
	3000 1000 3100 1100
Entry Wire Line
	3000 1100 3100 1200
Entry Wire Line
	3000 1200 3100 1300
Entry Wire Line
	3000 1300 3100 1400
Entry Wire Line
	3000 1500 3100 1600
Entry Wire Line
	3000 1600 3100 1700
Entry Wire Line
	3000 1700 3100 1800
Entry Wire Line
	3000 1800 3100 1900
Wire Wire Line
	3100 1600 3600 1600
Wire Wire Line
	3600 1700 3100 1700
Wire Wire Line
	3100 1800 3600 1800
Wire Wire Line
	3600 1900 3100 1900
Entry Wire Line
	5050 1100 5150 1000
Entry Wire Line
	5050 1300 5150 1200
Entry Wire Line
	5050 1400 5150 1300
$Comp
L power:+5V #PWR?
U 1 1 60A294FA
P 4100 800
F 0 "#PWR?" H 4100 650 50  0001 C CNN
F 1 "+5V" H 4115 973 50  0000 C CNN
F 2 "" H 4100 800 50  0001 C CNN
F 3 "" H 4100 800 50  0001 C CNN
	1    4100 800 
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 60A29B3C
P 4100 2500
F 0 "#PWR?" H 4100 2250 50  0001 C CNN
F 1 "GND" H 4105 2327 50  0000 C CNN
F 2 "" H 4100 2500 50  0001 C CNN
F 3 "" H 4100 2500 50  0001 C CNN
	1    4100 2500
	1    0    0    -1  
$EndComp
Text Label 3150 1100 0    50   ~ 0
regs_imux[0]
Wire Wire Line
	4600 1100 5050 1100
Entry Wire Line
	5050 1200 5150 1100
Text Label 3150 1200 0    50   ~ 0
regs_imux[1]
Text Label 3150 1300 0    50   ~ 0
regs_imux[2]
Text Label 3150 1400 0    50   ~ 0
regs_imux[3]
Text Label 4650 1100 0    50   ~ 0
regs_q[0]
Text Label 4650 1200 0    50   ~ 0
regs_q[1]
Text Label 4650 1300 0    50   ~ 0
regs_q[2]
Text Label 4650 1400 0    50   ~ 0
regs_q[3]
Text Label 3150 1600 0    50   ~ 0
regs_a[0]
Text Label 3150 1700 0    50   ~ 0
regs_a[0]
Text Label 3150 1800 0    50   ~ 0
regs_a[0]
Text Label 3150 1900 0    50   ~ 0
regs_a[0]
Wire Wire Line
	3600 2000 3100 2000
Wire Wire Line
	3100 2100 3600 2100
Text Label 3150 2000 0    50   ~ 0
~reg_a_we
Text Label 3150 2100 0    50   ~ 0
~reg_a_cs
Text Notes 4100 1650 0    50   ~ 0
REG A
$Comp
L TTL:74LS189 U?
U 1 1 60A2D8F5
P 6550 1600
F 0 "U?" H 6800 2400 50  0000 C CNN
F 1 "74LS189" H 6800 2300 50  0000 C CNN
F 2 "" H 6550 1600 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS189" H 6550 1600 50  0001 C CNN
	1    6550 1600
	1    0    0    -1  
$EndComp
Wire Wire Line
	5550 1200 6050 1200
Wire Wire Line
	6050 1300 5550 1300
Wire Wire Line
	5550 1400 6050 1400
Wire Wire Line
	7500 1300 7050 1300
Wire Wire Line
	7050 1200 7500 1200
Wire Wire Line
	5550 1100 6050 1100
Wire Wire Line
	7500 1400 7050 1400
Entry Wire Line
	5450 1000 5550 1100
Entry Wire Line
	5450 1100 5550 1200
Entry Wire Line
	5450 1200 5550 1300
Entry Wire Line
	5450 1300 5550 1400
Entry Wire Line
	5450 1500 5550 1600
Entry Wire Line
	5450 1600 5550 1700
Entry Wire Line
	5450 1700 5550 1800
Entry Wire Line
	5450 1800 5550 1900
Wire Wire Line
	5550 1600 6050 1600
Wire Wire Line
	6050 1700 5550 1700
Wire Wire Line
	5550 1800 6050 1800
Wire Wire Line
	6050 1900 5550 1900
Entry Wire Line
	7500 1100 7600 1000
Entry Wire Line
	7500 1300 7600 1200
Entry Wire Line
	7500 1400 7600 1300
$Comp
L power:+5V #PWR?
U 1 1 60A2D915
P 6550 800
F 0 "#PWR?" H 6550 650 50  0001 C CNN
F 1 "+5V" H 6565 973 50  0000 C CNN
F 2 "" H 6550 800 50  0001 C CNN
F 3 "" H 6550 800 50  0001 C CNN
	1    6550 800 
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 60A2D91F
P 6550 2500
F 0 "#PWR?" H 6550 2250 50  0001 C CNN
F 1 "GND" H 6555 2327 50  0000 C CNN
F 2 "" H 6550 2500 50  0001 C CNN
F 3 "" H 6550 2500 50  0001 C CNN
	1    6550 2500
	1    0    0    -1  
$EndComp
Text Label 5600 1100 0    50   ~ 0
regs_imux[0]
Wire Wire Line
	7050 1100 7500 1100
Entry Wire Line
	7500 1200 7600 1100
Text Label 5600 1200 0    50   ~ 0
regs_imux[1]
Text Label 5600 1300 0    50   ~ 0
regs_imux[2]
Text Label 5600 1400 0    50   ~ 0
regs_imux[3]
Text Label 7100 1100 0    50   ~ 0
regs_q[0]
Text Label 7100 1200 0    50   ~ 0
regs_q[1]
Text Label 7100 1300 0    50   ~ 0
regs_q[2]
Text Label 7100 1400 0    50   ~ 0
regs_q[3]
Text Label 5600 1600 0    50   ~ 0
regs_a[0]
Text Label 5600 1700 0    50   ~ 0
regs_a[0]
Text Label 5600 1800 0    50   ~ 0
regs_a[0]
Text Label 5600 1900 0    50   ~ 0
regs_a[0]
Wire Wire Line
	6050 2000 5550 2000
Wire Wire Line
	5550 2100 6050 2100
Text Label 5600 2000 0    50   ~ 0
~reg_a_we
Text Label 5600 2100 0    50   ~ 0
~reg_a_cs
Text Notes 6550 1650 0    50   ~ 0
REG B
$Comp
L TTL:74LS189 U?
U 1 1 60A387BC
P 9000 1600
F 0 "U?" H 9250 2400 50  0000 C CNN
F 1 "74LS189" H 9250 2300 50  0000 C CNN
F 2 "" H 9000 1600 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS189" H 9000 1600 50  0001 C CNN
	1    9000 1600
	1    0    0    -1  
$EndComp
Wire Wire Line
	8000 1200 8500 1200
Wire Wire Line
	8500 1300 8000 1300
Wire Wire Line
	8000 1400 8500 1400
Wire Wire Line
	9950 1300 9500 1300
Wire Wire Line
	9500 1200 9950 1200
Wire Wire Line
	8000 1100 8500 1100
Wire Wire Line
	9950 1400 9500 1400
Entry Wire Line
	7900 1000 8000 1100
Entry Wire Line
	7900 1100 8000 1200
Entry Wire Line
	7900 1200 8000 1300
Entry Wire Line
	7900 1300 8000 1400
Entry Wire Line
	7900 1500 8000 1600
Entry Wire Line
	7900 1600 8000 1700
Entry Wire Line
	7900 1700 8000 1800
Entry Wire Line
	7900 1800 8000 1900
Wire Wire Line
	8000 1600 8500 1600
Wire Wire Line
	8500 1700 8000 1700
Wire Wire Line
	8000 1800 8500 1800
Wire Wire Line
	8500 1900 8000 1900
Entry Wire Line
	9950 1100 10050 1000
Entry Wire Line
	9950 1300 10050 1200
Entry Wire Line
	9950 1400 10050 1300
$Comp
L power:+5V #PWR?
U 1 1 60A387DC
P 9000 800
F 0 "#PWR?" H 9000 650 50  0001 C CNN
F 1 "+5V" H 9015 973 50  0000 C CNN
F 2 "" H 9000 800 50  0001 C CNN
F 3 "" H 9000 800 50  0001 C CNN
	1    9000 800 
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 60A387E6
P 9000 2500
F 0 "#PWR?" H 9000 2250 50  0001 C CNN
F 1 "GND" H 9005 2327 50  0000 C CNN
F 2 "" H 9000 2500 50  0001 C CNN
F 3 "" H 9000 2500 50  0001 C CNN
	1    9000 2500
	1    0    0    -1  
$EndComp
Text Label 8050 1100 0    50   ~ 0
regs_imux[0]
Wire Wire Line
	9500 1100 9950 1100
Entry Wire Line
	9950 1200 10050 1100
Text Label 8050 1200 0    50   ~ 0
regs_imux[1]
Text Label 8050 1300 0    50   ~ 0
regs_imux[2]
Text Label 8050 1400 0    50   ~ 0
regs_imux[3]
Text Label 9550 1100 0    50   ~ 0
regs_q[0]
Text Label 9550 1200 0    50   ~ 0
regs_q[1]
Text Label 9550 1300 0    50   ~ 0
regs_q[2]
Text Label 9550 1400 0    50   ~ 0
regs_q[3]
Text Label 8050 1600 0    50   ~ 0
regs_a[0]
Text Label 8050 1700 0    50   ~ 0
regs_a[0]
Text Label 8050 1800 0    50   ~ 0
regs_a[0]
Text Label 8050 1900 0    50   ~ 0
regs_a[0]
Wire Wire Line
	8500 2000 8000 2000
Wire Wire Line
	8000 2100 8500 2100
Text Label 8050 2000 0    50   ~ 0
~reg_a_we
Text Label 8050 2100 0    50   ~ 0
~reg_a_cs
Text Notes 9000 1650 0    50   ~ 0
REG C
$Comp
L TTL:74LS189 U?
U 1 1 60A38803
P 11450 1600
F 0 "U?" H 11700 2400 50  0000 C CNN
F 1 "74LS189" H 11700 2300 50  0000 C CNN
F 2 "" H 11450 1600 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS189" H 11450 1600 50  0001 C CNN
	1    11450 1600
	1    0    0    -1  
$EndComp
Wire Wire Line
	10450 1200 10950 1200
Wire Wire Line
	10950 1300 10450 1300
Wire Wire Line
	10450 1400 10950 1400
Wire Wire Line
	12400 1300 11950 1300
Wire Wire Line
	11950 1200 12400 1200
Wire Wire Line
	10450 1100 10950 1100
Wire Wire Line
	12400 1400 11950 1400
Entry Wire Line
	10350 1000 10450 1100
Entry Wire Line
	10350 1100 10450 1200
Entry Wire Line
	10350 1200 10450 1300
Entry Wire Line
	10350 1300 10450 1400
Entry Wire Line
	10350 1500 10450 1600
Entry Wire Line
	10350 1600 10450 1700
Entry Wire Line
	10350 1700 10450 1800
Entry Wire Line
	10350 1800 10450 1900
Wire Wire Line
	10450 1600 10950 1600
Wire Wire Line
	10950 1700 10450 1700
Wire Wire Line
	10450 1800 10950 1800
Wire Wire Line
	10950 1900 10450 1900
Entry Wire Line
	12400 1100 12500 1000
Entry Wire Line
	12400 1300 12500 1200
Entry Wire Line
	12400 1400 12500 1300
$Comp
L power:+5V #PWR?
U 1 1 60A38823
P 11450 800
F 0 "#PWR?" H 11450 650 50  0001 C CNN
F 1 "+5V" H 11465 973 50  0000 C CNN
F 2 "" H 11450 800 50  0001 C CNN
F 3 "" H 11450 800 50  0001 C CNN
	1    11450 800 
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 60A3882D
P 11450 2500
F 0 "#PWR?" H 11450 2250 50  0001 C CNN
F 1 "GND" H 11455 2327 50  0000 C CNN
F 2 "" H 11450 2500 50  0001 C CNN
F 3 "" H 11450 2500 50  0001 C CNN
	1    11450 2500
	1    0    0    -1  
$EndComp
Text Label 10500 1100 0    50   ~ 0
regs_imux[0]
Wire Wire Line
	11950 1100 12400 1100
Entry Wire Line
	12400 1200 12500 1100
Text Label 10500 1200 0    50   ~ 0
regs_imux[1]
Text Label 10500 1300 0    50   ~ 0
regs_imux[2]
Text Label 10500 1400 0    50   ~ 0
regs_imux[3]
Text Label 12000 1100 0    50   ~ 0
regs_q[0]
Text Label 12000 1200 0    50   ~ 0
regs_q[1]
Text Label 12000 1300 0    50   ~ 0
regs_q[2]
Text Label 12000 1400 0    50   ~ 0
regs_q[3]
Text Label 10500 1600 0    50   ~ 0
regs_a[0]
Text Label 10500 1700 0    50   ~ 0
regs_a[0]
Text Label 10500 1800 0    50   ~ 0
regs_a[0]
Text Label 10500 1900 0    50   ~ 0
regs_a[0]
Wire Wire Line
	10950 2000 10450 2000
Wire Wire Line
	10450 2100 10950 2100
Text Label 10500 2000 0    50   ~ 0
~reg_a_we
Text Label 10500 2100 0    50   ~ 0
~reg_a_cs
Text Notes 11450 1650 0    50   ~ 0
REG B
$Comp
L TTL:74LS189 U?
U 1 1 60A41FDA
P 4100 4050
F 0 "U?" H 4350 4850 50  0000 C CNN
F 1 "74LS189" H 4350 4750 50  0000 C CNN
F 2 "" H 4100 4050 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS189" H 4100 4050 50  0001 C CNN
	1    4100 4050
	1    0    0    -1  
$EndComp
Wire Wire Line
	3100 3650 3600 3650
Wire Wire Line
	3600 3750 3100 3750
Wire Wire Line
	3100 3850 3600 3850
Wire Wire Line
	5050 3750 4600 3750
Wire Wire Line
	4600 3650 5050 3650
Wire Wire Line
	3100 3550 3600 3550
Wire Wire Line
	5050 3850 4600 3850
Entry Wire Line
	3000 3450 3100 3550
Entry Wire Line
	3000 3550 3100 3650
Entry Wire Line
	3000 3650 3100 3750
Entry Wire Line
	3000 3750 3100 3850
Entry Wire Line
	3000 3950 3100 4050
Entry Wire Line
	3000 4050 3100 4150
Entry Wire Line
	3000 4150 3100 4250
Entry Wire Line
	3000 4250 3100 4350
Wire Wire Line
	3100 4050 3600 4050
Wire Wire Line
	3600 4150 3100 4150
Wire Wire Line
	3100 4250 3600 4250
Wire Wire Line
	3600 4350 3100 4350
Entry Wire Line
	5050 3550 5150 3450
Entry Wire Line
	5050 3750 5150 3650
Entry Wire Line
	5050 3850 5150 3750
$Comp
L power:+5V #PWR?
U 1 1 60A41FFA
P 4100 3250
F 0 "#PWR?" H 4100 3100 50  0001 C CNN
F 1 "+5V" H 4115 3423 50  0000 C CNN
F 2 "" H 4100 3250 50  0001 C CNN
F 3 "" H 4100 3250 50  0001 C CNN
	1    4100 3250
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 60A42004
P 4100 4950
F 0 "#PWR?" H 4100 4700 50  0001 C CNN
F 1 "GND" H 4105 4777 50  0000 C CNN
F 2 "" H 4100 4950 50  0001 C CNN
F 3 "" H 4100 4950 50  0001 C CNN
	1    4100 4950
	1    0    0    -1  
$EndComp
Text Label 3150 3550 0    50   ~ 0
regs_imux[0]
Wire Wire Line
	4600 3550 5050 3550
Entry Wire Line
	5050 3650 5150 3550
Text Label 3150 3650 0    50   ~ 0
regs_imux[1]
Text Label 3150 3750 0    50   ~ 0
regs_imux[2]
Text Label 3150 3850 0    50   ~ 0
regs_imux[3]
Text Label 4650 3550 0    50   ~ 0
regs_q[0]
Text Label 4650 3650 0    50   ~ 0
regs_q[1]
Text Label 4650 3750 0    50   ~ 0
regs_q[2]
Text Label 4650 3850 0    50   ~ 0
regs_q[3]
Text Label 3150 4050 0    50   ~ 0
regs_a[0]
Text Label 3150 4150 0    50   ~ 0
regs_a[0]
Text Label 3150 4250 0    50   ~ 0
regs_a[0]
Text Label 3150 4350 0    50   ~ 0
regs_a[0]
Wire Wire Line
	3600 4450 3100 4450
Wire Wire Line
	3100 4550 3600 4550
Text Label 3150 4450 0    50   ~ 0
~reg_a_we
Text Label 3150 4550 0    50   ~ 0
~reg_a_cs
Text Notes 4100 4100 0    50   ~ 0
REG Y
$Comp
L TTL:74LS189 U?
U 1 1 60A42021
P 6550 4050
F 0 "U?" H 6800 4850 50  0000 C CNN
F 1 "74LS189" H 6800 4750 50  0000 C CNN
F 2 "" H 6550 4050 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS189" H 6550 4050 50  0001 C CNN
	1    6550 4050
	1    0    0    -1  
$EndComp
Wire Wire Line
	5550 3650 6050 3650
Wire Wire Line
	6050 3750 5550 3750
Wire Wire Line
	5550 3850 6050 3850
Wire Wire Line
	7500 3750 7050 3750
Wire Wire Line
	7050 3650 7500 3650
Wire Wire Line
	5550 3550 6050 3550
Wire Wire Line
	7500 3850 7050 3850
Entry Wire Line
	5450 3450 5550 3550
Entry Wire Line
	5450 3550 5550 3650
Entry Wire Line
	5450 3650 5550 3750
Entry Wire Line
	5450 3750 5550 3850
Entry Wire Line
	5450 3950 5550 4050
Entry Wire Line
	5450 4050 5550 4150
Entry Wire Line
	5450 4150 5550 4250
Entry Wire Line
	5450 4250 5550 4350
Wire Wire Line
	5550 4050 6050 4050
Wire Wire Line
	6050 4150 5550 4150
Wire Wire Line
	5550 4250 6050 4250
Wire Wire Line
	6050 4350 5550 4350
Entry Wire Line
	7500 3550 7600 3450
Entry Wire Line
	7500 3750 7600 3650
Entry Wire Line
	7500 3850 7600 3750
$Comp
L power:+5V #PWR?
U 1 1 60A42041
P 6550 3250
F 0 "#PWR?" H 6550 3100 50  0001 C CNN
F 1 "+5V" H 6565 3423 50  0000 C CNN
F 2 "" H 6550 3250 50  0001 C CNN
F 3 "" H 6550 3250 50  0001 C CNN
	1    6550 3250
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 60A4204B
P 6550 4950
F 0 "#PWR?" H 6550 4700 50  0001 C CNN
F 1 "GND" H 6555 4777 50  0000 C CNN
F 2 "" H 6550 4950 50  0001 C CNN
F 3 "" H 6550 4950 50  0001 C CNN
	1    6550 4950
	1    0    0    -1  
$EndComp
Text Label 5600 3550 0    50   ~ 0
regs_imux[0]
Wire Wire Line
	7050 3550 7500 3550
Entry Wire Line
	7500 3650 7600 3550
Text Label 5600 3650 0    50   ~ 0
regs_imux[1]
Text Label 5600 3750 0    50   ~ 0
regs_imux[2]
Text Label 5600 3850 0    50   ~ 0
regs_imux[3]
Text Label 7100 3550 0    50   ~ 0
regs_q[0]
Text Label 7100 3650 0    50   ~ 0
regs_q[1]
Text Label 7100 3750 0    50   ~ 0
regs_q[2]
Text Label 7100 3850 0    50   ~ 0
regs_q[3]
Text Label 5600 4050 0    50   ~ 0
regs_a[0]
Text Label 5600 4150 0    50   ~ 0
regs_a[0]
Text Label 5600 4250 0    50   ~ 0
regs_a[0]
Text Label 5600 4350 0    50   ~ 0
regs_a[0]
Wire Wire Line
	6050 4450 5550 4450
Wire Wire Line
	5550 4550 6050 4550
Text Label 5600 4450 0    50   ~ 0
~reg_a_we
Text Label 5600 4550 0    50   ~ 0
~reg_a_cs
Text Notes 6550 4100 0    50   ~ 0
REG Z
$Comp
L TTL:74LS189 U?
U 1 1 60A42068
P 9000 4050
F 0 "U?" H 9250 4850 50  0000 C CNN
F 1 "74LS189" H 9250 4750 50  0000 C CNN
F 2 "" H 9000 4050 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS189" H 9000 4050 50  0001 C CNN
	1    9000 4050
	1    0    0    -1  
$EndComp
Wire Wire Line
	8000 3650 8500 3650
Wire Wire Line
	8500 3750 8000 3750
Wire Wire Line
	8000 3850 8500 3850
Wire Wire Line
	9950 3750 9500 3750
Wire Wire Line
	9500 3650 9950 3650
Wire Wire Line
	8000 3550 8500 3550
Wire Wire Line
	9950 3850 9500 3850
Entry Wire Line
	7900 3450 8000 3550
Entry Wire Line
	7900 3550 8000 3650
Entry Wire Line
	7900 3650 8000 3750
Entry Wire Line
	7900 3750 8000 3850
Entry Wire Line
	7900 3950 8000 4050
Entry Wire Line
	7900 4050 8000 4150
Entry Wire Line
	7900 4150 8000 4250
Entry Wire Line
	7900 4250 8000 4350
Wire Wire Line
	8000 4050 8500 4050
Wire Wire Line
	8500 4150 8000 4150
Wire Wire Line
	8000 4250 8500 4250
Wire Wire Line
	8500 4350 8000 4350
Entry Wire Line
	9950 3550 10050 3450
Entry Wire Line
	9950 3750 10050 3650
Entry Wire Line
	9950 3850 10050 3750
$Comp
L power:+5V #PWR?
U 1 1 60A42088
P 9000 3250
F 0 "#PWR?" H 9000 3100 50  0001 C CNN
F 1 "+5V" H 9015 3423 50  0000 C CNN
F 2 "" H 9000 3250 50  0001 C CNN
F 3 "" H 9000 3250 50  0001 C CNN
	1    9000 3250
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 60A42092
P 9000 4950
F 0 "#PWR?" H 9000 4700 50  0001 C CNN
F 1 "GND" H 9005 4777 50  0000 C CNN
F 2 "" H 9000 4950 50  0001 C CNN
F 3 "" H 9000 4950 50  0001 C CNN
	1    9000 4950
	1    0    0    -1  
$EndComp
Text Label 8050 3550 0    50   ~ 0
regs_imux[0]
Wire Wire Line
	9500 3550 9950 3550
Entry Wire Line
	9950 3650 10050 3550
Text Label 8050 3650 0    50   ~ 0
regs_imux[1]
Text Label 8050 3750 0    50   ~ 0
regs_imux[2]
Text Label 8050 3850 0    50   ~ 0
regs_imux[3]
Text Label 9550 3550 0    50   ~ 0
regs_q[0]
Text Label 9550 3650 0    50   ~ 0
regs_q[1]
Text Label 9550 3750 0    50   ~ 0
regs_q[2]
Text Label 9550 3850 0    50   ~ 0
regs_q[3]
Text Label 8050 4050 0    50   ~ 0
regs_a[0]
Text Label 8050 4150 0    50   ~ 0
regs_a[0]
Text Label 8050 4250 0    50   ~ 0
regs_a[0]
Text Label 8050 4350 0    50   ~ 0
regs_a[0]
Wire Wire Line
	8500 4450 8000 4450
Wire Wire Line
	8000 4550 8500 4550
Text Label 8050 4450 0    50   ~ 0
~reg_a_we
Text Label 8050 4550 0    50   ~ 0
~reg_a_cs
Text Notes 9000 4100 0    50   ~ 0
REG T
Wire Bus Line
	3000 1000 3000 1300
Wire Bus Line
	3000 1500 3000 1800
Wire Bus Line
	5150 1000 5150 1300
Wire Bus Line
	5450 1000 5450 1300
Wire Bus Line
	5450 1500 5450 1800
Wire Bus Line
	7600 1000 7600 1300
Wire Bus Line
	7900 1000 7900 1300
Wire Bus Line
	7900 1500 7900 1800
Wire Bus Line
	10050 1000 10050 1300
Wire Bus Line
	10350 1000 10350 1300
Wire Bus Line
	10350 1500 10350 1800
Wire Bus Line
	12500 1000 12500 1300
Wire Bus Line
	3000 3450 3000 3750
Wire Bus Line
	3000 3950 3000 4250
Wire Bus Line
	5150 3450 5150 3750
Wire Bus Line
	5450 3450 5450 3750
Wire Bus Line
	5450 3950 5450 4250
Wire Bus Line
	7600 3450 7600 3750
Wire Bus Line
	7900 3450 7900 3750
Wire Bus Line
	7900 3950 7900 4250
Wire Bus Line
	10050 3450 10050 3750
$EndSCHEMATC
