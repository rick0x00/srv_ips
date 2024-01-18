#!/usr/bin/env bash

# ============================================================ #
# Tool Created date: 17 jan 2024                               #
# Tool Created by: Henrique Silva (rick.0x00@gmail.com)        #
# Tool Name: fail2ban Install                                  #
# Description: My simple script to provision fail2ban Server   #
# License: software = MIT License                              #
# Remote repository 1: https://github.com/rick0x00/srv_ips     #
# Remote repository 2: https://gitlab.com/rick0x00/srv_ips     #
# ============================================================ #
# base content:
#     https://www.the-art-of-web.com/system/fail2ban-filters/
#   

# ============================================================ #
# start root user checking
if [ $(id -u) -ne 0 ]; then
    echo "Please use root user to run the script."
    exit 1
fi
# end root user checking
# ============================================================ #
# start set variables

DATE_NOW="$(date +Y%Ym%md%d-H%HM%MS%S)" # extracting date and time now


os_distribution="Debian"
os_version=("11" "bullseye")

database_engine="mysql"
webserver_engine="fail2ban"

build_path="/usr/local/src"
workdir="/etc/fail2ban"
persistence_volumes=("${workdir}" "/var/log/")
expose_ports="${port_xpto[0]}/${port_xpto[1]}}"
# end set variables
# ============================================================ #
# start definition functions
# ============================== #
# start complement functions

