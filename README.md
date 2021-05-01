# Download_Organizer_OSX
Bash script that automatically organize the files inside a folder

How to use:
1) Go to: System Preferences -> Security & Privacy - > select the “Privacy” tab, then from the left-side menu select “Full Disk Access” and add the terminal app

2) Download the .bash script from this repository and put it in a folder inside Documents (eg. /Users/USER_NAME/Documents/automation/ )

3) Open automator, select - > Folder action, 
   - In the choose folder button select the desired folder to keep organized
   - from the drop down menu choose -> "Run shell script" 
   - in the text box write (use your real PATH:   
          
          cd /Users/USER_NAME/Downloads/ && /Users/USER_NAME/Documents/automation/organizer.bash "$1"
          
     if you want a delay before running the script:
          
          cd /Users/riccardomontaguti/Downloads/ && sleep 15 && /Users/riccardomontaguti/Documents/automation/organizer.bash "$1"
   
   - save the automator script.
   
4) Now every time a file is added to the chosen folder the file will be moved inside a folder with its extention name.
