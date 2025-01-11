#!/bin/bash
#
#**********************************************************************************
#Author:        Raymond
#QQ:            88563128
#Date:          2025-01-11
#FileName:      reset_opensuse.sh
#MIRROR:        raymond.blog.csdn.net
#Description:   The reset linux system initialization script supports 
#               “openSUSE 15“ operating systems.
#Copyright (C): 2025 All rights reserved
#**********************************************************************************
COLOR="echo -e \\033[01;31m"
END='\033[0m'

os(){
    OS_ID=`sed -rn '/^NAME=/s@.*="([[:alpha:]]+).*"$@\1@p' /etc/os-release`
    OS_NAME=`sed -rn '/^NAME=/s@.*="([[:alpha:]]+) (.*)"$@\2@p' /etc/os-release`
    OS_RELEASE=`sed -rn '/^VERSION_ID=/s@.*="?([0-9.]+)"?@\1@p' /etc/os-release`
}

check_ip(){
    local IP=$1
    VALID_CHECK=$(echo ${IP}|awk -F. '$1<=255&&$2<=255&&$3<=255&&$4<=255{print "yes"}')
    if echo ${IP}|grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$" >/dev/null; then
        if [ ${VALID_CHECK} == "yes" ]; then
            echo "IP ${IP}  available!"
            return 0
        else
            echo "IP ${IP} not available!"
            return 1
        fi
    else
        echo "IP format error!"
        return 1
    fi
}

set_network(){
    ETHNAME=`ip addr | awk -F"[ :]" '/^2/{print $3}'`
    while true; do
        read -p "请输入IP地址: " IP
        check_ip ${IP}
        [ $? -eq 0 ] && break
    done
    read -p "请输入子网掩码位数: " PREFIX
    while true; do
        read -p "请输入网关地址: " GATEWAY
        check_ip ${GATEWAY}
        [ $? -eq 0 ] && break
    done
    while true; do
        read -p "请输入主DNS地址（例如：阿里：223.5.5.5，腾讯：119.29.29.29，公共：114.114.114.114，google：8.8.8.8等）: " PRIMARY_DNS
        check_ip ${PRIMARY_DNS}
        [ $? -eq 0 ] && break
    done
    while true; do
        read -p "请输入备用DNS地址（例如：阿里：223.6.6.6，腾讯：119.28.28.28，公共：114.114.115.115，google：8.8.4.4等）: " BACKUP_DNS
        check_ip ${BACKUP_DNS}
        [ $? -eq 0 ] && break
    done
    cat > /etc/sysconfig/network/ifcfg-${ETHNAME} <<-EOF
STARTMODE='auto'
BOOTPROTO='static'
ZONE=public
IPADDR='${IP}'
PREFIXLEN='${PREFIX}'
EOF
    touch /etc/sysconfig/network/routes
    cat > /etc/sysconfig/network/routes  <<-EOF
default ${GATEWAY} - -
EOF
    sed -ri  's/(NETCONFIG_DNS_STATIC_SERVERS=).*/\1"${PRIMARY_DNS} ${BACKUP_DNS}"/g' /etc/sysconfig/network/config
    ${COLOR}"${OS_ID} ${OS_RELEASE} 网络已设置成功，请重新启动系统后生效!"${END}
}

