$zipname = (Get-ChildItem *.zip).fullname
if ($zipname.Count -gt 1 )
    { Write-Host "Error: More than 1 zip file."; Write-Host "Place only 1 zip file with the script folder..."; Pause }
elseif ($zipname.Count -eq 0)
    { Write-Host "Error: No zip files detected."; Write-Host "Place zip file with script folder..."; Pause }
elseif ($zipname.Count -eq 1)
    { 
    Write-Host "Welcome to Deuces Flashing Script"
    Write-Host "Detecting and flashing automagically!"
    Write-Host "Extracting $zipname for flashing..."
    $global:ProgressPreference = 'SilentlyContinue'
    Remove-Item _work -Recurse -Force -ErrorAction SilentlyContinue
    mkdir -p _work | Out-Null
    Write-Host "Extracting $zipname..."
    Expand-Archive -Path $zipname -DestinationPath _work/ -Force
    $sysimgfiles = (Get-ChildItem _work/*/*.img).fullname
    foreach ($sysimgfile in $sysimgfiles) {
        Write-Host "fastboot flash $sysimgfile"
        Remove-Item $sysimgfile -Force
    }
    
    $imgzipname = (Get-ChildItem _work/*/*.zip).fullname
    Write-Host "Extracting $imgzipname..."
    Expand-Archive -Path $imgzipname -DestinationPath _work/*/ -Force
    $imgfiles = (Get-ChildItem _work/*/*.img).fullname
    foreach ($imgfile in $imgfiles) {
        Write-Host "fastboot flash $imgfile"
    }
    }
Write-Host "Done!"
Pause
