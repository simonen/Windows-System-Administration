1. Generate a key pair on the client machine
2. Copy the public key to the server machine
3. Create a folder .ssh in $env:USERPROFILE and put the contents of the public key in authorized_keys file
4. Execute icacls authorized_keys" /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F"
5. In C:\ProgramData\ssh create a file administrators_authorized_keys and put the contents of the public key there.
6. Execute icacls administrators_authorized_keys" /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F"
7. In C:\ProgramData\ssh\sshd_config uncomment PublicKeyAuthentication and change it to yes. Uncomment StrictModes and change to no
8. Make powershell default shell for ssh sessions:
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
9. Add Subsystem powershell c:/progra~1/powershell/7/pwsh.exe -sshs -NoLogo to the c:\programdata\ssh\sshd_config file and restart the sshd service.
10. Example command: New-PSSession -Hostname 192.168.99.105 -Username administrator
11. Example command: Invoke-Command -Hostname 192.168.99.105 -Username administrator -Scriptblock {Get-Date}
12. Powershell must be installed on linux for PS remoting to work from a windows machine.
13. Add ansible_shell_type=powershell variable in the inventory file.