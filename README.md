# VMware-Workstation-Automated-Cloner-Launcher
Automate VMware VM cloning and launching with a single PowerShell script – fast, safe, and reliable.


VMware Workstation Automated Cloner + Launcher
Project Overview
This project is a fully automated solution for cloning and launching virtual machines in VMware Workstation Pro on Windows. It reduces manual effort by:
•	Listing available VMs in a source folder
•	Letting the user select a VM and the number of clones
•	Copying VMs to a destination folder with unique names
•	Fixing VMX conflicts (UUID/MAC address)
•	Launching cloned VMs automatically in VMware Workstation
•	Logging each clone with timestamps
•	Showing a progress bar with estimated time remaining (ETA)
This tool is ideal for cybersecurity labs, testing environments, classrooms, or any scenario where multiple VM clones are needed quickly.
________________________________________
Features
•	Dynamic listing of VMs from the source folder
•	Multi-clone support with user-defined quantity
•	Skips .lck lock files to prevent copy errors
•	Fixes VMX conflicts (UUID, MAC, ethernet address) automatically
•	Real-time progress bar with ETA for each clone
•	Automatically launches cloned VMs in VMware Workstation
•	Detailed logging of all cloning operations
________________________________________
Prerequisites
•	Windows OS
•	VMware Workstation Pro installed
•	PowerShell 5.1+ (default on Windows 10/11)
•	Execution policy allowing script execution (temporary or permanent)
________________________________________
Installation
1.	Clone the repository or download the script:
git clone <your-repo-url>
cd vmware-cloner
2.	Verify VMware Workstation executable paths in the script (default paths included):
$VMwarePaths = @(
    "C:\Program Files (x86)\VMware\VMware Workstation\vmware.exe",
    "C:\Program Files\VMware\VMware Workstation\vmware.exe"
)
3.	Ensure your source VM folder exists, e.g.:
C:\Users\<username>\Documents\Virtual Machines
4.	Ensure destination folder exists, or let the script create it automatically, e.g.:
E:\clone_vm
________________________________________
Usage
1. Open PowerShell and set execution policy for the session:
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
2. Run the script:
.\clone_and_launch.ps1
3. Follow the prompts:
1.	Select the VM to clone from the list
2.	Enter the number of clones you want to create
The script will:
•	Clone the VM(s) safely (skipping .lck files)
•	Fix VMX conflicts
•	Show a progress bar with ETA
•	Launch all cloned VMs automatically in VMware Workstation
•	Log all operations in clone.log
________________________________________
Logging
•	All cloning operations are logged in clone.log inside the destination folder.
•	Example log entry: 2025-09-25 07:15:30 | Source VM: Ubuntu | Clone VM: Ubuntu_clone1
•	Logs help track cloning history for labs or testing environments.
________________________________________
License
MIT License
MIT License

Copyright (c) 2025 Ovishek Pal

Permission is hereby granted, free of charge, to any person obtaining a copy
________________________________________
Getting Started for Contributors
1.	Fork the repository
2.	Clone your fork
3.	Make modifications to clone_and_launch.ps1
4.	Test thoroughly
5.	Open a pull request

