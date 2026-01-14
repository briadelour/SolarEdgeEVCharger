# SolarEdge EV Charger Integration for Home Assistant

Manual notes to monitor and **control** your SolarEdge EV Charger directly in Home Assistant using the private SolarEdge API.

[![Home Assistant](https://img.shields.io/badge/Home%20Assistant-Compatible-blue.svg)](https://www.home-assistant.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 📸 Screenshots

<img width="506" height="840" alt="image" src="https://github.com/user-attachments/assets/39aa1e1d-154e-4914-b59d-ee71e864487e" />

## ✨ Features

This integration provides comprehensive monitoring **and control** of your SolarEdge EV Charger.

### Main Sensors
- **Charger Status** - Current state (Charging, Plugged In, Not Connected)
- **Charging Power** - Real-time power in kW (properly displays kW, not W!)
- **Session Energy** - Energy delivered in current session (kWh)
- **Session Duration** - How long the current session has been active
- **Connected Vehicle** - Name of the connected vehicle
- **Charger Mode** - Manual or Auto (Solar/Schedule)
- **Connection Status** - Detailed connection information
- **Session Distance** - Estimated driving range added (km & miles)
- **Excess Solar Status** - Shows if Excess PV charging is enabled/disabled ✨
- **Session Solar Usage** - Solar energy used in session (when Excess PV enabled) ✨
- **Charging Schedules** - List of active charging schedules with times ✨
- **Next Scheduled Charge** - Timestamp of next scheduled charge ✨

### Binary Sensors
- **Vehicle Connected** - Is a vehicle plugged in?
- **Currently Charging** - Is charging active?
- **Schedule Enabled** - Is a charging schedule configured?
- **Excess Solar Enabled** - Is excess solar charging enabled? ✨

### Manual Control ✨ NEW
- **Start Charging** - Manually start charging at any time
- **Stop Charging** - Manually stop charging
- Smart dashboard buttons that only appear when relevant

### Automation Ready
All sensors include proper device classes and state classes for:
- Energy Dashboard integration
- Automations and notifications
- Historical tracking and statistics
- Smart home control workflows

## 📋 Prerequisites

- **Home Assistant OS** (HAOS) or Home Assistant Container
- **SolarEdge Account** with EV Charger
- **Admin Access** to your Home Assistant configuration files
- **Terminal & SSH Add-on** installed (for HAOS)

## 🚀 Quick Start

**New to this integration?** Check out the [Quick Start Guide](QUICKSTART.md) for a streamlined 10-minute setup!

## 📖 Full Installation Guide

### Step 1: Get Your SolarEdge Credentials

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

Paste the contents of [solaredge_login.sh](solaredge_login.sh) and update:
- Replace `YOUR_SITE_ID` with your Site ID
- Replace `YOUR_COOKIE_VALUE` with your cookie

**Save:** Press `CTRL+X`, then `Y`, then `ENTER`

**Make it executable:**
```bash
chmod +x /config/shell/solaredge_login.sh
```

### Step 3: Test the Script

```bash
/config/shell/solaredge_login.sh
```

You should see JSON output with your EV Charger data.

### Step 4: Create Configuration Files

Download and place these files in `/config/`:

- [command_line.yaml](command_line.yaml) - Sensor configuration
- [templates.yaml](templates.yaml) - Template sensors
- [shell_command.yaml](shell_command.yaml) - Shell commands for start/stop (optional)

### Step 5: Update configuration.yaml

```bash
nano /config/configuration.yaml
```

Add these lines:

```yaml
command_line: !include command_line.yaml
template: !include templates.yaml
shell_command: !include shell_command.yaml  # Optional: for start/stop control
```

### Step 6: Restart Home Assistant

```bash
ha core restart
```

Wait 2-3 minutes for Home Assistant to restart.

### Step 7: Verify Sensors

1. Go to **Developer Tools** → **States**
2. Search for `ev_charger`
3. You should see 16 sensors! ✅

## 🎮 Adding Manual Start/Stop Control (Optional)

Want to manually start and stop charging from Home Assistant? See the [Charging Control Guide](CHARGING_CONTROL.md) for complete setup instructions.

**Quick Overview:**
1. Find your Device ID (reporterId)
2. Create start/stop shell scripts
3. Add button entities to templates.yaml
4. Add conditional buttons to your dashboard

See full guide: [CHARGING_CONTROL.md](CHARGING_CONTROL.md)

## 📊 Dashboard Examples

### Basic Card

```yaml
type: entities
title: EV Charger
entities:
  - sensor.ev_charger_status
  - sensor.ev_charger_power
  - sensor.ev_session_energy
  - sensor.ev_excess_solar_status
  - sensor.ev_charging_schedules
```

**More examples:** [dashboard-examples.md](dashboard-examples.md)

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
          message: "{{ states('sensor.ev_connected_vehicle') }} is now charging"
```

**More examples:** [automation-examples.md](automation-examples.md)

## 🔧 Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed solutions to common issues:

- Sensors showing "Unknown" or "Unavailable"
- Cookie expiration issues
- "Empty reply" errors
- Power displaying in W instead of kW
- Template sensor issues

## 🔄 Maintenance

### Cookie Refresh (Every 7-14 Days)

The browser cookie typically expires after 7-14 days. When sensors stop updating:

1. Login to https://monitoring.solaredge.com
2. Extract new cookie (see Step 1)
3. Update `/config/shell/solaredge_login.sh`
4. Restart Home Assistant

**Tip:** Set up an automation to alert you when the cookie expires (see [automation-examples.md](automation-examples.md))

## 📁 File Structure

```
/config/
├── configuration.yaml
├── command_line.yaml
├── templates.yaml
├── shell_command.yaml (optional)
└── shell/
    ├── solaredge_login.sh
    ├── solaredge_start_charging.sh (optional)
    └── solaredge_stop_charging.sh (optional)
```

## 🌟 New in Version 1.1.0

### ✨ Enhanced Solar Monitoring
- **Excess Solar Status** - Track when excess PV charging is enabled/disabled
- **Session Solar Usage** - Monitor solar energy usage during charging sessions
- Real-time solar charging indicators

### 📅 Schedule Management
- **Active Schedules** - View all enabled charging schedules with times and days
- **Next Scheduled Charge** - See when your next scheduled charge will begin
- Schedule status integration with dashboard

### 🎮 Manual Charging Control (Optional)
- Start and stop charging directly from Home Assistant
- Smart conditional buttons that only appear when relevant
- Manual override of schedules and solar charging modes

### 🐛 Bug Fixes
- Fixed power sensor displaying W instead of kW
- Improved template sensor reliability
- Better error handling for missing data

## 📝 Changelog

### v1.1.0 (2026-01-13)
- ✨ Added Excess Solar status and usage sensors
- ✨ Added charging schedule monitoring
- ✨ Added next scheduled charge timestamp
- ✨ Added manual start/stop charging control (optional)
- ✨ Added Excess Solar Enabled binary sensor
- 🐛 Fixed power sensor displaying W instead of kW
- 📝 Improved documentation with separate guides
- 📝 Added comprehensive troubleshooting guide

### v1.0.0 (2026-01-10)
- Initial release
- Basic sensor monitoring
- Binary sensors for status tracking

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## ⚖️ License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This integration uses SolarEdge's private/undocumented API. It is not officially supported by SolarEdge and may break at any time if they change their API. Use at your own risk.

This integration is not affiliated with, endorsed by, or connected to SolarEdge Technologies Ltd.

## 🙏 Acknowledgments

- Thanks to the Home Assistant community
- Thanks to SolarEdge for their monitoring platform
- Thanks to all contributors and testers

---

## 📚 Documentation Index

- **[Quick Start Guide](QUICKSTART.md)** - Get started in 10 minutes
- **[Charging Control Guide](CHARGING_CONTROL.md)** - Add start/stop functionality
- **[Dashboard Examples](dashboard-examples.md)** - Various dashboard layouts
- **[Automation Examples](automation-examples.md)** - Useful automation templates
- **[Troubleshooting Guide](TROUBLESHOOTING.md)** - Solutions to common problems

---

**Made with ❤️ for the Home Assistant community**

If this integration helped you, consider giving it a ⭐ on GitHub!
