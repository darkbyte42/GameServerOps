# Threshold Keeper - (Server Memory Optimization Controller) 
This PowerShell script is designed to monitor and manage a game server's memory usage by automatically restarting the server and initiating a backup procedure if the memory usage exceeds a specified threshold. It loads configuration settings from a `config.json` file located in the same directory as the script. Here's a breakdown of the script's functionality:

**Load Configurations:** The script starts by reading a `config.json` file to load configurations such as the Remote Console (RCON) port, admin password, RCON address, backup batch file path, memory usage threshold, check interval, server process name, server executable path, and RCON commands.

**Initial Server Check:** It checks if the server process is running using the process name specified in the configuration. If the server is not running, the script starts the server using the configured executable path and launch parameters.

**Continuous Monitoring:** The script enters a continuous monitoring loop where it periodically checks the server's memory usage. This part of the script remains mostly unchanged, indicating that a function (not shown in the provided script) calculates the memory usage.

**Server Management Procedures:** If the memory usage exceeds the configured threshold, the script uses RCON commands to broadcast a warning message to the server, save the game, and then shut down the server. After shutting down the server, it waits for a specified time to ensure the server has fully stopped.

**Backup Procedure:** Once the server has stopped, the script attempts to run a backup procedure using a batch file specified in the configurations. It waits for a short period to allow the backup process to complete.

**Server Restart:** Finally, the script restarts the server using the configured executable path and launch parameters.

This script is useful for automated server management, ensuring that the game server remains responsive and is periodically backed up without manual intervention. The script is structured to be easily configurable through the `config.json` file, allowing for flexibility in deployment across different server setups.

The provided batch script is a backup utility designed to automatically back up game files from a specified game path to a designated backup location. The script is capable of handling custom configurations through a `backup-settings.conf` file, allows for dynamic naming of backup folders with date and time stamps, and compresses the backup into a ZIP file. Here's a step-by-step explanation of how it works:

**Environment Setup:** The script begins with `@echo off` to prevent the command line from showing the commands as they are executed, improving readability of the output. `setlocal` is used to ensure that variables defined in this script are local to the script.

**Configuration File Path:** Defines the path to the configuration file `backup-settings.conf`, which contains settings like game path, backup path, prefix, and suffix for backup names.

**Default Values:** Initializes variables for critical settings (`gamePath`, `backupPath`, `prefix`, `suffix`) with empty values. These serve as placeholders until they are populated from the configuration file.

**Load Settings from Configuration File:** Reads the `backup-settings.conf` file and sets the script variables (`gamePath`, `backupPath`, `prefix`, `suffix`) based on its content. It uses a `for` loop to parse each line that contains these settings.

**Verification of Critical Settings:** Checks if `gamePath` and `backupPath` have been set. If either is missing, it displays an error message and exits the script.

**Timestamp Creation:** Generates a timestamp using the current date and time, formatting it as `YYYY-MM-DD_HHMMSS`. This timestamp is used to create uniquely named backup folders.

**Backup Directory Preparation:** Checks if the specified backup path exists; if not, it creates the directory.

**Backup Folder Creation:** Assembles the name of the backup folder using the `prefix`, timestamp, and `suffix` variables, and then creates this folder within the backup path.

**File Copying:** Uses `xcopy` to copy all game files from the `gamePath` to the newly created backup folder, preserving the directory structure.

**Compression:** Employs a PowerShell command to compress the backup folder into a ZIP file. It uses the .NET `System.IO.Compression.FileSystem` class for creating the ZIP file, showcasing an example of integrating PowerShell within a batch script for advanced functionality.

**Completion Message:** Displays a message indicating that the backup was successfully created, along with the path to the ZIP file.

**Script End:** Marks the end of the script and restores the global environment settings with `endlocal`.

---
**Modified MIT License**

This repository contains scripts and configuration files (referred to as the "Materials") available under the MIT License:

**Permission:** You're granted permission, free of charge, to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Materials. You can also permit others to do the same, provided that they follow these conditions:

**Conditions:**

- Include the copyright notice and permission notice in all copies or substantial portions of the Materials.
- You cannot use the Materials for commercial purposes without explicit permission from Isaac Keller (Darkbyte).
- Any derivative works must be licensed under the same terms as this license and must give prominent attribution to the original author, Isaac Keller (Darkbyte).
- For commercial use or other permissions, please contact Isaac Keller at isaackeller90@gmail.com with the subject line "Requesting License Permission".

**Disclaimer:** The Materials are provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and noninfringement. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the Materials or the use or other dealings in the Materials.
