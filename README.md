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
- **Excess Solar Status** - Shows if Excess PV charging is enabled/disabled ✨ NEW
- **Session Solar Usage** - Solar energy used in session (when Excess PV enabled) ✨ NEW
- **Schedule Status** - Shows active charging schedules ✨ NEW
- **Next Scheduled Charge** - Time of next scheduled charge (when applicable) ✨ NEW

### Binary Sensors
- **Vehicle Connected** - Is a vehicle plugged in?
- **Currently Charging** - Is charging active?
- **Schedule Enabled** - Is a charging schedule configured?
- **Excess Solar Enabled** - Is excess solar charging enabled? ✨ NEW

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

Paste the following **UPDATED** template configuration:

```yaml
# =============================================================================
# SolarEdge EV Charger Template Sensors
# Updated to mimic SolarEdge Smart Home Dashboard
# =============================================================================

sensor:
  # =========================================================================
  # BASIC CHARGER INFORMATION
  # =========================================================================
  
  - name: "EV Charger Status"
    unique_id: ev_charger_status
    state: >
      {% set charger = state_attr('sensor.solaredge_ev_charger_raw', 'devicesByType')['EV_CHARGER'][0] %}
      {% if charger.chargerStatus == 'CHARGING' %}
        Charging
      {% elif charger.chargerStatus == 'PLUGGED_IN' %}
        Plugged In
      {% elif charger.chargerStatus == 'NOT_CONNECTED' %}
        Not Connected
      {% else %}
        {{ charger.chargerStatus }}
      {% endif %}
    icon: >
      {% set charger = state_attr('sensor.solaredge_ev_charger_raw', 'devicesByType')['EV_CHARGER'][0] %}
      {% if charger.chargerStatus == 'CHARGING' %}
        mdi:ev-station
      {% elif charger.chargerStatus == 'PLUGGED_IN' %}
        mdi:ev-plug-type2
      {% else %}
        mdi:ev-plug-type2
      {% endif %}

  - name: "EV Charger Power"
    unique_id: ev_charger_power
    unit_of_measurement: "kW"
    device_class: power
    state_class: measurement
    state: >
      {% set charger = state_attr('sensor.solaredge_ev_charger_raw', 'devicesByType')['EV_CHARGER'][0] %}
      {% if charger.chargerStatus == 'CHARGING' and charger.chargerStatusSubTitle is defined and charger.chargerStatusSubTitle|length > 0 %}
        {{ (charger.chargerStatusSubTitle[0].numericValue / 1000) | round(2) }}
      {% else %}
        0
      {% endif %}

  - name: "EV Session Energy"
    unique_id: ev_session_energy
    unit_of_measurement: "kWh"
    device_class: energy
    state_class: total_increasing
    state: >
      {% set charger = state_attr('sensor.solaredge_ev_charger_raw', 'devicesByType')['EV_CHARGER'][0] %}
      {% if charger.sessionActive %}
        {{ (charger.sessionEnergy / 1000) | round(2) }}
      {% else %}
        0
      {% endif %}

  - name: "EV Session Duration"
    unique_id: ev_session_duration
    icon: mdi:timer
    state: >
      {% set charger = state_attr('sensor.solaredge_ev_charger_raw', 'devicesByType')['EV_CHARGER'][0] %}
      {% if charger.sessionActive %}
        {% set duration_seconds = charger.sessionDuration %}
        {% set hours = (duration_seconds // 3600) | int %}
        {% set minutes = ((duration_seconds % 3600) // 60) | int %}
        {% if hours > 0 %}
          {{ hours }}h {{ minutes }}m
        {% else %}
          {{ minutes }}m
        {% endif %}
      {% else %}
        0m
      {% endif %}

  - name: "EV Connected Vehicle"
    unique_id: ev_connected_vehicle
    icon: mdi:car-electric
    state: >
      {% set charger = state_attr('sensor.solaredge_ev_charger_raw', 'devicesByType')['EV_CHARGER'][0] %}
      {% if charger.applianceData is defined %}
        {{ charger.applianceData.alias }}
      {% else %}
        Unknown
      {% endif %}

  - name: "EV Charger Mode"
    unique_id: ev_charger_mode
    icon: mdi:cog
    state: >
      {% set charger = state_attr('sensor.solaredge_ev_charger_raw', 'devicesByType')['EV_CHARGER'][0] %}
      {{ charger.activationMode | title }}

  - name: "EV Connection Status"
    unique_id: ev_connection_status
    icon: mdi:connection
    state: >
      {% set charger = state_attr('sensor.solaredge_ev_charger_raw', 'devicesByType')['EV_CHARGER'][0] %}
      {{ charger.connectionStatus | replace('_', ' ') | title }}

  - name: "EV Session Distance"
    unique_id: ev_session_distance
    unit_of_measurement: "km"
    icon: mdi:map-marker-distance
    state: >
      {% set charger = state_attr('sensor.solaredge_ev_charger_raw', 'devicesByType')['EV_CHARGER'][0] %}
      {% if charger.sessionActive %}
        {{ charger.sessionDistance | round(1) }}
      {% else %}
        0
      {% endif %}

  - name: "EV Session Distance (Miles)"
    unique_id: ev_session_distance_mi
    unit_of_measurement: "mi"
    icon: mdi:map-marker-distance
    state: >
      {% set charger = state_attr('sensor.solaredge_ev_charger_raw', 'devicesByType')['EV_CHARGER'][0] %}
      {% if charger.sessionActive %}
        {{ (charger.sessionDistance * 0.621371) | round(1) }}
      {% else %}
        0
      {% endif %}

  # =========================================================================
  # EXCESS SOLAR MONITORING (NEW)
  # =========================================================================
  
  - name: "EV Excess Solar Status"
    unique_id: ev_excess_solar_status
    icon: >
      {% set charger = state_attr('sensor.solaredge_ev_charger_raw', 'devicesByType')['EV_CHARGER'][0] %}
      {% if charger.excessPV == -1 %}
        mdi:solar-power
      {% else %}
        mdi:solar-power-variant-outline
      {% endif %}
    state: >
      {% set charger = state_attr('sensor.solaredge_ev_charger_raw', 'devicesByType')['EV_CHARGER'][0] %}
      {% if charger.excessPV == -1 %}
        Enabled
      {% elif charger.excessPV == -2 %}
        Disabled
      {% else %}
        Unknown
      {% endif %}

  - name: "EV Session Solar Usage"
    unique_id: ev_session_solar_usage
    icon: mdi:solar-panel
    state: >
      {% set charger = state_attr('sensor.solaredge_ev_charger_raw', 'devicesByType')['EV_CHARGER'][0] %}
      {% if charger.excessPV == -1 %}
        {% if charger.sessionSolarUsage != 'NONE' %}
          {{ charger.sessionSolarUsage | replace('_', ' ') | title }}
        {% else %}
          No Solar Usage
        {% endif %}
      {% else %}
        Excess Solar Disabled
      {% endif %}

  # =========================================================================
  # SCHEDULE MONITORING (NEW)
  # =========================================================================
  
  - name: "EV Charging Schedules"
    unique_id: ev_charging_schedules
    icon: mdi:calendar-clock
    state: >
      {% set charger = state_attr('sensor.solaredge_ev_charger_raw', 'devicesByType')['EV_CHARGER'][0] %}
      {% set enabled_schedules = charger.deviceTriggers | selectattr('enable', 'equalto', true) | list %}
      {% if enabled_schedules | length > 0 %}
        {{ enabled_schedules | length }} Schedule(s) Active
      {% else %}
        No Schedules
      {% endif %}
    attributes:
      schedules: >
        {% set charger = state_attr('sensor.solaredge_ev_charger_raw', 'devicesByType')['EV_CHARGER'][0] %}
        {% set enabled_schedules = charger.deviceTriggers | selectattr('enable', 'equalto', true) | list %}
        {% set schedule_list = [] %}
        {% for schedule in enabled_schedules %}
          {% set start_hour = (schedule.startTime // 60) | int %}
          {% set start_min = (schedule.startTime % 60) | int %}
          {% set end_hour = (schedule.endTime // 60) | int %}
          {% set end_min = (schedule.endTime % 60) | int %}
          {% set time_range = '%02d:%02d - %02d:%02d' | format(start_hour, start_min, end_hour, end_min) %}
          {% set days_abbrev = [] %}
          {% if 'MONDAY' in schedule.scheduledDays %}{% set days_abbrev = days_abbrev + ['Mon'] %}{% endif %}
          {% if 'TUESDAY' in schedule.scheduledDays %}{% set days_abbrev = days_abbrev + ['Tue'] %}{% endif %}
          {% if 'WEDNESDAY' in schedule.scheduledDays %}{% set days_abbrev = days_abbrev + ['Wed'] %}{% endif %}
          {% if 'THURSDAY' in schedule.scheduledDays %}{% set days_abbrev = days_abbrev + ['Thu'] %}{% endif %}
          {% if 'FRIDAY' in schedule.scheduledDays %}{% set days_abbrev = days_abbrev + ['Fri'] %}{% endif %}
          {% if 'SATURDAY' in schedule.scheduledDays %}{% set days_abbrev = days_abbrev + ['Sat'] %}{% endif %}
          {% if 'SUNDAY' in schedule.scheduledDays %}{% set days_abbrev = days_abbrev + ['Sun'] %}{% endif %}
          {% set days_str = days_abbrev | join(', ') %}
          {% set schedule_list = schedule_list + [time_range + ' (' + days_str + ')'] %}
        {% endfor %}
        {{ schedule_list }}

  - name: "EV Next Scheduled Charge"
    unique_id: ev_next_scheduled_charge
    icon: mdi:clock-outline
    device_class: timestamp
    state: >
      {% set charger = state_attr('sensor.solaredge_ev_charger_raw', 'devicesByType')['EV_CHARGER'][0] %}
      {% set enabled_schedules = charger.deviceTriggers | selectattr('enable', 'equalto', true) | list %}
      {% if enabled_schedules | length > 0 and charger.chargerStatus != 'CHARGING' %}
        {% if charger.scheduleInfo is defined and charger.scheduleInfo.startDate is defined %}
          {{ (charger.scheduleInfo.startDate / 1000) | timestamp_local }}
        {% else %}
          {% set now = now() %}
          {% set current_day = now.weekday() %}
          {% set current_time = now.hour * 60 + now.minute %}
          {% set days_map = {'MONDAY': 0, 'TUESDAY': 1, 'WEDNESDAY': 2, 'THURSDAY': 3, 'FRIDAY': 4, 'SATURDAY': 5, 'SUNDAY': 6} %}
          {% set next_schedule = namespace(time=none, days_ahead=999) %}
          {% for schedule in enabled_schedules %}
            {% for day in schedule.scheduledDays %}
              {% set schedule_day = days_map[day] %}
              {% set days_until = (schedule_day - current_day) % 7 %}
              {% if days_until == 0 and schedule.startTime > current_time %}
                {% if days_until < next_schedule.days_ahead or (days_until == next_schedule.days_ahead and schedule.startTime < next_schedule.time) %}
                  {% set next_schedule.time = schedule.startTime %}
                  {% set next_schedule.days_ahead = days_until %}
                {% endif %}
              {% elif days_until > 0 %}
                {% if days_until < next_schedule.days_ahead or (days_until == next_schedule.days_ahead and schedule.startTime < next_schedule.time) %}
                  {% set next_schedule.time = schedule.startTime %}
                  {% set next_schedule.days_ahead = days_until %}
                {% endif %}
              {% endif %}
            {% endfor %}
          {% endfor %}
          {% if next_schedule.time is not none %}
            {% set next_date = now + timedelta(days=next_schedule.days_ahead) %}
            {% set next_hour = (next_schedule.time // 60) | int %}
            {% set next_min = (next_schedule.time % 60) | int %}
            {{ next_date.replace(hour=next_hour, minute=next_min, second=0, microsecond=0).isoformat() }}
          {% else %}
            unavailable
          {% endif %}
        {% endif %}
      {% else %}
        unavailable
      {% endif %}

# =============================================================================
# BINARY SENSORS
# =============================================================================

binary_sensor:
  - name: "EV Charger Connected"
    unique_id: ev_charger_connected
    device_class: plug
    state: >
      {% set charger = state_attr('sensor.solaredge_ev_charger_raw', 'devicesByType')['EV_CHARGER'][0] %}
      {{ charger.connectionStatus in ['CONNECTED', 'CHARGING'] }}

  - name: "EV Charger Charging"
    unique_id: ev_charger_charging
    device_class: battery_charging
    state: >
      {% set charger = state_attr('sensor.solaredge_ev_charger_raw', 'devicesByType')['EV_CHARGER'][0] %}
      {{ charger.chargerStatus == 'CHARGING' }}

  - name: "EV Charge Schedule Enabled"
    unique_id: ev_charge_schedule_enabled
    device_class: running
    icon: mdi:calendar-check
    state: >
      {% set charger = state_attr('sensor.solaredge_ev_charger_raw', 'devicesByType')['EV_CHARGER'][0] %}
      {% set enabled_schedules = charger.deviceTriggers | selectattr('enable', 'equalto', true) | list %}
      {{ enabled_schedules | length > 0 }}

  - name: "EV Excess Solar Enabled"
    unique_id: ev_excess_solar_enabled
    device_class: running
    icon: mdi:solar-power
    state: >
      {% set charger = state_attr('sensor.solaredge_ev_charger_raw', 'devicesByType')['EV_CHARGER'][0] %}
      {{ charger.excessPV == -1 }}
```

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
3. You should see all 16 sensors with data (4 new sensors added!)

