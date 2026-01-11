# Quick Start Guide

Get your SolarEdge EV Charger integrated with Home Assistant in 10 minutes!

## Prerequisites

- Home Assistant OS with SSH access
- SolarEdge account with EV Charger

## Step-by-Step Installation

### 1️⃣ Get Your Credentials (2 minutes)

**Login to SolarEdge:**
```
https://monitoring.solaredge.com
```

**Get Site ID from URL:**
```
https://monitoring.solaredge.com/solaredge-web/p/site/XXXXXXX/#/dashboard
                                                      ^^^^^^^
                                                    Your Site ID
```

**Extract Cookie (Chrome):**
1. Press `F12`
2. Go to **Application** tab
3. Click **Cookies** → `monitoring.solaredge.com`
4. Find `SPRING_SECURITY_REMEMBER_ME_COOKIE`
5. Copy the Value

**Extract Cookie (Firefox):**
1. Press `F12`
2. Go to **Storage** tab
3. Click **Cookies** → `monitoring.solaredge.com`
4. Find `SPRING_SECURITY_REMEMBER_ME_COOKIE`
5. Copy the Value

### 2️⃣ SSH into Home Assistant (1 minute)

Open Terminal & SSH add-on or SSH client.

### 3️⃣ Create the Script (2 minutes)

```bash
# Create directory
mkdir -p /config/shell

# Create script
cat > /config/shell/solaredge_login.sh << 'EOF'
#!/bin/bash

SITE_ID="YOUR_SITE_ID"
COOKIE_VALUE="YOUR_COOKIE_VALUE"

curl -s -L \
    -H "Cookie: SPRING_SECURITY_REMEMBER_ME_COOKIE=${COOKIE_VALUE}" \
    "https://monitoring.solaredge.com/services/api/homeautomation/v1.0/sites/${SITE_ID}/devices" \
    -H "Accept: application/json" \
    -H "User-Agent: Mozilla/5.0"
EOF

# Make executable
chmod +x /config/shell/solaredge_login.sh
```

**Edit the script:**
```bash
nano /config/shell/solaredge_login.sh
```

- Replace `YOUR_SITE_ID` with your Site ID
- Replace `YOUR_COOKIE_VALUE` with your cookie
- Save: `CTRL+X`, `Y`, `ENTER`

**Test it:**
```bash
/config/shell/solaredge_login.sh
```

You should see JSON data! If not, check your Site ID and cookie.

### 4️⃣ Download Configuration Files (1 minute)

```bash
cd /config

# Download command_line.yaml
curl -o command_line.yaml https://raw.githubusercontent.com/YOURUSERNAME/solaredge-evcharger-ha/main/command_line.yaml

# Download templates.yaml
curl -o templates.yaml https://raw.githubusercontent.com/YOURUSERNAME/solaredge-evcharger-ha/main/templates.yaml
```

**OR** manually create them - see files in this repo.

### 5️⃣ Update configuration.yaml (2 minutes)

```bash
nano /config/configuration.yaml
```

Add these lines:
```yaml
command_line: !include command_line.yaml
template: !include templates.yaml
```

Save: `CTRL+X`, `Y`, `ENTER`

### 6️⃣ Restart Home Assistant (2 minutes)

```bash
ha core restart
```

Wait 2-3 minutes for restart.

### 7️⃣ Verify Sensors (1 minute)

1. Open Home Assistant web interface
2. Go to **Developer Tools** → **States**
3. Search for: `ev_charger`
4. You should see 12 sensors! ✅

## Sensors You'll Get

✅ `sensor.ev_charger_status` - Charging/Plugged In/Not Connected  
✅ `sensor.ev_charger_power` - Current power (kW)  
✅ `sensor.ev_session_energy` - Energy this session (kWh)  
✅ `sensor.ev_session_duration` - How long charging  
✅ `sensor.ev_connected_vehicle` - Vehicle name  
✅ `sensor.ev_charger_mode` - Manual/Auto mode  
✅ `sensor.ev_connection_status` - Connection details  
✅ `sensor.ev_session_distance` - Range added (km)  
✅ `binary_sensor.ev_charger_connected` - Vehicle plugged in?  
✅ `binary_sensor.ev_charger_charging` - Actively charging?  
✅ `binary_sensor.ev_charge_schedule_enabled` - Schedule on?  
✅ `sensor.solaredge_ev_charger_raw` - Raw data  

## Quick Dashboard Card

Add this to your dashboard:

```yaml
type: entities
title: EV Charger
entities:
  - sensor.ev_charger_status
  - sensor.ev_charger_power
  - sensor.ev_session_energy
  - sensor.ev_session_duration
  - sensor.ev_connected_vehicle
  - binary_sensor.ev_charger_charging
```

## Troubleshooting

**No sensors?**
```bash
ha core logs | grep -i solaredge
```

**Sensors show "Unknown"?**
```bash
/config/shell/solaredge_login.sh
```
Should return JSON. If not, cookie expired - get a new one (Step 1).

**"Empty reply" error?**
Cookie expired. Refresh it:
1. Login to monitoring.solaredge.com
2. Extract new cookie
3. Update script
4. Restart HA

## What's Next?

- 📊 Add to Energy Dashboard
- 🔔 Set up notifications
- 🤖 Create automations
- 📱 Add to mobile dashboard

See full documentation for:
- [Dashboard Examples](dashboard-examples.md)
- [Automation Examples](automation-examples.md)
- [Full README](README.md)

---

**Need help?** Open an issue on GitHub!

**Working?** Give the repo a ⭐!
