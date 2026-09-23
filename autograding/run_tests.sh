#!/bin/bash

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MOCK_DIR="$ROOT_DIR/.mock_bin"

rm -rf "$MOCK_DIR"
mkdir -p "$MOCK_DIR"

echo "======================================"
echo " Running Firewall Zones Autograder"
echo "======================================"

# -----------------------------------------
# Mock firewall-cmd
# -----------------------------------------

cat > "$MOCK_DIR/firewall-cmd" <<'EOF'
#!/bin/bash

case "$1" in

    --get-zones)
        echo "block dmz drop external home internal public trusted work"
        exit 0
        ;;

    --get-default-zone)
        if [ -f "/tmp/firewall_default_zone" ]; then
            cat "/tmp/firewall_default_zone"
        else
            echo "public"
        fi
        exit 0
        ;;

    --zone=public)
        if [ "$2" = "--list-all" ]; then
            echo "public (active)"
            echo "target: default"
            echo "interfaces:"
            echo "services: cockpit dhcpv6-client ssh"
            echo "ports:"
            exit 0
        fi
        ;;

    --set-default-zone=internal)
        echo "success"
        echo "internal" > /tmp/firewall_default_zone
        exit 0
        ;;

    *)
        echo "Unsupported firewall-cmd command"
        exit 1
        ;;
esac
EOF

chmod +x "$MOCK_DIR/firewall-cmd"

# -----------------------------------------
# Run static tests
# -----------------------------------------

bash "$ROOT_DIR/test_cases/test_firewall_zones.sh"

STATIC_RESULT=$?

if [ "$STATIC_RESULT" -ne 0 ]; then
    echo
    echo "Static tests failed."
    exit 1
fi

# -----------------------------------------
# Execute student script using mock command
# -----------------------------------------

echo
echo "Running student program..."

chmod +x "$ROOT_DIR/firewall_zones.sh"

rm -f /tmp/firewall_default_zone

PATH="$MOCK_DIR:$PATH" \
bash "$ROOT_DIR/firewall_zones.sh" > "$ROOT_DIR/student_output.txt" 2>&1

PROGRAM_RESULT=$?

cat "$ROOT_DIR/student_output.txt"

# -----------------------------------------
# Check exit status
# -----------------------------------------

if [ "$PROGRAM_RESULT" -eq 0 ]; then
    echo "PASS: Student script exited with status 0"
else
    echo "FAIL: Student script failed"
    exit 1
fi

# -----------------------------------------
# Check final default zone
# -----------------------------------------

if [ -f /tmp/firewall_default_zone ] && \
   grep -qx "internal" /tmp/firewall_default_zone; then

    echo "PASS: Default zone changed to internal"

else

    echo "FAIL: Default zone was not changed to internal"
    exit 1

fi

# -----------------------------------------
# Check output
# -----------------------------------------

if grep -q "block dmz drop external home internal public trusted work" \
"$ROOT_DIR/student_output.txt"; then

    echo "PASS: Available zones displayed"

else

    echo "FAIL: Available zones not displayed"
    exit 1

fi

if grep -q "public" "$ROOT_DIR/student_output.txt"; then
    echo "PASS: Public zone information displayed"
else
    echo "FAIL: Public zone information not displayed"
    exit 1
fi

echo
echo "======================================"
echo " ALL TESTS PASSED"
echo "======================================"

rm -f /tmp/firewall_default_zone

exit 0
