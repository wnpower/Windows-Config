$ISVM = (Get-WmiObject -Class Win32_ComputerSystem).Model | Select-String -Pattern "KVM|Virtual" -Quiet

echo "Desactivando SMB V1..."
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force

echo "Desactivando NetBIOS..."
$key = "HKLM:SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces"
Get-ChildItem $key |
foreach { 
  Write-Host("Modify $key\$($_.pschildname)")
  $NetbiosOptions_Value = (Get-ItemProperty "$key\$($_.pschildname)").NetbiosOptions
  Write-Host("NetbiosOptions updated value is $NetbiosOptions_Value")
}

echo "Activado DEP para Servicios Windows Essentials unicamente..."
cmd.exe /C "bcdedit.exe /set {current} nx OptIn"

echo "Desactivando servicios de red innecesarios..."
Disable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_lldp 2> $null
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

echo "Activando ICMP de entrada..."
Netsh advfirewall firewall set rule name="File and Printer Sharing (Echo Request - ICMPv4-In)" new enable=yes

echo "Activando RDP..."
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
Netsh advfirewall firewall set rule group="remote desktop" new enable=yes

echo "Actualizando hora del servidor con NTP..."
tzutil /s "Argentina Standard Time"
net start w32time
netsh advfirewall firewall delete rule name="Allow OUT NTP"
netsh advfirewall firewall add rule name="Allow OUT NTP" dir=out remoteport="123" protocol=udp  action=allow
w32tm /resync

echo "Desactivando auto-inicio Server Manager..."
Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask -Verbose

echo "Desactivando expiración del usuario Administrator..."
WMIC USERACCOUNT SET PasswordExpires=FALSE

if ($ISVM) {
	echo "VM detectada, desactivando Antivirus..."
	Set-MpPreference -DisableRealtimeMonitoring $true
}

echo "Cambiando puerto RDP a 20389..."
netsh advfirewall firewall add rule name="RDP Puerto alternativo" dir=in localport="20389" protocol=tcp  action=allow
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Terminal*Server\WinStations\RDP-TCP\ -Name PortNumber -Value 20389

echo "¡Listo!"
