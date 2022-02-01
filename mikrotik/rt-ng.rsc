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
# Wireguard
##################

/interface wireguard
:do { add name=azirevpn-dk1 } on-error={}
set [ find name=azirevpn-dk1 ] listen-port=51820 mtu=1420
# set [ find name=azirevpn-dk1 ] private-key="CHANGE_ME"
:do { add name=azirevpn-no1 } on-error={}
set [ find name=azirevpn-no1 ] listen-port=51821 mtu=1420
# set [ find name=azirevpn-no1 ] private-key="CHANGE_ME"
:do { add name=azirevpn-se1 } on-error={}
set [ find name=azirevpn-se1 ] listen-port=51823 mtu=1420
# set [ find name=azirevpn-se1 ] private-key="CHANGE_ME"
:do { add name=warp } on-error={}
set [ find name=warp ] listen-port=51824 mtu=1420
# set [ find name=warp ] private-key="CHANGE_ME"

/interface wireguard peers
:if ([print count-only where interface=azirevpn-dk1 endpoint-address=dk1.wg.azirevpn.net]=0) do={
  add interface=azirevpn-dk1 public-key="" allowed-address=::/0
}
set [ find interface=azirevpn-dk1 ] allowed-address=0.0.0.0/0,::/0 \
    public-key="rVwQJxsaiZAgv6DzXcX7hk5+zYqsgPMJpY8KDHvmFHQ=" \
    endpoint-address=dk1.wg.azirevpn.net endpoint-port=51820 persistent-keepalive=30s
:if ([print count-only where interface=azirevpn-se1 endpoint-address=se1.wg.azirevpn.net]=0) do={
  add interface=azirevpn-se1 public-key="" allowed-address=::/0
}
set [ find interface=azirevpn-se1 ] allowed-address=0.0.0.0/0,::/0 \
    public-key="T28Qn5VFzT4wiwEPd7DscwcP3Rsmq23QcnjH1N5G/wc=" \
    endpoint-address=se1.wg.azirevpn.net endpoint-port=51820 persistent-keepalive=30s
:if ([print count-only where interface=azirevpn-no1 endpoint-address=no1.wg.azirevpn.net]=0) do={
  add interface=azirevpn-no1 public-key="" allowed-address=::/0
}
set [ find interface=azirevpn-no1 ] allowed-address=0.0.0.0/0,::/0 \
    public-key="OsswT7RVN/M8jpDoARlsQshjtIr0R/1g3NAyCTl/4BY=" \
    endpoint-address=no1.wg.azirevpn.net endpoint-port=51820 persistent-keepalive=30s
:if ([print count-only where interface=warp endpoint-address=engage.cloudflareclient.com]=0) do={
  add interface=warp public-key="" allowed-address=::/0
}
set [ find interface=warp ] allowed-address=0.0.0.0/0,::/0 \
    public-key="bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=" \
    endpoint-address=engage.cloudflareclient.com endpoint-port=2408 persistent-keepalive=30s


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
:do { add name=wg } on-error={}

/interface list member
:do { add interface=vlan2-clients list=clients } on-error={}
:do { add interface=vlan3-guests list=guests } on-error={}
:do { add interface=vlan4-media list=media } on-error={}
:do { add interface=vlan5-iot list=iot } on-error={}
:do { add interface=vlan100-mgmt list=mgmt } on-error={}
:do { add interface=vlan1000-rostelecom list=WAN } on-error={}
:do { add interface=azirevpn-dk1 list=WAN } on-error={}
:do { add interface=azirevpn-no1 list=WAN } on-error={}
:do { add interface=azirevpn-se1 list=WAN } on-error={}
:do { add interface=azirevpn-dk1 list=wg } on-error={}
:do { add interface=azirevpn-no1 list=wg } on-error={}
:do { add interface=azirevpn-se1 list=wg } on-error={}
:do { add interface=warp list=WAN } on-error={}
:do { add interface=warp list=wg } on-error={}

