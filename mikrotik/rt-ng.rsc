###############################################################################
# RouterOS 7.1.1
# software id = MA7L-82YS
#
# model = RBD52G-5HacD2HnD
# serial number = A9740A4EC657
# Notes: Start with a reset
#   > /system reset-configuration keep-users=yes no-defaults=yes run-after-reset=flash/rt-ng.rsc
#   change CHANGE_ME's
###############################################################################

{
# startup delay
:delay 5s

# temporary logging to file
/system logging
:if ([print count-only where action=restore]>0) do={ remove [ find action=restore ] }
action add disk-file-count=1 disk-file-name=flash/restore.log disk-lines-per-file=4096 name=restore target=disk
add action=restore topics=system,info
add action=restore topics=script,info
add action=restore topics=warning
add action=restore topics=error
add action=restore topics=critical
add action=restore topics=debug



#######################################
# System settings
#######################################

/system identity set name="rt-ng"
/system clock set time-zone-name=Europe/Moscow
/system routerboard settings set auto-upgrade=yes cpu-frequency=auto


#######################################
# Interfaces
#######################################

##################
# Ethernet ports
##################

/interface ethernet
set [ find default-name=ether1 ] disabled=no
set [ find default-name=ether2 ] disabled=no
set [ find default-name=ether3 ] disabled=no
set [ find default-name=ether4 ] disabled=no
set [ find default-name=ether5 ] disabled=no


##################
# WIFI Setup
##################

/interface wireless security-profiles
:do { add name=clients wpa2-pre-shared-key=CHANGE_ME } on-error={}
set [ find name=clients ] authentication-types=wpa2-psk  \
    mode=dynamic-keys group-ciphers=tkip,aes-ccm unicast-ciphers=tkip,aes-ccm
:do { add name=guests wpa2-pre-shared-key=CHANGE_ME } on-error={}
set [ find name=guests ] authentication-types=wpa2-psk  \
    mode=dynamic-keys group-ciphers=tkip,aes-ccm unicast-ciphers=tkip,aes-ccm
:do { add name=iot wpa2-pre-shared-key=CHANGE_ME } on-error={}
set [ find name=iot ] authentication-types=wpa2-psk  \
    mode=dynamic-keys group-ciphers=tkip,aes-ccm unicast-ciphers=tkip,aes-ccm
:do { add name=media wpa2-pre-shared-key=CHANGE_ME } on-error={}
set [ find name=media ] authentication-types=wpa2-psk  \
    mode=dynamic-keys group-ciphers=tkip,aes-ccm unicast-ciphers=tkip,aes-ccm

/interface wireless
set [ find default-name=wlan2 ] name=wlan5 mode=ap-bridge disabled=no \
    comment="WLAN 5 Clients" ssid=KotikiHQ_5 security-profile=clients \
    antenna-gain=0 band=5ghz-a/n/ac channel-width=20/40/80mhz-Ceee \
    distance=indoors frequency=auto installation=indoor station-roaming=enabled \
    wireless-protocol=802.11 wps-mode=disabled multicast-helper=full
set [ find default-name=wlan1 ] name=wlan24 mode=ap-bridge disabled=no \
    comment="WLAN 2.4 Clients" ssid=KotikiHQ_2.4 security-profile=clients \
    antenna-gain=0 band=2ghz-b/g/n channel-width=20/40mhz-Ce \
    distance=indoors frequency=auto installation=indoor station-roaming=enabled \
    wireless-protocol=802.11 wps-mode=disabled multicast-helper=full

:do { add name=wlan-guests5 master-interface=wlan5 } on-error={}
set [ find name=wlan-guests5 ] ssid=Kotiki_Guests comment="WLAN 5 Guests" disabled=no \
    master-interface=wlan5 security-profile=guests wps-mode=disabled \
    mac-address=76:4D:28:01:CD:38 multicast-helper=full
:do { add name=wlan-guests24 master-interface=wlan24 } on-error={}
set [ find name=wlan-guests24 ] ssid=Kotiki_Guests comment="WLAN 2.4 Guests" disabled=no \
    master-interface=wlan24 security-profile=guests wps-mode=disabled \
    mac-address=76:4D:28:01:CD:37 multicast-helper=full
:do { add name=wlan-iot24 master-interface=wlan24 } on-error={}
set [ find name=wlan-iot24 ] ssid=iotta comment="WLAN 2.4 IoT" disabled=no \
    master-interface=wlan24 security-profile=iot wps-mode=disabled \
    mac-address=76:4D:28:01:CD:36 multicast-helper=full
:do { add name=wlan-media5 master-interface=wlan5 } on-error={}
set [ find name=wlan-media5 ] ssid=Kotiki_Media comment="WLAN 2.4 IoT" disabled=no \
    master-interface=wlan5 security-profile=media wps-mode=disabled \
    mac-address=76:4D:28:01:CD:39 multicast-helper=full


##################
# Bridge & VLANs
##################

/interface bridge
:do { set [ find default-name=bridge ] name=br1 } on-error={}
:do { add name=br1 } on-error={}
set [ find name=br1 ] comment="LAN Bridge" protocol-mode=none \
    igmp-snooping=yes multicast-querier=yes

/interface bridge port
# ISP
:do { add bridge=br1 interface=ether1 } on-error={}
set bridge=br1 [ find interface=ether1 ] pvid=1000 comment="ISP1" \
    frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes

# Client ports
:do { add bridge=br1 interface=ether2 } on-error={}
set bridge=br1 [ find interface=ether2 ] pvid=2 comment="clients" \
    frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes
:do { add bridge=br1 interface=ether3 } on-error={}
set bridge=br1 [ find interface=ether3 ] pvid=2 comment="clients" \
    frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes
:do { add bridge=br1 interface=ether4 } on-error={}
set bridge=br1 [ find interface=ether4 ] pvid=2 comment="clients" \
    frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes
:do { add bridge=br1 interface=wlan24 } on-error={}
set bridge=br1 [ find interface=wlan24 ] pvid=2 comment="clients" \
    frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes
:do { add bridge=br1 interface=wlan5 } on-error={}
set bridge=br1 [ find interface=wlan5 ] pvid=2 comment="clients" \
    frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes

# Management port
:do { add bridge=br1 interface=ether5 } on-error={}
set bridge=br1 [ find interface=ether5 ] pvid=100 comment="management" \
    frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes

# Guests
:do { add bridge=br1 interface=wlan-guests24 } on-error={}
set bridge=br1 [ find interface=wlan-guests24 ] pvid=3 comment="guests" \
    frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes
:do { add bridge=br1 interface=wlan-guests5 } on-error={}
set bridge=br1 [ find interface=wlan-guests5 ] pvid=3 comment="guests" \
    frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes

# Media
:do { add bridge=br1 interface=wlan-media5 } on-error={}
set bridge=br1 [ find interface=wlan-media5 ] pvid=4 comment="media" \
    frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes

# IoT
:do { add bridge=br1 interface=wlan-iot24 } on-error={}
set bridge=br1 [ find interface=wlan-iot24 ] pvid=5 comment="iot" \
    frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes


/interface bridge vlan
:do { add bridge=br1 vlan-ids=2 } on-error={}
set [ find bridge=br1 and vlan-ids=2 ] tagged=br1 untagged=ether2,ether3,ether4,wlan5,wlan24
:do { add bridge=br1 vlan-ids=3 } on-error={}
set [ find bridge=br1 and vlan-ids=3 ] tagged=br1 untagged=wlan-guests5,wlan-guests24
:do { add bridge=br1 vlan-ids=4 } on-error={}
set [ find bridge=br1 and vlan-ids=4 ] tagged=br1 untagged=wlan-media5
:do { add bridge=br1 vlan-ids=5 } on-error={}
set [ find bridge=br1 and vlan-ids=5 ] tagged=br1 untagged=wlan-iot24
:do { add bridge=br1 vlan-ids=100 } on-error={}
set [ find bridge=br1 and vlan-ids=100 ] tagged=br1 untagged=ether5
:do { add bridge=br1 vlan-ids=1000 } on-error={}
set [ find bridge=br1 and vlan-ids=1000 ] tagged=br1 untagged=ether1


# Enable vlan security at the end
/interface bridge set [ find name=br1 ] \
           vlan-filtering=yes frame-types=admit-only-vlan-tagged

/interface vlan
:do { add interface=br1 name=vlan2-clients vlan-id=2 } on-error={}
set [ find name=vlan2-clients ] interface=br1 vlan-id=2
:do { add interface=br1 name=vlan3-guests vlan-id=3 } on-error={}
set [ find name=vlan3-guests ] interface=br1 vlan-id=3
:do { add interface=br1 name=vlan4-media vlan-id=4 } on-error={}
set [ find name=vlan4-media ] interface=br1 vlan-id=4
:do { add interface=br1 name=vlan5-iot vlan-id=5 } on-error={}
set [ find name=vlan5-iot ] interface=br1 vlan-id=5
:do { add interface=br1 name=vlan100-mgmt vlan-id=100 } on-error={}
set [ find name=vlan100-mgmt ] interface=br1 vlan-id=100
:do { add interface=br1 name=vlan1000-rostelecom vlan-id=1000 } on-error={}
set [ find name=vlan1000-rostelecom ] interface=br1 vlan-id=1000


##################
# Interface Lists
##################

/interface list
:do { add name=WAN } on-error={}
:do { add name=autoWAN } on-error={}
:do { add name=autoINTERNET } on-error={}
:do { add name=clients } on-error={}
:do { add name=guests } on-error={}
:do { add name=media } on-error={}
:do { add name=iot } on-error={}
:do { add name=mgmt } on-error={}
:do { add name=mydudes } on-error={}
:do { add name=alldudes } on-error={}
set [ find name=mydudes ] include=clients,media,iot,mgmt exclude=""
set [ find name=alldudes ] include=clients,media,iot,mgmt,guests exclude=""

/interface list member
:do { add interface=vlan2-clients list=clients } on-error={}
:do { add interface=vlan3-guests list=guests } on-error={}
:do { add interface=vlan4-media list=media } on-error={}
:do { add interface=vlan5-iot list=iot } on-error={}
:do { add interface=vlan100-mgmt list=mgmt } on-error={}
:do { add interface=vlan1000-rostelecom list=WAN } on-error={}

/interface detect-internet
set detect-interface-list=WAN \
    internet-interface-list=autoINTERNET wan-interface-list=autoWAN


#######################################
# IP Addressing
#######################################

/ip settings set ip-forward=yes rp-filter=strict
/ipv6 settings set disable-ipv6=no forward=yes

/ip address
:do { add interface=vlan2-clients address=10.66.6.1/25 } on-error={}
set [ find address="10.66.6.1/25" ] network=10.66.6.0 interface=vlan2-clients
:do { add interface=vlan3-guests address=10.66.6.129/27 } on-error={}
set [ find address="10.66.6.129/27" ] network=10.66.6.128 interface=vlan3-guests
:do { add interface=vlan4-media address=10.66.6.161/27 } on-error={}
set [ find address="10.66.6.161/27" ] network=10.66.6.160 interface=vlan4-media
:do { add interface=vlan100-mgmt address=192.168.88.1/24 } on-error={}
set [ find address="192.168.88.1/24" ] network=192.168.88.0 interface=vlan100-mgmt
:do { add interface=vlan100-mgmt address=10.66.7.1/27 } on-error={}
set [ find address="10.66.7.1/27" ] network=10.66.7.0 interface=vlan100-mgmt
:do { add interface=vlan5-iot address=10.66.7.129/25 } on-error={}
set [ find address="10.66.7.129/25" ] network=10.66.7.128 interface=vlan5-iot

:if ([print count-only where interface=br1]>0) do={ remove [ find interface=br1 ] }

/ip dhcp-client
:if ([print count-only where interface=vlan1000-rostelecom]=0) do={ add interface=vlan1000-rostelecom }
set [ find interface=vlan1000-rostelecom ] !dhcp-options use-peer-dns=no

/ipv6 dhcp-client
:if ([print count-only where interface=vlan1000-rostelecom]=0) do={ add interface=vlan1000-rostelecom request=address }
set [ find interface=vlan1000-rostelecom ] add-default-route=yes pool-name=rostelecom-ipv6 \
    request=address,prefix use-peer-dns=no pool-prefix-length=64 prefix-hint=::/56

/ipv6 address
:if ([print count-only where interface=vlan2-clients from-pool=rostelecom-ipv6 ]=0) do={
    add interface=vlan2-clients from-pool=rostelecom-ipv6 address=::/64 advertise=yes eui-64=yes
}
:if ([print count-only where interface=vlan3-guests from-pool=rostelecom-ipv6 ]=0) do={
    add interface=vlan3-guests from-pool=rostelecom-ipv6 address=::/64 advertise=yes eui-64=yes
}
:if ([print count-only where interface=vlan4-media from-pool=rostelecom-ipv6 ]=0) do={
    add interface=vlan4-media from-pool=rostelecom-ipv6 address=::/64 advertise=yes eui-64=yes
}
:if ([print count-only where interface=vlan5-iot from-pool=rostelecom-ipv6 ]=0) do={
    add interface=vlan5-iot from-pool=rostelecom-ipv6 address=::/64 advertise=yes eui-64=yes
}
:if ([print count-only where interface=vlan100-mgmt from-pool=rostelecom-ipv6 ]=0) do={
    add interface=vlan100-mgmt from-pool=rostelecom-ipv6 address=::/64 advertise=yes eui-64=yes
}


#######################################
# Services
#######################################

/ip neighbor discovery-settings set discover-interface-list=alldudes


##################
# Management services
##################

/ip service
disable api
disable api-ssl
disable ftp
disable telnet
set www port=8080 disabled=no
set winbox disabled=no

# import ssh public key for admin if file exists
:if ([/file print count-only where name=admin.pub]) do={
    /user ssh-keys import user=admin public-key-file=admin.pub
}
/ip ssh set forwarding-enabled=both strong-crypto=yes

/tool mac-server mac-winbox set allowed-interface-list=mydudes
/tool mac-server set allowed-interface-list=mydudes


##################
# DNS server
##################

/certificate import file-name=flash/DigiCertGlobalRootCA.crt.pem passphrase=""

/ip dns
set allow-remote-requests=yes servers="" \
    use-doh-server=https://1.1.1.1/dns-query verify-doh-cert=yes \
    max-concurrent-tcp-sessions=100

/ip cloud set ddns-enabled=yes ddns-update-interval=5m update-time=yes


##################
# RADVD
##################

/ipv6 nd
:if ([print count-only where interface=all]>0) do={ set [ find interface=all ] disabled=yes }
:do { add interface=vlan2-clients } on-error={}
set [ find inreface=vlan2-clients ] ra-lifetime=2h
:do { add interface=vlan3-guests } on-error={}
set [ find inreface=vlan3-guests ] ra-lifetime=2h
:do { add interface=vlan4-media } on-error={}
set [ find inreface=vlan4-media ] ra-lifetime=2h
:do { add interface=vlan5-iot } on-error={}
set [ find inreface=vlan5-iot ] ra-lifetime=2h
:do { add interface=vlan100-mgmt } on-error={}
set [ find inreface=vlan100-mgmt ] ra-lifetime=2h

/ipv6 nd prefix default
set preferred-lifetime=1w valid-lifetime=31d


##################
# DHCP server
##################

/ip pool
:if ([print count-only where name=default-dhcp]>0) do={ remove [ find name=default-dhcp ] }
:do { add name=clients ranges=192.168.1.1 } on-error={}
set [ find name=clients ] ranges=10.66.6.2-10.66.6.126
:do { add name=guests ranges=192.168.1.1 } on-error={}
set [ find name=guests ] ranges=10.66.6.129-10.66.6.158
:do { add name=media ranges=192.168.1.1 } on-error={}
set [ find name=media ] ranges=10.66.6.161-10.66.6.190
:do { add name=iot ranges=192.168.1.1 } on-error={}
set [ find name=iot ] ranges=10.66.7.129-10.66.7.254
:do { add name=mgmt ranges=192.168.1.1 } on-error={}
set [ find name=mgmt ] ranges=10.66.7.2-10.66.7.30

/ip dhcp-server network
:if ([print count-only where address="192.168.88.0/24"]>0) do={ remove [ find address="192.168.88.0/24" ] }
:do { add address="10.66.6.0/25" } on-error={}
set [ find address="10.66.6.0/25" ] netmask=25 \
    gateway=10.66.6.1 dns-server=10.66.6.1 ntp-server=10.66.6.1 domain=1984.run
:do { add address="10.66.6.128/27" } on-error={}
set [ find address="10.66.6.128/27" ] netmask=27 \
    gateway=10.66.6.129 dns-server=10.66.6.129 ntp-server=10.66.6.129 domain=1984.run
:do { add address="10.66.6.160/27" } on-error={}
set [ find address="10.66.6.160/27" ] netmask=27 \
    gateway=10.66.6.161 dns-server=10.66.6.161 ntp-server=10.66.6.161 domain=1984.run
:do { add address="10.66.7.0/27" } on-error={}
set [ find address="10.66.7.0/27" ] netmask=27 \
    gateway=10.66.7.1 dns-server=10.66.7.1 ntp-server=10.66.7.1 domain=1984.run
:do { add address="10.66.7.128/25" } on-error={}
set [ find address="10.66.7.128/25" ] netmask=25 \
    gateway=10.66.7.129 dns-server=10.66.7.129 ntp-server=10.66.7.129 domain=1984.run


/ip dhcp-server
:if ([print count-only where name=defconf]>0) do={ remove [ find name=defconf ] }
:do { add name=dhcp-clients interface=vlan2-clients } on-error={}
set [ find interface=vlan2-clients ] name=dhcp-clients interface=vlan2-clients \
    server-address=10.66.6.1 address-pool=clients lease-time=1w disabled=no
:do { add name=dhcp-guests interface=vlan3-guests } on-error={}
set [ find interface=vlan3-guests ] name=dhcp-guests interface=vlan3-guests \
    server-address=10.66.6.129 address-pool=guests lease-time=1h disabled=no
:do { add name=dhcp-media interface=vlan4-media } on-error={}
set [ find interface=vlan4-media ] name=dhcp-media interface=vlan4-media \
    server-address=10.66.6.161 address-pool=media lease-time=1w disabled=no
:do { add name=dhcp-iot interface=vlan5-iot } on-error={}
set [ find interface=vlan5-iot ] name=dhcp-iot interface=vlan5-iot \
    server-address=10.66.7.1 address-pool=iot lease-time=4w disabled=no
:do { add name=dhcp-mgmt interface=vlan100-mgmt } on-error={}
set [ find interface=vlan100-mgmt ] name=dhcp-mgmt interface=vlan100-mgmt \
    server-address=10.66.7.129 address-pool=mgmt lease-time=1w disabled=no

/ip dhcp-server lease
:if ([print count-only where mac-address=54:EF:44:2F:2C:8D]=0) do={ add mac-address=54:EF:44:2F:2C:8D }
set [ find mac-address=54:EF:44:2F:2C:8D ] address=10.66.7.130 server=dhcp-iot comment="Xiaomi Gateway 3"


##################
# NTP client & server
##################

/system ntp server set enabled=yes
/system ntp client servers
:do { add address=ru.pool.ntp.org } on-error={}
:do { add address=time.cloudflare.com } on-error={}


##################
# UPnP
##################

/ip upnp set enabled=yes allow-disable-external-interface=no show-dummy-rule=yes
/ip upnp interfaces
:do { add interface=vlan1000-rostelecom type=external } on-error={}
set [ find interface=vlan1000-rostelecom ] type=external disabled=no
:do { add interface=vlan2-clients type=internal } on-error={}
set [ find interface=vlan2-clients ] type=internal disabled=no
:do { add interface=vlan4-media type=internal } on-error={}
set [ find interface=vlan4-media ] type=internal disabled=no


#######################################
# IPv4 Firewalling & NAT
#######################################


##################
# Layer7 Protocols
##################

/ip firewall layer7-protocol
:do { add name=rdp regexp=rdpdr.*cliprdr.*rdpsnd } on-error={}
:do { add name=sip regexp="^(invite|register|cancel) sip[\t-\r -~]*sip/[0-2]\\.[0-9]" } on-error={}


##################
# IP Lists
##################

/ip firewall address-list

:if ([print count-only where list=clients]>0) do={ remove [ find list=clients ] }
add address=10.66.6.0/25 comment=clients list=clients

:if ([print count-only where list=guests]>0) do={ remove [ find list=guests ] }
add address=10.66.6.128/27 comment=guests list=guests

:if ([print count-only where list=media]>0) do={ remove [ find list=media ] }
add address=10.66.6.160/27 comment=media list=media

:if ([print count-only where list=mgmt]>0) do={ remove [ find list=mgmt ] }
add address=10.66.7.0/27 comment=mgmt list=mgmt
add address=192.168.88.0/24 comment=mgmt list=mgmt

:if ([print count-only where list=iot]>0) do={ remove [ find list=iot ] }
add address=10.66.7.128/25 comment=iot list=iot

:if ([print count-only where list=mydudes]>0) do={ remove [ find list=mydudes ] }
add address=10.66.6.0/25 comment=clients list=mydudes
add address=10.66.6.160/27 comment=media list=mydudes
add address=10.66.7.0/27 comment=mgmt list=mydudes
add address=10.66.7.128/25 comment=iot list=mydudes

:if ([print count-only where list=alldudes]>0) do={ remove [ find list=alldudes ] }
add address=10.66.6.0/25 comment=clients list=alldudes
add address=10.66.6.128/27 comment=guests list=alldudes
add address=10.66.6.160/27 comment=media list=alldudes
add address=10.66.7.0/27 comment=mgmt list=alldudes
add address=10.66.7.128/25 comment=iot list=alldudes

:if ([print count-only where list=self]>0) do={ remove [ find list=self ] }
add address=192.168.88.1/32 comment=self list=self
add address=10.66.6.1/32 comment=self list=self
add address=10.66.6.129/32 comment=self list=self
add address=10.66.6.161/32 comment=self list=self
add address=10.66.7.1/32 comment=self list=self
add address=10.66.7.129/32 comment=self list=self


##################
# Common chains
##################

/ip firewall filter

:if ([print count-only where chain=ICMP]>0) do={ remove [ find chain=ICMP ] }
add chain=ICMP action=accept protocol=icmp comment="ICMP chain" icmp-options=8:0 limit=10,100:packet
add chain=ICMP action=accept protocol=icmp icmp-options=0:0
add chain=ICMP action=accept protocol=icmp icmp-options=11:0
add chain=ICMP action=accept protocol=icmp icmp-options=3:0-1
add chain=ICMP action=accept protocol=icmp icmp-options=3:4
add chain=ICMP action=drop protocol=icmp log=yes log-prefix="reject:"

:if ([print count-only where chain=ssh-bruteforce]>0) do={ remove [ find chain=ssh-bruteforce ] }
add chain=ssh-bruteforce comment="Prevent SSH bruteforce" \
    src-address-list=ssh_blacklist action=drop
add chain=ssh-bruteforce connection-state=new src-address-list=ssh_stage3 \
    action=add-src-to-address-list address-list=ssh_blacklist address-list-timeout=1w3d
add chain=ssh-bruteforce connection-state=new src-address-list=ssh_stage2 \
    action=add-src-to-address-list address-list=ssh_stage3 address-list-timeout=4w2d
add chain=ssh-bruteforce connection-state=new address-list=ssh_stage2 \
    action=add-src-to-address-list address-list-timeout=4w2d src-address-list=ssh_stage1
add chain=ssh-bruteforce connection-state=new address-list=ssh_stage1 \
    action=add-src-to-address-list address-list-timeout=4w2d

:if ([print count-only where chain=common-rules]>0) do={ remove [ find chain=common-rules ] }
add chain=common-rules comment="Common rules" \
    action=accept connection-state=established,related,untracked
add chain=common-rules connection-state=invalid \
    log=yes log-prefix=invalid: action=drop
add chain=common-rules protocol=icmp action=jump jump-target=ICMP


##################
# INPUT CHAIN
##################

/ip firewall filter

# disable rejects before apply
:do { set [ find chain=input action=reject ] disabled=yes } on-error={}

:if ([print count-only where chain=WAN-SELF]>0) do={ remove [ find chain=WAN-SELF ] }
add chain=WAN-SELF comment="WAN-SELF accept SSH" protocol=tcp dst-port=22 \
    action=jump jump-target=ssh-bruteforce
add chain=WAN-SELF action=accept protocol=tcp dst-port=22
add chain=WAN-SELF comment="WAN-SELF reject DNS" protocol=udp dst-port=53 \
    action=reject reject-with=icmp-admin-prohibited
add chain=WAN-SELF protocol=tcp dst-port=53 \
    action=reject reject-with=icmp-admin-prohibited
add chain=WAN-SELF comment="WAN-SELF reject at the end" \
    log=yes log-prefix=reject: action=reject reject-with=icmp-admin-prohibited

:if ([print count-only where chain=MYDUDES-SELF]>0) do={ remove [ find chain=MYDUDES-SELF ] }
add chain=MYDUDES-SELF comment="MYDUDES-SELF accept FTP" \
    protocol=tcp dst-port=21 action=accept
add chain=MYDUDES-SELF comment="MYDUDES-SELF accept SSH" \
    protocol=tcp dst-port=22 action=accept
add chain=MYDUDES-SELF comment="MYDUDES-SELF accept SSDP/UPNP" \
    protocol=udp dst-port=1900 action=accept
add chain=MYDUDES-SELF comment="MYDUDES-SELF accept UPNP" \
    protocol=tcp dst-port=2828 action=accept
add chain=MYDUDES-SELF comment="MYDUDES-SELF accept HTTP to Mikrotik" protocol=tcp \
    dst-port=[ /ip/service get www port ] action=accept
add chain=MYDUDES-SELF comment="MYDUDES-SELF accept WINBOX" \
    protocol=tcp dst-port=8291 action=accept

:if ([print count-only where chain=ALLDUDES-SELF]>0) do={ remove [ find chain=ALLDUDES-SELF ] }
add chain=ALLDUDES-SELF comment="ALLDUDES-SELF jump to MYDUDES-SELF" \
    in-interface-list=mydudes action=jump jump-target=MYDUDES-SELF
add chain=ALLDUDES-SELF comment="ALLDUDES-SELF accept DNS" \
    protocol=udp dst-port=53 action=accept
add chain=ALLDUDES-SELF protocol=tcp dst-port=53 action=accept
add chain=ALLDUDES-SELF comment="ALLDUDES-SELF accept DHCP" \
    protocol=udp dst-port=67,68 action=accept
add chain=ALLDUDES-SELF comment="ALLDUDES-SELF accept Neighbor Discovery" \
    protocol=udp dst-port=5678 action=accept
add chain=ALLDUDES-SELF comment="ALLDUDES-SELF drop DTS Play-Fi broadcasts" \
    protocol=udp dst-port=10102 dst-address=255.255.255.255 action=drop
add chain=ALLDUDES-SELF comment="ALLDUDES-SELF drop Xiaomi Gateway broadcasts" \
    protocol=udp dst-port=54321 dst-address=255.255.255.255 action=drop
add chain=ALLDUDES-SELF comment="ALLDUDES-SELF reject all" \
    log=yes log-prefix=reject: reject-with=icmp-admin-prohibited action=reject

:if ([print count-only where chain=main-input]>0) do={ remove [ find chain=main-input ] }
add chain=main-input comment="main-input common rules" action=jump jump-target=common-rules
add chain=main-input comment="main-input accept IGMP" \
    protocol=igmp action=accept
add chain=main-input comment="Jump to WAN-SELF chain" in-interface-list=WAN \
    action=jump jump-target=WAN-SELF
add chain=main-input comment="Jump to ALLDUDES-SELF chain" in-interface-list=alldudes \
    action=jump jump-target=ALLDUDES-SELF
add chain=main-input comment="Reject all at the end" \
    log=yes log-prefix="input chain policy reject:" \
    reject-with=icmp-admin-prohibited action=reject

:if ([print count-only where jump-target=main-input]>0) do={ remove [ find jump-target=main-input ] }
add chain=input comment="Jump to input table" action=jump jump-target=main-input

# enable rejects after apply
:do { set [ find chain=input action=reject ] disabled=no } on-error={}

##################
# FORWARD CHAIN
##################

/ip firewall filter

# disable rejects before apply
:do { set [ find chain=forward action=reject ] disabled=yes } on-error={}

:if ([print count-only where chain=WAN-ALLDUDES]>0) do={ remove [ find chain=WAN-ALLDUDES ] }
add chain=WAN-ALLDUDES comment="WAN-ALLDUDES common rules" \
    action=jump jump-target=common-rules
add chain=WAN-ALLDUDES comment="WAN-ALLDUDES drop all not DSTNATed" \
    connection-nat-state=!dstnat connection-state=new action=drop
add chain=WAN-ALLDUDES comment="WAN-ALLDUDES SSH bruteforce" protocol=tcp dst-port=22 \
    action=jump jump-target=ssh-bruteforce
add chain=WAN-ALLDUDES comment="WAN-ALLDUDES reject all" \
    action=reject reject-with=icmp-network-unreachable

:if ([print count-only where chain=ALLDUDES-WAN]>0) do={ remove [ find chain=ALLDUDES-WAN ] }
add chain=ALLDUDES-WAN comment="ALLDUDES-WAN common rules" \
    action=jump jump-target=common-rules
add chain=ALLDUDES-WAN comment="ALLDUDES-WAN drop packets from LAN that do not have LAN IP" \
    log=yes log-prefix="ALLDUDES-WAN !LAN:" src-address-list=!alldudes action=drop
add chain=ALLDUDES-WAN comment="ALLDUDES-WAN accept all" action=accept

:if ([print count-only where chain=WAN-WAN]>0) do={ remove [ find chain=WAN-WAN ] }
add chain=WAN-WAN comment="WAN-WAN common rules" \
    action=jump jump-target=common-rules
add chain=WAN-WAN comment="WAN-WAN reject all" \
    log=yes log-prefix=reject: action=reject reject-with=icmp-network-unreachable

:if ([print count-only where chain=MGMT-ALLDUDES]>0) do={ remove [ find chain=MGMT-ALLDUDES ] }
add chain=MGMT-ALLDUDES comment="MGMT-ALLDUDES common rules" \
    action=jump jump-target=common-rules
add chain=MGMT-ALLDUDES comment="MGMT-ALLDUDES accept all" action=accept

:if ([print count-only where chain=GUESTS-ALLDUDES]>0) do={ remove [ find chain=GUESTS-ALLDUDES ] }
add chain=GUESTS-ALLDUDES comment="GUESTS-ALLDUDES common rules" \
    action=jump jump-target=common-rules
add chain=GUESTS-ALLDUDES comment="GUESTS-ALLDUDES reject all" \
    log=yes log-prefix=reject: action=reject reject-with=icmp-network-unreachable

:if ([print count-only where chain=IOT-ALLDUDES]>0) do={ remove [ find chain=IOT-ALLDUDES ] }
add chain=IOT-ALLDUDES comment="IOT-ALLDUDES common rules" \
    action=jump jump-target=common-rules
add chain=IOT-ALLDUDES comment="IOT-ALLDUDES reject all" \
    log=yes log-prefix=reject: action=reject reject-with=icmp-network-unreachable

:if ([print count-only where chain=MEDIA-ALLDUDES]>0) do={ remove [ find chain=MEDIA-ALLDUDES ] }
add chain=MEDIA-ALLDUDES comment="MEDIA-ALLDUDES common rules" \
    action=jump jump-target=common-rules
add chain=MEDIA-ALLDUDES comment="MEDIA-ALLDUDES reject all" \
    log=yes log-prefix=reject: action=reject reject-with=icmp-network-unreachable

:if ([print count-only where chain=CLIENTS-ALLDUDES]>0) do={ remove [ find chain=CLIENTS-ALLDUDES ] }
add chain=CLIENTS-ALLDUDES comment="CLIENTS-ALLDUDES common rules" \
    action=jump jump-target=common-rules
add chain=CLIENTS-ALLDUDES comment="CLIENTS-ALLDUDES accept all" action=accept

:if ([print count-only where chain=main-forward]>0) do={ remove [ find chain=main-forward ] }
add chain=main-forward comment="Jump to WAN-ALLDUDES chain" in-interface-list=WAN \
    out-interface-list=alldudes action=jump jump-target=WAN-ALLDUDES
add chain=main-forward comment="Jump to ALLDUDES-WAN chain" in-interface-list=alldudes \
    out-interface-list=WAN action=jump jump-target=ALLDUDES-WAN
add chain=main-forward comment="Jump to WAN-WAN chain" in-interface-list=WAN \
    out-interface-list=WAN action=jump jump-target=WAN-WAN
add chain=main-forward comment="Jump to MGMT-ALLDUDES chain" in-interface-list=mgmt \
    out-interface-list=alldudes action=jump jump-target=MGMT-ALLDUDES
add chain=main-forward comment="Jump to GUESTS-ALLDUDES chain" in-interface-list=guests \
    out-interface-list=alldudes action=jump jump-target=GUESTS-ALLDUDES
add chain=main-forward comment="Jump to IOT-ALLDUDES chain" in-interface-list=iot \
    out-interface-list=alldudes action=jump jump-target=IOT-ALLDUDES
add chain=main-forward comment="Jump to MEDIA-ALLDUDES chain" in-interface-list=media \
    out-interface-list=alldudes action=jump jump-target=MEDIA-ALLDUDES
add chain=main-forward comment="Jump to CLIENTS-ALLDUDES chain" in-interface-list=media \
    out-interface-list=alldudes action=jump jump-target=CLIENTS-ALLDUDES
add chain=main-forward comment="Reject at the end" \
    log=yes log-prefix="forward chain policy reject:" \
    action=reject reject-with=icmp-network-unreachable

:if ([print count-only where jump-target=main-forward]>0) do={ remove [ find jump-target=main-forward ] }
add chain=forward comment="Jump to forward table" action=jump jump-target=main-forward

# enable rejects after apply
:do { set [ find chain=forward action=reject ] disabled=no } on-error={}


##################
# NAT
##################

/ip firewall nat

:if ([print count-only where chain=main-masq]) do={ remove [ find chain=main-masq ] }
add chain=main-masq comment="Clients masquerade" \
    src-address-list=clients out-interface=vlan1000-rostelecom action=masquerade
add chain=main-masq comment="Guests masquerade" \
    src-address-list=guests out-interface=vlan1000-rostelecom action=masquerade
add chain=main-masq comment="Media masquerade" \
    src-address-list=media out-interface=vlan1000-rostelecom action=masquerade
add chain=main-masq comment="IoT masquerade" \
    src-address-list=iot out-interface=vlan1000-rostelecom action=masquerade

:if ([print count-only where jump-target=main-masq]) do={ remove [ find jump-target=main-masq ] }
add chain=srcnat comment="Jump to masquerade table" action=jump jump-target=main-masq


##################
# Mangle
##################

/ip firewall mangle

:if ([print count-only where new-packet-mark=ISP1-up]>0) do={ remove [ find new-packet-mark=ISP1-up ] }
add chain=forward out-interface=vlan1000-rostelecom comment=ISP1-up \
      action=mark-packet new-packet-mark=ISP1-up passthrough=yes
add chain=output out-interface=vlan1000-rostelecom \
      action=mark-packet new-packet-mark=ISP1-up passthrough=yes

:if ([print count-only where new-packet-mark=ISP1-down]>0) do={ remove [ find new-packet-mark=ISP1-down ] }
add chain=forward in-interface=vlan1000-rostelecom comment=ISP1-down \
      action=mark-packet new-packet-mark=ISP1-down passthrough=yes
add chain=input in-interface=vlan1000-rostelecom \
      action=mark-packet new-packet-mark=ISP1-down passthrough=yes


#######################################
# IPv6 Firewalling
#######################################

##################
# IP Lists
##################

/ipv6 firewall address-list
:if ([print count-only where list=no_forward_ipv6]>0) do={ remove [ find list=no_forward_ipv6 ] }
add address=fe80::/10  comment="RFC6890 Linked-Scoped Unicast" list=no_forward_ipv6
add address=ff00::/8  comment="multicast" list=no_forward_ipv6


##################
# Common chains
##################

/ipv6 firewall filter

:if ([print count-only where chain=ssh-bruteforce]>0) do={ remove [ find chain=ssh-bruteforce ] }
add chain=ssh-bruteforce comment="Prevent SSH bruteforce" \
    src-address-list=ssh_blacklist action=drop
add chain=ssh-bruteforce connection-state=new src-address-list=ssh_stage3 \
    action=add-src-to-address-list address-list=ssh_blacklist address-list-timeout=1w3d
add chain=ssh-bruteforce connection-state=new src-address-list=ssh_stage2 \
    action=add-src-to-address-list address-list=ssh_stage3 address-list-timeout=4w2d
add chain=ssh-bruteforce connection-state=new address-list=ssh_stage2 \
    action=add-src-to-address-list address-list-timeout=4w2d src-address-list=ssh_stage1
add chain=ssh-bruteforce connection-state=new address-list=ssh_stage1 \
    action=add-src-to-address-list address-list-timeout=4w2d

:if ([print count-only where chain=common-rules]>0) do={ remove [ find chain=common-rules ] }
add chain=common-rules comment="Common: accept established,related,untracked" \
    connection-state=established,related,untracked action=accept
add chain=common-rules comment="Common: invalid" \
    log=yes log-prefix=invalid: action=drop connection-state=invalid
add chain=common-rules comment="Common: all ICMPv6" protocol=icmpv6 action=accept
add chain=common-rules comment="Common: accept IKE" protocol=udp dst-port=500,4500 action=accept
add chain=common-rules comment="Common: accept HIP" protocol=139
add chain=common-rules comment="Common: accept IPSec AH" protocol=ipsec-ah
add chain=common-rules comment="Common: accept IPSec ESP" protocol=ipsec-esp
add chain=common-rules comment="Common: accept all that matches IPSec policy" \
    ipsec-policy=in,ipsec action=accept
add chain=common-rules comment="Common: accept UDP traceroute" \
    protocol=udp port=33434-33534 action=accept


##################
# INPUT CHAIN
##################

/ipv6 firewall filter

# disable rejects before apply
:do { set [ find chain=input action=reject ] disabled=yes } on-error={}

:if ([print count-only where chain=WAN-SELF]>0) do={ remove [ find chain=WAN-SELF ] }
add chain=WAN-SELF comment="WAN-SELF accept SSH" protocol=tcp dst-port=22 \
    action=jump jump-target=ssh-bruteforce
add chain=WAN-SELF action=accept protocol=tcp dst-port=22
add chain=WAN-SELF comment="WAN-SELF reject DNS" protocol=udp dst-port=53 \
    action=reject reject-with=icmp-admin-prohibited
add chain=WAN-SELF protocol=tcp dst-port=53 \
    action=reject reject-with=icmp-admin-prohibited
add chain=WAN-SELF comment="WAN-SELF DHCPv6-Client prefix delegation" \
    protocol=udp dst-port=546 action=accept
add chain=WAN-SELF comment="WAN-SELF reject at the end" \
    log=yes log-prefix=reject: action=reject reject-with=icmp-admin-prohibited

:if ([print count-only where chain=MYDUDES-SELF]>0) do={ remove [ find chain=MYDUDES-SELF ] }
add chain=MYDUDES-SELF comment="MYDUDES-SELF accept FTP" \
    protocol=tcp dst-port=21 action=accept
add chain=MYDUDES-SELF comment="MYDUDES-SELF accept SSH" \
    protocol=tcp dst-port=22 action=accept
add chain=MYDUDES-SELF comment="MYDUDES-SELF accept HTTP to Mikrotik" protocol=tcp \
    dst-port=[ /ip/service get www port ] action=accept
add chain=MYDUDES-SELF comment="MYDUDES-SELF accept WINBOX" \
    protocol=tcp dst-port=8291 action=accept

:if ([print count-only where chain=ALLDUDES-SELF]>0) do={ remove [ find chain=ALLDUDES-SELF ] }
add chain=ALLDUDES-SELF comment="ALLDUDES-SELF jump to MYDUDES-SELF" \
    in-interface-list=mydudes action=jump jump-target=MYDUDES-SELF
add chain=ALLDUDES-SELF comment="ALLDUDES-SELF accept DNS" \
    protocol=udp dst-port=53 action=accept
add chain=ALLDUDES-SELF protocol=tcp dst-port=53 action=accept
add chain=ALLDUDES-SELF comment="ALLDUDES-SELF accept DHCP" \
    protocol=udp dst-port=67,68 action=accept
add chain=ALLDUDES-SELF comment="ALLDUDES-SELF accept Neighbor Discovery" \
    protocol=udp dst-port=5678 action=accept
add chain=ALLDUDES-SELF comment="ALLDUDES-SELF reject all" \
    log=yes log-prefix=reject: reject-with=icmp-admin-prohibited action=reject

:if ([print count-only where chain=main-input]>0) do={ remove [ find chain=main-input ] }
add chain=main-input comment="main-input common rules" action=jump jump-target=common-rules
add chain=main-input comment="main-input accept IGMP" \
    protocol=igmp action=accept
add chain=main-input comment="Jump to WAN-SELF chain" in-interface-list=WAN \
    action=jump jump-target=WAN-SELF
add chain=main-input comment="Jump to ALLDUDES-SELF chain" in-interface-list=alldudes \
    action=jump jump-target=ALLDUDES-SELF
add chain=main-input comment="Reject all at the end" \
    log=yes log-prefix="input chain policy reject:" \
    reject-with=icmp-admin-prohibited action=reject

:if ([print count-only where jump-target=main-input]>0) do={ remove [ find jump-target=main-input ] }
add chain=input comment="Jump to input table" action=jump jump-target=main-input

# enable rejects after apply
:do { set [ find chain=input action=reject ] disabled=no } on-error={}

##################
# FORWARD CHAIN
##################

/ipv6 firewall filter

# disable rejects before apply
:do { set [ find chain=forward action=reject ] disabled=yes } on-error={}

:if ([print count-only where chain=WAN-ALLDUDES]>0) do={ remove [ find chain=WAN-ALLDUDES ] }
add chain=WAN-ALLDUDES comment="WAN-ALLDUDES common rules" \
    action=jump jump-target=common-rules
add chain=WAN-ALLDUDES comment="WAN-ALLDUDES SSH bruteforce" protocol=tcp dst-port=22 \
    action=jump jump-target=ssh-bruteforce
add chain=WAN-ALLDUDES comment="WAN-ALLDUDES IPFS" \
    protocol=tcp dst-port=4001 action=accept
add chain=WAN-ALLDUDES protocol=udp dst-port=4001 action=accept
add chain=WAN-ALLDUDES comment="WAN-ALLDUDES ZeroTier" \
    protocol=udp dst-port=9993 action=accept
add chain=WAN-ALLDUDES comment="WAN-ALLDUDES reject all" \
    action=reject reject-with=icmp-admin-prohibited

:if ([print count-only where chain=ALLDUDES-WAN]>0) do={ remove [ find chain=ALLDUDES-WAN ] }
add chain=ALLDUDES-WAN comment="ALLDUDES-WAN common rules" \
    action=jump jump-target=common-rules
add chain=ALLDUDES-WAN comment="ALLDUDES-WAN accept all" action=accept

:if ([print count-only where chain=WAN-WAN]>0) do={ remove [ find chain=WAN-WAN ] }
add chain=WAN-WAN comment="WAN-WAN common rules" \
    action=jump jump-target=common-rules
add chain=WAN-WAN comment="WAN-WAN reject all" \
    log=yes log-prefix=reject: action=reject reject-with=icmp-admin-prohibited

:if ([print count-only where chain=MGMT-ALLDUDES]>0) do={ remove [ find chain=MGMT-ALLDUDES ] }
add chain=MGMT-ALLDUDES comment="MGMT-ALLDUDES common rules" \
    action=jump jump-target=common-rules
add chain=MGMT-ALLDUDES comment="MGMT-ALLDUDES accept all" action=accept

:if ([print count-only where chain=GUESTS-ALLDUDES]>0) do={ remove [ find chain=GUESTS-ALLDUDES ] }
add chain=GUESTS-ALLDUDES comment="GUESTS-ALLDUDES common rules" \
    action=jump jump-target=common-rules
add chain=GUESTS-ALLDUDES comment="GUESTS-ALLDUDES reject all" \
    log=yes log-prefix=reject: action=reject reject-with=icmp-admin-prohibited

:if ([print count-only where chain=IOT-ALLDUDES]>0) do={ remove [ find chain=IOT-ALLDUDES ] }
add chain=IOT-ALLDUDES comment="IOT-ALLDUDES common rules" \
    action=jump jump-target=common-rules
add chain=IOT-ALLDUDES comment="IOT-ALLDUDES reject all" \
    log=yes log-prefix=reject: action=reject reject-with=icmp-admin-prohibited

:if ([print count-only where chain=MEDIA-ALLDUDES]>0) do={ remove [ find chain=MEDIA-ALLDUDES ] }
add chain=MEDIA-ALLDUDES comment="MEDIA-ALLDUDES common rules" \
    action=jump jump-target=common-rules
add chain=MEDIA-ALLDUDES comment="MEDIA-ALLDUDES reject all" \
    log=yes log-prefix=reject: action=reject reject-with=icmp-admin-prohibited

:if ([print count-only where chain=CLIENTS-ALLDUDES]>0) do={ remove [ find chain=CLIENTS-ALLDUDES ] }
add chain=CLIENTS-ALLDUDES comment="CLIENTS-ALLDUDES common rules" \
    action=jump jump-target=common-rules
add chain=CLIENTS-ALLDUDES comment="CLIENTS-ALLDUDES accept all" action=accept

:if ([print count-only where chain=main-forward]>0) do={ remove [ find chain=main-forward ] }
add chain=main-forward comment="Drop bad forward IPs" \
    action=drop src-address-list=no_forward_ipv6
add chain=main-forward action=drop dst-address-list=no_forward_ipv6
add chain=main-forward comment="rfc4890 drop hop-limit=1" \
    hop-limit=equal:1 protocol=icmpv6 action=drop
add chain=main-forward comment="Jump to WAN-ALLDUDES chain" in-interface-list=WAN \
    out-interface-list=alldudes action=jump jump-target=WAN-ALLDUDES
add chain=main-forward comment="Jump to ALLDUDES-WAN chain" in-interface-list=alldudes \
    out-interface-list=WAN action=jump jump-target=ALLDUDES-WAN
add chain=main-forward comment="Jump to WAN-WAN chain" in-interface-list=WAN \
    out-interface-list=WAN action=jump jump-target=WAN-WAN
add chain=main-forward comment="Jump to MGMT-ALLDUDES chain" in-interface-list=mgmt \
    out-interface-list=alldudes action=jump jump-target=MGMT-ALLDUDES
add chain=main-forward comment="Jump to GUESTS-ALLDUDES chain" in-interface-list=guests \
    out-interface-list=alldudes action=jump jump-target=GUESTS-ALLDUDES
add chain=main-forward comment="Jump to IOT-ALLDUDES chain" in-interface-list=iot \
    out-interface-list=alldudes action=jump jump-target=IOT-ALLDUDES
add chain=main-forward comment="Jump to MEDIA-ALLDUDES chain" in-interface-list=media \
    out-interface-list=alldudes action=jump jump-target=MEDIA-ALLDUDES
add chain=main-forward comment="Jump to CLIENTS-ALLDUDES chain" in-interface-list=media \
    out-interface-list=alldudes action=jump jump-target=CLIENTS-ALLDUDES
add chain=main-forward comment="Reject at the end" \
    log=yes log-prefix="forward chain policy reject:" \
    action=reject reject-with=icmp-admin-prohibited

:if ([print count-only where jump-target=main-forward]>0) do={ remove [ find jump-target=main-forward ] }
add chain=forward comment="Jump to forward table" action=jump jump-target=main-forward

# enable rejects after apply
:do { set [ find chain=forward action=reject ] disabled=no } on-error={}


##################
# Mangle
##################

# disabled because of ROS7 IPv6 conntrack vs queues bug

/ipv6 firewall mangle

:if ([print count-only where new-packet-mark=ISP1-up]>0) do={ remove [ find new-packet-mark=ISP1-up ] }
add chain=forward out-interface=vlan1000-rostelecom comment=ISP1-up \
      action=mark-packet new-packet-mark=ISP1-up passthrough=yes disabled=yes
add chain=output out-interface=vlan1000-rostelecom \
      action=mark-packet new-packet-mark=ISP1-up passthrough=yes disabled=yes

:if ([print count-only where new-packet-mark=ISP1-down]>0) do={ remove [ find new-packet-mark=ISP1-down ] }
add chain=forward in-interface=vlan1000-rostelecom comment=ISP1-down \
      action=mark-packet new-packet-mark=ISP1-down passthrough=yes disabled=yes
add chain=input in-interface=vlan1000-rostelecom \
      action=mark-packet new-packet-mark=ISP1-down passthrough=yes disabled=yes


#######################################
# Queue
#######################################

/queue type
:do { add name=ISP1-upload kind=cake } on-error={}
set [ find name=ISP1-upload ] kind=cake cake-bandwidth=81M cake-rtt-scheme=internet \
    cake-nat=yes cake-diffserv=diffserv3 cake-overhead-scheme=ether-vlan \
    cake-autorate-ingress=no cake-ack-filter=filter
:do { add name=ISP1-download kind=cake } on-error={}
set [ find name=ISP1-download ] kind=cake cake-bandwidth=83M cake-rtt-scheme=internet \
    cake-nat=yes cake-diffserv=diffserv3 cake-overhead-scheme=ether-vlan \
    cake-autorate-ingress=yes cake-wash=yes

/queue tree
:do { add name=ISP1-upload parent=global } on-error={}
set [ find name=ISP1-upload ] packet-mark=ISP1-up queue=ISP1-upload

:do { add name=ISP1-download parent=global } on-error={}
set [ find name=ISP1-download ] packet-mark=ISP1-down queue=ISP1-download


#######################################
# Backups
#######################################

/system script
:do { add name=cbackup } on-error={}
set [ find name=cbackup ] source="/system/backup/cloud\r\n:if ([print count-only where name=default]=0) do={\r\n    upload-file action=create-and-upload name=default password=(:put [/system/identity get name])\r\n} else={\r\n    upload-file action=create-and-upload name=default password=(:put [/system/identity get name]) replace=default\r\n}"

/system scheduler
:do { add name=cloud_backup } on-error={}
set [ find name="cloud_backup" ] interval=1d on-event=cbackup


# ending delay
:delay 10s

# Teardown temporary logging to disk
/system logging
remove [ find where action=restore ]
action remove [/system logging action find where name=restore]

}
