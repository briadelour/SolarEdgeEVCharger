#!/bin/bash

# ============================================
# CONFIGURATION
# ============================================
SITE_ID="YOUR_SITE_ID"
COOKIE_VALUE="YOUR_COOKIE_VALUE"
EV_CHARGER_DEVICE_ID="YOUR_REPORTER_ID"
# ============================================

curl -s -L -X PUT \
    -H "Cookie: SPRING_SECURITY_REMEMBER_ME_COOKIE=${COOKIE_VALUE}" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -H "User-Agent: Mozilla/5.0" \
    -d '{"mode":"MANUAL","level":0,"duration":null}' \
    "https://monitoring.solaredge.com/services/m/api/homeautomation/v1.0/${SITE_ID}/devices/${EV_CHARGER_DEVICE_ID}/activationState"