/interface detect-internet set detect-interface-list=none


#######################################
# IP Addressing
#######################################

/ip settings set ip-forward=yes rp-filter=strict allow-fast-path=no
/ipv6 settings set disable-ipv6=no forward=yes

/ip address
:do { add interface=vlan2-clients address=10.66.6.1/25 } on-error={}
set [ find address="10.66.6.1/25" ] network=10.66.6.0 interface=vlan2-clients
:do { add interface=vlan3-guests address=10.66.6.129/27 } on-error={}
set [ find address="10.66.6.129/27" ] network=10.66.6.128 interface=vlan3-guests
:do { add interface=vlan4-media address=10.66.6.161/27 } on-error={}
set [ find address="10.66.6.161/27" ] network=10.66.6.160 interface=vlan4-media
:do { add interface=vlan100-mgmt address=10.66.7.1/27 } on-error={}
set [ find address="10.66.7.1/27" ] network=10.66.7.0 interface=vlan100-mgmt
:do { add interface=vlan5-iot address=10.66.7.129/25 } on-error={}
set [ find address="10.66.7.129/25" ] network=10.66.7.128 interface=vlan5-iot
:do { add interface=azirevpn-dk1 address=100.73.18.133/19 } on-error={}
set [ find address="100.73.18.133/19" ] network=100.73.0.0 interface=azirevpn-dk1
:do { add interface=azirevpn-no1 address=10.0.28.206/19 } on-error={}
set [ find address="10.0.28.206/19" ] network=10.0.0.0 interface=azirevpn-no1
:do { add interface=azirevpn-se1 address=10.10.15.61/19 } on-error={}
set [ find address="10.10.15.61/19" ] network=10.10.0.0 interface=azirevpn-se1
:do { add interface=warp address=172.16.0.2/32 } on-error={}
set [ find address="172.16.0.2/32" ] network=172.16.0.2 interface=warp

:if ([print count-only where interface=br1]>0) do={ remove [ find interface=br1 ] }

/ip dhcp-client
:if ([print count-only where interface=vlan1000-rostelecom]=0) do={ add interface=vlan1000-rostelecom }
set [ find interface=vlan1000-rostelecom ] !dhcp-options use-peer-dns=no \
    add-default-route=yes script=":if (\$bound=1) do={\r\
    \n    /ip route set [ find comment=ISP1-check ] gateway=\$\"gateway-address\"\r\
    \n    /routing rule set [ find comment=ISP1-out ] src-address=\$\"lease-address\" disabled=no\r\
    \n    /routing bgp template set default router-id=\$\"lease-address\"\r\
    \n} else={\
    \n    /ip firewall connection remove [ find connection-mark=ISP1 ]\r\
    \n    /routing rule set [ find comment=ISP1-out ] disabled=yes\
    \n}"

/ipv6 dhcp-client
:if ([print count-only where interface=vlan1000-rostelecom]=0) do={ add interface=vlan1000-rostelecom request=address }
set [ find interface=vlan1000-rostelecom ] add-default-route=yes pool-name=rostelecom-ipv6 \
    request=address,prefix use-peer-dns=no pool-prefix-length=64 prefix-hint=::/56 \
    default-route-distance=254

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
:if ([print count-only where interface=azirevpn-dk1]=0) do={
    add interface=azirevpn-dk1 address=2a0e:1c80:f:2000::1286/64 advertise=yes
}
:if ([print count-only where interface=azirevpn-se1]=0) do={
    add interface=azirevpn-se1 address=2a03:8600:1001:4000::f3e/64 advertise=yes
}
:if ([print count-only where interface=azirevpn-no1]=0) do={
    add interface=azirevpn-no1 address=2a0c:dd43:1:2000::1ccf/64 advertise=yes
}
:if ([print count-only where interface=warp]=0) do={
    add interface=warp address=fd01:5ca1:ab1e:82d0:ae30:4c4a:9629:2bbe/128 advertise=no
}


