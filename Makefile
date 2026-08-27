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
	@echo "  make branding        - Regenerate app icons + splash (Android & iOS)"
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

.PHONY: branding
branding:
	bash scripts/refresh_app_branding.sh

# Android
.PHONY: android-dev android-pilot android-prod android-prod-release
android-dev:
	flutter build apk --flavor dev --dart-define=FLAVOR=dev

android-pilot:
	flutter build apk --flavor pilot --dart-define=FLAVOR=pilot

android-prod:
	flutter build apk --flavor prod --dart-define=FLAVOR=prod

android-prod-release:
	flutter build apk --flavor prod --dart-define=FLAVOR=prod --release

# iOS
.PHONY: ios-dev ios-pilot ios-prod
ios-dev:
	flutter build ios --flavor dev --dart-define=FLAVOR=dev --no-codesign

ios-pilot:
	flutter build ios --flavor pilot --dart-define=FLAVOR=pilot --no-codesign

ios-prod:
	flutter build ios --flavor prod --dart-define=FLAVOR=prod --no-codesign

# Run
.PHONY: run-dev run-pilot run-prod
run-dev:
	flutter run --flavor dev --dart-define=FLAVOR=dev

run-pilot:
	flutter run --flavor pilot --dart-define=FLAVOR=pilot

run-prod:
	flutter run --flavor prod --dart-define=FLAVOR=prod

# Utils
.PHONY: test
test:
	flutter test
