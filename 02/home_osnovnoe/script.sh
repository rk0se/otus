# !/bin/bash

#создаем рейд 5 из 5 дисков
mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
mdadm --create --verbose /dev/md0 -l 5 -n 5 /dev/sd{b,c,d,e,f}

#создадим конфиг 
slee5
mkdir /etc/mdadm
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf

#создаем GPT и разделы
parted -s /dev/md0 mklabel gpt
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%

#создаем фс
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done

#создаем точки монтирования
mkdir -p /raid/part{1,2,3,4,5}

#монтируем
for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done

#пропишем в fstab
for i in $(seq 1 5);  do echo "/dev/md0p$i /raid/part$i ext4 auto 0 0" >> /etc/fstab; done
 