function remove_space_from_beginning_of_line {
    #correct execution
    #remove_space_from_beginning_of_line "<number of spaces>" "<file to remove spaces>"

    # Remove a white apace from beginning of line
    #sed -i 's/^[[:space:]]\+//' "$1"
    #sed -i 's/^[[:blank:]]\+//' "$1"
    #sed -i 's/^ \+//' "$1"

    # check if 2 arguments exist
    if [ $# -eq 2 ]; then
        #echo "correct quantity of args"
        local spaces="${1}"
        local file="${2}"
    else
        #echo "incorrect quantity of args"
        local spaces="4"
        local file="${1}"
    fi 
    sed -i "s/^[[:space:]]\{${spaces}\}//" "${file}"
}

function massager_sharp() {
    line_divisor="###########################################################################################"
    echo "${line_divisor}"
    echo "$*"
    echo "${line_divisor}"
}

function massager_line() {
    line_divisor="-------------------------------------------------------------------------------------------"
    echo "${line_divisor}"
    echo "$*"
    echo "${line_divisor}"
}

function massager_plus() {
    line_divisor="++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "${line_divisor}"
    echo "$*"
    echo "${line_divisor}"
}

# end complement functions
# ============================== #
# start main functions

function pre_install_server () {
    massager_line "Pre install server step"

    function install_generic_tools() {
        # update repository
        apt update

        #### start generic tools
        # install basic network tools
        apt install -y net-tools iproute2 traceroute iputils-ping mtr
        # install advanced network tools
        apt install -y tcpdump nmap netcat
        # install DNS tools
        apt install -y dnsutils
        # install process inspector
        apt install -y procps htop
        # install text editors
        apt install -y nano vim 
        # install web-content downloader tools
        apt install -y wget curl
        # install uncompression tools
        apt install -y unzip tar
        # install file explorer with CLI
        apt install -y mc
        # install task scheduler 
        apt install -y cron
        # install log register 
        apt install -y rsyslog
        #### stop generic tools
    }

    function install_dependencies () {
        echo "step not necessary"
        exit 1;
    }

    function install_complements () {
        echo "step not necessary"
        exit 1;
    }

    install_generic_tools
    #install_dependencies;
    #install_complements;
}

##########################
## install steps

function install_fail2ban () {
    # installing fail2ban
    massager_plus "Installing fail2ban"

    function install_from_source () {
        # Installing from Source
        massager_plus " Installing from Source"
        echo "step not configured"
        exit 1;
    }

    function install_from_apt () {
        # Installing from APT
        massager_plus " Installing from APT"
        apt install -y fail2ban
    }

    ## Installing fail2ban From Source ##
    #install_from_source

    ## Installing fail2ban From APT (Debian package manager) ##
    install_from_apt
}
#############################

function install_server () {
    massager_line "Install server step"

    ##  fail2ban
    install_fail2ban
}

#############################
## start/stop steps ##

function start_fail2ban () {
    # starting fail2ban
    massager_plus "Starting fail2ban"

    #service fail2ban start
    #systemctl start fail2ban
    /etc/init.d/fail2ban start

    # Daemon running on foreground mode
    #/usr/bin/python3 /usr/bin/fail2ban-server -xf start
}

function stop_fail2ban () {
    # stopping fail2ban
    massager_plus "Stopping fail2ban"

    #service fail2ban stop
    #systemctl stop fail2ban
    /etc/init.d/fail2ban stop

    # ensuring it will be stopped
    # for Daemon running on foreground mode
    killall fail2ban-server
}

################################

function start_server () {
    massager_line "Starting server step"
    # Starting Service

    # starting fail2ban
    start_fail2ban
}

function stop_server () {
    massager_line "Stopping server step"

    # stopping server
    stop_fail2ban
}

################################
## configuration steps ##
function configure_fail2ban() {
    # Configuring fail2ban
    massager_plus "Configuring fail2ban"

    function configure_fail2ban_configs() {
        # Configuring fail2ban 
        massager_plus "Configuring fail2ban"

        echo "Setting default confs..."
        echo "
        [DEFAULT]
        ignoreip = 127.0.0.1/8 ::1
        bantime  = -1
        findtime  = 1w
        maxretry = 3
        protocol = tcp, udp, icmp
        banaction = nftables[type=allports]
        " >> /etc/fail2ban/jail.d/default.conf

        remove_space_from_beginning_of_line "8" "/etc/fail2ban/jail.d/default.conf"

        echo "Setting SSHD confs..."
        echo "
        [sshd]
        #mode   = normal
        enabled = true
        port    = ssh, 2222
        filter  = sshd
        logpath = %(sshd_log)s
        backend = %(sshd_backend)s
        " >> /etc/fail2ban/jail.d/sshd.conf

        remove_space_from_beginning_of_line "8" "/etc/fail2ban/jail.d/sshd.conf"

    }

    # setting fail2ban site
    configure_fail2ban_configs
}

################################

function configure_server () {
    # configure server
    massager_line "Configure server"

    # configure fail2ban 
    configure_fail2ban
}

################################
## check steps ##

function check_configs_fail2ban() {
    # Check config of fail2ban
    massager_plus "Check config of fail2ban"

    fail2ban-server -t
}

#####################

function check_configs () {
    massager_line "Check Configs server"

    # check if the configuration is ok.
    check_configs_fail2ban
}

################################
## test steps ##

function test_fail2ban () {
    # Testing fail2ban
    massager_plus "Testing of fail2ban"


    # is running ????
    #service fail2ban status
    #systemctl status  --no-pager -l fail2ban
    /etc/init.d/fail2ban status
    ps -ef --forest | grep fail2ban

    # is listening ?
    # fail2ban not need listen

    # is creating logs ????
    tail -f /var/log/fail2ban.log

    # Validating...
    # the validations its possible using anothers Hosts


    # is creating firewall rules ???(after fisrt ban ip)
    nft list table inet f2b-table
    #root@fail2ban:/etc/fail2ban/jail.d# nft list table inet f2b-table
    #table inet f2b-table {
    #	set addr-set-sshd {
    #		type ipv4_addr
    #		elements = { 192.168.0.155 }
    #	}
    #
    #	chain f2b-chain {
    #		type filter hook input priority filter - 1; policy accept;
    #		meta l4proto { icmp, tcp, udp } ip saddr @addr-set-sshd reject
    #	}
    #}


}


################################

function test_server () {
    massager_line "Testing server"

    # testing fail2ban
    test_fail2ban

}

################################

# end main functions
# ============================== #

# end definition functions
# ============================================================ #
# start argument reading

# end argument reading
# ============================================================ #
# start main executions of code
massager_sharp "Starting fail2ban installation script"
pre_install_server;
install_server;
stop_server;
configure_server;
check_configs;
start_server;
test_server;
massager_sharp "Finished fail2ban installation script"


