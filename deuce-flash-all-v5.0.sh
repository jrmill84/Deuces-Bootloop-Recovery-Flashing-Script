#!/bin/sh
clear
echo "Deuces-flash-all-script-V4.5-Linux"
echo "for Taimen & Walleye - Google Pixel 2 / XL"
echo "USE AT YOUR OWN RISK"
echo "THIS HAS NOT BEEN TESTED ON MAC / OSX"
read -n1 -r -p "Press any key to continue..." key

echo "Make Sure your Device is in Fastboot Mode"
echo "(Power off, hold Volume-Down, hold Power)"
echo "Once you are in fastboot,"
read -n1 -r -p "Press any key to continue..." key
clear
##choices-Bootloader-Unlocking

echo -n "Unlock Bootloader? (y/n)"
read answer
if echo "$answer" | grep -iq "^y" ;then
    echo "Running Unlock"
    echo "Look at your device,"
    echo "press up arrow and Power to confirm"
	fastboot flashing unlock
    echo "This will say FAILED if already unlocked - ignore"
    sleep 5

    echo "Running Unlock_critical"
    echo "Look at your device,"
    echo "press up arrow and Power to confirm"
	fastboot flashing unlock_critical
    echo "This will say FAILED if already unlocked, or if device=Walleye - ignore"
	sleep 5
else
    echo "Skipping unlock(s)"
fi

echo "Flashing Bootloader & Radio A&B"
fastboot flash bootloader_a bootloader*.img
fastboot reboot-bootloader
sleep 5
fastboot flash bootloader_b bootloader*.img
fastboot reboot-bootloader
sleep 5
fastboot flash radio_a radio*.img
fastboot reboot-bootloader
sleep 5
fastboot flash radio_b radio*.img
fastboot reboot-bootloader
sleep 5

echo "Flashing All Others -- Without Reboot"
fastboot --set-active=_a
fastboot --set-active=a

##Flashing Slot A
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

echo "Flashing System A"
fastboot flash system_a system.img
echo "Flashing System B"
fastboot flash system_b system_other.img

##Flashing Slot B
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

##choices-format-relocks

echo -n "FORMAT USERDATA? (y/n)"
read answer
if echo "$answer" | grep -iq "^y" ;then
    echo "Wiping UserData.."
    fastboot format userdata
else
    echo "Not wiping..."
fi
echo "Finished Flashing... if you are still having bootloops, you may need to format userdata in factory recovery"
echo "DO NOT LOCK THE BOOTLOADER UNLESS YOU ARE SURE IT IS OPERATING PROPERLY"


