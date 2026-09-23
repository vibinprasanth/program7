#!/bin/bash

# Student Name:
# Register Number:

# 1. Display all available firewall zones
firewall-cmd --get-zones

# 2. Display current default zone
firewall-cmd --get-default-zone


# 3. Display information about public zone
firewall-cmd --zone=public --list-all

# 4. Set default zone to internal
firewall-cmd --set-default-zone=internal


# 5. Verify the new default zone
firewall-cmd --get-default-zone






exit 0
