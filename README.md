# SolarEdge EV Charger Integration for Home Assistant

Monitor and track your SolarEdge EV Charger directly in Home Assistant using the private SolarEdge API.

[![Home Assistant](https://img.shields.io/badge/Home%20Assistant-Compatible-blue.svg)](https://www.home-assistant.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 📸 Screenshots

<img width="505" height="741" alt="image" src="https://github.com/user-attachments/assets/4b36c4ff-152b-4e96-8fe0-d4871d0cd51e" />

## ✨ Features

This integration provides real-time monitoring of your SolarEdge EV Charger with the following sensors:

### Main Sensors
- **Charger Status** - Current state (Charging, Plugged In, Not Connected)
- **Charging Power** - Real-time power in kW
- **Session Energy** - Energy delivered in current session (kWh)
- **Session Duration** - How long the current session has been active
- **Connected Vehicle** - Name of the connected vehicle
- **Charger Mode** - Manual or Auto (Solar/Schedule)
- **Connection Status** - Detailed connection information
- **Session Distance** - Estimated driving range added (km)

### Binary Sensors
- **Vehicle Connected** - Is a vehicle plugged in?
- **Currently Charging** - Is charging active?
- **Schedule Enabled** - Is a charging schedule configured?

### Automation Ready
All sensors include proper device classes and state classes for:
- Energy Dashboard integration
- Automations and notifications
- Historical tracking and statistics

## 📋 Prerequisites

- **Home Assistant OS** (HAOS) or Home Assistant Container
- **SolarEdge Account** with EV Charger
- **Admin Access** to your Home Assistant configuration files
- **Terminal & SSH Add-on** installed (for HAOS)

## 🚀 Installation

### Step 1: Get Your SolarEdge Cookie

The SolarEdge private API requires authentication via browser cookie.

1. **Login to SolarEdge**
   - Go to https://monitoring.solaredge.com
   - Login with your credentials

2. **Extract the Cookie**

   **For Firefox:**
   - Press `F12` to open Developer Tools
   - Go to the **Storage** tab
   - Click **Cookies** → `monitoring.solaredge.com`
   - Find `SPRING_SECURITY_REMEMBER_ME_COOKIE`
   - Double-click the **Value** and copy it

   **For Chrome:**
   - Press `F12` to open Developer Tools
   - Go to the **Application** tab
   - Click **Cookies** → `monitoring.solaredge.com`
   - Find `SPRING_SECURITY_REMEMBER_ME_COOKIE`
   - Double-click the **Value** column and copy it

3. **Find Your Site ID**
   - While logged into SolarEdge, look at the URL
   - Format: `https://monitoring.solaredge.com/solaredge-web/p/site/XXXXXXX/#/dashboard`
   - The number `XXXXXXX` is your Site ID

### Step 2: Create the Shell Script

SSH into your Home Assistant and create the directory:

```bash
mkdir -p /config/shell
```

Create the script:

```bash
nano /config/shell/solaredge_login.sh
```

Paste this script:

```bash
#!/bin/bash

# ============================================
# CONFIGURATION
# ============================================
SITE_ID="YOUR_SITE_ID"
COOKIE_VALUE="YOUR_COOKIE_VALUE"
# ============================================

curl -s -L \
    -H "Cookie: SPRING_SECURITY_REMEMBER_ME_COOKIE=${COOKIE_VALUE}" \
    "https://monitoring.solaredge.com/services/api/homeautomation/v1.0/sites/${SITE_ID}/devices" \
    -H "Accept: application/json" \
    -H "User-Agent: Mozilla/5.0"
```

**Update the configuration:**
- Replace `YOUR_SITE_ID` with your Site ID
- Replace `YOUR_COOKIE_VALUE` with the cookie you copied

**Save:** Press `CTRL+X`, then `Y`, then `ENTER`

**Make it executable:**
```bash
chmod +x /config/shell/solaredge_login.sh
```

### Step 3: Test the Script

```bash
/config/shell/solaredge_login.sh
```

You should see JSON output with your EV Charger data. If you see nothing or an error, verify your cookie and Site ID.

### Step 4: Create command_line.yaml

```bash
nano /config/command_line.yaml
```

Paste this configuration:

```yaml
# SolarEdge EV Charger
- sensor:
    name: solaredge_ev_charger_raw
    command: "/config/shell/solaredge_login.sh"
    scan_interval: 30
    command_timeout: 30
    value_template: >
      {% if value_json is defined and value_json.devicesByType is defined %}
        {% if value_json.devicesByType.EV_CHARGER is defined and value_json.devicesByType.EV_CHARGER|length > 0 %}
          {{ value_json.devicesByType.EV_CHARGER[0].chargerStatus }}
        {% else %}
          No Charger
        {% endif %}
      {% else %}
        No Data
      {% endif %}
    json_attributes:
      - devicesByType
```

Save with `CTRL+X`, `Y`, `ENTER`.

### Step 5: Create templates.yaml

```bash
nano /config/templates.yaml
```

Copy the template sensors from the [templates.yaml](templates.yaml) file in this repository.

Save with `CTRL+X`, `Y`, `ENTER`.

### Step 6: Update configuration.yaml

```bash
nano /config/configuration.yaml
```

Add these lines (if they don't already exist):

```yaml
command_line: !include command_line.yaml
template: !include templates.yaml
```

Save with `CTRL+X`, `Y`, `ENTER`.

### Step 7: Restart Home Assistant

```bash
ha core restart
```

Wait 2-3 minutes for Home Assistant to restart.

### Step 8: Verify Sensors

1. Go to **Developer Tools** → **States**
2. Search for `ev_charger`
3. You should see all 12 sensors with data

## 📊 Dashboard Configuration

### Basic Entities Card

```yaml
type: entities
title: EV Charger
entities:
  - entity: sensor.ev_charger_status
  - entity: sensor.ev_charger_power
  - entity: sensor.ev_session_energy
  - entity: sensor.ev_session_duration
  - entity: sensor.ev_connected_vehicle
  - entity: sensor.ev_charger_mode
  - entity: sensor.ev_connection_status
  - entity: sensor.ev_session_distance
  - entity: binary_sensor.ev_charger_connected
  - entity: binary_sensor.ev_charger_charging
  - entity: binary_sensor.ev_charge_schedule_enabled
show_header_toggle: false
```

### Enhanced Multi-Card Layout

```yaml
type: vertical-stack
cards:
  - type: glance
    title: EV Charger Status
    entities:
      - entity: sensor.ev_charger_status
        name: Status
      - entity: sensor.ev_charger_power
        name: Power
      - entity: binary_sensor.ev_charger_charging
        name: Charging
    show_name: true
    show_state: true
  
  - type: entities
    title: Current Session
    entities:
      - entity: sensor.ev_session_energy
        name: Energy Delivered
      - entity: sensor.ev_session_duration
        name: Duration
      - entity: sensor.ev_session_distance_mi
        name: Estimated Range
      - entity: sensor.ev_connected_vehicle
        name: Vehicle
    show_header_toggle: false
  
  - type: entities
    title: Settings & Status
    entities:
      - entity: sensor.ev_charger_mode
        name: Charging Mode
      - entity: sensor.ev_connection_status
        name: Connection Status
      - entity: binary_sensor.ev_charger_connected
        name: Vehicle Connected
      - entity: binary_sensor.ev_charge_schedule_enabled
        name: Schedule Enabled
    show_header_toggle: false
```

## 🔔 Automation Examples

### Notify When Charging Starts

```yaml
automation:
  - alias: "EV Charging Started"
    trigger:
      - platform: state
        entity_id: binary_sensor.ev_charger_charging
        to: 'on'
    action:
      - service: notify.notify
        data:
          title: "⚡ EV Charging Started"
          message: >
            {{ states('sensor.ev_connected_vehicle') }} is now charging at 
            {{ states('sensor.ev_charger_power') }} kW
```

### Notify When Charging Completes

```yaml
automation:
  - alias: "EV Charging Complete"
    trigger:
      - platform: state
        entity_id: binary_sensor.ev_charger_charging
        to: 'off'
        for:
          minutes: 5
    condition:
      - condition: state
        entity_id: binary_sensor.ev_charger_connected
        state: 'on'
    action:
      - service: notify.notify
        data:
          title: "✅ EV Charging Complete"
          message: >
            {{ states('sensor.ev_connected_vehicle') }} charged 
            {{ states('sensor.ev_session_energy') }} kWh in 
            {{ states('sensor.ev_session_duration') }}
```

### Notify When Unplugged

```yaml
automation:
  - alias: "EV Unplugged"
    trigger:
      - platform: state
        entity_id: binary_sensor.ev_charger_connected
        to: 'off'
        for:
          seconds: 30
    action:
      - service: notify.notify
        data:
          title: "🔌 EV Unplugged"
          message: >
            {{ states('sensor.ev_connected_vehicle') }} disconnected. 
            Session total: {{ states('sensor.ev_session_energy') }} kWh
```

## 🔧 Troubleshooting

### Sensors Show "Unknown" or "Unavailable"

1. **Test the script manually:**
   ```bash
   /config/shell/solaredge_login.sh
   ```
   Should return JSON data.

2. **Check logs:**
   ```bash
   ha core logs | grep -i solaredge
   ```

3. **Verify cookie hasn't expired:**
   - If the script returns empty data, your cookie has expired
   - Follow Step 1 again to get a fresh cookie
   - Update the script with the new cookie value
   - Restart Home Assistant

### "Empty reply found when expecting JSON data"

Your cookie has expired. Extract a fresh cookie from your browser and update the script.

### Script Returns No Data

1. **Verify your Site ID is correct:**
   - Login to monitoring.solaredge.com
   - Check the URL for your site ID

2. **Verify cookie is valid:**
   - Extract a fresh cookie from browser
   - Update the script

3. **Check network connectivity:**
   ```bash
   curl -s https://monitoring.solaredge.com | head -20
   ```

### Template Sensors Not Updating

1. **Check raw sensor has data:**
   - Go to Developer Tools → States
   - Find `sensor.solaredge_ev_charger_raw`
   - Click to expand and verify `devicesByType` attribute exists

2. **Reload templates:**
   - Developer Tools → YAML
   - Click "Template Entities" → Reload

## 🔄 Maintenance

### Cookie Refresh (Every 7-14 Days)

The browser cookie typically expires after 7-14 days. When sensors stop updating:

1. Login to https://monitoring.solaredge.com in your browser
2. Extract the new `SPRING_SECURITY_REMEMBER_ME_COOKIE` (see Step 1)
3. Update the cookie in the script:
   ```bash
   nano /config/shell/solaredge_login.sh
   ```
4. Replace the `COOKIE_VALUE` with the new cookie
5. Save and restart Home Assistant:
   ```bash
   ha core restart
   ```

### Monitoring Cookie Expiration

You can create an automation to alert you when the cookie expires:

```yaml
automation:
  - alias: "SolarEdge Cookie Expired"
    trigger:
      - platform: state
        entity_id: sensor.solaredge_ev_charger_raw
        to: 'No Data'
        for:
          minutes: 10
    action:
      - service: notify.notify
        data:
          title: "⚠️ SolarEdge Cookie Expired"
          message: "Please refresh the SolarEdge authentication cookie"
```

## 📁 File Structure

After installation, your configuration should look like this:

```
/config/
├── configuration.yaml          (includes command_line.yaml and templates.yaml)
├── command_line.yaml           (sensor that fetches data)
├── templates.yaml              (template sensors for display)
├── automations.yaml            (optional automation examples)
└── shell/
    └── solaredge_login.sh      (script that fetches data from SolarEdge)
```

## ⚙️ Configuration Options

### Scan Interval

By default, the sensor updates every 30 seconds. You can adjust this in `command_line.yaml`:

```yaml
scan_interval: 30  # Change to 60 for once per minute
```

**Note:** Don't set this too low to avoid potential rate limiting.

### Timeout

If your network is slow, increase the timeout:

```yaml
command_timeout: 30  # Change to 60 for slower connections
```

## 🌟 Features in Detail

### Charger Status Values
- **Charging** - Actively charging the vehicle
- **Plugged In** - Vehicle connected but not charging
- **Not Connected** - No vehicle plugged in

### Charger Mode Values
- **Manual** - Manual control only
- **Auto** - Automatic mode (solar-based or scheduled)

### Energy Dashboard Integration

The session energy sensor is compatible with Home Assistant's Energy Dashboard:

1. Go to **Settings** → **Dashboards** → **Energy**
2. Click **Add Consumption**
3. Select `sensor.ev_session_energy`

## 🔒 Security Considerations

- **Cookie Storage:** The authentication cookie is stored in plain text in the shell script
- **File Permissions:** The script is only readable by root/homeassistant user
- **Cookie Lifetime:** Cookies expire after 7-14 days for security
- **No API Key Required:** This uses browser authentication, not an API key

## 🐛 Known Issues

1. **Cookie Expiration:** You need to manually refresh the cookie every 1-2 weeks
2. **Private API:** This uses SolarEdge's undocumented private API which could change at any time
3. **No Write Access:** This integration is read-only; you cannot control the charger from Home Assistant
4. **Single Charger:** Designed for single charger setups (can be modified for multiple)

## 🗺️ Roadmap

- [ ] Automated cookie refresh mechanism
- [ ] Multi-charger support
- [ ] Charger control (start/stop charging)
- [ ] HACS integration
- [ ] Custom Lovelace card

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 Changelog

### v1.0.0 (2026-01-10)
- Initial release
- Support for all EV Charger sensors
- Dashboard examples
- Automation examples

## ⚖️ License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Thanks to the Home Assistant community
- Thanks to SolarEdge for their monitoring platform
- Inspired by various community integrations

## ⚠️ Disclaimer

This integration uses SolarEdge's private/undocumented API. It is not officially supported by SolarEdge and may break at any time if they change their API. Use at your own risk.

This integration is not affiliated with, endorsed by, or connected to SolarEdge Technologies Ltd.

---

**Made with ❤️ for the Home Assistant community**

If this integration helped you, consider giving it a ⭐ on GitHub!