#######################################
# Services
#######################################

/ip neighbor discovery-settings set discover-interface-list=!WAN


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
set allow-remote-requests=yes \
    servers=91.231.153.2,2001:67c:15ec:1337::2,192.211.0.2,2a0a:3507::2 \
    use-doh-server=https://1.1.1.1/dns-query verify-doh-cert=yes \
    max-concurrent-tcp-sessions=100

/ip dns static
:if ([print count-only where name=dk1.wg.azirevpn.net]=0) do={ add name=dk1.wg.azirevpn.net address=127.1.1.1 }
set [ find name=dk1.wg.azirevpn.net ] address=45.148.16.18
:if ([print count-only where name=no1.wg.azirevpn.net]=0) do={ add name=no1.wg.azirevpn.net address=127.1.1.1 }
set [ find name=no1.wg.azirevpn.net ] address=194.32.146.82
:if ([print count-only where name=se1.wg.azirevpn.net]=0) do={ add name=se1.wg.azirevpn.net address=127.1.1.1 }
set [ find name=se1.wg.azirevpn.net ] address=45.15.16.60
:if ([print count-only where name=engage.cloudflareclient.com]=0) do={ add name=engage.cloudflareclient.com address=127.1.1.1 }
set [ find name=engage.cloudflareclient.com ] address=162.159.192.1

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
:if ([print count-only where mac-address=9C:B6:D0:03:A3:8F]=0) do={ add mac-address=9C:B6:D0:03:A3:8F }
set [ find mac-address=9C:B6:D0:03:A3:8F ] address=10.66.6.7 server=dhcp-clients comment="alien"
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
# Routing
#######################################

##################
# Routings tables
##################

/routing table
:if ([print count-only where name=ISP1]=0) do={ add fib name=ISP1 }
:if ([print count-only where name=anyvpn]=0) do={ add fib name=anyvpn }
:if ([print count-only where name=azirevpn-dk1]=0) do={ add fib name=azirevpn-dk1 }
:if ([print count-only where name=azirevpn-no1]=0) do={ add fib name=azirevpn-no1 }
:if ([print count-only where name=azirevpn-se1]=0) do={ add fib name=azirevpn-se1 }
:if ([print count-only where name=warp]=0) do={ add fib name=warp }
:if ([print count-only where name=antifilter]=0) do={ add fib name=antifilter }


##################
# Routing rules
##################

/routing rule
:if ([print count-only]>0) do={ remove [ find ] }
add comment=toLAN dst-address=10.66.6.0/23 action=lookup table=main
add comment=ISP1-out action=lookup table=ISP1 \
    src-address=[ /ip/address/get value-name=address number=[ find interface=vlan1000-rostelecom ] ]
add comment=azirevpn-dk1-out action=lookup table=azirevpn-dk1 \
    src-address=[ /ip/address/get value-name=address number=[ find interface=azirevpn-dk1 ] ]
add comment=azirevpn-no1-out action=lookup table=azirevpn-no1 \
    src-address=[ /ip/address/get value-name=address number=[ find interface=azirevpn-no1 ] ]
add comment=azirevpn-se1-out action=lookup table=azirevpn-se1 \
    src-address=[ /ip/address/get value-name=address number=[ find interface=azirevpn-se1 ] ]
add comment=warp-out action=lookup table=warp \
    src-address=[ /ip/address/get value-name=address number=[ find interface=warp ] ]
# dhcp client adds dynamic rule
/ip dhcp-client release vlan1000-rostelecom

add comment="anitifilter bgp peer" dst-address=163.172.210.8/32 action=lookup table=anyvpn
add comment="Upstream DNS servers" dst-address=91.231.153.2/32 action=lookup table=anyvpn
add comment="Upstream DNS servers" dst-address=192.211.0.2/32 action=lookup table=anyvpn
add comment="Upstream DNS servers" dst-address=2001:67c:15ec:1337::2/128 action=lookup table=anyvpn
add comment="Upstream DNS servers" dst-address=2a0a:3507::2/128 action=lookup table=anyvpn
add comment="LinkedIn" dst-address=144.2.12.0/24 action=lookup table=anyvpn
add comment="alien to vpn" src-address=10.66.6.7/32 action=lookup table=anyvpn
add comment="antifilter - last before main table" action=lookup table=antifilter


