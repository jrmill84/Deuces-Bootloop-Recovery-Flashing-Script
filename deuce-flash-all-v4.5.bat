@ECHO OFF
cls
echo Deuces-flash-all-script-V4.5-Windows
echo for Taimen or Walleye - Google Pixel 2 / XL
echo USE AT YOUR OWN RISK
pause
PATH=%PATH%;"%SYSTEMROOT%\System32"
echo Make Sure your Device is in Fastboot Mode
echo (Power off, hold Volume-Down, hold Power)
echo Once you are in fastboot,
pause

@echo off
:chooseunlock
set /P c= Unlock Bootloader[Y/N]?
if /I "%c%" EQU "Y" goto :yesunlock
if /I "%c%" EQU "N" goto :nounlock
goto :chooseformat
:yesunlock
echo Running Unlock
echo Look at your device,
echo press up arrow and Power to confirm
fastboot flashing unlock
echo This will say "failed" if already unlocked - ignore
ping -n 5 127.0.0.1 >nul
echo Running Unlock_critical
echo Look at your device,
echo press up arrow and Power to confirm
fastboot flashing unlock_critical
echo This will say "failed" if already unlocked - ignore
ping -n 5 127.0.0.1 >nul
:nounlock
:: Setting Active Slot A and Flashing Bootloaders
:: finding and flashing bootloader and radio
@echo off
echo Locating Bootloader and Radio Filenames
echo Flashing...
echo it is safe to ignore errors about active partition - there are multiple entries to support multiple versions of platform tools
dir /B /X bootloader* > blname.txt
dir /B /X radio* > radname.txt
set blimg_name=blname.txt
set radimg_name=radname.txt
fastboot --set-active=_a
fastboot --set-active=a
for /f "tokens=*" %%i in (%blimg_name%) DO (
	fastboot flash bootloader "%%i"
)
fastboot reboot-bootloader
ping -n 5 127.0.0.1 >nul
for /f "tokens=*" %%i in (%radimg_name%) DO (
	fastboot flash radio "%%i"
)
fastboot reboot-bootloader
ping -n 5 127.0.0.1 >nul

fastboot --set-active=_b
fastboot --set-active=b
for /f "tokens=*" %%i in (%blimg_name%) DO (
	fastboot flash bootloader "%%i"
)
fastboot reboot-bootloader
ping -n 5 127.0.0.1 >nul
for /f "tokens=*" %%i in (%radimg_name%) DO (
	fastboot flash radio "%%i"
)
fastboot reboot-bootloader
ping -n 5 127.0.0.1 >nul
:: Cleaning up find-file-names
del /Q blname.txt
del /Q radname.txt

:: Flashing All Others (Without Reboot)
fastboot --set-active=_a
fastboot --set-active=a

::Flashing Slot A
fastboot flash abl_a abl.img
fastboot flash aes_a aes.img
fastboot flash apdp_a apdp.img
fastboot flash boot_a boot.img
fastboot flash cmnlib_a cmnlib.img
fastboot flash cmnlib64_a cmnlib64.img
fastboot flash devcfg_a devcfg.img
fastboot flash dtbo_a dtbo.img
fastboot flash hyp_a hyp.img
fastboot flash keymaster_a keymaster.img
fastboot flash laf_a laf.img
fastboot flash modem_a modem.img
fastboot flash msadp_a msadp.img
fastboot flash pmic_a pmic.img
fastboot flash rpm_a rpm.img
fastboot flash tz_a tz.img
fastboot flash vbmeta_a vbmeta.img
fastboot flash vendor_a vendor.img
fastboot flash xbl_a xbl.img


echo Flashing System A
fastboot flash system_a system.img
echo Flashing System B
fastboot flash system_b system_other.img

::Flashing Slot B
fastboot --set-active=_b
fastboot --set-active=b
fastboot flash abl_b abl.img
fastboot flash aes_b aes.img
fastboot flash apdp_b apdp.img
fastboot flash boot_b boot.img
fastboot flash cmnlib_b cmnlib.img
fastboot flash cmnlib64_b cmnlib64.img
fastboot flash devcfg_b devcfg.img
fastboot flash dtbo_b dtbo.img
fastboot flash hyp_b hyp.img
fastboot flash keymaster_b keymaster.img
fastboot flash laf_b laf.img
fastboot flash modem_b modem.img
fastboot flash msadp_b msadp.img
fastboot flash pmic_b pmic.img
fastboot flash rpm_b rpm.img
fastboot flash tz_b tz.img
fastboot flash vbmeta_b vbmeta.img
fastboot flash vendor_b vendor.img
fastboot flash xbl_b xbl.img

fastboot --set-active=_a
fastboot --set-active=a

@echo off
:chooseformat
set /P c= Format Userdata[Y/N]?
if /I "%c%" EQU "Y" goto :yesformat
if /I "%c%" EQU "N" goto :noformat
goto :chooseformat
:yesformat
fastboot format userdata
pause

:noformat

echo Finished Flashing... if you are still having bootloops, you may need to format userdata in factory recovery
echo DO NOT LOCK THE BOOTLOADER UNLESS YOU ARE SURE IT IS OPERATING PROPERLY

