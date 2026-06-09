# Dayfi (consumer mobile app)

Flutter consumer wallet — pairs with **`dayfi_backend`** at `https://api.dayfi.co/api/v1` (see `lib/flavors.dart`).

Backend docs: [`dayfi_backend/docs/MOBILE_INTEGRATION.md`](../dayfi_backend/docs/MOBILE_INTEGRATION.md) · [API reference](../dayfi_backend/docs/API.md)

## Run against production API

```bash
flutter run --flavor pilot --dart-define=FLAVOR=pilot
```

VS Code: **Flutter Dev (api.dayfi.co)** or **Flutter Pilot/Prod**.

## After backend deploy

Rebuild the app when API history/notifications change. Then:

1. **History** — pull to refresh (server repairs failed bill/YC rows)
2. Status labels: **Success** / **Failed** (not “Completed” for successes)
3. **People** — bank recipients show **Opay · NG** (not “Bank · NG”)
4. YC sends — **To Name · Bank**, fee line from `fees` / `ledger_metadata.feeUsd`

See [`dayfi_backend/docs/TEST_PRODUCTION.md`](../dayfi_backend/docs/TEST_PRODUCTION.md) for the full checklist.