##################
# Static routes
##################

#               Virtual IPs
# ISP1          127.88.1.1
# ISP2          127.88.1.2
# azirevpn-dk1  127.88.2.1
# azirevpn-no1  127.88.2.2
# azirevpn-se1  127.88.2.3
# warp          127.88.2.4
# any alive vpn 127.88.2.100

# checks
#         adguard             cleanbrowsing   opendns        cloudflare           yndx                    quad9           dnsfilter
# ISP1    94.140.14.14        185.228.168.168 208.67.222.123 1.1.1.2              77.88.8.88
#         2a10:50c0::ad1:ff   2a0d:2a00:1::                  2606:4700:4700::1112 2a02:6b8::feed:bad
# ISP2    94.140.15.15        185.228.169.168 208.67.220.123 1.0.0.2              77.88.8.2
#         2a10:50c0::ad2:ff   2a0d:2a00:2::                  2606:4700:4700::1002 2a02:6b8:0:1::feed:bad
# az dk1  94.140.14.140       185.228.168.10  208.67.222.222 1.1.1.3                                      9.9.9.9
#         2a10:50c0::1:ff     2a0d:2a00:1::1                 2606:4700:4700::1113                         2620:fe::fe
# az no1  94.140.14.141       185.228.169.11  208.67.220.220 1.0.0.3                                      9.9.9.11
#         2a10:50c0::2:ff     2a0d:2a00:2::1                 2606:4700:4700::1003                         2620:fe::9
# az se1  94.140.14.15        185.228.168.9                                       77.88.8.7               149.112.112.112 103.247.36.36
#         2a10:50c0::bad1:ff  2a0d:2a00:1::2                                      2a02:6b8::feed:a11      2620:fe::11
# warp    94.140.15.16        185.228.169.9                                       77.88.8.3               149.112.112.11  103.247.37.37
#         2a10:50c0::bad2:ff  2a0d:2a00:2::2                                      2a02:6b8:0:1::feed:a11  2620:fe::fe:11

/ip route

:if ([print count-only where comment=BOGONs]>0) do={ remove [ find comment=BOGONs ] }
add comment=BOGONs blackhole dst-address=10.0.0.0/8
add comment=BOGONs blackhole dst-address=172.16.0.0/12
add comment=BOGONs blackhole dst-address=192.168.0.0/16

:if ([print count-only where comment=ISP1-check]>0) do={ remove [ find comment=ISP1-check ] }
:if ([print count-only where comment=ISP1]>0) do={ remove [ find comment=ISP1 ] }
:foreach host in={
    "94.140.14.14";"185.228.168.168";"208.67.222.123";"1.1.1.2";"77.88.8.88";
} do={
    add comment=ISP1-check distance=1 dst-address="$host/32" gateway=vlan1000-rostelecom scope=10
    add comment=ISP1 distance=1 dst-address=127.88.1.1/32 gateway="$host" \
        scope=10 target-scope=11 check-gateway=ping
    add comment=ISP1 distance=99 dst-address="$host/32" blackhole
}
/ip dhcp-client release vlan1000-rostelecom
add comment=ISP1 distance=1 gateway=127.88.1.1 scope=10 target-scope=12
add comment=ISP1 distance=1 gateway=127.88.1.1 scope=10 target-scope=12 routing-table=ISP1

