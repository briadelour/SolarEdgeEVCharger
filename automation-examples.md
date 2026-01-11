# Automation Examples

This file contains various automation examples for your SolarEdge EV Charger integration.

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

### Notify When Vehicle is Plugged In

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

### Notify When Vehicle is Unplugged

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
```

## Advanced Notifications

### Rich Notification with Session Stats

```yaml
automation:
  - alias: "EV Charging Summary"
    description: "Detailed charging summary when unplugged"
    trigger:
      - platform: state
        entity_id: binary_sensor.ev_charger_connected
        to: 'off'
        for:
          seconds: 30
    variables:
      energy: "{{ states('sensor.ev_session_energy') }}"
      duration: "{{ states('sensor.ev_session_duration') }}"
      distance: "{{ states('sensor.ev_session_distance') }}"
      vehicle: "{{ states('sensor.ev_connected_vehicle') }}"
    action:
      - service: notify.mobile_app_your_phone
        data:
          title: "🚗 {{ vehicle }} - Charging Summary"
          message: >
            Energy: {{ energy }} kWh
            Duration: {{ duration }}
            Range Added: {{ distance }} km
          data:
            group: "ev-charging"
            tag: "ev-session-complete"
```

### Notify on High Power Charging

```yaml
automation:
  - alias: "EV High Power Charging Alert"
    description: "Alert when charging at high power (useful for monitoring)"
    trigger:
      - platform: numeric_state
        entity_id: sensor.ev_charger_power
        above: 7
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
            EV is charging at {{ states('sensor.ev_charger_power') }} kW
```

## Cookie Expiration Monitoring

### Alert When Cookie Expires

```yaml
automation:
  - alias: "SolarEdge Cookie Expired"
    description: "Alert when authentication cookie needs to be refreshed"
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
          message: >
            The SolarEdge authentication cookie has expired. 
            Please refresh it in the configuration.
          data:
            tag: "solaredge-cookie-expired"
            group: "system-alerts"
```

### Alert When Sensor is Unavailable

```yaml
automation:
  - alias: "EV Charger Sensor Unavailable"
    description: "Alert when the EV charger sensor goes unavailable"
    trigger:
      - platform: state
        entity_id: sensor.solaredge_ev_charger_raw
        to: 'unavailable'
        for:
          minutes: 15
    action:
      - service: notify.notify
        data:
          title: "⚠️ EV Charger Sensor Offline"
          message: "The SolarEdge EV Charger sensor is unavailable. Check your configuration."
```

## Time-Based Automations

### Remind to Plug In at Night

```yaml
automation:
  - alias: "Remind to Plug In EV"
    description: "Evening reminder to plug in vehicle"
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
          title: "🔌 Don't Forget!"
          message: "Remember to plug in the {{ states('sensor.ev_connected_vehicle') }} tonight"
```

### Morning Charging Status Report

```yaml
automation:
  - alias: "Morning EV Status Report"
    description: "Daily morning report on EV charging status"
    trigger:
      - platform: time
        at: "07:00:00"
    action:
      - service: notify.notify
        data:
          title: "🌅 Good Morning - EV Status"
          message: >
            {% if is_state('binary_sensor.ev_charger_connected', 'on') %}
              {{ states('sensor.ev_connected_vehicle') }} is plugged in.
              Status: {{ states('sensor.ev_charger_status') }}
              {% if is_state('binary_sensor.ev_charger_charging', 'on') %}
                Currently charging at {{ states('sensor.ev_charger_power') }} kW
              {% endif %}
            {% else %}
              {{ states('sensor.ev_connected_vehicle') }} is not connected.
            {% endif %}
```

## Energy Tracking

### Log Daily Charging Summary

```yaml
automation:
  - alias: "Daily EV Charging Log"
    description: "Log daily charging statistics"
    trigger:
      - platform: time
        at: "23:59:00"
    action:
      - service: logbook.log
        data:
          name: "EV Daily Charging Summary"
          message: >
            Total energy: {{ states('sensor.ev_session_energy') }} kWh
            {% if is_state('binary_sensor.ev_charger_connected', 'on') %}
              Vehicle is currently connected
            {% else %}
              Vehicle not connected
            {% endif %}
