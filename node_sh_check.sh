#!/bin/bash

# Node/React project scanner for known compromised packages
# Dependency-free, works on Linux/macOS

# CONFIG 
PROJECT_DIR="$1"
COMPROMISED_LIST="compromised.txt"
REPORT_FILE="compromised_report.csv"

if [[ -z "$PROJECT_DIR" ]]; then
  echo "Usage: $0 /path/to/project"
  exit 1
fi

if [[ ! -f "$COMPROMISED_LIST" ]]; then
  echo "Error: $COMPROMISED_LIST not found!"
  exit 1
fi

TOTAL_KNOWN=$(wc -l < "$COMPROMISED_LIST" | tr -d ' ')
echo "⚠️  Total known compromised packages in list: $TOTAL_KNOWN"


# INIT
echo "📦 Scanning project at: $PROJECT_DIR"
echo "------------------------------------------------------------"

> "$REPORT_FILE"
echo "Package,Version,Status" >> "$REPORT_FILE"

TOTAL_PACKAGES=0
FOUND_COUNT=0

# SCAN node_modules
while IFS= read -r package_json; do
  # Extract name and version using grep/cut (dependency-free)
  # PACKAGE_NAME=$(grep '"name"' "$package_json" | head -1 | cut -d'"' -f4)
  # PACKAGE_VERSION=$(grep '"version"' "$package_json" | head -1 | cut -d'"' -f4)

  PACKAGE_NAME=$(grep -m1 '"name"' "$package_json" | sed -E 's/.*"name": *"([^"]+)".*/\1/')
  PACKAGE_VERSION=$(grep -m1 '"version"' "$package_json" | sed -E 's/.*"version": *"([^"]+)".*/\1/')

  if [[ -z "$PACKAGE_NAME" || -z "$PACKAGE_VERSION" ]]; then
    continue
  fi

  TOTAL_PACKAGES=$((TOTAL_PACKAGES+1))
  FULL="$PACKAGE_NAME@$PACKAGE_VERSION"

  # Checking against the compromised list
  if grep -Fxq "$FULL" "$COMPROMISED_LIST"; then
    echo "Working on $FULL... ⚠️ WARNING"
    echo "$PACKAGE_NAME,$PACKAGE_VERSION,COMPROMISED" >> "$REPORT_FILE"
    FOUND_COUNT=$((FOUND_COUNT+1))
  else
    echo "Working on $FULL... OK"
    echo "$PACKAGE_NAME,$PACKAGE_VERSION,SAFE" >> "$REPORT_FILE"
  fi

done < <(find "$PROJECT_DIR/node_modules" -name "package.json")

# AND THE END....
echo "------------------------------------------------------------"
echo "Scan complete."
echo "Total packages scanned: $TOTAL_PACKAGES"
echo "Compromised packages found: $FOUND_COUNT"
echo "📄 Report saved to: $REPORT_FILE"