:if ([print count-only where comment=azirevpn-dk1]>0) do={ remove [ find comment=azirevpn-dk1 ] }
:foreach host in={
    "94.140.14.140";"185.228.168.10";"208.67.222.222";"1.1.1.3";"9.9.9.9";
} do={
    add comment=azirevpn-dk1 distance=1 dst-address="$host/32" gateway=azirevpn-dk1 scope=10
    add comment=azirevpn-dk1 distance=1 dst-address=127.88.2.1/32 gateway="$host" \
        scope=10 target-scope=11 check-gateway=ping
    add comment=azirevpn-dk1 distance=99 dst-address="$host/32" blackhole
}
add comment=azirevpn-dk1 distance=1 gateway=127.88.2.1 scope=10 target-scope=12 routing-table=azirevpn-dk1

:if ([print count-only where comment=azirevpn-no1]>0) do={ remove [ find comment=azirevpn-no1 ] }
:foreach host in={
    "94.140.14.141";"185.228.169.11";"208.67.220.220";"1.0.0.3";"9.9.9.11";
} do={
    add comment=azirevpn-no1 distance=1 dst-address="$host/32" gateway=azirevpn-no1 scope=10
    add comment=azirevpn-no1 distance=1 dst-address=127.88.2.2/32 gateway="$host" \
        scope=10 target-scope=11 check-gateway=ping
    add comment=azirevpn-no1 distance=99 dst-address="$host/32" blackhole
}
add comment=azirevpn-no1 distance=1 gateway=127.88.2.2 scope=10 target-scope=12 routing-table=azirevpn-no1

:if ([print count-only where comment=azirevpn-se1]>0) do={ remove [ find comment=azirevpn-se1 ] }
:foreach host in={
    "94.140.14.15";"185.228.168.9";"77.88.8.7";"149.112.112.112";"103.247.36.36";
} do={
    add comment=azirevpn-se1 distance=1 dst-address="$host/32" gateway=azirevpn-se1 scope=10
    add comment=azirevpn-se1 distance=1 dst-address=127.88.2.3/32 gateway="$host" \
        scope=10 target-scope=11 check-gateway=ping
    add comment=azirevpn-se1 distance=99 dst-address="$host/32" blackhole
}
add comment=azirevpn-se1 distance=1 gateway=127.88.2.3 scope=10 target-scope=12 routing-table=azirevpn-se1

:if ([print count-only where comment=warp]>0) do={ remove [ find comment=warp ] }
:foreach host in={
    "94.140.15.16";"185.228.169.9";"77.88.8.3";"149.112.112.11";"103.247.37.37";
} do={
    add comment=warp distance=1 dst-address="$host/32" gateway=warp scope=10
    add comment=warp distance=1 dst-address=127.88.2.4/32 gateway="$host" \
        scope=10 target-scope=11 check-gateway=ping
    add comment=warp distance=99 dst-address="$host/32" blackhole
}
add comment=warp distance=1 gateway=127.88.2.4 scope=10 target-scope=12 routing-table=warp

:if ([print count-only where comment=anyvpn]>0) do={ remove [ find comment=anyvpn ] }
:foreach i,gw in={1="127.88.2.3";2="127.88.2.1";3="127.88.2.2";4="127.88.2.4"} do={
    add comment=anyvpn distance="$i" dst-address=127.88.2.100/32 gateway="$gw" scope=10 target-scope=12
}
add comment=anyvpn distance=1 gateway=127.88.2.100 scope=10 target-scope=13 routing-table=anyvpn


##################
# BGP
##################

/routing bgp template
set [ find default-name=default ] as=64512 router-id=[/routing/id/get main dynamic-id ]

/routing bgp connection
:if ([print count-only where name=antifilter]=0) do={ add name=antifilter remote.address=163.172.210.8 local.role=ibgp }
set [ find name=antifilter ] disabled=no templates=default \
    local.role=ibgp \
    input.ignore-as-path-len=yes input.filter=bgp_in \
    remote.address=163.172.210.8/32 \
    hold-time=4m keepalive-time=1m multihop=yes routing-table=antifilter

/routing filter rule
:if ([print count-only where chain=bgp_in]>0) do={ remove [ find chain=bgp_in ] }
# accept routes and send to any vpn gw
add chain=bgp_in rule="set gw 127.88.2.100; accept"