set_dual_network(){
    ETHNAME=`ip addr | awk -F"[ :]" '/^2/{print $3}'`
    ETHNAME2=`ip addr | awk -F"[ :]" '/^3/{print $3}'`
    while true; do
        read -p "请输入第一块网卡IP地址: " IP
        check_ip ${IP}
        [ $? -eq 0 ] && break
    done
    read -p "请输入子网掩码位数: " PREFIX
    while true; do
        read -p "请输入网关地址: " GATEWAY
        check_ip ${GATEWAY}
        [ $? -eq 0 ] && break
    done
    while true; do
        read -p "请输入主DNS地址（例如：阿里：223.5.5.5，腾讯：119.29.29.29，公共：114.114.114.114，google：8.8.8.8等）: " PRIMARY_DNS
        check_ip ${PRIMARY_DNS}
        [ $? -eq 0 ] && break
    done
    while true; do
        read -p "请输入备用DNS地址（例如：阿里：223.6.6.6，腾讯：119.28.28.28，公共：114.114.115.115，google：8.8.4.4等）: " BACKUP_DNS
        check_ip ${BACKUP_DNS}
        [ $? -eq 0 ] && break
    done
    while true; do
        read -p "请输入第二块网卡IP地址: " IP2
        check_ip ${IP2}
        [ $? -eq 0 ] && break
    done
    read -p "请输入子网掩码位数: " PREFIX2
    cat > /etc/sysconfig/network/ifcfg-${ETHNAME} <<-EOF
STARTMODE='auto'
BOOTPROTO='static'
ZONE=public
IPADDR='${IP}'
PREFIXLEN='${PREFIX}'
EOF
    touch /etc/sysconfig/network/routes
    cat > /etc/sysconfig/network/routes  <<-EOF
default ${GATEWAY} - -
EOF
    sed -ri  's/(NETCONFIG_DNS_STATIC_SERVERS=).*/\1"${PRIMARY_DNS} ${BACKUP_DNS}"/g' /etc/sysconfig/network/config
    cat > /etc/sysconfig/network/ifcfg-${ETHNAME2} <<-EOF
STARTMODE='auto'
BOOTPROTO='static'
ZONE=public
IPADDR='${IP2}'
PREFIXLEN='${PREFIX2}'
EOF
    ${COLOR}"${OS_ID} ${OS_RELEASE} 网络已设置成功，请重新启动系统后生效!"${END}
}

set_hostname(){
    read -p "请输入主机名: " HOST
    hostnamectl set-hostname ${HOST}
    ${COLOR}"${OS_ID} ${OS_RELEASE} 主机名设置成功,请重新登录生效!"${END}
}

aliyun(){
    MIRROR=mirrors.aliyun.com
}

huawei(){
    MIRROR=repo.huaweicloud.com
}

tencent(){
    MIRROR=mirrors.tencent.com
}

tuna(){
    MIRROR=mirrors.tuna.tsinghua.edu.cn
}

netease(){
    MIRROR=mirrors.163.com
}

sohu(){
    MIRROR=mirrors.sohu.com
}

nju(){
    MIRROR=mirrors.nju.edu.cn
}

ustc(){
    MIRROR=mirrors.ustc.edu.cn
}

sjtu(){
    MIRROR=mirrors.sjtug.sjtu.edu.cn
}

bfsu(){
    MIRROR=mirrors.bfsu.edu.cn
}

pku(){
    MIRROR=mirrors.pku.edu.cn
}

zju(){
    MIRROR=mirrors.zju.edu.cn
}

lzu(){
    MIRROR=mirror.lzu.edu.cn
}

cqupt(){
    MIRROR=mirrors.cqupt.edu.cn
}

volces(){
    MIRROR=mirrors.volces.com
}

