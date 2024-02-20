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

$serverProcessName = $config.SERVER_PROCESS_NAME
$serverExecutablePath = $config.SERVER_EXECUTABLE_PATH
$serverLaunchParameters = $config.SERVER_LAUNCH_PARAMETERS
$arrconExecutablePath = $config.ARRCON_EXECUTABLE_PATH
$arrconCommands = $config.ARRCON_COMMANDS

# Function to calculate memory usage remains unchanged

# Initial server check and start if not running
$serverRunning = Get-Process $serverProcessName -ErrorAction SilentlyContinue
if (-not $serverRunning) {
    Write-Host "Server is not running. Starting server..."
    & $serverExecutablePath $serverLaunchParameters
    Start-Sleep -Seconds 30  # Wait a bit for the server to fully start up
}
function Calculate-MemoryUsage {
    # Your logic here
    # This is just an example; adjust the logic according to your needs
    $totalMem = Get-ComputerInfo | Select-Object -ExpandProperty CsTotalPhysicalMemory
    $freeMem = Get-ComputerInfo | Select-Object -ExpandProperty OsFreePhysicalMemory
    $usedMem = $totalMem - $freeMem
    $percentUsed = ($usedMem / $totalMem) * 100
    return $percentUsed
}
# Continuous monitoring loop
while ($true) {
    $MemoryUsage = Calculate-MemoryUsage
    if ($MemoryUsage -gt $THRESHOLD) {
        Write-Host "Memory usage is above $THRESHOLD%. Initiating server management procedures."
        & $arrconExecutablePath -a $RCON_ADDRESS -P $RCON_PORT -p $ADMIN_PASSWORD -c "$($arrconCommands.BROADCAST) Rebooting_for_performance!" # Memory_Is_Above_$THRESHOLD%
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
        Start-Sleep -Seconds 60
        & $arrconExecutablePath -a $RCON_ADDRESS -P $RCON_PORT -p $ADMIN_PASSWORD -c "$($arrconCommands.BROADCAST) Rebooting_in_1min!"
	Start-Sleep -Seconds 2
	& $arrconExecutablePath -a $RCON_ADDRESS -P $RCON_PORT -p $ADMIN_PASSWORD -c "$($arrconCommands.SAVE)"
        Start-Sleep -Seconds 28
        & $arrconExecutablePath -a $RCON_ADDRESS -P $RCON_PORT -p $ADMIN_PASSWORD -c "$($arrconCommands.SHUTDOWN)"
        Start-Sleep -Seconds 120  # Wait for the server to shut down

        $serverRunning = Get-Process -Name $serverProcessName -ErrorAction SilentlyContinue
        if (-not $serverRunning) {
            Write-Host "Server process is not running. Proceeding with backup..."
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c $backupBatPath" -NoNewWindow -Wait
            Start-Sleep -Seconds 10  # Wait for the backup process to complete
        } else {
            Write-Host "Server process is still running. Backup will not proceed."
        }

        Write-Host "Relaunching the game server..."
        & $serverExecutablePath $serverLaunchParameters
    } # Closing brace for the if statement

    Start-Sleep -Seconds $CHECK_INTERVAL_SECONDS  # Wait before checking again
} # Closing brace for the while loop
# Script ends