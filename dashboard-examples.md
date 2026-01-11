# Dashboard Examples

This file contains various dashboard card configurations for displaying your SolarEdge EV Charger data in Home Assistant.

## Basic Entities Card

Simple list of all sensors:

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

## Enhanced Entities Card with Sections

Organized by category:

```yaml
type: entities
title: EV Charger - Ioniq
entities:
  - type: section
    label: Status
  - entity: sensor.ev_charger_status
    name: Charger Status
  - entity: sensor.ev_connection_status
    name: Connection
  - entity: sensor.ev_charger_mode
    name: Mode
  - entity: sensor.ev_connected_vehicle
    name: Vehicle
  
  - type: section
    label: Current Session
  - entity: sensor.ev_charger_power
    name: Power
  - entity: sensor.ev_session_energy
    name: Energy Delivered
  - entity: sensor.ev_session_duration
    name: Duration
  - entity: sensor.ev_session_distance
    name: Estimated Range
  
  - type: section
    label: Indicators
  - entity: binary_sensor.ev_charger_connected
    name: Vehicle Connected
  - entity: binary_sensor.ev_charger_charging
    name: Currently Charging
  - entity: binary_sensor.ev_charge_schedule_enabled
    name: Schedule Enabled
show_header_toggle: false
```

## Compact Glance Card

Quick overview with icons:

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
show_name: true
show_state: true
```

## Multi-Card Vertical Stack

Most detailed view:

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
      - entity: sensor.ev_session_distance
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

## Gauge Card for Power

Visual power meter:

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

## History Graph Card

Track energy over time:

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
hours_to_show: 24
refresh_interval: 0
```

## Conditional Card (Only Show When Charging)

Show detailed stats only when actively charging:

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
    - entity: sensor.ev_session_distance
      name: Range Added
```

## Markdown Card for Summary

Custom formatted summary:

```yaml
type: markdown
title: EV Charger Summary
content: >
  **Status:** {{ states('sensor.ev_charger_status') }}
  
  **Vehicle:** {{ states('sensor.ev_connected_vehicle') }}
  
  **Current Power:** {{ states('sensor.ev_charger_power') }} kW
  
  **Session Energy:** {{ states('sensor.ev_session_energy') }} kWh
  
  **Duration:** {{ states('sensor.ev_session_duration') }}
  
  **Range Added:** {{ states('sensor.ev_session_distance') }} km
```

## Energy Distribution Card

For Energy Dashboard:

```yaml
type: energy-distribution
title: EV Charging Energy
```

## Statistics Graph Card

Long-term trends:

```yaml
type: statistics-graph
title: EV Charging Statistics
entities:
  - sensor.ev_session_energy
days_to_show: 30
stat_types:
  - mean
  - min
  - max
```

## Custom Button Card (using custom:button-card)

If you have button-card installed:

```yaml
type: custom:button-card
entity: binary_sensor.ev_charger_charging
name: EV Charger
show_state: true
show_icon: true
tap_action:
  action: more-info
styles:
  card:
    - height: 100px
  icon:
    - color: |
        [[[
          if (entity.state === 'on') return 'lime';
          return 'grey';
        ]]]
state:
  - value: 'on'
    icon: mdi:ev-station
  - value: 'off'
    icon: mdi:power-plug-off
```

## Mini Graph Card (using mini-graph-card)

If you have mini-graph-card installed:

```yaml
type: custom:mini-graph-card
entities:
  - entity: sensor.ev_charger_power
    name: Power
  - entity: sensor.ev_session_energy
    name: Energy
    y_axis: secondary
hours_to_show: 12
points_per_hour: 4
line_width: 2
animate: true
```

## Mobile-Optimized Card

Compact view for mobile devices:

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
  - entity: sensor.ev_session_duration
    name: ''
show_name: false
show_state: true
columns: 4
```

## Picture Elements Card

Custom visual layout (requires background image):

```yaml
type: picture-elements
image: /local/ev_charger_background.png
elements:
  - type: state-label
    entity: sensor.ev_charger_status
    style:
      top: 20%
      left: 50%
      font-size: 24px
      color: white
  - type: state-label
    entity: sensor.ev_charger_power
    suffix: ' kW'
    style:
      top: 50%
      left: 50%
      font-size: 32px
      color: lime
```

---

## Tips for Dashboard Organization

1. **Use sections** to group related sensors
2. **Hide unnecessary sensors** from the default entities card
3. **Create different views** for mobile vs desktop
4. **Use conditional cards** to show/hide based on state
5. **Combine with other energy sensors** for a complete energy dashboard

## Integration with Energy Dashboard

To add EV charging to your Energy Dashboard:

1. Go to **Settings** → **Dashboards** → **Energy**
2. Under **Individual Devices**, click **Add Consumption**
3. Select `sensor.ev_session_energy`
4. Configure the entity

This will track your EV charging alongside solar production and home consumption!
