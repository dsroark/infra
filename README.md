A place where my infrastructure code lives.  Currently I am using Terraform in tandem with ansible.  It may be more feasible in the future to split these out but while they remain my pet projects it is easier for me to put the code here
.
# VPN server

The vpn stack is built using [this guide from digitalocean](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-openvpn-server-on-ubuntu-18-04)

Run terraform followed by ansible against the dynamic inventory to create a ca
server (which will remain powered off once all the necessary certs are signed)
and an openvpn server.

The ansible code lives in the `vpn.yml` under the `ansible` directory.  If it
gets any larger I may split it out into multiple roles.

# Contributing

Feel free to fork, use what you need for your own infrastructure, and ideally
submit a pull request back into this PR if something can be improved.  This repo
is single trunk and just use `master` as the base branch.
