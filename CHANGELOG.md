# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-01-13

### Added
- **Excess Solar Monitoring**
  - `sensor.ev_excess_solar_status` - Shows if Excess PV charging is enabled/disabled (excessPV -1 or -2)
  - `sensor.ev_session_solar_usage` - Displays solar energy usage during session when Excess PV enabled
  - `binary_sensor.ev_excess_solar_enabled` - Boolean sensor for excess solar status
  
- **Schedule Management**
  - `sensor.ev_charging_schedules` - Shows count and list of active charging schedules
  - Schedule details in attributes showing times and days (e.g., "10:00 - 12:00 (Mon, Tue, Wed)")
  - `sensor.ev_next_scheduled_charge` - Timestamp of next scheduled charge (with device_class: timestamp)
  - Calculates next charge time based on current day and time when scheduleInfo not available
  
- **Manual Charging Control** (Optional Feature)
  - Start charging command via shell script
  - Stop charging command via shell script
  - Button entities for Home Assistant dashboard
  - `button.ev_charger_start_charging` - Start charging manually
  - `button.ev_charger_stop_charging` - Stop charging manually
  - Comprehensive guide: CHARGING_CONTROL.md
  - Example dashboard cards with conditional start/stop buttons
  
- **Documentation**
  - New CHARGING_CONTROL.md guide for manual control setup
  - shell_command.yaml for start/stop commands
  - Updated dashboard examples with new sensors and control buttons
  - Updated automation examples for solar monitoring, schedules, and manual control
  - QUICKSTART.md improvements
  - Comprehensive TROUBLESHOOTING.md

### Changed
- **templates.yaml**
  - Removed `device_class: power` from EV Charger Power sensor to display kW instead of W
  - Added new template sensors for solar and schedule monitoring
  - Added button entities for manual control (optional)
  
- **README.md**
  - Updated features list with 4 new sensors
  - Added manual control section
  - Updated sensor count from 12 to 16
  - Added link to CHARGING_CONTROL.md guide
  - Reorganized documentation with clear index
  
- **dashboard-examples.md**
  - Added examples with new solar and schedule sensors
  - Added conditional button examples for start/stop control
  - Added solar-focused dashboard layouts
  - Added schedule monitoring examples
  
- **automation-examples.md**
  - Added solar charging automation examples
  - Added schedule monitoring automations
  - Added manual control automations (auto-start/stop)
  - Added comprehensive session summaries with solar usage

### Fixed
- **Power Display Issue**: Removed `device_class: power` from power sensor template to properly display kW instead of forcing W
- Improved template sensor reliability with better null checks
- Better handling of missing scheduleInfo in next charge calculation

### Technical Details

#### New API Fields Used
- `excessPV`: -1 (enabled) or -2 (disabled)
- `sessionSolarUsage`: Values like "NONE", "LOW", "MEDIUM", "HIGH", "FULL"
- `deviceTriggers`: Array of schedule objects with enable, scheduledDays, startTime, endTime
- `scheduleInfo.startDate`: Timestamp of next scheduled charge (when available)
- `reporterId`: Device ID used for start/stop commands

#### New API Endpoints
- `PUT /services/m/api/homeautomation/v1.0/{site_id}/devices/{device_id}/activationState`
  - Start charging: `{"mode":"MANUAL","level":100,"duration":null}`
  - Stop charging: `{"mode":"MANUAL","level":0,"duration":null}`

## [1.0.0] - 2026-01-10

### Added
- Initial release
- Basic sensor monitoring via SolarEdge private API
- Template sensors for all charger states
- Binary sensors for vehicle connection, charging status, schedule status
- Command line sensor for raw data retrieval
- Shell script for API authentication
- Basic dashboard examples
- Basic automation examples
- Installation guide and documentation

### Sensors Included
- Charger Status
- Charging Power (kW)
- Session Energy (kWh)
- Session Duration
- Connected Vehicle
- Charger Mode
- Connection Status
- Session Distance (km and miles)
- Vehicle Connected (binary)
- Currently Charging (binary)
- Schedule Enabled (binary)
- Raw sensor with full API response

## [Unreleased]

### Planned
- Automated cookie refresh mechanism
- Multi-charger support
- HACS integration
- Custom Lovelace card
- Energy cost tracking
- Charge session history tracking
- Integration with vehicle battery level (if available)
- Smart charging based on electricity prices
- Charge curve analysis

---

## Migration Guide

### Upgrading from 1.0.0 to 1.1.0

1. **Backup your existing configuration**
   ```bash
   tar -czf solaredge_backup_v1.0.0.tar.gz \
     /config/shell/solaredge_login.sh \
     /config/command_line.yaml \
     /config/templates.yaml
   ```

2. **Update templates.yaml**
   - Replace your existing templates.yaml with the new version
   - The kW display fix is already included
   - New sensors will be automatically added

3. **Update dashboard** (optional)
   - Review new dashboard examples
   - Add new solar and schedule sensors to your cards
   - Add conditional control buttons if desired

4. **Add manual control** (optional)
   - Follow CHARGING_CONTROL.md guide
   - Create start/stop scripts
   - Add shell_command.yaml
   - Add button entities to templates.yaml

5. **Restart Home Assistant**
   ```bash
   ha core restart
   ```

6. **Verify new sensors**
   - Developer Tools → States
   - Search for `ev_excess`, `ev_charging_schedules`, `ev_next`
   - Should see 4 new sensors

## Breaking Changes

### None in 1.1.0
All changes are backward compatible. Existing sensors continue to work unchanged.

---

## Contributors

Thank you to everyone who contributed to this release!

- Feature requests and testing from the Home Assistant community
- Bug reports and fixes

---

## Support

- **Issues**: https://github.com/YOURUSERNAME/solaredge-evcharger-ha/issues
- **Discussions**: https://github.com/YOURUSERNAME/solaredge-evcharger-ha/discussions
- **Home Assistant Community**: https://community.home-assistant.io/
