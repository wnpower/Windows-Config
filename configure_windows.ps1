echo "Desactivando SMB V1..."
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force

echo "Desactivando NetBIOS..."
wmic /interactive:off nicconfig where TcpipNetbiosOptions=0 call SetTcpipNetbios 2
wmic /interactive:off nicconfig where TcpipNetbiosOptions=1 call SetTcpipNetbios 2

echo "Desactivando servicios de red innecesarios..."
Disable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_lldp
Disable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_lltdio
Disable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_implat
Disable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_rspndr
Disable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_tcpip6
Disable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_server
Disable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_msclient

echo "Activando actualizaciones automáticas..."
reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions /t REG_DWORD /d 4 /f

echo "Desactivando reglas del Firewall..."
Netsh advfirewall firewall set rule group="Windows Remote Management" new enable=no
Netsh advfirewall firewall set rule group="Windows Management Instrumentation (WMI)" new enable=no

echo "Activando RDP..."
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
Netsh advfirewall firewall set rule group="remote desktop" new enable=yes

echo "Actualizando hora del servidor con NTP..."
tzutil /s "Argentina Standard Time"
net start w32time
netsh advfirewall firewall delete rule name="Allow OUT NTP"
netsh advfirewall firewall add rule name="Allow OUT NTP" dir=out remoteport="123" protocol=udp  action=allow
w32tm /resync
