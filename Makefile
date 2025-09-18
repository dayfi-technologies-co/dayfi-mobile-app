# Dayfi Flutter Build Makefile
FLAVOR ?= dev

.PHONY: help
help:
	@echo "Dayfi Flutter Build Commands"
	@echo ""
	@echo "Android:"
	@echo "  make android-dev     - Build Android APK (dev)"
	@echo "  make android-pilot   - Build Android APK (pilot)"
	@echo "  make android-prod    - Build Android APK (prod)"
	@echo ""
	@echo "iOS:"
	@echo "  make ios-dev         - Build iOS app (dev)"
	@echo "  make ios-pilot       - Build iOS app (pilot)"
	@echo "  make ios-prod        - Build iOS app (prod)"
	@echo ""
	@echo "Run:"
	@echo "  make run-dev         - Run dev flavor"
	@echo "  make run-pilot       - Run pilot flavor"
	@echo "  make run-prod        - Run prod flavor"
	@echo ""
	@echo "Utils:"
	@echo "  make clean           - Clean project"
	@echo "  make test            - Run tests"
	@echo "  make generate        - Generate assets and code"

# Setup
.PHONY: setup clean generate
setup:
	flutter pub get
	flutter pub run flutter_flavorizr

clean:
	flutter clean
	flutter pub get

generate:
	dart run build_runner build --delete-conflicting-outputs

# Android
.PHONY: android-dev android-pilot android-prod
android-dev:
	flutter build apk --flavor dev

android-pilot:
	flutter build apk --flavor pilot

android-prod:
	flutter build apk --flavor prod

# iOS
.PHONY: ios-dev ios-pilot ios-prod
ios-dev:
	flutter build ios --flavor dev --no-codesign

ios-pilot:
	flutter build ios --flavor pilot --no-codesign

ios-prod:
	flutter build ios --flavor prod --no-codesign

# Run
.PHONY: run-dev run-pilot run-prod
run-dev:
	flutter run --flavor dev

run-pilot:
	flutter run --flavor pilot

run-prod:
	flutter run --flavor prod

# Utils
.PHONY: test
test:
	flutter test
