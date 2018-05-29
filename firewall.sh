
#!/bin/bash -norc


# Initialisation de la table FILTER

# Suppression de toutes les chaines pre-definies de la table
iptables -t filter -F
# Suppression de toutes les chaenes utilisateur de la table
iptables -t filter -X

# Initialisation de la table NAT
# Suppression de toutes les chaenes pre-definies de la table
iptables -t nat -F
# Suppression de toutes les chaenes utilisateur de la table
iptables -t nat -X
# Initialisation de la table MANGLE

# Suppression de toutes les chaenes pre-definies de la table
iptables -t mangle -F

# Suppression de toutes les chaenes utilisateur de la table
iptables -t mangle -X

MY_IP=`export LC_ALL=C && /sbin/ifconfig eth0 | grep 'inet addr' | cut -d':' -f2 | awk '{print $1}'`
IP_SERVEUR=192.168.1.50
IP_ANSIBLE= 10.1.1.137
IP_MAITRE= 10.1.1.1

# Initialisation de la table FILTER
#iptables -t filter -P INPUT   DROP
#iptables -t filter -P FORWARD DROP
#iptables -t filter -P OUTPUT  DROP
#iptables -t filter -F
#iptables -t filter -X


# Initialisation de la table NAT
iptables -t nat -P PREROUTING  ACCEPT
iptables -t nat -P OUTPUT      ACCEPT
iptables -t nat -P POSTROUTING ACCEPT
iptables -t nat -F
iptables -t nat -X


# Initialisation de la table MANGLE
iptables -t mangle -P PREROUTING  ACCEPT
iptables -t mangle -P INPUT       ACCEPT
iptables -t mangle -P FORWARD     ACCEPT
iptables -t mangle -P OUTPUT      ACCEPT
iptables -t mangle -P POSTROUTING ACCEPT
iptables -t mangle -F
iptables -t mangle -X

# Autorise toutes les connexions vers le loopback
iptables -t filter -A INPUT  -i lo -j ACCEPT
iptables -t filter -A OUTPUT -o lo -j ACCEPT

# Autorise les pings entrants et sortant depuis eth0
iptables -t filter -A INPUT  -i eth0 -p icmp -j DROP
iptables -t filter -A OUTPUT -o eth0 -p icmp -j ACCEPT

# Autorise a acc�der au serveur HTTP du pr�sentateur
iptables -t filter -A INPUT  -i eth0 -s $IP_SERVEUR -d $MY_IP -p tcp --sport 80 -j ACCEPT
iptables -t filter -A OUTPUT -o eth0 -s $MY_IP -d $IP_SERVEUR -p tcp --dport 80 -j ACCEPT

# Autorise notre machine ANSIBLE local a controler les autres
iptables -t filter -A INPUT  -i eth0 -s $IP_ANSIBLE -d $MY_IP -p tcp --sport 22 -j ACCEPT
iptables -t filter -A OUTPUT -o eth0 -s $MY_IP -d $IP_ANSIBLE -p tcp --dport 22 -j ACCEPT

# Autorise notre machine physique a controler les autres via SSH
iptables -t filter -A INPUT  -i eth0 -s $IP_MAITRE -d $MY_IP -p tcp --sport 22 -j ACCEPT
iptables -t filter -A OUTPUT -o eth0 -s $MY_IP -d $IP_MAITRE -p tcp --dport 22 -j ACCEPT