## 📊 Dashboard Configuration

### Enhanced Entities Card (Mimics SolarEdge Dashboard)

```yaml
type: entities
title: EV Charger
entities:
  # Main Status
  - entity: sensor.ev_charger_status
    name: Status
  - entity: sensor.ev_connected_vehicle
    name: Connected Car
  
  # Charging Information (when active)
  - type: conditional
    conditions:
      - entity: binary_sensor.ev_charger_charging
        state: "on"
    row:
      entity: sensor.ev_charger_power
      name: Charging Power
  
  - type: conditional
    conditions:
      - entity: binary_sensor.ev_charger_connected
        state: "on"
    row:
      entity: sensor.ev_session_energy
      name: Session Energy
  
  - type: conditional
    conditions:
      - entity: binary_sensor.ev_charger_connected
        state: "on"
    row:
      entity: sensor.ev_session_duration
      name: Session Duration
  
  # Excess Solar Status
  - type: section
  - entity: sensor.ev_excess_solar_status
    name: Excess Solar
  - type: conditional
    conditions:
      - entity: sensor.ev_excess_solar_status
        state: "Enabled"
    row:
      entity: sensor.ev_session_solar_usage
      name: Solar Usage
  
  # Schedule Status
  - type: section
  - entity: sensor.ev_charging_schedules
    name: Charging Schedule
  
  - type: conditional
    conditions:
      - entity: binary_sensor.ev_charge_schedule_enabled
        state: "on"
    row:
      type: attribute
      entity: sensor.ev_charging_schedules
      attribute: schedules
      name: Active Schedules
  
  - type: conditional
    conditions:
      - entity: binary_sensor.ev_charge_schedule_enabled
        state: "on"
      - entity: binary_sensor.ev_charger_charging
        state: "off"
    row:
      entity: sensor.ev_next_scheduled_charge
      name: Next Charge
      format: relative

show_header_toggle: false
```

