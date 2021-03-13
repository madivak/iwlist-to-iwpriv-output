iwlist-to-iwpriv-output
========================
Linux Bash script to perform wifi scan and generate similar output to iwpriv using iwlist.


Iwpriv deals with parameters and setting specific to each driver (as opposed to iwconfig which deals with generic ones). 
It may so happen that one needs to replicate the same WIFI scan output but if the driver does not support iwpriv, then this linux bash script will help generate the same output.

This script has 8 stages where the iwlist WIFI scan output is sampled and formatted into the desired output.

A sample WIFI scan output command and output for iwpriv is as shown below:
--------------------------------------------------------------------------
<pre>
#ifconfig wlan0 up
#ifconfig wlan0 down
#iwpriv wlan0 set SiteSurvey=
#iwpriv wlan0 get_site_survey wlan0
</pre>
<pre>
Ch  SSID                             BSSID               Security               Siganl(%)W-Mode  ExtCH  NT WPS DPID     
1   ssid1                            xx:8a:xx:2a:bf:xx   WPA1PSKWPA2PSK/TKIPAES 24       11b/g/n NONE   In  NO     
1   ssid2                            6a:xx:98:xx:12:xx   WPA2/TKIPAES           42       11b/g/n NONE   In  NO     
1   ssid3                            8c:xx:c3:14:xx:05   WPA2PSK/AES            15       11b/g/n NONE   In YE     
4   ssid4                            xx:7f:3c:xx:06:32   WPA2PSK/TKIPAES        60       11b/g/n NONE   In YES     
6   ssid5                            34:xx:xx:da:xx:xx   WPA1PSKWPA2PSK/TKIPAES 89       11b/g/n NONE   In YES      
11  ssid6                            xx:51:xx:04:xx:db   WPA1PSKWPA2PSK/TKIPAES 15       11b/g/n NONE   In YES 
</pre>

This script makes use of iwlist to generate a similar output.