set_zypper(){
    [ -d /etc/zypp/repos.d/backup ] || { mkdir /etc/zypp/repos.d/backup; mv /etc/zypp/repos.d/*.repo /etc/zypp/repos.d/backup; }
    zypper ar -cfg 'https://'${MIRROR}'/opensuse/distribution/leap/$releasever/repo/oss/' mirror-oss
    zypper ar -cfg 'https://'${MIRROR}'/opensuse/distribution/leap/$releasever/repo/non-oss/' mirror-non-oss
    zypper ar -cfg 'https://'${MIRROR}'/opensuse/update/leap/$releasever/oss/' mirror-update
    zypper ar -cfg 'https://'${MIRROR}'/opensuse/update/leap/$releasever/non-oss/' mirror-update-non-oss
    zypper ar -cfg 'https://'${MIRROR}'/opensuse/update/leap/$releasever/sle/' mirror-sle-update
    zypper ar -cfg 'https://'${MIRROR}'/opensuse/update/leap/$releasever/backports/' mirror-backports-update
    ${COLOR}"更新镜像源中,请稍等..."${END}
    zypper refresh
    ${COLOR}"${OS_ID} ${OS_RELEASE} zypper源设置完成!"${END}
}

base_menu(){
    while true;do
        echo -e "\E[$[RANDOM%7+31];1m"
        cat <<-EOF
1)阿里镜像源
2)华为镜像源
3)腾讯镜像源
4)清华镜像源
5)网易镜像源
6)搜狐镜像源
7)南京大学镜像源
8)中国科学技术大学镜像源
9)上海交通大学镜像源
10)北京外国语大学镜像源
11)北京大学镜像源
12)浙江大学镜像源
13)兰州大学镜像源
14)重庆邮电大学镜像源
15)火山引擎镜像源
16)退出
EOF
        echo -e '\E[0m'

        read -p "请输入镜像源编号(1-16): " NUM
        case ${NUM} in
        1)
            aliyun
            set_zypper
            ;;
        2)
            huawei
            set_zypper
            ;;
        3)
            tencent
            set_zypper
            ;;
        4)
            tuna
            set_zypper
            ;;
        5)
            netease
            set_zypper
            ;;
        6)
            sohu
            set_zypper
            ;;
        7)
            nju
            set_zypper
            ;;
        8)
            ustc
            set_zypper
            ;;
        9)
            sjtu
            set_zypper
            ;;
        10)
            bfsu
            set_zypper
            ;;
        11)
            pku
            set_zypper
            ;;
        12)
            zju
            set_zypper
            ;;
        13)
            lzu
            set_zypper
            ;;
        14)
            cqupt
            set_zypper
            ;;
        15)
            volces
            set_zypper
            ;;
        16)
            break
            ;;
        *)
            ${COLOR}"输入错误,请输入正确的数字(1-16)!"${END}
            ;;
        esac
    done
}

minimal_install(){
    ${COLOR}'开始安装“建议安装软件包”,请稍等......'${END}
    zypper install -y gcc make autoconf gcc-c++ glibc-devel pcre pcre-devel openssl-devel systemd-devel zlib-devel lrzsz tree tmux tcpdump iotop bc unzip nfs-utils &> /dev/null
    ${COLOR}"${OS_ID} ${OS_RELEASE} 建议安装软件包已安装完成!"${END}
}

disable_firewalls(){
    rpm -q firewalld &> /dev/null && { systemctl disable --now firewalld &> /dev/null; ${COLOR}"${OS_ID} ${OS_RELEASE} Firewall防火墙已关闭!"${END}; } || ${COLOR}"${OS_ID} ${OS_RELEASE} iptables防火墙已关闭!"${END}
}

disable_apparmor(){
    systemctl disable --now apparmor &> /dev/null; ${COLOR}"${OS_ID} ${OS_RELEASE} AppArmor已禁用!"${END}
}

set_swap(){
    sed -ri.bak '/swap/s/(.*)(defaults)(.*)/\1\2,noauto\3/g' /etc/fstab
    swapoff -a
    ${COLOR}"${OS_ID} ${OS_RELEASE} 禁用swap成功!"${END}
}

set_localtime(){
    timedatectl set-timezone Asia/Shanghai
    echo 'Asia/Shanghai' >/etc/timezone
    ${COLOR}"${OS_ID} ${OS_RELEASE} 系统时区已设置成功,请重启系统后生效!"${END}
}

set_limits(){
    cat >> /etc/security/limits.conf <<-EOF
root     soft   core     unlimited
root     hard   core     unlimited
root     soft   nproc    1000000
root     hard   nproc    1000000
root     soft   nofile   1000000
root     hard   nofile   1000000
root     soft   memlock  32000
root     hard   memlock  32000
root     soft   msgqueue 8192000
root     hard   msgqueue 8192000
EOF
    ${COLOR}"${OS_ID} ${OS_RELEASE} 优化资源限制参数成功!"${END}
}

set_kernel(){
    modprobe  br_netfilter
    cat > /etc/sysctl.conf <<-EOF
# Controls source route verification
net.ipv4.conf.default.rp_filter = 1
net.ipv4.ip_nonlocal_bind = 1
net.ipv4.ip_forward = 1

# Do not accept source routing
net.ipv4.conf.default.accept_source_route = 0

# Controls the System Request debugging functionality of the kernel
kernel.sysrq = 0

# Controls whether core dumps will append the PID to the core filename.
# Useful for debugging multi-threaded applications.
kernel.core_uses_pid = 1

# Controls the use of TCP syncookies
net.ipv4.tcp_syncookies = 1

# Disable netfilter on bridges.
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0

# Controls the default maxmimum size of a mesage queue
kernel.msgmnb = 65536

# Controls the maximum size of a message, in bytes
kernel.msgmax = 65536

# Controls the maximum shared segment size, in bytes
kernel.shmmax = 68719476736

# Controls the maximum number of shared memory segments, in pages
kernel.shmall = 4294967296

# TCP kernel paramater
net.ipv4.tcp_mem = 786432 1048576 1572864
net.ipv4.tcp_rmem = 4096        87380   4194304
net.ipv4.tcp_wmem = 4096        16384   4194304
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_sack = 1

# socket buffer
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 262144
net.core.somaxconn = 20480
net.core.optmem_max = 81920

# TCP conn
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_syn_retries = 3
net.ipv4.tcp_retries1 = 3
net.ipv4.tcp_retries2 = 15

# tcp conn reuse
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_timestamps = 0

net.ipv4.tcp_max_tw_buckets = 20000
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syncookies = 1

# keepalive conn
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.ip_local_port_range = 10001    65000

# swap
vm.overcommit_memory = 0
vm.swappiness = 10

#net.ipv4.conf.eth1.rp_filter = 0
#net.ipv4.conf.lo.arp_ignore = 1
#net.ipv4.conf.lo.arp_announce = 2
#net.ipv4.conf.all.arp_ignore = 1
#net.ipv4.conf.all.arp_announce = 2
EOF
    MAIN_KERNEL=`uname -r | cut -d. -f1`
    SUB_KERNEL=`uname -r | cut -d. -f2`
    if [ ${MAIN_KERNEL} -lt "4" -a ${SUB_KERNEL} -lt "12" ];then
    cat >> /etc/sysctl.conf <<-EOF	
net.ipv4.tcp_tw_recycle = 0
EOF
    fi
    sysctl -p &> /dev/null
    ${COLOR}"${OS_ID} ${OS_RELEASE} 优化内核参数成功!"${END}
}

optimization_ssh(){
    sed -ri.bak -e 's/^#(UseDNS).*/\1 no/' -e 's/^(GSSAPIAuthentication).*/\1 no/' /etc/ssh/sshd_config
    systemctl restart sshd
    ${COLOR}"${OS_ID} ${OS_RELEASE} SSH已优化完成!"${END}
}

set_ssh_port(){
    disable_apparmor
    disable_firewalls
    read -p "请输入端口号: " PORT
    sed -i 's/#Port 22/Port '${PORT}'/' /etc/ssh/sshd_config
    systemctl restart sshd
    ${COLOR}"${OS_ID} ${OS_RELEASE} 更改SSH端口号已完成,请重新登陆后生效!"${END}
}

set_base_alias(){
    ETHNAME=`ip addr | awk -F"[ :]" '/^2/{print $3}'`
    ETHNAME2=`ip addr | awk -F"[ :]" '/^3/{print $3}'`
    IP_NUM=`ip addr | awk -F"[: ]" '{print $1}' | grep -v '^$' | wc -l`
    if [ ${IP_NUM} == "2" ];then
        cat >>~/.bashrc <<-EOF
alias cdnet="cd /etc/sysconfig/network"
alias cdrepo="cd /etc/zypp/repos.d"
alias vie0="vim /etc/sysconfig/network/ifcfg-${ETHNAME}"
EOF
    else	
        cat >>~/.bashrc <<-EOF
alias cdnet="cd /etc/sysconfig/network"
alias cdrepo="cd /etc/zypp/repos.d"
alias vie0="vim /etc/sysconfig/network/ifcfg-${ETHNAME}"
alias vie1="vim /etc/sysconfig/network/ifcfg-${ETHNAME2}"
EOF
    fi
    DISK_NAME=`lsblk|awk -F" " '/disk/{printf $1}' | cut -c1-4`
    if [ ${DISK_NAME} == "sda" ];then
        cat >>~/.bashrc <<-EOF
alias scandisk="echo '- - -' > /sys/class/scsi_host/host0/scan;echo '- - -' > /sys/class/scsi_host/host1/scan;echo '- - -' > /sys/class/scsi_host/host2/scan"
EOF
    fi
    ${COLOR}"${OS_ID} ${OS_RELEASE} 系统别名已设置成功,请重新登陆后生效!"${END}
}

set_alias(){
    if grep -Eqi "(.*cdnet|.*cdrepo|.*vie0|.*vie1|.*scandisk)" ~/.bashrc;then
        sed -i -e '/.*cdnet/d'  -e '/.*cdrepo/d' -e '/.*vie0/d' -e '/.*vie1/d' -e '/.*scandisk/d' ~/.bashrc
        set_base_alias
    else
        set_base_alias
    fi
}

set_vimrc(){
    read -p "请输入作者名: " AUTHOR
    read -p "请输入QQ号: " QQ
    read -p "请输入网址: " V_MIRROR
    cat >~/.vimrc <<-EOF
set ts=4
set expandtab
set ignorecase
set cursorline
set autoindent
autocmd BufNewFile *.sh exec ":call SetTitle()"
func SetTitle()
    if expand("%:e") == 'sh'
    call setline(1,"#!/bin/bash")
    call setline(2,"#")
    call setline(3,"#*********************************************************************************************")
    call setline(4,"#Author:        ${AUTHOR}")
    call setline(5,"#QQ:            ${QQ}")
    call setline(6,"#Date:          ".strftime("%Y-%m-%d"))
    call setline(7,"#FileName:      ".expand("%"))
    call setline(8,"#MIRROR:        ${V_MIRROR}")
    call setline(9,"#Description:   The test script")
    call setline(10,"#Copyright (C): ".strftime("%Y")." All rights reserved")
    call setline(11,"#*********************************************************************************************")
    call setline(12,"")
    endif
endfunc
autocmd BufNewFile * normal G
EOF
    ${COLOR}"${OS_ID} ${OS_RELEASE} vimrc设置完成,请重新系统启动才能生效!"${END}
}

set_mail(){                                                                                                 
    rpm -q postfix &> /dev/null || { ${COLOR}"安装postfix服务,请稍等..."${END};zypper install -y postfix &> /dev/null; systemctl enable --now postfix &> /dev/null; }
    rpm -q mailx &> /dev/null || { ${COLOR}"安装mailx服务,请稍等..."${END};zypper install -y mailx &> /dev/null; }
    read -p "请输入邮箱地址: " MAIL
    read -p "请输入邮箱授权码: " AUTH
    SMTP=`echo ${MAIL} |awk -F"@" '{print $2}'`
    cat >~/.mailrc <<-EOF
set from=${MAIL}
set smtp=smtp.${SMTP}
set smtp-auth-user=${MAIL}
set smtp-auth-password=${AUTH}
set smtp-auth=login
set ssl-verify=ignore
EOF
    ${COLOR}"${OS_ID} ${OS_RELEASE} 邮件设置完成,请重新登录后才能生效!"${END}
}

red(){
    P_COLOR=31
}

green(){
    P_COLOR=32
}

yellow(){
    P_COLOR=33
}

blue(){
    P_COLOR=34
}

violet(){
    P_COLOR=35
}

cyan_blue(){
    P_COLOR=36
}

random_color(){
    P_COLOR="$[RANDOM%7+31]"
}

set_base_ps1(){
    C_PS1=$(echo "export PS1='\[\e[1;${P_COLOR}m\]\[\]\u@\h:\w #\[\] \[\e[0m\]'" >> ~/.bashrc)
}

set_ps1_env(){
    if grep -Eqi "^.*PS1" ~/.bashrc;then
        sed -i '/^.*PS1/d' ~/.bashrc
        set_base_ps1
    else
        set_base_ps1
    fi
}

set_ps1(){
    TIPS="${COLOR}${OS_ID} ${OS_RELEASE} PS1设置成功,请重新登录生效!${END}"
    while true;do
        echo -e "\E[$[RANDOM%7+31];1m"
        cat <<-EOF
1)31 红色
2)32 绿色
3)33 黄色
4)34 蓝色
5)35 紫色
6)36 青色
7)随机颜色
8)退出
EOF
        echo -e '\E[0m'

        read -p "请输入颜色编号(1-8): " NUM
        case ${NUM} in
        1)
            red
            set_ps1_env
            ${TIPS}
            ;;
        2)
            green
            set_ps1_env
            ${TIPS}
            ;;
        3)
            yellow
            set_ps1_env
            ${TIPS}
            ;;
        4)
            blue
            set_ps1_env
            ${TIPS}
            ;;
        5)
            violet
            set_ps1_env
            ${TIPS}
            ;;
        6)
            cyan_blue
            set_ps1_env
            ${TIPS}
            ;;
        7)
            random_color
            set_ps1_env
            ${TIPS}
            ;;
        8)
            break
            ;;
        *)
            ${COLOR}"输入错误,请输入正确的数字(1-8)!"${END}
            ;;
        esac
    done
}