### Advanced Multi-Card Layout

```yaml
type: vertical-stack
cards:
  # Status Overview
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
  
  # Current Session Info
  - type: conditional
    conditions:
      - entity: binary_sensor.ev_charger_connected
        state: "on"
    card:
      type: entities
      title: Current Session
      entities:
        - entity: sensor.ev_session_energy
          name: Energy Delivered
        - entity: sensor.ev_session_duration
          name: Duration
        - entity: sensor.ev_session_distance_mi
          name: Estimated Range Added
        - entity: sensor.ev_connected_vehicle
          name: Vehicle
      show_header_toggle: false
  
  # Solar & Schedule Settings
  - type: entities
    title: Charging Settings
    entities:
      - entity: sensor.ev_charger_mode
        name: Charging Mode
      
      - type: section
        label: Solar Charging
      
      - entity: sensor.ev_excess_solar_status
        name: Excess Solar
      
      - type: conditional
        conditions:
          - entity: sensor.ev_excess_solar_status
            state: "Enabled"
        row:
          entity: sensor.ev_session_solar_usage
          name: Session Solar Usage
      
      - type: section
        label: Scheduled Charging
      
      - entity: sensor.ev_charging_schedules
        name: Schedule Status
      
      - type: conditional
        conditions:
          - entity: binary_sensor.ev_charge_schedule_enabled
            state: "on"
        row:
          type: attribute
          entity: sensor.ev_charging_schedules
          attribute: schedules
          name: Active Schedules
      
      - type: conditional
        conditions:
          - entity: binary_sensor.ev_charge_schedule_enabled
            state: "on"
          - entity: binary_sensor.ev_charger_charging
            state: "off"
        row:
          entity: sensor.ev_next_scheduled_charge
          name: Next Scheduled Charge
          format: relative
    
    show_header_toggle: false
```

