# Параметры 
$LogFile = "C:\Logs\NetworkDiag.log"
$TestHosts = @("8.8.8.8", "google.com", "your-dns-server")  # Хосты для теста ping
$TraceHost = "google.com"  # Хост для трассировки маршрута

# Функция для записи в лог
function Write-Log {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "${Timestamp}: $Message" | Out-File -FilePath $LogFile -Append
}

# Проверка существования папки для лога
$logFolder = Split-Path $LogFile
if (-not (Test-Path $logFolder)) {
    New-Item -Path $logFolder -ItemType Directory -Force | Out-Null
}

# Получение сетевых адаптеров
$Report = "Network Diagnostics Report`n"
$Report += "=================================`n"
$Report += "Report Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n`n"  # Добавлена метка времени
$Adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }

$Report += "Network Adapters:`n"
foreach ($Adapter in $Adapters) {
    $IPConfig = Get-NetIPConfiguration -InterfaceAlias $Adapter.Name
    $Report += "  - Adapter: $($Adapter.Name) (Status: $($Adapter.Status))`n"
    $Report += "    IP Address: $($IPConfig.IPv4Address.IPAddress)`n"
    $Report += "    Gateway: $($IPConfig.IPv4DefaultGateway.NextHop)`n"
    $Report += "    DNS Servers: $($IPConfig.DNSServer.ServerAddresses -join ', ')`n`n"
}

# Тесты ping
$Report += "Ping Tests:`n"
$Report += "-----------`n"
foreach ($TestHost in $TestHosts) {
    $PingResult = Test-Connection -ComputerName $TestHost -Count 2 -Quiet
    if ($PingResult) {
        $Report += "   Ping to $TestHost successful`n"
    } else {
        $Report += "   Ping to $TestHost failed`n"
    }
}
$Report += "`n"

# Трассировка маршрута (вывод в колонках с отступами)
$Report += "Traceroute to ${TraceHost}:`n"
$Report += "-----------------------`n"
$TraceResult = tracert $TraceHost 2>$null  # Получение вывода tracert в виде массива
foreach ($line in $TraceResult) {
    $Report += "  $line`n"  # Добавление отступа для каждой строки
}
$Report += "`n"

# Запись отчёта в лог
Write-Log $Report

# Вывод отчёта в консоль
Write-Host $Report
