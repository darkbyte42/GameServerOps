# Assuming the config.json is in the same directory as the script
$configPath = Join-Path (Get-Location) "config.json"
$config = Get-Content $configPath | ConvertFrom-Json

# Use the loaded configurations
$RCON_PORT = $config.RCON_PORT
$ADMIN_PASSWORD = $config.ADMIN_PASSWORD
$RCON_ADDRESS = $config.RCON_ADDRESS
$backupBatPath = $config.BACKUP_BAT_PATH
$THRESHOLD = $config.THRESHOLD
$CHECK_INTERVAL_SECONDS = $config.CHECK_INTERVAL_SECONDS
$DURATION_THRESHOLD_SECONDS = $config.DURATION_THRESHOLD_SECONDS # Load duration threshold
$serverProcessName = $config.SERVER_PROCESS_NAME
$serverExecutablePath = $config.SERVER_EXECUTABLE_PATH
$serverLaunchParameters = $config.SERVER_LAUNCH_PARAMETERS
$arrconExecutablePath = $config.ARRCON_EXECUTABLE_PATH
$arrconCommands = $config.ARRCON_COMMANDS

# Initialize a variable to track the duration for which the memory usage is above the threshold
$aboveThresholdDuration = 0

# Flag to control server restart attempts
$shouldRestartServer = $true

function Get-ServerMemoryUsage {
    $process = Get-Process -Name $serverProcessName -ErrorAction SilentlyContinue
    if ($process) {
        $processMem = ($process | Measure-Object WorkingSet64 -Sum).Sum
        $totalMem = Get-ComputerInfo | Select-Object -ExpandProperty CsTotalPhysicalMemory
        $percentUsed = ($processMem / $totalMem) * 100
        return $percentUsed
    } else {
        Write-Host "Server process not found."
        return $null
    }
}

# Continuous monitoring loop with duration check
while ($true) {
    $MemoryUsage = Get-ServerMemoryUsage
    Write-Host "Current memory usage: $MemoryUsage%"

    if ($MemoryUsage -gt $THRESHOLD) {
        $aboveThresholdDuration += $CHECK_INTERVAL_SECONDS
        Write-Host "Memory usage above threshold for $aboveThresholdDuration seconds."
        
        if ($aboveThresholdDuration -ge $DURATION_THRESHOLD_SECONDS) {
            Write-Host "Memory usage is above $THRESHOLD%. Initiating server management procedures."
            & $arrconExecutablePath -a $RCON_ADDRESS -P $RCON_PORT -p $ADMIN_PASSWORD -c "$($arrconCommands.BROADCAST) Rebooting_server_in_20mins!" # Memory_Is_Above_$THRESHOLD%
            & $arrconExecutablePath -a $RCON_ADDRESS -P $RCON_PORT -p $ADMIN_PASSWORD -c "$($arrconCommands.SAVE)"
            Start-Sleep -Seconds 2
            & $arrconExecutablePath -a $RCON_ADDRESS -P $RCON_PORT -p $ADMIN_PASSWORD -c "$($arrconCommands.BROADCAST) Rebooting_in_15mins!"
            Start-Sleep -Seconds 300  # 5 minutes
            & $arrconExecutablePath -a $RCON_ADDRESS -P $RCON_PORT -p $ADMIN_PASSWORD -c "$($arrconCommands.BROADCAST) Rebooting_in_10mins!"
            Start-Sleep -Seconds 300  # 5 minutes
            & $arrconExecutablePath -a $RCON_ADDRESS -P $RCON_PORT -p $ADMIN_PASSWORD -c "$($arrconCommands.BROADCAST) Rebooting_in_5mins!"
            Start-Sleep -Seconds 120  # 2 minutes
            & $arrconExecutablePath -a $RCON_ADDRESS -P $RCON_PORT -p $ADMIN_PASSWORD -c "$($arrconCommands.BROADCAST) Rebooting_in_3mins!"
            Start-Sleep -Seconds 60   # 1 minute
            & $arrconExecutablePath -a $RCON_ADDRESS -P $RCON_PORT -p $ADMIN_PASSWORD -c "$($arrconCommands.BROADCAST) Rebooting_in_2mins!"
            Start-Sleep -Seconds 60   # 1 minute
            & $arrconExecutablePath -a $RCON_ADDRESS -P $RCON_PORT -p $ADMIN_PASSWORD -c "$($arrconCommands.BROADCAST) Rebooting_in_1min!"
            Start-Sleep -Seconds 2    # 2 seconds
            & $arrconExecutablePath -a $RCON_ADDRESS -P $RCON_PORT -p $ADMIN_PASSWORD -c "$($arrconCommands.SAVE)"
            Start-Sleep -Seconds 18
            & $arrconExecutablePath -a $RCON_ADDRESS -P $RCON_PORT -p $ADMIN_PASSWORD -c "$($arrconCommands.SHUTDOWN)"

            Start-Sleep -Seconds 120 # Wait for the server to fully shut down
$shouldRestartServer = $true
            $serverRunning = Get-Process -Name $serverProcessName -ErrorAction SilentlyContinue
            if (-not $serverRunning) {
                Write-Host "Server is down. Starting backup process..."
                Start-Process -FilePath "cmd.exe" -ArgumentList "/c $backupBatPath" -NoNewWindow -Wait
                Write-Host "Backup completed. Preparing to restart the server."
                $shouldRestartServer = $true
            } else {
                Write-Host "Server shutdown check failed. Manual intervention may be required."
            }

            $aboveThresholdDuration = 0 # Reset the duration counter after actions are taken
            $shouldRestartServer = $true
        }
    } else {
        if ($aboveThresholdDuration -gt 0) {
            Write-Host "Memory usage returned below threshold. Resetting duration counter."
        }
        $aboveThresholdDuration = 0
    }

    # Check and manage server process restart
    if ($shouldRestartServer) {
        $serverRunning = Get-Process -Name $serverProcessName -ErrorAction SilentlyContinue
        if (-not $serverRunning) {
            Write-Host "Server not running. Attempting to start..."
            & $serverExecutablePath $serverLaunchParameters
            $shouldRestartServer = $false # Prevent further restart attempts until explicitly allowed
            Start-Sleep -Seconds 30 # Allow time for server to start
        } else {
            Write-Host "Server is currently running."
        }
    }

    Start-Sleep -Seconds $CHECK_INTERVAL_SECONDS
}