
编译步骤
make all 编译出kernel文件

make install 将kernel文件安装进硬盘hd80M.img中

执行su 命令进入root用户, 并到runkernel/bochs目录下执行bochs -f bochsrc.disk命令启动bochs即可