```

### Track Monthly Charging Energy

```yaml
automation:
  - alias: "Monthly EV Energy Report"
    description: "Calculate and log monthly charging energy"
    trigger:
      - platform: time
        at: "00:01:00"
    condition:
      - condition: template
        value_template: "{{ now().day == 1 }}"
    action:
      - service: notify.notify
        data:
          title: "📊 Monthly EV Report"
          message: >
            Last month's charging summary will be in your Energy Dashboard.
            Check Settings → Dashboards → Energy for details.
```

## Smart Charging Helpers

### Create Input Boolean for Smart Charging

First create an input_boolean in configuration.yaml:

```yaml
input_boolean:
  ev_smart_charging:
    name: EV Smart Charging Enabled
    icon: mdi:lightbulb-auto
```

### Enable Charging Only During Off-Peak Hours

```yaml
automation:
  - alias: "EV Smart Charging Control"
    description: "Only allow charging during off-peak hours if smart charging is enabled"
    trigger:
      - platform: state
        entity_id: binary_sensor.ev_charger_connected
        to: 'on'
      - platform: time
        at:
          - "23:00:00"  # Off-peak start
          - "07:00:00"  # Off-peak end
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
                  title: "⚡ Smart Charging Active"
                  message: "Off-peak hours - EV charging is optimal now"
        default:
          - service: notify.notify
            data:
              title: "⏸️ Peak Hours"
              message: "Consider waiting for off-peak hours (11pm-7am)"
```

## Integration with Solar Production

### Notify When Charging from Solar (if you have solar sensors)

```yaml
automation:
  - alias: "EV Charging from Solar"
    description: "Notify when EV is charging primarily from solar"
    trigger:
      - platform: state
        entity_id: binary_sensor.ev_charger_charging
        to: 'on'
    condition:
      - condition: numeric_state
        entity_id: sensor.solar_power  # Your solar power sensor
        above: 3000  # Adjust based on your system
    action:
      - service: notify.notify
        data:
          title: "☀️ Solar Charging Active"
          message: >
            {{ states('sensor.ev_connected_vehicle') }} is charging from solar power!
            Solar: {{ states('sensor.solar_power') }} W
            Charger: {{ states('sensor.ev_charger_power') }} kW
```

## Voice Announcements

### Announce Charging Status on Smart Speaker

```yaml
automation:
  - alias: "Announce EV Charging Complete"
    description: "Announce on smart speaker when charging is done"
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
            {{ states('sensor.ev_connected_vehicle') }} has finished charging. 
            {{ states('sensor.ev_session_energy') }} kilowatt hours were added.
```

## Persistent Notifications

### Create Persistent Notification When Cookie Needs Refresh

```yaml
automation:
  - alias: "Persistent Alert - Cookie Expired"
    description: "Create persistent notification in HA UI"
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
          message: >
            The SolarEdge authentication cookie has expired.
            
            To fix:
            1. Login to monitoring.solaredge.com
            2. Extract SPRING_SECURITY_REMEMBER_ME_COOKIE
            3. Update /config/shell/solaredge_login.sh
            4. Restart Home Assistant
          notification_id: solaredge_cookie_expired
```

## Script Examples

### Script to Log Charging Session Details

```yaml
script:
  log_ev_charging_session:
    alias: "Log EV Charging Session"
    sequence:
      - service: logbook.log
        data:
          name: "EV Charging Session"
          message: >
            Vehicle: {{ states('sensor.ev_connected_vehicle') }}
            Energy: {{ states('sensor.ev_session_energy') }} kWh
            Duration: {{ states('sensor.ev_session_duration') }}
            Distance: {{ states('sensor.ev_session_distance') }} km
            Mode: {{ states('sensor.ev_charger_mode') }}
          entity_id: sensor.ev_charger_status
```

Call this script from automations when needed.

---

## Tips for Effective Automations

1. **Use the `for:` clause** to avoid rapid triggering
2. **Add conditions** to prevent unwanted notifications
3. **Use variables** to make messages clearer
4. **Tag notifications** so they can be dismissed together
5. **Test automations** before enabling them permanently
6. **Use `trace` mode** to debug automation issues

## Testing Your Automations

Enable trace mode to see execution history:

```yaml
automation:
  - alias: "Test EV Automation"
    trace:
      stored_traces: 5
    # ... rest of automation
```

Then check: **Settings** → **Automations** → Click automation → **Traces**