#######################################
# IPv4 Firewalling & NAT
#######################################

/ip firewall connection tracking set udp-timeout=20s


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
add address=10.66.6.1/32 comment=self list=self
add address=10.66.6.129/32 comment=self list=self
add address=10.66.6.161/32 comment=self list=self
add address=10.66.7.1/32 comment=self list=self
add address=10.66.7.129/32 comment=self list=self


##################
# Common chains
##################

/ip firewall filter

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
add chain=common-rules connection-state=invalid action=drop
add chain=common-rules protocol=icmp action=accept


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
add chain=WAN-SELF comment="WAN-SELF Wireguard" disabled=yes
:foreach none,int in={ "azirevpn-dk1";"azirevpn-no1";"azirevpn-se1";"warp" } do={
    add chain=WAN-SELF protocol=udp  \
        dst-port=[ /interface/wireguard/get $int listen-port ] \
        action=accept
}
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
add chain=WAN-ALLDUDES comment="WAN-ALLDUDES drop all not DSTNATed" \
    connection-nat-state=!dstnat connection-state=new action=drop
add chain=WAN-ALLDUDES comment="WAN-ALLDUDES SSH bruteforce" protocol=tcp dst-port=22 \
    action=jump jump-target=ssh-bruteforce
add chain=WAN-ALLDUDES comment="WAN-ALLDUDES reject all" \
    action=reject reject-with=icmp-network-unreachable

:if ([print count-only where chain=ALLDUDES-WAN]>0) do={ remove [ find chain=ALLDUDES-WAN ] }
add chain=ALLDUDES-WAN comment="ALLDUDES-WAN drop packets from LAN that do not have LAN IP" \
    log=yes log-prefix="ALLDUDES-WAN !LAN:" src-address-list=!alldudes action=drop
add chain=ALLDUDES-WAN comment="ALLDUDES-WAN accept all" action=accept

:if ([print count-only where chain=WAN-WAN]>0) do={ remove [ find chain=WAN-WAN ] }
add chain=WAN-WAN comment="WAN-WAN reject all" \
    log=yes log-prefix=reject: action=reject reject-with=icmp-network-unreachable

:if ([print count-only where chain=MGMT-ALLDUDES]>0) do={ remove [ find chain=MGMT-ALLDUDES ] }
add chain=MGMT-ALLDUDES comment="MGMT-ALLDUDES accept all" action=accept

:if ([print count-only where chain=GUESTS-ALLDUDES]>0) do={ remove [ find chain=GUESTS-ALLDUDES ] }
add chain=GUESTS-ALLDUDES comment="GUESTS-ALLDUDES reject all" \
    log=yes log-prefix=reject: action=reject reject-with=icmp-network-unreachable

:if ([print count-only where chain=IOT-ALLDUDES]>0) do={ remove [ find chain=IOT-ALLDUDES ] }
add chain=IOT-ALLDUDES comment="IOT-ALLDUDES reject all" \
    log=yes log-prefix=reject: action=reject reject-with=icmp-network-unreachable

:if ([print count-only where chain=MEDIA-ALLDUDES]>0) do={ remove [ find chain=MEDIA-ALLDUDES ] }
add chain=MEDIA-ALLDUDES comment="MEDIA-ALLDUDES reject all" \
    log=yes log-prefix=reject: action=reject reject-with=icmp-network-unreachable

:if ([print count-only where chain=CLIENTS-ALLDUDES]>0) do={ remove [ find chain=CLIENTS-ALLDUDES ] }
add chain=CLIENTS-ALLDUDES comment="CLIENTS-ALLDUDES accept all" action=accept

:if ([print count-only where chain=main-forward]>0) do={ remove [ find chain=main-forward ] }
add chain=main-forward comment="forward common rules" \
    action=jump jump-target=common-rules
