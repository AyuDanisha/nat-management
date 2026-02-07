1. Setup pertama kali (wajib)
   chmod +x ./vps
   sudo ./vps setup --wan eth0 --bridge br-nat --subnet 10.10.0.0/24 --gw 10.10.0.1

WAN interface harus eth0, cek:

ip route | grep default

2. Create VPS (contoh NAT)
   sudo ./vps create vps-01 \
    --os ubuntu:jammy \
    --ip 10.10.0.10 \
    --ssh-port 22010 \
    --ram 1024 \
    --cpu 1 \
    --bw 10mbit \
    --hostname vps01 \
    --hosts "google.com=5.180.255.138"

3. Start/Stop/Delete
   sudo ./vps stop vps-01
   sudo ./vps start vps-01
   sudo ./vps delete vps-01

Disk limit (WAJIB LVM kalau kamu mau “real limit”)

Cek VG:
sudo vgs

Create VPS dengan disk limit:

sudo ./vps create vps-02 \
 --os ubuntu:jammy \
 --ip 10.10.0.11 \
 --ssh-port 22011 \
 --ram 1024 --cpu 1 --bw 10mbit \
 --disk 20 --vg vg0

List VPS yang tercatat
sudo ./vps list

Info detail
sudo ./vps info vps-01

# atau

sudo ./vps info nat-8f31a2c1

Re-apply NAT + bandwidth setelah reboot / rule hilang
sudo ./vps reconcile
