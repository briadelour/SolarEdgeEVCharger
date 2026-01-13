# Dashboard Examples

This file contains various dashboard card configurations for displaying your SolarEdge EV Charger data in Home Assistant, including the new Excess Solar, Schedule, and Manual Control features.

## Table of Contents

- [Basic Cards](#basic-cards)
- [Enhanced Cards with New Features](#enhanced-cards-with-new-features)
- [Manual Control Dashboards](#manual-control-dashboards)
- [Solar & Schedule Monitoring](#solar--schedule-monitoring)
- [Advanced Layouts](#advanced-layouts)

---

## Basic Cards

### Simple Entities Card

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
show_header_toggle: false
```

### Compact Glance Card

```yaml
type: glance
title: EV Charger Quick View
entities:
  - entity: sensor.ev_charger_status
    name: Status
  - entity: sensor.ev_charger_power
    name: Power
  - entity: sensor.ev_session_energy
    name: Energy
  - entity: binary_sensor.ev_charger_charging
    name: Charging
```

---

## Enhanced Cards with New Features

### Complete Status Card with Solar & Schedules ✨

```yaml
type: entities
title: EV Charger - Complete
entities:
  # Status
  - type: section
    label: Status
  - entity: sensor.ev_charger_status
    name: Charger Status
  - entity: sensor.ev_connected_vehicle
    name: Vehicle
  - entity: sensor.ev_charger_mode
    name: Mode
  
  # Current Session
  - type: section
    label: Current Session
  - entity: sensor.ev_charger_power
    name: Power
  - entity: sensor.ev_session_energy
    name: Energy Delivered
  - entity: sensor.ev_session_duration
    name: Duration
  - entity: sensor.ev_session_distance_mi
    name: Range Added
  
  # Solar Charging ✨ NEW
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
      name: Solar Usage
  
  # Scheduled Charging ✨ NEW
  - type: section
    label: Scheduled Charging
  - entity: sensor.ev_charging_schedules
    name: Schedules
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

### Solar & Schedule Focused Card ✨

```yaml
type: entities
title: EV Charging Settings
entities:
  - entity: sensor.ev_charger_mode
    name: Charging Mode
  
  - type: section
    label: ☀️ Solar Charging
  
  - entity: binary_sensor.ev_excess_solar_enabled
    name: Excess Solar Active
  - entity: sensor.ev_excess_solar_status
    name: Status
  - entity: sensor.ev_session_solar_usage
    name: Current Solar Usage
  
  - type: section
    label: 📅 Charging Schedules
  
  - entity: binary_sensor.ev_charge_schedule_enabled
    name: Schedules Active
  - entity: sensor.ev_charging_schedules
    name: Schedule Status
  - entity: sensor.ev_next_scheduled_charge
    name: Next Scheduled Charge
    format: relative

show_header_toggle: false
```

---

## Manual Control Dashboards

### Control Panel with Start/Stop Buttons ✨

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
      - entity: binary_sensor.ev_charger_connected
        name: Connected
  
  # Manual Control
  - type: entities
    title: Manual Control
    entities:
      # Message when not plugged in
      - type: conditional
        conditions:
          - entity: binary_sensor.ev_charger_connected
            state: "off"
        row:
          type: section
          label: "⚠️ No vehicle connected"
      
      # Start button (plugged in, not charging)
      - type: conditional
        conditions:
          - entity: binary_sensor.ev_charger_connected
            state: "on"
          - entity: binary_sensor.ev_charger_charging
            state: "off"
        row:
          type: button
          name: "⚡ Start Charging Now"
          action_name: START
          tap_action:
            action: call-service
            service: button.press
            service_data:
              entity_id: button.ev_charger_start_charging
            confirmation:
              text: Start charging now?
          icon: mdi:play-circle
      
      # Stop button (currently charging)
      - type: conditional
        conditions:
          - entity: binary_sensor.ev_charger_charging
            state: "on"
        row:
          type: button
          name: "⏹️ Stop Charging"
          action_name: STOP
          tap_action:
            action: call-service
            service: button.press
            service_data:
              entity_id: button.ev_charger_stop_charging
            confirmation:
              text: Stop charging now?
          icon: mdi:stop-circle
    show_header_toggle: false
  
  # Current Session
  - type: conditional
    conditions:
      - entity: binary_sensor.ev_charger_connected
        state: "on"
    card:
      type: entities
      title: Current Session
      entities:
        - entity: sensor.ev_session_energy
        - entity: sensor.ev_session_duration
        - entity: sensor.ev_session_distance_mi
      show_header_toggle: false
```

### Simple Control Card ✨

```yaml
type: entities
title: EV Charger Control
entities:
  - entity: sensor.ev_charger_status
    name: Status
  - entity: sensor.ev_connected_vehicle
    name: Vehicle
  
  - type: section
    label: Manual Control
  
  # Start button
  - type: conditional
    conditions:
      - entity: binary_sensor.ev_charger_connected
        state: "on"
      - entity: binary_sensor.ev_charger_charging
        state: "off"
    row:
      type: button
      name: Start Charging
      action_name: START
      tap_action:
        action: call-service
        service: button.press
        service_data:
          entity_id: button.ev_charger_start_charging
      icon: mdi:play-circle
  
  # Stop button
  - type: conditional
    conditions:
      - entity: binary_sensor.ev_charger_charging
        state: "on"
    row:
      type: button
      name: Stop Charging
      action_name: STOP
      tap_action:
        action: call-service
        service: button.press
        service_data:
          entity_id: button.ev_charger_stop_charging
      icon: mdi:stop-circle

show_header_toggle: false
```

---

## Solar & Schedule Monitoring

### Solar Charging Dashboard ✨

```yaml
type: vertical-stack
cards:
  - type: entities
    title: ☀️ Solar Charging
    entities:
      - entity: sensor.ev_excess_solar_status
        name: Excess Solar Status
      - entity: binary_sensor.ev_excess_solar_enabled
        name: Feature Enabled
      - type: conditional
        conditions:
          - entity: sensor.ev_excess_solar_status
            state: "Enabled"
        row:
          entity: sensor.ev_session_solar_usage
          name: Current Solar Usage
    show_header_toggle: false
  
  - type: conditional
    conditions:
      - entity: binary_sensor.ev_charger_charging
        state: "on"
      - entity: sensor.ev_excess_solar_status
        state: "Enabled"
    card:
      type: markdown
      content: >
        **☀️ Charging with Solar Power**
        
        Solar Usage: {{ states('sensor.ev_session_solar_usage') }}
        
        Session Energy: {{ states('sensor.ev_session_energy') }} kWh
```

### Schedule Monitoring Dashboard ✨

```yaml
type: entities
title: 📅 Charging Schedules
entities:
  - entity: binary_sensor.ev_charge_schedule_enabled
    name: Schedules Active
  - entity: sensor.ev_charging_schedules
    name: Status
  
  - type: conditional
    conditions:
      - entity: binary_sensor.ev_charge_schedule_enabled
        state: "on"
    row:
      type: attribute
      entity: sensor.ev_charging_schedules
      attribute: schedules
      name: Active Schedules
  
  - type: section
    label: Next Charge
  
  - type: conditional
    conditions:
      - entity: binary_sensor.ev_charge_schedule_enabled
        state: "on"
      - entity: binary_sensor.ev_charger_charging
        state: "off"
    row:
      entity: sensor.ev_next_scheduled_charge
      name: Scheduled For
      format: relative
  
  - type: conditional
    conditions:
      - entity: binary_sensor.ev_charger_charging
        state: "on"
    row:
      type: section
      label: "⚡ Currently Charging"

show_header_toggle: false
```

---

## Advanced Layouts

### Complete Control Panel ✨

```yaml
type: vertical-stack
cards:
  # Header Status
  - type: glance
    title: EV Charger
    entities:
      - entity: sensor.ev_charger_status
        name: Status
      - entity: sensor.ev_charger_power
        name: Power
      - entity: binary_sensor.ev_charger_connected
        name: Connected
      - entity: binary_sensor.ev_charger_charging
        name: Charging
  
  # Manual Control
  - type: horizontal-stack
    cards:
      - type: conditional
        conditions:
          - entity: binary_sensor.ev_charger_connected
            state: "on"
          - entity: binary_sensor.ev_charger_charging
            state: "off"
        card:
          type: button
          name: Start Charging
          icon: mdi:play-circle
          tap_action:
            action: call-service
            service: button.press
            service_data:
              entity_id: button.ev_charger_start_charging
      
      - type: conditional
        conditions:
          - entity: binary_sensor.ev_charger_charging
            state: "on"
        card:
          type: button
          name: Stop Charging
          icon: mdi:stop-circle
          tap_action:
            action: call-service
            service: button.press
            service_data:
              entity_id: button.ev_charger_stop_charging
  
  # Session Info
  - type: conditional
    conditions:
      - entity: binary_sensor.ev_charger_connected
        state: "on"
    card:
      type: entities
      title: Current Session
      entities:
        - entity: sensor.ev_connected_vehicle
          name: Vehicle
        - entity: sensor.ev_session_energy
          name: Energy
        - entity: sensor.ev_session_duration
          name: Duration
        - entity: sensor.ev_session_distance_mi
          name: Range Added
      show_header_toggle: false
  
  # Solar & Schedule Status
  - type: horizontal-stack
    cards:
      - type: button
        entity: sensor.ev_excess_solar_status
        name: Solar
        show_state: true
        tap_action:
          action: more-info
      
      - type: button
        entity: sensor.ev_charging_schedules
        name: Schedules
        show_state: true
        tap_action:
          action: more-info
```

### Multi-Column Layout

```yaml
type: horizontal-stack
cards:
  # Left: Status & Control
  - type: vertical-stack
    cards:
      - type: entities
        title: Status & Control
        entities:
          - sensor.ev_charger_status
          - sensor.ev_connected_vehicle
          - sensor.ev_charger_mode
          - type: conditional
            conditions:
              - entity: binary_sensor.ev_charger_connected
                state: "on"
              - entity: binary_sensor.ev_charger_charging
                state: "off"
            row:
              type: button
              name: Start
              action_name: START
              tap_action:
                action: call-service
                service: button.press
                service_data:
                  entity_id: button.ev_charger_start_charging
          - type: conditional
            conditions:
              - entity: binary_sensor.ev_charger_charging
                state: "on"
            row:
              type: button
              name: Stop
              action_name: STOP
              tap_action:
                action: call-service
                service: button.press
                service_data:
                  entity_id: button.ev_charger_stop_charging
        show_header_toggle: false
  
  # Right: Solar & Schedules
  - type: vertical-stack
    cards:
      - type: entities
        title: Solar & Schedules
        entities:
          - sensor.ev_excess_solar_status
          - sensor.ev_session_solar_usage
          - sensor.ev_charging_schedules
          - sensor.ev_next_scheduled_charge
        show_header_toggle: false
```

---

## Conditional Cards

### Simple Status Banner (When Charging)

```yaml
type: conditional
conditions:
  - condition: state
    entity: binary_sensor.ev_charger_charging
    state: "on"
card:
  type: markdown
  content: |
    ## ⚡ EV is **{{ states('sensor.ev_charger_status') }}**
    Est. Charging Power: **{{ states('sensor.ev_charger_power') }}** kW
```

### Show Only When Charging

```yaml
type: conditional
conditions:
  - entity: binary_sensor.ev_charger_charging
    state: 'on'
card:
  type: entities
  title: 🔋 Currently Charging
  entities:
    - entity: sensor.ev_charger_power
      name: Current Power
    - entity: sensor.ev_session_energy
      name: Energy This Session
    - entity: sensor.ev_session_duration
      name: Charging Duration
    - entity: sensor.ev_session_distance_mi
      name: Range Added
    - entity: sensor.ev_session_solar_usage
      name: Solar Usage
```

### Show Only When Plugged In But Not Charging

```yaml
type: conditional
conditions:
  - entity: binary_sensor.ev_charger_connected
    state: 'on'
  - entity: binary_sensor.ev_charger_charging
    state: 'off'
card:
  type: entities
  title: 🔌 Ready to Charge
  entities:
    - entity: sensor.ev_charger_status
    - entity: sensor.ev_charger_mode
    - entity: sensor.ev_excess_solar_status
    - type: button
      name: Start Charging Now
      action_name: START
      tap_action:
        action: call-service
        service: button.press
        service_data:
          entity_id: button.ev_charger_start_charging
      icon: mdi:play-circle
```

---

## Gauge & Graph Cards

### Power Gauge

```yaml
type: gauge
entity: sensor.ev_charger_power
name: Charging Power
unit: kW
min: 0
max: 10
severity:
  green: 0
  yellow: 5
  red: 8
```

### History Graph with Solar Indicator

```yaml
type: history-graph
title: EV Charging History
entities:
  - entity: sensor.ev_charger_power
    name: Power (kW)
  - entity: sensor.ev_session_energy
    name: Energy (kWh)
  - entity: binary_sensor.ev_charger_charging
    name: Charging Active
  - entity: binary_sensor.ev_excess_solar_enabled
    name: Solar Mode
hours_to_show: 24
refresh_interval: 0
```

---

## Markdown Cards

### Dynamic Status Summary

```yaml
type: markdown
title: EV Charger Summary
content: >
  **Status:** {{ states('sensor.ev_charger_status') }}
  
  **Vehicle:** {{ states('sensor.ev_connected_vehicle') }}
  
  {% if is_state('binary_sensor.ev_charger_charging', 'on') %}
  **⚡ Charging at:** {{ states('sensor.ev_charger_power') }} kW
  
  **Energy Delivered:** {{ states('sensor.ev_session_energy') }} kWh
  
  **Duration:** {{ states('sensor.ev_session_duration') }}
  {% endif %}
  
  **Solar Status:** {{ states('sensor.ev_excess_solar_status') }}
  {% if is_state('sensor.ev_excess_solar_status', 'Enabled') %}
  - Usage: {{ states('sensor.ev_session_solar_usage') }}
  {% endif %}
  
  **Schedules:** {{ states('sensor.ev_charging_schedules') }}
  {% if is_state('binary_sensor.ev_charge_schedule_enabled', 'on') and is_state('binary_sensor.ev_charger_charging', 'off') %}
  - Next: {{ relative_time(states('sensor.ev_next_scheduled_charge')) }}
  {% endif %}
```

---

## Mobile-Optimized Cards

### Compact Mobile View

```yaml
type: glance
title: 🚗 EV
entities:
  - entity: sensor.ev_charger_status
    name: ''
  - entity: sensor.ev_charger_power
    name: ''
  - entity: sensor.ev_session_energy
    name: ''
  - entity: sensor.ev_excess_solar_status
    name: ''
show_name: false
show_state: true
columns: 4
```

### Mobile Control Card

```yaml
type: entities
title: EV
entities:
  - sensor.ev_charger_status
  - sensor.ev_charger_power
  - type: conditional
    conditions:
      - entity: binary_sensor.ev_charger_connected
        state: "on"
      - entity: binary_sensor.ev_charger_charging
        state: "off"
    row:
      type: button
      name: ▶️ Start
      tap_action:
        action: call-service
        service: button.press
        service_data:
          entity_id: button.ev_charger_start_charging
  - type: conditional
    conditions:
      - entity: binary_sensor.ev_charger_charging
        state: "on"
    row:
      type: button
      name: ⏹️ Stop
      tap_action:
        action: call-service
        service: button.press
        service_data:
          entity_id: button.ev_charger_stop_charging
show_header_toggle: false
```

---

## Tips for Dashboard Organization

1. **Use conditional cards** to show/hide based on state
2. **Group related sensors** in sections
3. **Add confirmation dialogs** for control buttons
4. **Use glance cards** for quick status views
5. **Create separate tabs** for detailed vs mobile views
6. **Leverage markdown cards** for dynamic summaries
7. **Use relative time format** for next scheduled charge
8. **Show solar usage** only when excess solar is enabled

## Integration with Energy Dashboard

To add EV charging to your Energy Dashboard:

1. Go to **Settings** → **Dashboards** → **Energy**
2. Under **Individual Devices**, click **Add Consumption**
3. Select `sensor.ev_session_energy`
4. Configure the entity

This will track your EV charging alongside solar production and home consumption!

---

**Need More Help?** Check out the [main README](README.md) or open an issue on GitHub!