add chain=main-forward comment="MultiWAN" disabled=yes
:foreach int,mark in={
    "vlan1000-rostelecom"="ISP1";
    "azirevpn-dk1"="azirevpn-dk1";
    "azirevpn-no1"="azirevpn-no1";
    "azirevpn-se1"="azirevpn-se1";
    "warp"="warp";
} do={
    add chain=main-forward connection-mark="$mark" out-interface="!$int" \
        action=reject reject-with=icmp-network-unreachable
}
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
add chain=main-masq comment="Clients masquerade" ipsec-policy=out,none \
    src-address-list=clients out-interface-list=WAN action=masquerade
add chain=main-masq comment="Guests masquerade" ipsec-policy=out,none \
    src-address-list=guests out-interface-list=WAN action=masquerade
add chain=main-masq comment="Media masquerade" ipsec-policy=out,none \
    src-address-list=media out-interface-list=WAN action=masquerade
add chain=main-masq comment="IoT masquerade" ipsec-policy=out,none \
    src-address-list=iot out-interface-list=WAN action=masquerade
add chain=main-masq comment="Hairpin to ALLDUDES" out-interface-list=alldudes \
    action=src-nat src-address-list=alldudes to-addresses=10.66.6.0/23


:if ([print count-only where jump-target=main-masq]) do={ remove [ find jump-target=main-masq ] }
add chain=srcnat comment="Jump to masquerade table" action=jump jump-target=main-masq


##################
# Mangle
##################

/ip firewall mangle
:if ([print count-only where comment="MTU-fix"]>0) do={ remove [ find comment="MTU-fix" ] }
add chain=forward comment=MTU-fix in-interface-list=wg \
    protocol=tcp tcp-flags=syn tcp-mss=!0-1380 \
    action=change-mss new-mss=1380 passthrough=yes
add chain=forward comment=MTU-fix out-interface-list=wg \
    protocol=tcp tcp-flags=syn tcp-mss=!0-1380 \
    action=change-mss new-mss=1380 passthrough=yes

:foreach int,mark in={
  "vlan1000-rostelecom"="ISP1";
  "azirevpn-dk1"="azirevpn-dk1";
  "azirevpn-no1"="azirevpn-no1";
  "azirevpn-se1"="azirevpn-se1";
  "warp"="warp";
} do={
    :if ([print count-only where new-connection-mark="$mark-conn"]>0) do={ remove [ find new-connection-mark="$mark-conn" ] }
    :if ([print count-only where new-routing-mark="$mark"]>0) do={ remove [ find new-routing-mark="$mark" ] }

    # connmark ingress from isp (input + forward)
    add chain=prerouting comment="$mark" in-interface="$int" connection-mark=no-mark \
        action=mark-connection new-connection-mark="$mark-conn" passthrough=yes

    # routemark transit out
    add chain=prerouting in-interface-list=!WAN connection-mark="$mark-conn" \
        dst-address-type=!local action=mark-routing new-routing-mark="$mark"

    # routemark local out
    add chain=output out-interface="$int" connection-mark="$mark-conn" \
        dst-address-type=!local action=mark-routing new-routing-mark="$mark"
}


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
add chain=common-rules comment="Common: invalid" connection-state=invalid action=drop
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
add chain=WAN-SELF comment="WAN-SELF Wireguard" disabled=yes
:foreach none,int in={ "azirevpn-dk1";"azirevpn-no1";"azirevpn-se1";"warp" } do={
    add chain=WAN-SELF protocol=udp  \
        dst-port=[ /interface/wireguard/get $int listen-port ] \
        action=accept
}
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
add chain=ALLDUDES-WAN comment="ALLDUDES-WAN accept all" action=accept

:if ([print count-only where chain=WAN-WAN]>0) do={ remove [ find chain=WAN-WAN ] }
add chain=WAN-WAN comment="WAN-WAN reject all" \
    log=yes log-prefix=reject: action=reject reject-with=icmp-admin-prohibited

