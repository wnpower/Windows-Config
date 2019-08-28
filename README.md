## Configuración recomendada Windows

Este script configura Windows según nuestras buenas prácticas:

-   Desactiva SMB v1
-   Desactiva NetBIOS
-   Desactiva servicios de red innecesarios (compartir archivos, búsqueda de dispositivos, etc)
-   Activa las actualizaciones automáticas de Windows
-   Deactiva reglas de Firewall de acceso remoto (WinRM)
-   Activa RDP y cambia puerto al 20389 (requiere reinicio)
-   Activa NTP y sincroniza la hora del servidor

## Instalación (desde PowerShell)

    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
	$Url = "https://raw.githubusercontent.com/wnpower/Windows-Config/master/configure_windows.ps1"
	$Output = "C:\configure_windows.ps1"
	$WebClient = New-Object System.Net.WebClient
	$WebClient.DownloadFile( $url , $Output)
	Invoke-Expression $Output

Al finalizar reiniciar servidor para aplicar los cambios de RDP
