#!/bin/bash
sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
sleep 5
sudo mkdir -p /data
sudo mount -o discard,defaults /dev/sdb /data
sleep 5
sudo chmod a+w /data
sudo cp /etc/fstab /etc/fstab.backup
sleep 5
echo UUID=`sudo blkid -s UUID -o value /dev/sdb` /data ext4 discard,defaults,noatime,nofail 0 2 | sudo tee -a /etc/fstab