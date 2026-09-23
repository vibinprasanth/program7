#!/bin/bash

SCRIPT="./firewall_zones.sh"

PASS=0
FAIL=0

test_pass() {
    echo "PASS: $1"
    PASS=$((PASS + 1))
}

test_fail() {
    echo "FAIL: $1"
    FAIL=$((FAIL + 1))
}

echo "======================================"
echo " Firewall Zones Autograder"
echo "======================================"

# TC01 - File exists

if [ -f "$SCRIPT" ]; then
    test_pass "firewall_zones.sh exists"
else
    test_fail "firewall_zones.sh does not exist"
    exit 1
fi


# TC02 - Bash shebang

if head -n 1 "$SCRIPT" | grep -q "#!/bin/bash"; then
    test_pass "Bash shebang found"
else
    test_fail "Bash shebang missing"
fi


# TC03 - Get zones

if grep -Eq 'firewall-cmd[[:space:]]+--get-zones' "$SCRIPT"; then
    test_pass "firewall-cmd --get-zones found"
else
    test_fail "firewall-cmd --get-zones missing"
fi


# TC04 - Get default zone

if grep -Eq 'firewall-cmd[[:space:]]+--get-default-zone' "$SCRIPT"; then
    test_pass "firewall-cmd --get-default-zone found"
else
    test_fail "firewall-cmd --get-default-zone missing"
fi


# TC05 - Public zone list

if grep -Eq 'firewall-cmd[[:space:]]+--zone=public[[:space:]]+--list-all' "$SCRIPT"; then
    test_pass "public zone --list-all found"
else
    fail_test "public zone --list-all missing"
fi


# TC06 - Set default zone to internal

if grep -Eq 'firewall-cmd[[:space:]]+--set-default-zone=internal' "$SCRIPT"; then
    test_pass "Set default zone to internal found"
else
    test_fail "Set default zone to internal missing"
fi


# TC07 - Verify default zone command appears twice

COUNT=$(grep -Ec 'firewall-cmd[[:space:]]+--get-default-zone' "$SCRIPT")

if [ "$COUNT" -ge 2 ]; then
    test_pass "Default zone checked before and after configuration"
else
    test_fail "Default zone should be checked before and after configuration"
fi


# TC08 - Bash syntax

if bash -n "$SCRIPT"; then
    test_pass "Bash syntax is valid"
else
    test_fail "Bash syntax error"
fi


# TC09 - Check destructive commands

if grep -Eq \
'iptables[[:space:]]+-F|nft[[:space:]]+flush[[:space:]]+ruleset|firewall-cmd[[:space:]]+--complete-reload' \
"$SCRIPT"; then

    test_fail "Destructive firewall command found"

else
    test_pass "No prohibited destructive command found"
fi


echo
echo "======================================"
echo "Tests Passed: $PASS"
echo "Tests Failed: $FAIL"
echo "======================================"

if [ "$FAIL" -eq 0 ]; then
    exit 0
else
    exit 1
fi
