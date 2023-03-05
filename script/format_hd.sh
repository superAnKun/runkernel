#!/bin/bash
runOS=$1
grubCfg=$2
grub=$3
bochs_dir=$4
hd_img=hd80M.img
mountdir=$5
echo $hd_img

#挂载的目录 如果存在先删除
if [[ -d $mountdir ]]; then
    umount $mountdir
    rm -rf $mountdir
fi

#重新创建虚拟硬盘，硬盘存在则删除
if [[ -f $hd_img ]]; then
    echo "$hd_img is exist. now remove it"
    rm -rf $hd_img
    echo "remove ok"
fi

echo "create $hd_img"
#bximage -hd -mode="flat" -size=80 -q $hd_img
bximage -hd=80 -mode=create -q $hd_img

#给新创建的硬盘创建分区
expect<<-EOF
set timeout -1
spawn fdisk $hd_img
expect {
    "Command (m for help)" {send "n\n";exp_continue}
    "Select (default p)" {send "p\n";exp_continue}
    "Partition number (1-4, default 1)" {send "1\n";exp_continue}
    "default 2048)" {send "\n";exp_continue}
    "Last sector, +sectors or +size{K,M,G}" {send "\n"}
}
expect "Command (m for help)" {send "w\n";exp_continue} 
EOF

#第一步需要将虚拟硬盘变成linux下的回环设备才能将其挂载并格式化
loop_device=$(losetup --partscan --find --show  $hd_img)
echo $loop_device
subpartition=`ls ${loop_device}p* -1`
echo "subpartition is :$subpartition"
#mkfs.ext2 $loop_device  #给硬盘创建文件系统
mkfs.ext2 -q $subpartition  #给硬盘分区创建文件系统

#创建挂载的目录
mkdir $mountdir
mount $subpartition $mountdir  #挂载硬盘到指定目录
mkdir $mountdir/boot/  #创建boot目录
mkdir -p $mountdir/etc/default

#安装grub
grub2-install --boot-directory=$mountdir/boot --force --no-floppy $loop_device

#安装os和grub配置
cp -f $runOS  $mountdir/boot/
cp -f $grubCfg $mountdir/boot/grub2/
cp -f $grub $mountdir/etc/default/

#卸载虚拟磁盘
umount $mountdir
losetup --detach $loop_device


