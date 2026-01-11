# Troubleshooting Guide

Detailed solutions for common issues with the SolarEdge EV Charger integration.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Sensor Issues](#sensor-issues)
- [Authentication Issues](#authentication-issues)
- [Data Issues](#data-issues)
- [Performance Issues](#performance-issues)

---

## Installation Issues

### Script Returns Nothing

**Symptom:** Running `/config/shell/solaredge_login.sh` returns no output.

**Diagnosis:**
```bash
# Check if script exists
ls -l /config/shell/solaredge_login.sh

# Check if it's executable
ls -la /config/shell/solaredge_login.sh

# View script contents
cat /config/shell/solaredge_login.sh
```

**Solutions:**

1. **Script not executable:**
   ```bash
   chmod +x /config/shell/solaredge_login.sh
   ```

2. **Script has wrong credentials:**
   ```bash
   nano /config/shell/solaredge_login.sh
   # Verify SITE_ID and COOKIE_VALUE are correct
   ```

3. **curl not working:**
   ```bash
   # Test basic curl
   curl -s https://monitoring.solaredge.com | head -20
   ```

### Sensors Not Appearing

**Symptom:** After restart, no `ev_charger` sensors appear.

**Diagnosis:**
```bash
# Check if command_line.yaml exists
ls -l /config/command_line.yaml

# Check if configuration.yaml includes it
grep "command_line" /config/configuration.yaml

# Check logs for errors
ha core logs | grep -i "command_line\|solaredge"
```

**Solutions:**

1. **Missing include in configuration.yaml:**
   ```bash
   nano /config/configuration.yaml
   # Add: command_line: !include command_line.yaml
   ```

2. **YAML syntax error:**
   ```bash
   # Check configuration
   ha core check
   # Fix any errors shown
   ```

3. **Restart required:**
   ```bash
   ha core restart
   ```

### Template Sensors Show "Unknown"

**Symptom:** Raw sensor works, but template sensors show "unknown".

**Diagnosis:**
```bash
# Check if templates.yaml exists
ls -l /config/templates.yaml

# Check if included in configuration.yaml
grep "template" /config/configuration.yaml

# Check raw sensor has attributes
# Go to Developer Tools → States → sensor.solaredge_ev_charger_raw
# Look for devicesByType attribute
```

**Solutions:**

1. **Missing template include:**
   ```bash
   nano /config/configuration.yaml
   # Add: template: !include templates.yaml
   ```

2. **Reload templates without restart:**
   - Developer Tools → YAML
   - Click "Template Entities" → Reload

3. **Check raw sensor state:**
   - If raw sensor shows "No Data", the script isn't working
   - If raw sensor has no `devicesByType` attribute, JSON parsing failed

---

## Sensor Issues

### "Empty reply found when expecting JSON data"

**Symptom:** Log shows: `WARNING [homeassistant.components.command_line] Empty reply found when expecting JSON data`

**Root Cause:** Script is returning empty data (cookie expired or invalid).

**Solutions:**

1. **Test script manually:**
   ```bash
   /config/shell/solaredge_login.sh
   ```
   If this returns nothing, continue to next step.

2. **Get fresh cookie:**
   - Login to https://monitoring.solaredge.com
   - Extract `SPRING_SECURITY_REMEMBER_ME_COOKIE` from browser
   - Update script:
     ```bash
     nano /config/shell/solaredge_login.sh
     # Replace COOKIE_VALUE with new cookie
     ```

3. **Restart Home Assistant:**
   ```bash
   ha core restart
   ```

### Sensor Shows "unavailable"

**Symptom:** Sensor exists but shows as "unavailable".

**Possible Causes:**
- Script is timing out
- Script is crashing
- Network issues

**Solutions:**

1. **Increase timeout:**
   ```bash
   nano /config/command_line.yaml
   # Change: command_timeout: 30
   # To:     command_timeout: 60
   ```

2. **Check network connectivity:**
   ```bash
   curl -s https://monitoring.solaredge.com | head -20
   ```

3. **Check logs for timeout errors:**
   ```bash
   ha core logs | grep -i timeout
   ```

### Sensor Shows "No Data"

**Symptom:** Raw sensor state is "No Data".

**Root Cause:** Script is returning data, but it doesn't contain expected structure.

**Solutions:**

1. **Check script output:**
   ```bash
   /config/shell/solaredge_login.sh | head -50
   ```

2. **Verify JSON structure:**
   Look for `devicesByType` → `EV_CHARGER` in the output.

3. **Check Site ID:**
   Make sure your SITE_ID is correct. Login to monitoring.solaredge.com and check the URL.

---

## Authentication Issues

### Cookie Expired

**Symptom:** Integration was working, now shows "No Data" or empty responses.

**Why:** Cookies typically expire after 7-14 days.

**Solution:**

1. **Login to SolarEdge:**
   ```
   https://monitoring.solaredge.com
   ```

2. **Extract fresh cookie:**
   - Chrome: F12 → Application → Cookies
   - Firefox: F12 → Storage → Cookies
   - Find: `SPRING_SECURITY_REMEMBER_ME_COOKIE`
   - Copy the Value

3. **Update script:**
   ```bash
   nano /config/shell/solaredge_login.sh
   # Replace COOKIE_VALUE="..." with new cookie
   ```

4. **Test:**
   ```bash
   /config/shell/solaredge_login.sh | head -20
   ```

5. **Restart:**
   ```bash
   ha core restart
   ```

### Wrong Site ID

**Symptom:** Script returns JSON but no EV_CHARGER data.

**Solution:**

1. **Verify Site ID:**
   - Login to https://monitoring.solaredge.com
   - Look at URL: `.../site/XXXXXXX/...`
   - XXXXXXX is your Site ID

2. **Update script:**
   ```bash
   nano /config/shell/solaredge_login.sh
   # Verify SITE_ID="XXXXXXX"
   ```

### Multiple Sites

**Symptom:** You have multiple SolarEdge sites.

**Solution:**

You need the Site ID that has the EV Charger:

1. Login to monitoring.solaredge.com
2. Switch to the site with the EV Charger
3. Check the URL for that site's ID
4. Use that ID in the script

---

## Data Issues

### Power Shows 0 While Charging

**Symptom:** `sensor.ev_charger_status` shows "Charging" but `sensor.ev_charger_power` shows 0.

**Cause:** Power data is in `chargerStatusSubTitle[0].numericValue` which may not be populated.

**Diagnosis:**
```bash
# Check raw data
/config/shell/solaredge_login.sh | grep -A50 "chargerStatusSubTitle"
```

**Solution:**

If `chargerStatusSubTitle` is empty, the charger may not be reporting power. This is a limitation of the SolarEdge API for some charger models or states.

### Session Energy Not Resetting

**Symptom:** Session energy doesn't reset when you unplug the car.

**Explanation:** 

The `sessionEnergy` value from SolarEdge represents the total energy of the *last* or *current* session. It doesn't automatically reset in the API.

**Workaround:**

Create a utility meter to track daily charging:

```yaml
# configuration.yaml
utility_meter:
  daily_ev_charging:
    source: sensor.ev_session_energy
    cycle: daily
```

### Distance Calculation Wrong

**Symptom:** `sensor.ev_session_distance` doesn't match your vehicle's actual range.

**Explanation:**

The distance is calculated by SolarEdge using the vehicle's efficiency factor (kWh/km). This may not match your actual driving efficiency.

**Note:** This is informational only and based on SolarEdge's calculation.

---

## Performance Issues

### High CPU Usage

**Symptom:** Home Assistant CPU usage increased after installing integration.

**Cause:** scan_interval is too low.

**Solution:**

```bash
nano /config/command_line.yaml
# Change: scan_interval: 30
# To:     scan_interval: 60  (or higher)
```

Restart Home Assistant.

### Slow Response Times

**Symptom:** Dashboard takes long to load charger data.

**Solutions:**

1. **Increase script timeout:**
   ```bash
   nano /config/command_line.yaml
   # Change: command_timeout: 30
   # To:     command_timeout: 60
   ```

2. **Check network latency:**
   ```bash
   time /config/shell/solaredge_login.sh > /dev/null
   ```
   Should complete in under 2-3 seconds.

3. **Optimize dashboard:**
   - Reduce number of cards showing EV data
   - Use conditional cards to hide when not in use

---

## Network Issues

### "Could not resolve host"

**Symptom:** Error in logs about DNS resolution.

**Solutions:**

1. **Check DNS:**
   ```bash
   nslookup monitoring.solaredge.com
   ```

2. **Try with IP (not recommended for production):**
   Find SolarEdge IP:
   ```bash
   nslookup monitoring.solaredge.com
   ```
   Note: IP may change, so this is temporary.

3. **Check Home Assistant network settings:**
   - Settings → System → Network
   - Verify DNS servers are configured

### Timeout Errors

**Symptom:** `Command failed: '/config/shell/solaredge_login.sh', return code: 124, stdout: "", stderr: ""`

**Cause:** Script is taking longer than `command_timeout`.

**Solutions:**

1. **Increase timeout:**
   ```bash
   nano /config/command_line.yaml
   # Increase command_timeout to 60 or 90
   ```

2. **Check network speed:**
   ```bash
   time curl -s https://monitoring.solaredge.com > /dev/null
   ```

3. **Check if firewall is blocking:**
   Some networks block or slow down API requests.

---

## Debugging Tips

### Enable Debug Logging

Add to `configuration.yaml`:

```yaml
logger:
  default: warning
  logs:
    homeassistant.components.command_line: debug
    homeassistant.components.template: debug
```

Restart, then check logs:
```bash
ha core logs | grep -i "command_line\|template" | tail -50
```

### Test Template Manually

Go to Developer Tools → Template and test:

```yaml
{% set raw = state_attr('sensor.solaredge_ev_charger_raw', 'devicesByType') %}
{{ raw }}
```

Should show your charger data.

### Check Entity Registry

If sensors appear but don't update:

1. Settings → Devices & Services → Entities
2. Search for `ev_charger`
3. Check if entities are disabled
4. Enable if needed

### View Raw JSON

To see exactly what data SolarEdge is returning:

```bash
/config/shell/solaredge_login.sh | python3 -m json.tool > /config/solaredge_raw.json 2>&1
cat /config/solaredge_raw.json
```

Or if python3 isn't available:
```bash
/config/shell/solaredge_login.sh > /config/solaredge_raw.txt
cat /config/solaredge_raw.txt
```

---

## Getting Help

If none of these solutions work:

1. **Check the logs:**
   ```bash
   ha core logs > /tmp/logs.txt
   cat /tmp/logs.txt | grep -i "solaredge\|command_line" | tail -100
   ```

2. **Test the script:**
   ```bash
   /config/shell/solaredge_login.sh > /tmp/output.txt 2>&1
   cat /tmp/output.txt
   ```

3. **Open a GitHub Issue** with:
   - Home Assistant version
   - Integration setup (copy of your YAML files with credentials removed)
   - Relevant log entries
   - Output of manual script test
   - What you've already tried

4. **Visit Home Assistant Community:**
   - https://community.home-assistant.io/
   - Search for "SolarEdge EV Charger"
   - Post in Integrations category

---

## Prevention

### Set Up Cookie Expiration Alert

```yaml
automation:
  - alias: "Alert - SolarEdge Cookie Expiring Soon"
    trigger:
      - platform: state
        entity_id: sensor.solaredge_ev_charger_raw
        to: 'No Data'
        for:
          minutes: 10
    action:
      - service: persistent_notification.create
        data:
          title: "SolarEdge Cookie Expired"
          message: "Refresh the authentication cookie"
```

### Regular Maintenance

- **Weekly:** Check that sensors are updating
- **Bi-weekly:** Consider refreshing cookie proactively
- **Monthly:** Review logs for any errors

### Keep Configuration Backed Up

```bash
# Backup your files
tar -czf solaredge_backup.tar.gz \
  /config/shell/solaredge_login.sh \
  /config/command_line.yaml \
  /config/templates.yaml
```

---

**Still stuck?** Open an issue on GitHub with detailed information!
