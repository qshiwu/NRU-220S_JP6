#!/bin/bash
### BEGIN INIT INFO
# Provides:          Neousys
# Required-Start:    $local_fs $remote_fs $syslog $time
# Required-Stop:     $local_fs $remote_fs $syslog $time
# Default-Start:     2 3 4 5
# Default-Stop:      
# Short-Description: NRU-220S Startup Script
# Description: NRU-220S Startup Script
### END INIT INFO

# ref: https://wiki.debian.org/LSBInitScripts


function setGPO(){ 
# $1=gpo_id $2=gpo_name #3=gpo_value
    sudo echo $1 > /sys/class/gpio/export
    sudo echo out > /sys/class/gpio/$2/direction
    sudo echo $3 > /sys/class/gpio/$2/value
    sleep 0.005
}



function getLineTegra234Gpio (){
  # $1 = GPIO_NAME
  GPIO_LINE=$(/usr/src/libgpiod/tools/gpioinfo -c 0 )
  
  
  GPIO_PIN=$(sudo cat /sys/kernel/debug/gpio | grep $1 | awk -F"-| " '{print $3}')
  echo $1 $GPIO_PIN
  sudo echo $GPIO_PIN > /sys/class/gpio/export
  sudo echo out > /sys/class/gpio/$1/direction
  sudo echo 0 > /sys/class/gpio/$1/value
  sleep 0.005
}

function setLineTegra234Gpio() {  
  # $1: GpioName
  # $2: GpioValue 
  GPIO_CHIP=0
  GPIO_LINE=$(sudo /usr/src/libgpiod/tools/gpioinfo -c $GPIO_CHIP | grep $1 | awk -F":| " '{print $4}')
  echo $1 $GPIO_LINE >> /tmp/gpio.log
  sudo /usr/src/libgpiod/tools/gpioset -c $GPIO_CHIP --daemonize $GPIO_LINE=$2
}

function setLineTegra234GpioAon() {  
  # $1: GpioName
  # $2: GpioValue 
  GPIO_CHIP=1
  GPIO_LINE=$(sudo /usr/src/libgpiod/tools/gpioinfo -c $GPIO_CHIP | grep $1 | awk -F":| " '{print $4}')
  echo $1 $GPIO_LINE >> /tmp/gpio.log
  sudo /usr/src/libgpiod/tools/gpioset -c $GPIO_CHIP --daemonize $GPIO_LINE=$2
}



case $1 in
  start)
    echo "----" > /tmp/gpio.log
    ### UART D /dev/ttyTHS3 ###
    sudo busybox devmem 0x02434018 w 0x00000450
    
    sudo pkill gpioset
    ### ES2 GPIO enable ###
   
    # MCU_BIOS_OK_ORIN _ to 0    
    # setGPO 323 PAA.07 0    
    setLineTegra234GpioAon PAA.07 0 

    # OSLED _ to 1
    # GPIO3_PAA.04 _ gpio-320 
    # setGPO 320 PAA.04 1
    setLineTegra234GpioAon PAA.04 1
    
    # GPO_UART_EN _ to 1	
    # GPIO3_PAC.07 _ gpio-493 	
    # setGPO 493 PAC.07 1
    setLineTegra234GpioAon PAC.07 1

    # GPO_CAN_EN _ to 1
    # GPIO3_PBB.00 _ gpio-324 	
    # setGPO 324 PBB.00 1
    setLineTegra234GpioAon PBB.00 1
    
    # ---
    # GPO_FAN_EN _ to 1	 
    # PAC.05 _  gpio-491
    setLineTegra234GpioAon PAC.05 1

    # GPO_RS232_EN _ to 1 _ Drive 1 after GPO_FAN_EN
    # GPIO3_PBB.01 _  gpio-325 
    setLineTegra234GpioAon PBB.01 1
    
    # ---
    # GPO_PWR_POE_EN _ to 1
    # GPIO3_PAC.01 _  gpio-487
    setLineTegra234GpioAon PAC.01 1

    # GPO_PSE_RESET_N _ to 1 _ Drive 1 after GPO_PWR_POE_EN
    # GPIO3_PBB.02 _  gpio-326
    setLineTegra234GpioAon PBB.02 1


    ### Enable Marvell 88E6172
    # sudo echo 388 > /sys/class/gpio/export
    # sudo echo out > /sys/class/gpio/PG.05/direction
    # sudo echo 1 > /sys/class/gpio/PG.05/value
    setLineTegra234Gpio PG.05 1
    sleep 0.1

    sudo insmod /usr/src/mdio-netlink.ko

    ifconfig eth0 up
    sleep 0.1
    sudo /usr/src/mdio 2310000.ethernet phy 0x15 raw 1 0xc01e
    sleep 0.2
    sudo /usr/src/mdio 2310000.ethernet phy 0x15 raw 1 0xc03e
    sleep 0.2

    ifconfig eth0 down
    ifconfig eth0 up

    ### CAN Bus Configure
    modprobe can
    modprobe can-raw
    modprobe mttcan

    sudo ip link set can0 up type can bitrate 500000
    sudo ip link set can1 up type can bitrate 500000
    
    sudo ifconfig can0 txqueuelen 1000
    sudo ifconfig can1 txqueuelen 1000


    ### Change Power Button behaviour -> Moved to installation
    # Setup in install script
    # Ref: https://askubuntu.com/questions/66723/how-do-i-modify-the-options-for-the-power-button
 #   gsettings set org.gnome.settings-daemon.plugins.power button-power 'shutdown'
   # gsettings get org.gnome.settings-daemon.plugins.power button-power
   # gsettings set org.gnome.settings-daemon.plugins.power button-power 'interactive'

esac

exit 0
