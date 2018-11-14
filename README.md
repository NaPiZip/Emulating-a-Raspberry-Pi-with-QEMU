
<a href="https://www.raspberrypi.org/">
  <img src="https://upload.wikimedia.org/wikipedia/de/thumb/c/cb/Raspberry_Pi_Logo.svg/1200px-Raspberry_Pi_Logo.svg.png" alt="Raspberry_Pi_Logo" style="width:42px;height:42px;">
</a>

<h1>Emulating a Raspberry Pi 3 with QEMU</h1>

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
<br/>
<div>
This is a tutorial showing how to use QEMU to simulate a Raspberry Pi. The following
programs are needed.
<ul>
    <li>
        <a href="https://www.microsoft.com/en-us/windows/get-windows-10">Windows 10</a>
    </li>
    <li>
        <a href="https://www.qemu.org/">QEMU</a>
    </li>
<ul/>
</div>

<h2>Installation</h2>
<div>
  <ol>
    <li>
      Download the latest version of the QEMU installer e.g <a href="https://qemu.weilnetz.de/w64/">qemu-w64-setup-20181108.exe</a> and run the installer.
    </li>
    <li>
      Download a QEMU kernel image and a corresponding Raspberry Pi distribution:
      <ul>
        <li>kernel-qemu-4.9.xx-stretch</li>
        <li>2017-11-29-raspbian-stretch.zip</li>
      </ul>
      The files are on <a href="https://github.com/dhruvvyas90/qemu-rpi-kernel">dhruvvyas90</a> GitHub page.<br>
      <i>Note:<br> It's important to use matching images for kernel and Raspberry Pi image!</i>
    </li>
  </ol>
</div>

<h2>Tutorial</h2>
<div>
  This tutorial is using particular versions for the Raspberry Pi kernel as well as for the distribution.
  <ol>
    <li>
      Extract the Raspberry Pi image file `2017-11-29-raspbian-stretch.zip` into a new directory.
    </li>
    <li>
      Extract the kernel file `kernel-qemu-4.9.59-stretch_with_VirtFS` into the same directory.<br>
      <i>
        Note:<br>
        This kernel version also needs a particular Device Tree Blob (.dtb) file <a href="https://github.com/dhruvvyas90/qemu-rpi-kernel/blob/master/versatile-pb.dtb"> versatile-pb.dtb</a>.
      </i>
    </li>
    <li>
      Run the following command in the directory containing the extracted files:<br>
      `C:/mydir>qemu-system-arm.exe -kernel kernel-qemu-4.9.59-stretch_with_VirtFS -cpu arm1176 -m 256 -M versatilepb -dtb versatile-pb.dtb -no-reboot -append "root=/dev/sda2 panic=1 rootfstype=ext4 rw" -net nic -net user,hostfwd=tcp::5022-:22 -hda 2017-11-29-raspbian-stretch.img`<br>
      A detailed description of all command arguments can be found <a href="https://wiki.qemu.org/Documentation">here</a>.<br>
      <i>
        Note:<br>
        The configuration for the qemu is the default host NAT network (aka. qemu -net nic -net user configuration).
        The option `hostfwd=tcp::5022-:22` connections from port 5022 on your host (your PC) to port 22 inside your qemu guest.
      </i>
    </li>
    <li>
      QEMU should open a graphical user interface showing the status of the booting process of the Raspberry Pi image. After successful boot open a command window and create a file in the following directory: `etc/udev/rules.d/90-qemu.rules`, the file should contain the following content.<br>
      `KERNEL=="sda",SYMLINK=+"mmcblk0"`<br>
      `KERNEL=="sda?",SYMLINK=+"mmcblkOp%n"`<br>
      `KERNEL=="sda2",SYMLINK=+"root"`<br>
      Shutdown QEMU after this step, by running:<br>
      `$sudo shutdown -h now`
    </li>
    <li>
      The next step is increasing the size of the filesystem of the image, the following command increases the size of the image by 2Gb:<br>
      `C:/mydir>qemu-image.exe resize 2017-11-29-raspbian-stretch.img +2G`
    </li>
    <li>
      Now it's time to expand the filesystem using fdisk, start QEMU by executing step tree. After QEMU has fully booted and the Pi home screen is visible, start opening a command prompt and type the command below:<br>
      `$ sudo fdisk /dev/sda`<br>
      <ul>
        <li>Press p and hit return for showing the current partitions</li>
        <li>Type d and return to enter delete mode</li>
        <li>Enter `2` in order to delete partition two</li>
        <li>Type `n` for creating a new partition</li>
        <li>Press `p` for new primary partition</li>
        <li>Enter partition number `2`</li>
        <li>Next enter the start sector for partition two, this is the end partiton of partiton one, incremented by one!</li>
        <li>Hit enter for the last sector to allocate the end sector</li>
        <li>
          Press w to write and exit<br>
          <i>Note:<br>
             After exiting fdisk a error message should appear saying:<br> `Re-reading the partition table failed.: Device or resource busy`<br>
             This is fine since a reboot is needed in order to make the changes available.
          </i>
        </li>
      </ul>
      <li>
        Reboot the QEMU and run step 3 again, open a command prompt and enter the following command:<br>
        `$ sudo resize2fs /dev/sda2`
      </li>
      <li>
        The next step is increasing the swap size by entering:<br>
        `$ sudo nano /etc/dphys-swapfile`<br>
        And change the setting `CON_SWAPSIZE=1024` restart the service by running:<br>
        `$ sudo /etc/init.d/dphys-swapfile stop` and right afterwards<br>
        `$ sudo /etc/init.d/dphys-swapfile start` the success can be verified by calling<br>
        `$ free -m` the swap size should now contain the new value.
      </li>
    </li>
  </ol>

<i>Note:<br>
It's also possible to convert the image file into a .qcow using the following command, and then follow step 3.<br>
`$ qemu-img.exe convert -f raw -O qcow2 2017-11-29-raspbian-stretch.img 2017-11-29-raspbian-stretch.qcow`<br>
In order to debug add the option `-serial stdio` to step 3.<br>
</i><br>
Special hanks to <a href="http://embedonix.com/articles/linux/emulating-raspberry-pi-on-linux/">Saeid Yazdaniy</a>, for an awesome article which I used as a starting point. Also thanks to <a href="https://blog.agchapman.com/using-qemu-to-emulate-a-raspberry-pi/">Alistair Chapman</a>,
  <a href="https://www.youtube.com/watch?v=xiQX0YXYuqU">TechWizTime</a> for the video version of this repo, as well as <a href="https://github.com/dhruvvyas90/qemu-rpi-kernel">dhruvvyas90</a> as he is the provider of the kernel image as well as the distribution.

</div>
<h2>Contributing</h2>

<div>
To get started with contributing to me GitHub repository, please contact me <a href="https://slack.com/">Slack<a/>.
</div>
