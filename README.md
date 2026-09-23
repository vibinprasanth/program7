# Linux Firewall – Predefined Firewall Zones

## Aim

To configure and manage predefined firewall zones using `firewall-cmd`.

## Theory

Firewall zones define different levels of trust for network connections.

Common predefined firewalld zones include:

- public – Default zone
- internal – For internal/trusted networks
- trusted – All network connections are accepted
- dmz – For systems accessible from the public network
- work – For work networks
- home – For home networks

## Commands to Study

The following commands are required for this practical:

```bash
firewall-cmd --get-zones
firewall-cmd --get-default-zone
firewall-cmd --zone=public --list-all
firewall-cmd --set-default-zone=internal
firewall-cmd --get-default-zone