### Compact Dashboard Card

```yaml
type: entities
title: EV Charger - Compact
entities:
  - entity: sensor.ev_charger_status
  - entity: sensor.ev_connected_vehicle
  - entity: sensor.ev_excess_solar_status
  - entity: sensor.ev_charging_schedules
  - type: conditional
    conditions:
      - entity: binary_sensor.ev_charge_schedule_enabled
        state: "on"
    row:
      entity: sensor.ev_next_scheduled_charge
      format: relative
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
            {% if is_state('sensor.ev_excess_solar_status', 'Enabled') %}
            (Excess Solar: {{ states('sensor.ev_session_solar_usage') }})
            {% endif %}
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
            {% if not is_state('sensor.ev_session_solar_usage', 'No Solar Usage') and not is_state('sensor.ev_session_solar_usage', 'Excess Solar Disabled') %}
            Solar Usage: {{ states('sensor.ev_session_solar_usage') }}
            {% endif %}
```

### Notify About Next Scheduled Charge

```yaml
automation:
  - alias: "EV Next Scheduled Charge Reminder"
    trigger:
      - platform: time_pattern
        hours: "20"
        minutes: "0"
    condition:
      - condition: state
        entity_id: binary_sensor.ev_charge_schedule_enabled
        state: 'on'
      - condition: state
        entity_id: binary_sensor.ev_charger_connected
        state: 'on'
      - condition: state
        entity_id: binary_sensor.ev_charger_charging
        state: 'off'
    action:
      - service: notify.notify
        data:
          title: "📅 EV Charging Reminder"
          message: >
            Your {{ states('sensor.ev_connected_vehicle') }} is scheduled to charge 
            {{ relative_time(states('sensor.ev_next_scheduled_charge')) }}
```

