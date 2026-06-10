# Dayfi mobile — production QA checklist

Run on **pilot/prod** builds against `https://api.dayfi.co/api/v1` (see `lib/flavors.dart`).

Toggle feature gates in [`lib/common/constants/product_features.dart`](../lib/common/constants/product_features.dart) before release.

## Build

- [ ] `flutter run --flavor pilot --dart-define=FLAVOR=pilot` (or prod)
- [ ] iOS + Android smoke on real devices
- [ ] Backend deployed (`dayfi_backend` `./scripts/deploy-vps.sh`)

## Tier A — must pass

### Auth

- [ ] Sign up → email verify → passcode
- [ ] KYC tier required for send completes without dead ends
- [ ] Logout → login again
- [ ] Apple / Google sign-in (if enabled) on device

### Wallet / add money

- [ ] Bank transfer (NGN VA minimum) credits balance
- [ ] Balance visible on Home after refresh
- [ ] Disabled rails show “coming soon”, not primary CTAs

### Send

- [ ] NGN bank send succeeds → history + notification
- [ ] Dayfi tag send succeeds
- [ ] Rate unavailable shows clear message (no raw API errors)

### Pay (local)

- [ ] Pay bills → Local → airtime or cable succeeds
- [ ] International bills tile disabled / “Coming soon”

### DayFlow + Budgets

- [ ] Home → DayFlow → automate send or bill (form)
- [ ] Dashboard lists schedule; pull-to-refresh works
- [ ] Tap row → schedule detail
- [ ] Edit payment → DayX chat opens; change applies after refresh
- [ ] Stop automation removes row from dashboard + Budgets
- [ ] Budgets list: DayFlow rows labeled; tap → schedule detail
- [ ] Home ongoing budgets section: tap → schedule detail
- [ ] Budget notification tap → schedule detail (not budget detail)
- [ ] Dashboard load failure shows **Try again** (not fake empty)

### History & profile

- [ ] Transaction history accurate statuses (Success / Failed)
- [ ] Profile: Terms, Privacy, Contact, Logout work
- [ ] Delete account: gated per `ProductFeatures.profileDeleteAccount` (support path if false)

## Tier B — labeled OK

- [ ] Crypto add money (if `cryptoAddMoney = true`)
- [ ] Profile name/phone change → support copy (if self-serve false)
- [ ] DayEarn promo (if `dayEarnHomePromo = true`)

## Tier C — must not appear in nav

- [ ] No SoftPOS / Tap to Pay entry on Home or Pay
- [ ] No `DayFlowChatView` prototype route
- [ ] Invest hidden on Home when `investHomeOngoing = false`

## Regression notes

| Area | Pass | Fail | Notes |
|------|------|------|-------|
| Auth | | | |
| Add money | | | |
| Send | | | |
| Pay local | | | |
| DayFlow | | | |
| Budgets | | | |
| Notifications | | | |
