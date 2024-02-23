
# Log String Search
This utility script allows users to search through text files within a specified folder for a particular string. It's designed to be user-friendly, allowing non-technical users to easily find specific terms, such as references to cheating in log files.

## Installation
To use this script, you will need Python installed on your computer. If you do not have Python installed, you can download and install it from [python.org](https://www.python.org/). 

1.  **Download Python**: Go to [python.org](https://www.python.org/), download the latest version of Python, and install it on your PC.

2.  **Download the Script**: Download the `log_reader.py` and `Drag_Log_Folder_Here.bat` to your computer. You can place it in any folder you prefer. 

3.  **Prepare Your Logs**: Ensure your log files are in a text format (`.txt`) and gathered in a single folder that the script can access.

## Usage  

1.  **Open Command Prompt**: Open the Command Prompt (CMD) on Windows or Terminal on macOS/Linux.  

2.  **Navigate to the Script**: Use the `cd` command to navigate to the folder containing the `log_reader.py` script. For example:

cd path\to\your\script\folder  

3.  **Run the Script**: Drag the folder containing your log files onto `Drag_Log_Folder_Here.bat`, or if you're comfortable using the command line, type the following command and press Enter:

python search_logs.py "path\to\your\log\folder"  

Replace `"path\to\your\log\folder"` with the actual path to your log folder.  

4.  **Enter Search Term**: When prompted, enter the string you want to search for within the log files. The script will search all text files in the specified folder for this term.  

5.  **Review Results**: The script will output the results directly in the Command Prompt or Terminal window, showing the date, file name, and content of each line that matches your search term.  

6.  **Repeat or Exit**: After a search is completed, you can perform another search by entering a new term when prompted. To exit, type `exit` and press Enter.  

## Features
-  **Flexible Search**: Allows searching for any string you specify.
-  **User-Friendly**: Designed for non-technical users to easily operate.
-  **Efficient**: Quickly scans through large numbers of files to find matches.  

For any issues or suggestions, feel free to contact `.darkybyte` on discord or submit an issue on the repository (if applicable).