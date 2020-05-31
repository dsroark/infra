# VPN server

The vpn stack is built using [this guide from digitalocean](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-openvpn-server-on-ubuntu-18-04)

Run terraform followed by ansible against the dynamic inventory to create a ca
server (which will remain powered off once all the necessary certs are signed)
and an openvpn server.

The ansible code lives in the `vpn.yml` under the `ansible` directory.  If it
gets any larger I may split it out into multiple roles.

note: this is an openvpn stack to be replaced by wireguard shortly and it will
be deleted once wireguard is in place in the main aws project

