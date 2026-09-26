# solar_network_foundation

Reusable building blocks shared by Solar Network Flutter clients:

- `cloud_files.dart` / `cloud_file_widgets.dart` — cloud-file URL building and
  shared presentation primitives.
- `format.dart`, `markdown.dart`, `markdown_content.dart` — formatting and
  markdown rendering.
- `media_kit_init.dart` — idempotent `media_kit` bootstrap.
- `drive/` — the cloud drive service shared by Solian and SolWatt.

## Drive host seam

`drive/drive_service.dart` and `drive/upload_tasks.dart` are app-agnostic: they
never read app state directly. Everything they need from the host is declared in
`drive/drive_host.dart` and supplied by the host through Riverpod overrides.

A host **must** override these before any drive code runs, otherwise the drive
throws `UnimplementedError` on first use:

| Provider | Contract |
| --- | --- |
| `driveClientProvider` | authenticated `SolarNetworkClient` |
| `driveServerUrlProvider` | base URL for rendering drive assets |
| `driveSecretStoreProvider` | `setSecret` / `getSecret` for E2EE file keys |
| `driveTaskSinkProvider` | `addTask` / `updateTask` / `getTask` for the host's task overlay |
| `driveNavigatorKeyProvider` | navigator key for sheets shown above the whole app |

Optional:

| Provider | Effect when overridden | Default |
| --- | --- | --- |
| `driveSettingsProvider` | data-saver, image compression, default pool | `const DriveSettings()` |
| `driveErrorReporterProvider` | surfaces upload/download errors to the user | no-op |
| `driveQuotaUpgradePresenterProvider` | shows the host's "buy more storage" flow; `null` hides the action | `null` |

Both apps wire these in `lib/core/drive_wiring.dart`, and both use the same
`driveHostOverrides()` helper in their root `ProviderScope`.

### Task and status types

The drive reports progress through `DriveTaskSink` using `DriveTaskStatus` and
`DriveTaskTypes` / `DriveUploadStage` / `DriveUploadTaskMeta` /
`DriveDownloadTaskMeta`. `DriveTaskStatus` is re-exported from
`solar_network_sdk`; the host maps it onto its own task model (Solian's and
SolWatt's task models differ, so this is the only way to keep one drive copy).

### Localization

The drive reads its strings with `easy_localization`'s `tr()`, so hosts must
ship the drive keys in their own `assets/i18n` catalogs.

## Consuming this package

The package lives in the Solian repo and is consumed either by relative path
(Solian itself) or through the repo's git remote (SolWatt). Relative path
dependencies (`../solar_network_sdk`, `../island_ui_foundation`) are resolved
within the same checkout, so all Solar Network packages must come from a single
source in a given app — mixing one package from `path:` and another from `git:`
for the same repo is rejected by pub.
