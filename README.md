<img src="https://upload.wikimedia.org/wikipedia/de/thumb/c/cb/Raspberry_Pi_Logo.svg/1200px-Raspberry_Pi_Logo.svg.png" alt="Raspberry_Pi_Logo" height="42px" width="42px" align="left"><br>

# Emulating a Raspberry Pi 3 with QEMU
<div>
    <a href="https://github.com/NaPiZip/Docker_GUI_Apps_on_Windows">
        <img src="https://img.shields.io/badge/Document%20Version-1.0.0-brightgreen.svg"/>
    </a>
    <a href="https://www.qemu.org/">
        <img src="https://img.shields.io/badge/QEMU%20x64-3.1.0--rc0-blue.svg"/>
    </a>
    <a href="https://www.microsoft.com">
        <img src="https://img.shields.io/badge/Windows%2010%20x64-10.0.17134%20Build%2017134-blue.svg"/>
    </a>
    <a href="https://downloads.raspberrypi.org/raspbian/images/raspbian-2017-12-01/">
        <img src="https://img.shields.io/badge/Raspbian-2017--12--01-blue.svg"/>
    </a>
    <a href="https://github.com/raspberrypi/linux/releases/tag/raspberrypi-kernel_1.20171029-1">
        <img src="https://img.shields.io/badge/Raspberrypi%20Kernel-1.20171029--1-blue.svg"/>
    </a>
</div>

This is a tutorial showing how to use QEMU to simulate a Raspberry Pi. The following programs are needed.
- [Windows 10](https://www.microsoft.com/en-us/windows/get-windows-10)
- [QEMU](https://www.qemu.org)

## Installation

1. Download the latest version of the QEMU installer e.g [qemu-w64-setup-20181108.exe](https://qemu.weilnetz.de/w64/) and run it.
2. Download a QEMU kernel image and a corresponding Raspberry Pi distribution, the files can be found on [dhruvvyas90](https://github.com/dhruvvyas90/qemu-rpi-kernel) GitHub page.
    - kernel-qemu-4.9.xx-stretch
    -  2017-11-29-raspbian-stretch.zip<br>
*Note:<br>
 It's important to use matching images for kernel and Raspberry Pi image!*

## Tutorial

This tutorial is using particular versions for the Raspberry Pi kernel as well as for the distribution.

1. Extract the Raspberry Pi image file `2017-11-29-raspbian-stretch.zip` into a new directory.
2. Extract the kernel file `kernel-qemu-4.9.59-stretch_with_VirtFS` into the same directory.<br>
  *Note:<br>
   This kernel version also needs a particular Device Tree Blob (.dtb) file [versatile-pb.dtb](https://github.com/dhruvvyas90/qemu-rpi-kernel/blob/master/versatile-pb.dtb).*
3. Run the following command in the directory containing the extracted files:<br>
   `C:/mydir>qemu-system-arm.exe -kernel kernel-qemu-4.9.59-stretch_with_VirtFS -cpu arm1176 -m 256 -M versatilepb -dtb versatile-pb.dtb -no-reboot -append "root=/dev/sda2 panic=1 rootfstype=ext4 rw" -net nic -net user,hostfwd=tcp::5022-:22 -hda 2017-11-29-raspbian-stretch.img`
   A detailed description of all command arguments can be found [here](https://wiki.qemu.org/Documentation).<br>
   *Note:<br>
    The configuration for the qemu is the default host NAT network (aka. qemu -net nic -net user configuration).
    The option `hostfwd=tcp::5022-:22` connections from port 5022 on your host (your PC) to port 22 inside your qemu guest.*
4. QEMU should open a graphical user interface showing the status of the booting process of the Raspberry Pi image. After successful boot open a command window and create a file in the following directory:<br>
   `etc/udev/rules.d/90-qemu.rules`, the file should contain the following content.<br>
   ```
   KERNEL=="sda", SYMLINK+="mmcblk0"
   KERNEL=="sda?", SYMLINK+="mmcblk0p%n"
   KERNEL=="sda2", SYMLINK+="root"
   ```

   Shutdown QEMU after this step, by running:<br>
   `$sudo shutdown -h now`
5. The next step is increasing the size of the filesystem of the image, the following command increases the size of the image by 2Gb:<br>
   `C:/mydir>qemu-image.exe resize 2017-11-29-raspbian-stretch.img +2G`
6. Now it's time to expand the filesystem using fdisk, start QEMU by executing step tree. After QEMU has fully booted and the Pi home screen is visible, start opening a command prompt and type the command below:<br>
   `$ sudo fdisk /dev/sda`
   -  Press p and hit return for showing the current partitions
   - Type d and return to enter delete mode
   - Enter 2 in order to delete partition two
   - Type n for creating a new partition
   - Press p for new primary partition
   - Enter partition number 2
   - Next enter the start sector for partition two, this is previous value of partiton two!
   - Hit enter for the last sector to allocate the end sector
   - Press w to write and exit<br>
   *Note:<br>
    After exiting fdisk a error message should appear saying:
    Re-reading the partition table failed.: Device or resource busy
    This is fine since a reboot is needed in order to make the changes available.*
7. Reboot the QEMU and run step 3 again, open a command prompt and enter the following command:<br>
  `$ sudo resize2fs /dev/sda2`
8. The next step is increasing the swap size by entering:<br>
   `$ sudo nano /etc/dphys-swapfile`
   And change the setting CON_SWAPSIZE=1024 restart the service by running:<br>
  `$ sudo /etc/init.d/dphys-swapfile` stop and right afterwards<br>
  `$ sudo /etc/init.d/dphys-swapfile` start the success can be verified by calling
  `$ free -m` the swap size should now contain the new value.<br>
*Note:<br>
It's also possible to convert the image file into a .qcow using the following command, and then follow step 3.
`$ qemu-img.exe convert -f raw -O qcow2 2017-11-29-raspbian-stretch.img 2017-11-29-raspbian-stretch.qcow`
In order to debug add the option -serial stdio to step 3.*

Special thanks to [Saeid Yazdaniy](http://embedonix.com/articles/linux/emulating-raspberry-pi-on-linux), for an awesome article which I used as a starting point. Also thanks to [Alistair Chapman](https://blog.agchapman.com/using-qemu-to-emulate-a-raspberry-pi), [TechWizTime](https://www.youtube.com/watch?v=xiQX0YXYuqU) for the video version of this repo, as well as [dhruvvyas90](https://github.com/dhruvvyas90/qemu-rpi-kernel) as he is the provider of the kernel image as well as the distribution.

## Contributing

To get started with contributing to me GitHub repository, please contact me [Slack](https://slack.com).
