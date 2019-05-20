Start-Transcript deuces-script-$(get-date -f yyyy-MM-dd--hhmm).log | out-null
Write-Host "Welcome to Deuces Flashing Script!"
Write-Host "v5.0-Windows"
Write-Host "Checking if ADB/Fastboot exes are in PATH or script directory"


if (Get-ChildItem fastboot.exe 2>$null) {
    $fb = ".\fastboot.exe"
  } else {
    $fb = "fastboot.exe"
  }
if (Get-ChildItem adb.exe 2>$null) {
    $adb = ".\adb.exe"
  } else {
    $adb = "adb.exe"
  }


Write-Host "Checking if ADB/Fastboot work correctly"
$error.clear()
try { (Invoke-Expression "$adb --version") }
catch { Write-Host -ForegroundColor Red "Error! ADB not accessible!"; pause; exit 1 }
if (!$error) {
Write-Host -ForegroundColor Green "ADB Detected!"
}
$error.clear()
try { (Invoke-Expression "$fb --version") }
catch { Write-Host -ForegroundColor Red "Error! Fastboot not accessible!"; pause; exit 1 }
if (!$error) {
Write-Host -ForegroundColor Green "Fastboot Detected!"
}


Write-Host "Checking if device is attached via ADB."
$adbdv = (Invoke-Expression "$adb devices -l")
if ( $adbdv -Like '*transport_id*') { Write-Host "ADB device attached!" }
else { Write-Host -ForegroundColor Red "Error: Device not detected via ADB."; Write-Host "If device is already in Bootloader mode, continue."; Write-Host -ForegroundColor Yellow "If not, check device cables / drivers and continue to checking device trust..."; Pause }


Write-Host "Checking if computer is trusted by device via ADB."
if ( $adbdv -like '*unauthorized*') { Write-Host -ForegroundColor Red "Device Detected, but does not trust computer. Verify you have allowed ADB on the device."; Pause; Exit 1 }
elseif ( $adbdv -like '*device product*') { Write-Host -ForegroundColor Green "Device Trusts PC and is ready to continue..."; Write-Host "Rebooting to bootloader..."; (Invoke-Expression "$adb reboot-bootloader"); Start-Sleep 7 }



Write-Host "Checking if device is detected via Fastboot."
$fbdv = (Invoke-Expression "$fb devices -l")
if ($fbdv -like '*fastboot*') { Write-Host -ForegroundColor Green "Device Detected in Fastboot!" }
else {Write-Host -ForegroundColor Red "Error: Device not detected via Fastboot."; Write-Host -ForegroundColor Red "Check device cables and fastboot drivers..."; pause; Exit 1 }


$zipname = (Get-ChildItem *.zip).fullname
if ($zipname.Count -gt 1 )
    { Write-Host "Error: More than 1 zip file."; Write-Host "Place only 1 zip file with the script folder..."; Pause; exit 1 }
elseif ($zipname.Count -eq 0)
    { Write-Host "Error: No zip files detected."; Write-Host "Place zip file with script folder..."; Pause; exit 1 }
elseif ($zipname.Count -eq 1)
    { 
            Write-Host -ForegroundColor Black -BackgroundColor White "Are you SURE you want to continue?"
            Pause
            Write-Host -ForegroundColor Yellow -BackgroundColor Black "This tool will reformat most partitions in your device!"
            Write-Host -ForegroundColor Yellow -BackgroundColor Black "It will attempt to keep your user data!"
            Write-Host -ForegroundColor Black -BackgroundColor Yellow "Data could be lost! - Use At Your Own Risk!"
            Write-Host -nonewline "Continue? (y/N) "
            $resp1 = read-host
            if ( $resp1 -ne "Y" ) { Write-Host Tool Cancelled!; pause; exit 1 }
        if ( $resp1 -eq "Y" ) {
            Write-Host "Checking if bootloader is unlocked."
            Write-Host "Look at device to confirm if script is waiting..."
            Invoke-Expression "$fb flashing unlock" 2>$null
            Write-Host "Preparing files for flash..."
            $global:ProgressPreference = 'SilentlyContinue'
            Remove-Item _work -Recurse -Force -ErrorAction SilentlyContinue
            mkdir -p _work > $null
            Write-Host "Extracting $zipname..."
            Expand-Archive -Path $zipname -DestinationPath _work/ -Force
            $sysimgfiles = Get-ChildItem _work/*/*.img
            foreach ($sysimgfile in $sysimgfiles) {
                $imgslot = ($sysimgfile).name
                $slot = $imgslot.Substring(0, $imgslot.IndexOf('-'))
                $sysimgfilelong = ($sysimgfile).fullname
                Invoke-Expression "$fb flash $slot $sysimgfilelong"
                Remove-Item $sysimgfile -Force
            }
            Invoke-Expression "$fb reboot-bootloader"
        
    $imgzipname = (Get-ChildItem _work/*/*.zip).fullname
    Write-Host "Extracting $imgzipname."
    Expand-Archive -Path $imgzipname -DestinationPath _work/*/ -Force
    Write-Host "Flashing B-Slot items first."
    $otherimgs = (Get-ChildItem _work/*/*other.img)
        foreach ( $otherimg in $otherimgs ) {
            $imgslot = ($otherimg).name
            $slot = $imgslot.Substring(0, $imgslot.IndexOf('_'))
            $b = "_b"
            Invoke-Expression "$fb flash $slot$b $otherimg"
            remove-item $otherimg
            }
            remove-item _work/*/system_other.img -Force
        $imgfiles = Get-ChildItem _work/*/*.img
    foreach ($imgfile in $imgfiles) {
        $imgslot = ($imgfile).name
        $slot = $imgslot.Substring(0, $imgslot.IndexOf('.'))
        $imgfilelong = ($imgfile).fullname
        Invoke-Expression "$fb flash $slot $imgfilelong"
        Remove-Item $imgfile -Force
            }
            Remove-Item $imgzipname -Force
            Remove-Item _work -Recurse -Force -ErrorAction SilentlyContinue

        } }
Write-Host -nonewline -BackgroundColor Yellow -ForegroundColor Black "Format UserData? (y/N) "
$resp2 = read-host
if ( $resp2 -ne "Y" ) { Write-Host "Done!"; pause; exit }
if ( $resp2 -eq "Y" ) { Write-Host -nonewline -BackgroundColor Yellow -ForegroundColor Black "Are you Sure?! (y/N) "; $resp3 = read-host; if ($resp3 -eq "Y") { Invoke-Expression "$fb format userdata" 2>$null; Invoke-Expression "$fb reboot-recovery 2>$null"; Write-Host "Done!"; pause; exit } }
            
Write-Host "Done!"
Pause
exit