set_vim(){
    echo "export EDITOR=vim" >> ~/.bashrc
}

set_vim_env(){
    if grep -Eqi ".*EDITOR" ~/.bashrc;then
        sed -i '/.*EDITOR/d' ~/.bashrc
        set_vim
    else
        set_vim
    fi
    ${COLOR}"${OS_ID} ${OS_RELEASE} 默认文本编辑器设置成功,请重新登录生效!"${END}
}

set_history(){
    echo 'export HISTTIMEFORMAT="%F %T "' >> ~/.bashrc 
}

set_history_env(){
    if grep -Eqi ".*HISTTIMEFORMAT" ~/.bashrc;then
        sed -i '/.*HISTTIMEFORMAT/d' ~/.bashrc
        set_history
    else
        set_history
    fi
    ${COLOR}"${OS_ID} ${OS_RELEASE} history格式设置成功,请重新登录生效!"${END}
}

disable_restart(){
    systemctl mask ctrl-alt-del.target
    ${COLOR}"${OS_ID} ${OS_RELEASE} 禁用ctrl+alt+del重启功能设置成功!"${END}
}

menu(){
    while true;do
        echo -e "\E[$[RANDOM%7+31];1m"
        cat <<-EOF
*********************************************************
*             系统初始化脚本菜单                        *
* 1.设置网络(单网卡)    13.更改SSH端口号                *
* 2.设置网络(双网卡)    14.设置系统别名                 *
* 3.设置主机名          15.设置vimrc配置文件            *
* 4.设置镜像仓库        16.安装邮件服务并配置邮件       *
* 5.建议安装软件        17.设置PS1(请进入选择颜色)      *
* 6.关闭防火墙          18.设置默认文本编辑器为vim      *
* 7.禁用AppArmor        19.设置history格式              *
* 8.禁用SWAP            20.禁用ctrl+alt+del重启系统功能 *
* 9.设置系统时区        21.重启系统                     *
* 10.优化资源限制参数   22.关机                         *
* 11.优化内核参数       23.退出                         *
* 12.优化SSH                                            *
*********************************************************
EOF
        echo -e '\E[0m'

        read -p "请选择相应的编号(1-23): " choice
        case ${choice} in
        1)
            set_network
            ;;
        2)
            set_dual_network
            ;;
        3)
            set_hostname
            ;;
        4)
            base_menu
            ;;
        5)
            minimal_install
            ;;
        6)
            disable_firewalls
            ;;
        7)
            disable_apparmor
            ;;
        8)
            set_swap
            ;;
        9)
            set_localtime
            ;;
        10)
            set_limits
            ;;
        11)
            set_kernel
            ;;
        12)
            optimization_ssh
            ;;
        13)
            set_ssh_port
            ;;
        14)
            set_alias
            ;;
        15)
            set_vimrc
            ;;
        16)
            set_mail
            ;;
        17)
            set_ps1
            ;;
        18)
            set_vim_env
            ;;
        19)
            set_history_env
            ;;
        20)
            disable_restart
            ;;
        21)
            reboot
            ;;
        22)
            shutdown -h now
            ;;
        23)
            break
            ;;
        *)
            ${COLOR}"输入错误,请输入正确的数字(1-23)!"${END}
            ;;
        esac
    done
}

main(){
    os
    if [ ${OS_ID} == "openSUSE" ];then
        menu
    else
        ${COLOR}"此脚本不支持${OS_ID} ${OS_RELEASE} 系统!"${END}
    fi
}

main