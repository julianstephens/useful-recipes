# WSL Backup

This script generates a compressed WSL backup with 7zip. Backups are stored locally in the configured directory and remotely via FTP. The script will automatically remove backups from the local backup directory if they are older than N (default: 90) days old.

[Original Script](https://gist.github.com/WillPresley/e662e07fa966de41de7e045b2bf05ff7)

Prerequisites:

- [7zip](https://7-zip.org/download.html)

## Usage

Ensure all variables are set in the 'Variables' section of `backup.ps1`

**Note**: If you are not using remote backups, comment out the 'Upload backup via FTP' section

```sh
.\backup.ps1
```

### Configure Scheduled Backups

1. Open Windows Task Scheduler (`Win+R` + 'taskschd.msc')
2. On the right hand side, select 'Create Task' from the 'Actions' menu
3. On the 'General' tab, give the task a name and ensure the options 'Run whether user is logged in or not' and 'Run with highest privileges' are selected.
4. On the 'Triggers' tab, click the 'New' button. Select 'On a schedule' from the 'Begin the task dropdown' and configure the desired schedule (recommended at least 1x/month). Click 'ok'.
5. On the 'Actions' tab, click the 'New' button. Select the 'Start a program' action. In the program/script box enter, `powershell.exe`. In the arguments box, enter `-File <drive>:\path\to\backup.ps1`. Click 'ok'.
6. On the 'Conditions' tab, the following options are recommended but not required: 'Stop if the computer ceases to be idle', 'Stop if the computer switches to battery power', 'Wake the computer to run this task', 'Start only if the following network connection is available': `Any connection`.
7. On the settings tab, select 'Allow task to be run on demand' and 'If the running task does not end when requested, force it to stop. Configure a max runtime using the 'Stop task if it runs longer than' option (recommended 4-6 hours).

Your backup script should now be schedule to run at the configured cadence. Backups can also be run off schedule by manually running the Windows task or running the powershell script explicitly. 
