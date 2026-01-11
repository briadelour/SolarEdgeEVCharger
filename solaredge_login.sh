#!/bin/bash

# ============================================
# SolarEdge EV Charger Data Fetcher
# ============================================
# This script fetches EV Charger data from the SolarEdge monitoring API
# using browser-based cookie authentication.
#
# CONFIGURATION REQUIRED:
# 1. Get your SITE_ID from the SolarEdge monitoring URL
# 2. Extract SPRING_SECURITY_REMEMBER_ME_COOKIE from your browser
#
# See README.md for detailed instructions
# ============================================

# CONFIGURATION - Update these values
SITE_ID="YOUR_SITE_ID"
COOKIE_VALUE="YOUR_COOKIE_VALUE"

# ============================================
# Do not modify below this line
# ============================================

curl -s -L \
    -H "Cookie: SPRING_SECURITY_REMEMBER_ME_COOKIE=${COOKIE_VALUE}" \
    "https://monitoring.solaredge.com/services/api/homeautomation/v1.0/sites/${SITE_ID}/devices" \
    -H "Accept: application/json" \
    -H "User-Agent: Mozilla/5.0"
