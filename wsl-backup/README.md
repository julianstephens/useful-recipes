# WSL Backup

This script generates a compressed WSL backup with 7zip. Backups are stored locally in the configured directory and remotely via FTP. The script will automatically remove backups from the local backup directory if they are older than N (default: 90) days old.

[Original Script](https://gist.github.com/WillPresley/e662e07fa966de41de7e045b2bf05ff7)

Prerequisites:

- [7zip](https://7-zip.org/download.html)

## Usage

Ensure all variables are set in the 'Variables' section of `backup.ps1`

**Note**: If you are not using FTP for remote backups, comment out the 'Upload backup via FTP' section

```sh
.\backup.ps1
```
