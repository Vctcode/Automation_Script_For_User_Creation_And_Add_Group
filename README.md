# AUTOMATION SCRIPT FOR USER CREATION AND GROUP
This script is written to automate the process of user creation and add the user to specific groups. It simplifies the steps of manually getting the job done. This script is usefull in a typical day-to-day activity in an organization as a SysOps Engineer or similar roles.

[Follow Link to read the breakdown article](https://dev.to/vctcode/automating-user-creation-with-bash-script-1d75)

### SCRIPT REQUIREMENT
- Linux base terminal - Ubuntu preferrably
- `sudo` priviledges on the executor account
- a `.txt` file containing username and groupname in the format below.

```
# user1;group1,group2
light;sudo,www-data,dev
ade;support,engineering
```

### HOW TO RUN THE SCRIPT
- clone repo to your specified directory
- run `sudo chmod +x create_users.sh` to permit execution
- use `./create_users.sh <name_of_textfile>.txt` 
    - Make sure the textfile is in the same path as the script.