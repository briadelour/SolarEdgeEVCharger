# Automation Examples

This file contains various automation examples for your SolarEdge EV Charger integration, including automations for the new Excess Solar, Schedule Monitoring, and Manual Control features.

## Table of Contents

- [Basic Notifications](#basic-notifications)
- [Solar Charging Automations](#solar-charging-automations-new)
- [Schedule Monitoring](#schedule-monitoring-new)
- [Manual Control Automations](#manual-control-automations-new)
- [Advanced Notifications](#advanced-notifications)
- [Time-Based Automations](#time-based-automations)
- [Energy Tracking](#energy-tracking)
- [Smart Charging](#smart-charging)
- [Integration with Solar](#integration-with-solar)
- [Cookie & Maintenance](#cookie--maintenance)

---

## Basic Notifications

### Notify When Charging Starts

```yaml
automation:
  - alias: "EV Charging Started"
    description: "Send notification when EV starts charging"
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
    description: "Notify when charging stops while vehicle is still connected"
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

### Notify When Vehicle Plugged In

```yaml
automation:
  - alias: "EV Plugged In"
    description: "Notify when vehicle is connected to charger"
    trigger:
      - platform: state
        entity_id: binary_sensor.ev_charger_connected
        to: 'on'
        for:
          seconds: 10
    action:
      - service: notify.notify
        data:
          title: "🔌 EV Connected"
          message: >
            {{ states('sensor.ev_connected_vehicle') }} has been plugged in.
            Charger mode: {{ states('sensor.ev_charger_mode') }}
```

### Notify When Vehicle Unplugged

```yaml
automation:
  - alias: "EV Unplugged"
    description: "Notify when vehicle is disconnected"
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

show_header_toggle: false
```

---

## Solar Charging Automations ✨ NEW

### Notify When Solar Charging Becomes Available

```yaml
automation:
  - alias: "EV Solar Charging Available"
    description: "Notify when excess solar becomes available for charging"
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
          title: "☀️ Solar Charging Active"
          message: >
            Your {{ states('sensor.ev_connected_vehicle') }} is now using 
            {{ states('sensor.ev_session_solar_usage') }} solar power!
```

### Notify When Excess Solar is Enabled

```yaml
automation:
  - alias: "EV Excess Solar Enabled"
    description: "Notify when excess solar charging is turned on"
    trigger:
      - platform: state
        entity_id: sensor.ev_excess_solar_status
        to: 'Enabled'
    action:
      - service: notify.notify
        data:
          title: "☀️ Excess Solar Enabled"
          message: >
            Excess solar charging is now active. Your EV will charge from 
            surplus solar production when available.
```

### Report Solar Usage in Charging Summary

```yaml
automation:
  - alias: "EV Charging Summary with Solar"
    description: "Detailed summary including solar usage"
    trigger:
      - platform: state
        entity_id: binary_sensor.ev_charger_connected
        to: 'off'
        for:
          seconds: 30
    variables:
      energy: "{{ states('sensor.ev_session_energy') }}"
      duration: "{{ states('sensor.ev_session_duration') }}"
      solar: "{{ states('sensor.ev_session_solar_usage') }}"
      vehicle: "{{ states('sensor.ev_connected_vehicle') }}"
    action:
      - service: notify.notify
        data:
          title: "🚗 {{ vehicle }} - Charging Complete"
          message: >
            Energy: {{ energy }} kWh
            Duration: {{ duration }}
            {% if solar != 'No Solar Usage' and solar != 'Excess Solar Disabled' %}
            Solar Usage: {{ solar }}
            {% endif %}
```

### Auto-Start Charging When Solar is High

```yaml
automation:
  - alias: "EV Auto-Start on High Solar"
    description: "Start charging when solar production is high (requires manual control setup)"
    trigger:
      - platform: numeric_state
        entity_id: sensor.solar_power  # Your solar power sensor
        above: 5000  # Adjust for your system
        for:
          minutes: 5
    condition:
      - condition: state
        entity_id: binary_sensor.ev_charger_connected
        state: 'on'
      - condition: state
        entity_id: binary_sensor.ev_charger_charging
        state: 'off'
      - condition: state
        entity_id: sensor.ev_excess_solar_status
        state: 'Enabled'
    action:
      - service: button.press
        target:
          entity_id: button.ev_charger_start_charging
      - service: notify.notify
        data:
          title: "☀️ Auto-Started Solar Charging"
          message: "High solar production detected, started EV charging"
```

---

## Schedule Monitoring ✨ NEW

### Notify About Next Scheduled Charge

```yaml
automation:
  - alias: "EV Next Charge Reminder"
    description: "Evening reminder about next scheduled charge"
    trigger:
      - platform: time
        at: "20:00:00"
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

### Notify When Schedule Charging Starts

```yaml
automation:
  - alias: "EV Scheduled Charging Started"
    description: "Notify when charging starts via schedule"
    trigger:
      - platform: state
        entity_id: binary_sensor.ev_charger_charging
        to: 'on'
    condition:
      - condition: state
        entity_id: sensor.ev_charger_mode
        state: 'Auto'
      - condition: state
        entity_id: binary_sensor.ev_charge_schedule_enabled
        state: 'on'
    action:
      - service: notify.notify
        data:
          title: "📅 Scheduled Charging Started"
          message: >
            {{ states('sensor.ev_connected_vehicle') }} started charging on schedule.
            Active schedules: {{ state_attr('sensor.ev_charging_schedules', 'schedules') }}
```

### Alert When Schedule is Disabled

```yaml
automation:
  - alias: "EV Schedule Disabled Alert"
    description: "Notify when charging schedule is turned off"
    trigger:
      - platform: state
        entity_id: binary_sensor.ev_charge_schedule_enabled
        to: 'off'
    action:
      - service: notify.notify
        data:
          title: "⚠️ Charging Schedule Disabled"
          message: >
            Your EV charging schedule has been disabled. 
            Vehicle will not charge automatically based on schedule.
```

---

## Manual Control Automations ✨ NEW

### Notify After Manual Start

```yaml
automation:
  - alias: "EV Manual Charging Started"
    description: "Confirm manual charge start"
    trigger:
      - platform: state
        entity_id: binary_sensor.ev_charger_charging
        to: 'on'
    condition:
      - condition: state
        entity_id: sensor.ev_charger_mode
        state: 'Manual'
    action:
      - service: notify.notify
        data:
          title: "⚡ Manual Charging Started"
          message: >
            {{ states('sensor.ev_connected_vehicle') }} is now charging manually at
            {{ states('sensor.ev_charger_power') }} kW
```

### Notify After Manual Stop

```yaml
automation:
  - alias: "EV Manual Charging Stopped"
    description: "Confirm manual charge stop"
    trigger:
      - platform: state
        entity_id: binary_sensor.ev_charger_charging
        to: 'off'
        for:
          seconds: 10
    condition:
      - condition: state
        entity_id: binary_sensor.ev_charger_connected
        state: 'on'
      - condition: state
        entity_id: sensor.ev_charger_mode
        state: 'Manual'
    action:
      - service: notify.notify
        data:
          title: "⏹️ Manual Charging Stopped"
          message: >
            Charging stopped manually.
            Session: {{ states('sensor.ev_session_energy') }} kWh in
            {{ states('sensor.ev_session_duration') }}
```

### Auto-Stop at Target Energy

```yaml
automation:
  - alias: "EV Auto-Stop at Target"
    description: "Stop charging when target energy is reached"
    trigger:
      - platform: numeric_state
        entity_id: sensor.ev_session_energy
        above: 25  # Target kWh
    condition:
      - condition: state
        entity_id: binary_sensor.ev_charger_charging
        state: 'on'
    action:
      - service: button.press
        target:
          entity_id: button.ev_charger_stop_charging
      - service: notify.notify
        data:
          title: "🎯 Target Energy Reached"
          message: >
            Charging stopped automatically at {{ states('sensor.ev_session_energy') }} kWh
```

### Smart Charge Control Based on Time

```yaml
automation:
  - alias: "EV Smart Time-Based Control"
    description: "Start charging during off-peak hours"
    trigger:
      - platform: time
        at: "23:00:00"  # Off-peak start
    condition:
      - condition: state
        entity_id: binary_sensor.ev_charger_connected
        state: 'on'
      - condition: state
        entity_id: binary_sensor.ev_charger_charging
        state: 'off'
    action:
      - service: button.press
        target:
          entity_id: button.ev_charger_start_charging
      - service: notify.notify
        data:
          title: "🌙 Off-Peak Charging Started"
          message: "EV charging started during off-peak hours"
```

---

## Advanced Notifications

### Rich Notification with All Details

```yaml
automation:
  - alias: "EV Complete Session Summary"
    description: "Comprehensive session summary with all new features"
    trigger:
      - platform: state
        entity_id: binary_sensor.ev_charger_connected
        to: 'off'
        for:
          seconds: 30
    variables:
      energy: "{{ states('sensor.ev_session_energy') }}"
      duration: "{{ states('sensor.ev_session_duration') }}"
      distance: "{{ states('sensor.ev_session_distance_mi') }}"
      vehicle: "{{ states('sensor.ev_connected_vehicle') }}"
      mode: "{{ states('sensor.ev_charger_mode') }}"
      solar: "{{ states('sensor.ev_session_solar_usage') }}"
    action:
      - service: notify.mobile_app_your_phone
        data:
          title: "🚗 {{ vehicle }} - Session Complete"
          message: >
            Energy: {{ energy }} kWh
            Duration: {{ duration }}
            Range Added: {{ distance }} mi
            Mode: {{ mode }}
            {% if solar != 'No Solar Usage' and solar != 'Excess Solar Disabled' %}
            Solar: {{ solar }}
            {% endif %}
          data:
            group: "ev-charging"
            tag: "ev-session-complete"
```

### Notify on High Power Charging

```yaml
automation:
  - alias: "EV High Power Alert"
    description: "Alert when charging at maximum power"
    trigger:
      - platform: numeric_state
        entity_id: sensor.ev_charger_power
        above: 9
        for:
          minutes: 1
    condition:
      - condition: state
        entity_id: binary_sensor.ev_charger_charging
        state: 'on'
    action:
      - service: notify.notify
        data:
          title: "⚡ High Power Charging"
          message: >
            EV is charging at {{ states('sensor.ev_charger_power') }} kW (near maximum)
```

---

## Time-Based Automations

### Evening Plug-In Reminder

```yaml
automation:
  - alias: "Remind to Plug In EV"
    description: "Evening reminder to connect vehicle"
    trigger:
      - platform: time
        at: "22:00:00"
    condition:
      - condition: state
        entity_id: binary_sensor.ev_charger_connected
        state: 'off'
    action:
      - service: notify.notify
        data:
          title: "🔌 Plug In Reminder"
          message: >
            Remember to plug in {{ states('sensor.ev_connected_vehicle') }} tonight.
            {% if is_state('binary_sensor.ev_charge_schedule_enabled', 'on') %}
            Scheduled to charge at {{ state_attr('sensor.ev_charging_schedules', 'schedules')[0] if state_attr('sensor.ev_charging_schedules', 'schedules') else 'scheduled time' }}
            {% endif %}
```

### Morning Status Report

```yaml
automation:
  - alias: "Morning EV Status Report"
    description: "Comprehensive morning status"
    trigger:
      - platform: time
        at: "07:00:00"
    action:
      - service: notify.notify
        data:
          title: "🌅 Morning EV Status"
          message: >
            {% if is_state('binary_sensor.ev_charger_connected', 'on') %}
              ✅ {{ states('sensor.ev_connected_vehicle') }} is connected
              Status: {{ states('sensor.ev_charger_status') }}
              {% if is_state('binary_sensor.ev_charger_charging', 'on') %}
                ⚡ Charging at {{ states('sensor.ev_charger_power') }} kW
              {% endif %}
              Solar: {{ states('sensor.ev_excess_solar_status') }}
              Schedules: {{ states('sensor.ev_charging_schedules') }}
            {% else %}
              ❌ {{ states('sensor.ev_connected_vehicle') }} not connected
            {% endif %}
```

---

## Energy Tracking

### Daily Charging Log

```yaml
automation:
  - alias: "Daily EV Energy Log"
    description: "Log daily statistics"
    trigger:
      - platform: time
        at: "23:59:00"
    action:
      - service: logbook.log
        data:
          name: "EV Daily Summary"
          message: >
            Energy: {{ states('sensor.ev_session_energy') }} kWh
            Solar Status: {{ states('sensor.ev_excess_solar_status') }}
            {% if is_state('binary_sensor.ev_charger_connected', 'on') %}
              Currently connected
            {% else %}
              Not connected
            {% endif %}
```

### Weekly Solar Usage Report

```yaml
automation:
  - alias: "Weekly Solar Charging Report"
    description: "Summary of solar charging usage"
    trigger:
      - platform: time
        at: "20:00:00"
    condition:
      - condition: template
        value_template: "{{ now().weekday() == 6 }}"  # Sunday
    action:
      - service: notify.notify
        data:
          title: "📊 Weekly Solar Report"
          message: >
            This week's EV charging summary available in Energy Dashboard.
            Excess Solar Status: {{ states('sensor.ev_excess_solar_status') }}
```

---

## Smart Charging

### Input Boolean Setup

First create in configuration.yaml:

```yaml
input_boolean:
  ev_smart_charging:
    name: EV Smart Charging
    icon: mdi:lightbulb-auto
```

### Smart Charging Control

```yaml
automation:
  - alias: "EV Smart Charging Manager"
    description: "Intelligent charging based on conditions"
    trigger:
      - platform: state
        entity_id: binary_sensor.ev_charger_connected
        to: 'on'
      - platform: time
        at:
          - "23:00:00"  # Off-peak
          - "07:00:00"  # Peak
    condition:
      - condition: state
        entity_id: input_boolean.ev_smart_charging
        state: 'on'
      - condition: state
        entity_id: binary_sensor.ev_charger_connected
        state: 'on'
    action:
      - choose:
          - conditions:
              - condition: time
                after: "23:00:00"
                before: "07:00:00"
            sequence:
              - service: notify.notify
                data:
                  title: "⚡ Smart Charging"
                  message: "Off-peak hours - optimal for charging"
        default:
          - service: notify.notify
            data:
              title: "⏸️ Peak Hours"
              message: "Consider waiting for off-peak (11pm-7am)"
```

---

## Integration with Solar

### Maximum Solar Utilization

```yaml
automation:
  - alias: "EV Maximize Solar Charging"
    description: "Start charging when solar production is optimal"
    trigger:
      - platform: numeric_state
        entity_id: sensor.solar_power
        above: 6000
        for:
          minutes: 10
    condition:
      - condition: state
        entity_id: binary_sensor.ev_charger_connected
        state: 'on'
      - condition: state
        entity_id: binary_sensor.ev_charger_charging
        state: 'off'
      - condition: state
        entity_id: sensor.ev_excess_solar_status
        state: 'Enabled'
      - condition: time
        after: "09:00:00"
        before: "16:00:00"
    action:
      - service: button.press
        target:
          entity_id: button.ev_charger_start_charging
      - service: notify.notify
        data:
          title: "☀️ Solar Charging Optimized"
          message: >
            Started EV charging with {{ states('sensor.solar_power') }}W solar production
```

---

## Cookie & Maintenance

### Cookie Expiration Alert

```yaml
automation:
  - alias: "SolarEdge Cookie Expired"
    description: "Alert when authentication needs refresh"
    trigger:
      - platform: state
        entity_id: sensor.solaredge_ev_charger_raw
        to: 'No Data'
        for:
          minutes: 10
    action:
      - service: persistent_notification.create
        data:
          title: "⚠️ SolarEdge Cookie Expired"
          message: >
            Authentication cookie has expired.
            
            To fix:
            1. Login to monitoring.solaredge.com
            2. Extract cookie
            3. Update /config/shell/solaredge_login.sh
            4. Restart Home Assistant
          notification_id: solaredge_cookie_expired
```

### Sensor Unavailable Alert

```yaml
automation:
  - alias: "EV Sensor Unavailable"
    description: "Alert when sensor goes offline"
    trigger:
      - platform: state
        entity_id: sensor.solaredge_ev_charger_raw
        to: 'unavailable'
        for:
          minutes: 15
    action:
      - service: notify.notify
        data:
          title: "⚠️ EV Sensor Offline"
          message: "SolarEdge EV Charger sensor unavailable. Check configuration."
```

---

## Voice Announcements

### Announce Charging Status

```yaml
automation:
  - alias: "Announce EV Charging Complete"
    description: "Voice announcement when done"
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
      - condition: time
        after: "07:00:00"
        before: "22:00:00"
    action:
      - service: tts.google_translate_say
        entity_id: media_player.living_room_speaker
        data:
          message: >
            {{ states('sensor.ev_connected_vehicle') }} finished charging. 
            {{ states('sensor.ev_session_energy') }} kilowatt hours added.
```

---

## Tips for Effective Automations

1. **Use the `for:` clause** to avoid rapid triggering
2. **Add meaningful conditions** to prevent unwanted notifications
3. **Use variables** for cleaner message templates
4. **Tag notifications** for better management
5. **Test automations** before permanent deployment
6. **Enable trace mode** for debugging
7. **Combine multiple triggers** for efficiency
8. **Use relative_time()** for human-readable schedules

## Testing Your Automations

Enable trace mode:

```yaml
automation:
  - alias: "Test EV Automation"
    trace:
      stored_traces: 10
    # ... rest of automation
```

View traces: **Settings** → **Automations** → Click automation → **Traces**

---

**Need More Examples?** Check out [Home Assistant's automation documentation](https://www.home-assistant.io/docs/automation/) or open an issue on GitHub!
