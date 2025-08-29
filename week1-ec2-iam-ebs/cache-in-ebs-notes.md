# create an EBS volume
# Find AZ of ec2 instance. Console details gives Region only.

aws ec2 describe-instances \
  --instance-ids i-09e25918b78c2f3e1 \
  --query "Reservations[].Instances[].Placement.AvailabilityZone" \
  --output text \
  --region ap-south-1

  # ap-south-1b. make sure new volume is same AZ

  # open volume > Actions > Attach volume. 

  lsblk

ubuntu@ip-172-31-13-101:~$ lsblk
NAME         MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
loop0          7:0    0 27.6M  1 loop /snap/amazon-ssm-agent/11797
loop1          7:1    0 63.8M  1 loop /snap/core20/2599
loop2          7:2    0 73.9M  1 loop /snap/core22/2045
loop3          7:3    0 89.4M  1 loop /snap/lxd/31333
loop4          7:4    0 49.3M  1 loop /snap/snapd/24792
loop5          7:5    0 50.8M  1 loop /snap/snapd/25202
loop6          7:6    0 73.9M  1 loop /snap/core22/2082
nvme0n1      259:0    0    8G  0 disk 
├─nvme0n1p1  259:1    0  7.9G  0 part /
├─nvme0n1p14 259:2    0    4M  0 part 
└─nvme0n1p15 259:3    0  106M  0 part /boot/efi
nvme1n1      259:4    0    5G  0 disk 
ubuntu@ip-172-31-13-101:~$ 

# nvme1n1      259:4    0    5G  0 disk  ---> seems to be the new volume

#format volume before use


ubuntu@ip-172-31-13-101:~$ sudo mkfs -t ext4 /dev/nvme1n1
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 1310720 4k blocks and 327680 inodes
Filesystem UUID: fad0b8b0-a3fc-42ea-ad20-b0390b6d9d01
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done 

ubuntu@ip-172-31-13-101:~$ 

#mount the volume

ubuntu@ip-172-31-13-101:~$ sudo mkdir /mnt/data
ubuntu@ip-172-31-13-101:~$ sudo mount /dev/nvme1n1 /mnt/data
ubuntu@ip-172-31-13-101:~$ df -h
Filesystem       Size  Used Avail Use% Mounted on
/dev/root        7.6G  5.8G  1.8G  77% /
tmpfs            458M     0  458M   0% /dev/shm
tmpfs            183M  996K  182M   1% /run
tmpfs            5.0M     0  5.0M   0% /run/lock
efivarfs         128K  3.6K  120K   3% /sys/firmware/efi/efivars
/dev/nvme0n1p15  105M  6.1M   99M   6% /boot/efi
tmpfs             92M  4.0K   92M   1% /run/user/1000
/dev/nvme1n1     4.9G   24K  4.6G   1% /mnt/data

#persist across reboots

#add the following to /etc/fstab
UUID=fad0b8b0-a3fc-42ea-ad20-b0390b6d9d01   /mnt/data   ext4   defaults,nofail   0   2

#to find UUID
ubuntu@ip-172-31-13-101:~$ sudo blkid /dev/nvme1n1
/dev/nvme1n1: UUID="fad0b8b0-a3fc-42ea-ad20-b0390b6d9d01" BLOCK_SIZE="4096" TYPE="ext4"

#changed server.js to have logic for cache. if in ec2, uses EBS volume, else a local directory (dev)

#docker was causing too many overheads. so ditched docker
#ran npm run dev on ec2. ran into npm version issue. box had a very very old version. updated npm after installing nvm. 
#server crashed again because it doesn't have write perms on /mnt/data (ebs volume)

#debuglogs at start server.js
+console.log('Current user:', process.getuid?.() || 'unknown');
+console.log('Working directory:', process.cwd());
+console.log('Can access /mnt:', fsSync.existsSync('/mnt'));
+console.log('Can access /mnt/data:', fsSync.existsSync('/mnt/data'));
+


Creating cache directory: /mnt/data/cache
Failed to start server: [Error: EACCES: permission denied, mkdir '/mnt/data/cache'] {
  errno: -13,
  code: 'EACCES',
  syscall: 'mkdir',
  path: '/mnt/data/cache'
}
[nodemon] app crashed - waiting for file changes before starting...
^C
ubuntu@ip-172-31-13-101:~/how-is-your-day/backend$ 
ubuntu@ip-172-31-13-101:~/how-is-your-day/backend$ 
ubuntu@ip-172-31-13-101:~/how-is-your-day/backend$ 
ubuntu@ip-172-31-13-101:~/how-is-your-day/backend$ ls -la /mnt/
total 12
drwxr-xr-x  3 root root 4096 Aug 29 08:37 .
drwxr-xr-x 19 root root 4096 Aug 27 13:38 ..
drwxr-xr-x  3 root root 4096 Aug 29 08:36 data
ubuntu@ip-172-31-13-101:~/how-is-your-day/backend$ sudo chmod 755 /mnt/data
ubuntu@ip-172-31-13-101:~/how-is-your-day/backend$ sudo chown ubuntu:ubuntu /mnt/data


#changing permission started server. EBS is now being used for caching.
#frontend was set to api IP address http://3.110.28.176. and frontend went into a loop because it couldn't connect. this is because now docker is not there and there is no port mapping 80:5001. so now frontend has to access 5001 of the ec2 box. so security group needed to be changed to add 5001 incoming traffic (outgoing is enabled by default for ALL). changed .env to point to http://3.110.28.176:5001

