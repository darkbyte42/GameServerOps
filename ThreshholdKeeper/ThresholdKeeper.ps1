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

# Continuous monitoring loop remains mostly unchanged

while ($true) {
    $MemoryUsage = Calculate-MemoryUsage
    if ($MemoryUsage -gt $THRESHOLD) {
        Write-Host "Memory usage is above $THRESHOLD%. Initiating server management procedures."
        & $arrconExecutablePath -a $RCON_ADDRESS -P $RCON_PORT -p $ADMIN_PASSWORD -c "$($arrconCommands.BROADCAST) Memory_Is_Above_$THRESHOLD%"
        & $arrconExecutablePath -a $RCON_ADDRESS -P $RCON_PORT -p $ADMIN_PASSWORD -c "$($arrconCommands.SAVE)"
        & $arrconExecutablePath -a $RCON_ADDRESS -P $RCON_PORT -p $ADMIN_PASSWORD -c "$($arrconCommands.SHUTDOWN) Reboot_In_60_Seconds"
# Wait for the server to shut down
Start-Sleep -Seconds 120

# Check if the server process is no longer running
$serverRunning = Get-Process $serverProcessName -ErrorAction SilentlyContinue
if (-not $serverRunning) {
    Write-Host "Server process is not running. Proceeding with backup..."
# Execute the backup .bat file
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c $backupBatPath" -NoNewWindow -Wait
    
 # Wait for 10 seconds to allow the backup process to complete
    Start-Sleep -Seconds 10
} else {
    Write-Host "Server process is still running. Backup will not proceed."
}

Write-Host "Relaunching the game server..."
& $serverExecutablePath $serverLaunchParameters

# Script end