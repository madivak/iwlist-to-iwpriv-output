#!/bin/sh
#
# *  iwlist_to_iwpriv_wifiscan.sh
# *
# * Copyright (c) 2021 Kevin Amadiva <madivak@live.co.uk>
# *
# *  This program is free software; you can redistribute it and/or modify
# *  it under the terms of the GNU General Public License as published by
# *  the Free Software Foundation; either version 2, or (at your option)
# *  any later version.
# *
# *  This program is distributed in the hope that it will be useful,
# *  but WITHOUT ANY WARRANTY; without even the implied warranty of
# *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# *  GNU General Public License for more details.
# *
# */

INTERFACE="wlan0"

#Stage1: WiFi Scan
#=================
iwlist $INTERFACE scan | grep -w 'Address\|Channel\|ESSID\|Authentication\|IE: WPA\|Pairwise\|IEEE\|Quality' | grep -v 'Frequency' |cut -c 20- | sed 's/\/70  Signal level.*/|/' | sed 's/"/|/g'| xargs | sed 's/\n//g' | sed 's/IE: IEEE 802.11i\/WPA2 Version 1/|WPA2|/g' | sed 's/Authentication Suites (1) : PSK/|PSK|/g' | sed 's/Authentication Suites (1) : 802.1x//g' | sed 's/Authentication Suites (2) : PSK/|PSK|/g'  > /tmp/"$INTERFACE"_scan0

#Stage2: separate the variable
#=============================
sed 's/Address: /\n/g' /tmp/"$INTERFACE"_scan0 | sed 's/ Channel:/\t||/g' | sed 's/ Quality=/\t||/g' | sed 's/ ESSID:/\t/g' | sed 's/| /|\t/g' | sed 's/Pairwise Ciphers (1) : CCMP/|AES|/g' | sed 's/Pairwise Ciphers (1) : TKIP/|TKIP|/g' | sed 's/Pairwise Ciphers (2) : TKIP CCMP/|TKIPAES|/g' | sed 's/Pairwise Ciphers (2) : CCMP TKIP/|TKIPAES|/g' | sed 's/Pairwise Ciphers (2) : Proprietary Proprietary/|TKIPAES|/g' | sed 's/IE: WPA Version 1/|WPA1|/g' | sed 's/IE: IEEE 802.11i\/WPA2 Version 1/|WPA2|/g' > /tmp/"$INTERFACE"_scan1

#Stage3: Remove first line, then remove all tabs & spaces before '|', terminate the lines on occurence of white space (to remove extra unwanted characters and words), remove 2nd occurence of '|TKIPAES|' in lines
#==========================================================================================================================================================================================================
cat /tmp/"$INTERFACE"_scan1 | sed '1d;$d' | sed 's/\s\+|/|/g' | sed 's/|\s.*/|/g' | sed 's/|TKIPAES|//2' > /tmp/"$INTERFACE"_scan2

#Stage4: Concatenate encryption formats
#======================================
cat /tmp/"$INTERFACE"_scan2 | sed 's/|WPA1||PSK|/|WPA1PSK|/g' | sed 's/|WPA1||TKIPAES||PSK|/|WPA1PSK\/TKIPAES|/g' | sed 's/|WPA1||TKIP||PSK|/|WPA1PSK\/TKIP|/g' | sed 's/|WPA2||AES||PSK|/|WPA2PSK\/AES|/g' | sed 's/|WPA2||PSK|/|WPA2PSK|/g' | sed 's/|WPA2||TKIP||PSK|/|WPA2PSK\/TKIP|/g' | sed 's/|WPA2||TKIPAES||PSK|/|WPA2PSK\/TKIPAES|/g' | sed 's/|WPA2||TKIPAES|/|WPA2\/TKIPAES|/g' > /tmp/"$INTERFACE"_scan3

#Stage5: Clean-up the encryption formats
#=======================================
cat /tmp/"$INTERFACE"_scan3 | sed 's/WPA1PSK\/TKIPAES||WPA2PSK/WPA1PSKWPA2PSK\/TKIPAES/g' | sed 's/WPA2PSK\/AES||WPA1PSK\/TKIP/WPA1PSKWPA2PSK\/TKIPAES/g' | sed 's/WPA2PSK\/TKIPAES||WPA1PSK/WPA1PSKWPA2PSK\/TKIPAES/g' > /tmp/"$INTERFACE"_scan4

#Stage6: Separate the variables
#==============================
cat /tmp/"$INTERFACE"_scan4 | sed 's/||/\t/1' | sed 's/||/\t/1' | sed 's/|/\t/1' | sed 's/|/|\t/2' > /tmp/"$INTERFACE"_scan5

#Stage7: Replace blank encryption field ($5) with 'NONE' then Rearrange the variables 'ch, SSID, BSSID, strength, security', then Encapsulate SSIDs with '*' instead of '|' and later remove blank SSIDs
#===============================================================================================================================================================================================
cat /tmp/"$INTERFACE"_scan5 | awk 'BEGIN { FS = OFS = "\t" } {if($5 ~ /^ *$/) $5 = "NONE" }; 1' | awk 'BEGIN { FS = OFS = "\t" } {print $2, $4, $1, $5, $3}' | sed 's/|/\*/1' | sed 's/|/\*/1' | sed '/\*\*/d'  > /tmp/"$INTERFACE"_scan6

#Stage8: Remove all '*' and '|' characters. Format output by right padding fields to correct position. Convert signal stregth to %. Add dumy W-mode & WPS info on each string end.
#=========================================================================================================================================================================
cat /tmp/"$INTERFACE"_scan6 | sed 's/*//g' | sed 's/|//g' | awk 'BEGIN { FS = "\t" } {printf "%-4s%-33s%-20s%-23s%-8d\n", $1, $2, $3, $4, $5*100/70}' | awk '{print $0,"11b/g/n NONE   In YES"}'

