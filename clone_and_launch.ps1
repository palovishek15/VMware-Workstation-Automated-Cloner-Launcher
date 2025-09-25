<#
.SYNOPSIS
    Fully automated VM cloning + auto-launch for VMware Workstation Pro on Windows.
.DESCRIPTION
    - Lists available VMs in source folder
    - Lets user select VM and number of clones
    - Copies VM to destination folder with unique names (skips .lck)
    - Fixes VMX conflicts (UUID/MAC)
    - Logs each clone
    - Automatically opens each cloned VM in VMware Workstation
    - Shows a progress bar for file copying
#>

# ---------------- Configuration ----------------
$SourcePath = "C:\Users\palov\Documents\Virtual Machines"
$DestinationPath = "E:\clone_vm"
$LogFile = "$DestinationPath\clone.log"

# Detect VMware Workstation executable
$VMwarePaths = @(
    "C:\Program Files (x86)\VMware\VMware Workstation\vmware.exe",
    "C:\Program Files\VMware\VMware Workstation\vmware.exe"
)
$VMwarePath = $VMwarePaths | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $VMwarePath) {
    Write-Host "VMware Workstation executable not found. Please install Workstation."
    exit
}

# Ensure destination folder exists
if (-not (Test-Path $DestinationPath)) {
    New-Item -Path $DestinationPath -ItemType Directory | Out-Null
}

# ---------------- List Available VMs ----------------
$VMs = Get-ChildItem -Path $SourcePath -Directory | Where-Object {
    Test-Path (Join-Path $_.FullName "*.vmx")
}

if ($VMs.Count -eq 0) {
    Write-Host "No VMs found in $SourcePath"
    exit
}

Write-Host "Available Virtual Machines:"
for ($i=0; $i -lt $VMs.Count; $i++) {
    Write-Host " [$($i+1)] $($VMs[$i].Name)"
}

# ---------------- User selects VM ----------------
$choice = Read-Host "Enter the number of the VM to clone"
if (-not ($choice -as [int]) -or $choice -lt 1 -or $choice -gt $VMs.Count) {
    Write-Host "Invalid choice"
    exit
}
$VMName = $VMs[$choice - 1].Name
$SourceVMFolder = Join-Path $SourcePath $VMName

# ---------------- Ask how many clones ----------------
$NumClones = Read-Host "Enter how many clones you want to create"
if (-not ($NumClones -as [int]) -or $NumClones -lt 1) {
    Write-Host "Invalid number of clones"
    exit
}

# ---------------- Start cloning ----------------
$ClonedVMXFiles = @()
for ($c=1; $c -le $NumClones; $c++) {

    # Generate unique clone folder
    $CloneIndex = 1
    do {
        $CloneName = "$VMName`_clone$CloneIndex"
        $DestinationVMFolder = Join-Path $DestinationPath $CloneName
        $CloneIndex++
    } while (Test-Path $DestinationVMFolder)

    Write-Host "Cloning $VMName to $CloneName ..."

    # ---------------- Copy files excluding .lck with progress & ETA ----------------
    $AllItems = Get-ChildItem -Path $SourceVMFolder -Recurse -Force | Where-Object { $_.Extension -ne ".lck" }
    $TotalItems = $AllItems.Count
    $Counter = 0
    $StartTime = Get-Date

    foreach ($item in $AllItems) {
        $Counter++
        $Elapsed = (Get-Date) - $StartTime
        $AvgTimePerItem = $Elapsed.TotalSeconds / $Counter
        $RemainingItems = $TotalItems - $Counter
        $ETA = [TimeSpan]::FromSeconds($AvgTimePerItem * $RemainingItems)
        $percent = [math]::Round(($Counter / $TotalItems) * 100, 0)

        Write-Progress -Activity "Cloning $VMName to $CloneName" `
                    -Status "$Counter of $TotalItems items, ETA: $($ETA.ToString("hh\:mm\:ss"))" `
                    -PercentComplete $percent

        $sourcePath = $item.FullName
        $relativePath = $sourcePath.Substring($SourceVMFolder.Length)
        $destPath = Join-Path $DestinationVMFolder $relativePath.TrimStart('\')

        # Create destination folder if needed
        $destDir = Split-Path $destPath
        if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir | Out-Null }

        if ($item.PSIsContainer) {
            if (-not (Test-Path $destPath)) { New-Item -ItemType Directory -Path $destPath | Out-Null }
        } else {
            Copy-Item $sourcePath -Destination $destPath -Force
        }
    }

    # Clear progress bar
    Write-Progress -Activity "Cloning $VMName to $CloneName" -Completed


    # ---------------- Fix VMX conflicts ----------------
    $VMXFile = Get-ChildItem -Path $DestinationVMFolder -Filter *.vmx | Select-Object -First 1
    if (-not $VMXFile) {
        Write-Host "No VMX file found in clone $CloneName"
        continue
    }

    Write-Host "Fixing VMX conflicts ..."
    (Get-Content $VMXFile.FullName) |
        ForEach-Object {
            $_ -replace "^uuid.location.*","" `
               -replace "^uuid.bios.*","" `
               -replace "^ethernet0.generatedAddress.*","" `
               -replace "^uuid.action.*",""
        } | Set-Content $VMXFile.FullName
    Add-Content $VMXFile.FullName "uuid.action = `"create`""

    # ---------------- Logging ----------------
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "$Timestamp | Source VM: $VMName | Clone VM: $CloneName"
    Add-Content -Path $LogFile -Value $LogEntry

    Write-Host "Clone $c completed: $CloneName"

    # Store VMX path for launching
    $ClonedVMXFiles += $VMXFile.FullName
}

# ---------------- Launch all cloned VMs ----------------
Write-Host "`nLaunching cloned VMs in VMware Workstation..."
foreach ($vmx in $ClonedVMXFiles) {
    Start-Process -FilePath $VMwarePath -ArgumentList "`"$vmx`""
    Start-Sleep -Seconds 2  # small delay to prevent overload
}

Write-Host "`nAll clones created and launched. Log saved to $LogFile"
