#!/bin/bash

#1. Create a custom service file
touch /etc/systemd/system/reboot-stress.service

cat > /etc/systemd/system/reboot-stress.service << EOF
[Unit]
Description=My Reboot Service

[Service]
ExecStart=/root/reboot.sh

[Install]
WantedBy=multi-user.target
EOF


#2. Enable the service
systemctl enable reboot-stress.service


#3. Create the /root/reboot.sh and give exec permission
cat > /root/reboot.sh << EOF
#!/bin/bash
count="\$(cat /root/count)"

#Reset this value if you need more
num_of_reboots=2

if [ \$count -lt \$num_of_reboots ]
then
    ((count++))
    echo "\$count" > /root/count
    reboot -f
fi
EOF

chmod +x /root/reboot.sh


#4. Create the count file and set it to zero
touch /root/count
echo 0 > /root/count
