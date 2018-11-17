set DIRECTORY=C:\Program Files\qemu\
"%DIRECTORY%qemu-system-arm.exe" -kernel kernel-qemu-4.9.59-stretch_with_VirtFS ^
                                 -cpu arm1176 -m 256 -M versatilepb -dtb versatile-pb.dtb ^
                                 -no-reboot -append "root=/dev/sda2 panic=1 rootfstype=ext4 rw" ^
                                 -net nic -net user,hostfwd=tcp::5022-:22 -hda 2018-04-18-raspbian-stretch.img