:if ([print count-only where chain=MGMT-ALLDUDES]>0) do={ remove [ find chain=MGMT-ALLDUDES ] }
add chain=MGMT-ALLDUDES comment="MGMT-ALLDUDES accept all" action=accept

:if ([print count-only where chain=GUESTS-ALLDUDES]>0) do={ remove [ find chain=GUESTS-ALLDUDES ] }
add chain=GUESTS-ALLDUDES comment="GUESTS-ALLDUDES reject all" \
    log=yes log-prefix=reject: action=reject reject-with=icmp-admin-prohibited

:if ([print count-only where chain=IOT-ALLDUDES]>0) do={ remove [ find chain=IOT-ALLDUDES ] }
add chain=IOT-ALLDUDES comment="IOT-ALLDUDES reject all" \
    log=yes log-prefix=reject: action=reject reject-with=icmp-admin-prohibited

:if ([print count-only where chain=MEDIA-ALLDUDES]>0) do={ remove [ find chain=MEDIA-ALLDUDES ] }
add chain=MEDIA-ALLDUDES comment="MEDIA-ALLDUDES reject all" \
    log=yes log-prefix=reject: action=reject reject-with=icmp-admin-prohibited

:if ([print count-only where chain=CLIENTS-ALLDUDES]>0) do={ remove [ find chain=CLIENTS-ALLDUDES ] }
add chain=CLIENTS-ALLDUDES comment="CLIENTS-ALLDUDES accept all" action=accept

:if ([print count-only where chain=main-forward]>0) do={ remove [ find chain=main-forward ] }
add chain=main-forward comment="forward common rules" \
    action=jump jump-target=common-rules
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

# disabled because of ROS7 IPv6 conntrack vs queues bug

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


#######################################
# ADBlock
#######################################

/system script
:do { add name=adblock } on-error={}
set [ find name=adblock ] policy=read,write,policy,test source="{\r\
    \n:local hostScriptUrl \"https://stopad.hook.sh/script/source\?format=routeros&version=4.4.0&redirect_to=127.4.5.\
    1&limit=15000&sources_urls=https%3A%2F%2Fcdn.jsdelivr.net%2Fgh%2Ftarampampam%2Fmikrotik-hosts-parser%40master%2F.\
    hosts%2Fbasic.txt,https%3A%2F%2Fadaway.org%2Fhosts.txt&excluded_hosts=localhost,localhost.localdomain,broadcastho\
    st,local,ip6-localhost,ip6-loopback,ip6-localnet,ip6-mcastprefix,ip6-allnodes,ip6-allrouters,ip6-allhosts\";\r\
    \n:local scriptName \"adblock.rsc\";\r\
    \n:local logPrefix \"[ADBlock]\";\r\
    \n\r\
    \ndo {\r\
    \n  /tool fetch check-certificate=no mode=https url=\$hostScriptUrl dst-path=(\"./\".\$scriptName);\r\
    \n  :delay 3s;\r\
    \n  :if ([:len [/file find name=\$scriptName]] > 0) do={\r\
    \n    /ip dns static\r\
    \n    remove [ find comment=ADBlock ]\r\
    \n    /import file-name=\$scriptName;\r\
    \n    /file remove \$scriptName;\r\
    \n    :log info \"\$logPrefix AD block script imported\";\r\
    \n  } else={\r\
    \n    :log warning \"\$logPrefix AD block script not downloaded, script stopped\";\r\
    \n  }\r\
    \n} on-error={\r\
    \n  :log warning \"\$logPrefix AD block script download FAILED\";\r\
    \n};\r\
    \n}"

/system scheduler
:do { add name=update_adblock } on-error={}
set [ find name=update_adblock ] policy=read,write,policy,test \
    start-date=jan/22/2022 start-time=03:53:25 interval=1d on-event=adblock



# ending delay
:delay 10s

# Teardown temporary logging to disk
/system logging
remove [ find where action=restore ]
action remove [/system logging action find where name=restore]

}
