import os
import sys
import re
from datetime import datetime

def find_cheaters_in_files(folder_path):
    # Create a list to hold files and their creation times
    cheater_lines = []

    # Compile a regex to match the desired strings
    regex = re.compile(r'\bis a cheat\b|(?<!\w)cheater(?!\w)')

    # Walk through the folder
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            # Check if the file is a text file
            if file.endswith('.txt'):
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        for line in f:
                            if regex.search(line):
                                # Get file modification time
                                mod_time = os.path.getmtime(file_path)
                                cheater_lines.append((mod_time, line.strip(), file))
                except Exception as e:
                    print(f"Error reading {file_path}: {e}")

    # Sort the list by the file modification time
    cheater_lines.sort()

    # Print the results
    for mod_time, line, file in cheater_lines:
        print(f"{datetime.fromtimestamp(mod_time)} - {file}: {line}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Please drag a folder onto the script or pass the folder path as an argument.")
    else:
        folder_path = sys.argv[1]
        find_cheaters_in_files(folder_path)
        input("Press Enter to exit...")