### Notify When Excess Solar Charging Available

```yaml
automation:
  - alias: "EV Excess Solar Available"
    trigger:
      - platform: state
        entity_id: sensor.ev_session_solar_usage
        from: 'No Solar Usage'
    condition:
      - condition: state
        entity_id: binary_sensor.ev_charger_connected
        state: 'on'
      - condition: state
        entity_id: sensor.ev_excess_solar_status
        state: 'Enabled'
    action:
      - service: notify.notify
        data:
          title: "☀️ Excess Solar Charging"
          message: >
            Your {{ states('sensor.ev_connected_vehicle') }} is now using 
            {{ states('sensor.ev_session_solar_usage') }} solar power
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

### New Sensors Not Appearing

1. **Reload template entities:**
   - Developer Tools → YAML
   - Click "Template Entities" → Reload

2. **Check raw sensor has data:**
   - Go to Developer Tools → States
   - Find `sensor.solaredge_ev_charger_raw`
   - Click to expand and verify `devicesByType` attribute exists
   - Verify `excessPV` and `deviceTriggers` fields are present

### Schedule Times Not Correct

The schedule times use your local timezone. If they appear incorrect:
1. Verify your Home Assistant timezone is set correctly
2. Check Settings → System → General → Time Zone

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
├── templates.yaml              (template sensors for display - UPDATED)
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

### Excess Solar Status Values ✨ NEW
- **Enabled** - Excess PV charging is active (excessPV = -1)
- **Disabled** - Excess PV charging is off (excessPV = -2)

### Session Solar Usage Values ✨ NEW
Shows solar energy usage when Excess Solar is enabled:
- **No Solar Usage** - No solar power being used (sessionSolarUsage = "NONE")
- **Low / Medium / High / Full** - Various levels of solar usage
- **Excess Solar Disabled** - When excess solar is turned off

### Schedule Information ✨ NEW
- **Active Schedules** - List of enabled charging schedules with times and days
- **Next Scheduled Charge** - Timestamp of the next scheduled charging session
- Schedules display in 24-hour format with day abbreviations (e.g., "10:00 - 12:00 (Mon, Tue, Wed)")

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
5. **Schedule Calculation:** Next schedule calculation is estimated based on current time if SolarEdge doesn't provide scheduleInfo

## 🗺️ Roadmap

- [ ] Automated cookie refresh mechanism
- [ ] Multi-charger support
- [ ] Charger control (start/stop charging)
- [ ] HACS integration
- [ ] Custom Lovelace card

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 Changelog

### v1.1.0 (2026-01-12)
- ✨ Added Excess Solar status sensor
- ✨ Added Session Solar Usage sensor
- ✨ Added Charging Schedules sensor with schedule details
- ✨ Added Next Scheduled Charge sensor with timestamp
- ✨ Added Excess Solar Enabled binary sensor
- 📝 Updated dashboard examples to mimic SolarEdge Smart Home interface
- 📝 Added new automation examples for solar and schedule notifications

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
