# Solsynth Express release distribution

Solsynth Express is the product-facing name for DistributionCenter, the
release control plane used by Island. It owns release metadata, artifact
matching, download URLs, and update checks. GitHub Actions builds the binaries;
Solsynth Express stores and publishes the resulting release artifacts.

This guide covers the migration from the previous GitHub/R2 download flow to
Solsynth Express.

## Architecture

```text
GitHub tag v1.2.3
        |
        v
GitHub Actions builds Windows, Linux, and Android artifacts
        |
        v
SolsynthExpressUpload@v1 requests an upload URL and uploads each file
        |
        v
DistributionCenter draft release 1.2.3
        |
        v
Human reviews and publishes the draft release
        |
        v
Island calls DistributionCenter and downloads the matching artifact
```

The upload action is maintained in its own repository:

<https://github.com/Solsynth/SolsynthExpressUpload>

The action creates a stable draft automatically when the requested version is
not present. Uploading and publishing are separate operations because a
product-scoped upload key is not allowed to publish releases.

## Prerequisites

- A deployed DistributionCenter instance reachable by GitHub Actions and Island.
- A DistributionCenter product for Island.
- A Sphere publisher editor token for one-time product and key management.
- A product-scoped DistributionCenter upload key for CI.
- A publisher who reviews and publishes draft releases.
- The Island workflow changes from this branch.

The complete API contract is in `DistributionCenter/docs/MARKETPLACE_API.md`.

## One-time DistributionCenter setup

### 1. Create or identify the Island product

Create the product under the Solsynth publisher, or record the existing
DistributionCenter product UUID:

```http
POST {DISTRIBUTION_API_BASE_URL}/publishers/{publisher_name}/products
Authorization: Bearer <Sphere publisher token>
Content-Type: application/json

{
  "slug": "solian",
  "name": "Solian"
}
```

Use the returned DistributionCenter product `id` as
`DISTRIBUTION_PRODUCT_ID`. The product ID is not the legacy custom-app ID.

### 2. Create the CI upload key

Create a key while authenticated as a publisher editor:

```http
POST {DISTRIBUTION_API_BASE_URL}/products/{product_id}/upload-api-keys
Authorization: Bearer <Sphere publisher token>
Content-Type: application/json

{"name":"Island GitHub Actions"}
```

Save the response `key` immediately. The plaintext key is only returned during
creation. Store it as the `DISTRIBUTION_UPLOAD_KEY` GitHub secret.

The upload key can only:

- Request an artifact upload URL.
- Attach an uploaded artifact to a release.

It cannot publish, edit, yank, or delete releases.

### 3. Prepare for human publication

The workflow only uploads artifacts and leaves the release as a stable draft.
After reviewing the artifacts, a publisher can publish the release by version.
The publish operation is not performed by GitHub Actions.

## GitHub repository configuration

Configure the Island repository (`Solsynth/Solian`) with these repository
variables:

| Name | Value |
| --- | --- |
| `DISTRIBUTION_API_BASE_URL` | DistributionCenter REST base URL, including `/api` |
| `DISTRIBUTION_PRODUCT_ID` | Island's DistributionCenter product UUID |

Configure these repository secrets:

| Name | Value |
| --- | --- |
| `DISTRIBUTION_UPLOAD_KEY` | Plaintext product-scoped upload key |

The existing Sentry and signing secrets remain unchanged.

With the GitHub CLI, non-secret variables can be configured as follows:

```sh
gh variable set DISTRIBUTION_API_BASE_URL \
  --repo Solsynth/Solian \
  --body 'https://distribution.example.com/api'

gh variable set DISTRIBUTION_PRODUCT_ID \
  --repo Solsynth/Solian \
  --body '<distribution-center-product-uuid>'
```

Set secrets through standard input so they are not included in shell history:

```sh
printf '%s' "$DISTRIBUTION_UPLOAD_KEY" |
  gh secret set DISTRIBUTION_UPLOAD_KEY --repo Solsynth/Solian

```

Replace the example API URL and product UUID with the real deployment values.

## Release workflow

The workflow is `.github/workflows/build.yml`.

### Version source

A release is created from a tag such as:

```text
v1.2.3
```

The workflow passes `github.ref_name` to `SolsynthExpressUpload@v1`. The action
normalizes the leading `v` and sends version `1.2.3` to DistributionCenter.
DistributionCenter requires SemVer without the leading `v`.

The upload job only runs for pushed tags beginning with `v`:

```yaml
if: github.event_name == 'push' && startsWith(github.ref, 'refs/tags/v')
```

`workflow_dispatch` remains useful for building individual platforms, but it
does not upload or publish because a branch name is not a release version.

### Build-time update configuration

Each Flutter build receives the public API base URL and product UUID:

```sh
flutter build windows \
  --dart-define=DISTRIBUTION_API_BASE_URL="..." \
  --dart-define=DISTRIBUTION_PRODUCT_ID="..."
```

The workflow already passes these defines to Windows, Linux, and Android builds.
They are compiled into the application; the upload key and publish token are
never compiled into Island.

### Artifact mapping

The workflow attaches these artifacts to the same release version:

| Artifact | Platform | Architecture | MIME type |
| --- | --- | --- | --- |
| Windows installer ZIP | `windows` | `amd64` | `application/zip` |
| Linux AppImage ZIP | `linux` | `amd64` | `application/zip` |
| `app-arm64-v8a-release.apk` | `android` | `arm64` | `application/vnd.android.package-archive` |
| `app-armeabi-v7a-release.apk` | `android` | `armeabi-v7a` | `application/vnd.android.package-archive` |
| `app-x86_64-release.apk` | `android` | `x86_64` | `application/vnd.android.package-archive` |

Each action invocation:

1. Computes the artifact SHA-256 digest.
2. Requests a versioned presigned upload URL.
3. Creates the stable draft when needed.
4. Uploads the bytes with `x-amz-meta-sha256`.
5. Attaches the object with platform and architecture metadata.

After all uploads, the workflow intentionally leaves the release as a draft.
Publishing is a human-controlled review step. A publisher can publish the
reviewed release by version:

```http
POST /api/products/{product_id}/releases/{version}/publish
Authorization: Bearer <Sphere publisher token>
```

DistributionCenter resolves the SemVer path segment to the product release.
The CI upload key cannot perform this operation.


## Island update handling

`lib/core/services/update_service.dart` uses the values supplied through
`DISTRIBUTION_API_BASE_URL` and `DISTRIBUTION_PRODUCT_ID`.

### Update check

For automatic and manual update checks, Island calls:

```http
GET /api/products/{product_id}/update
  ?current_version=1.1.0
  &channel=stable
  &os=android
  &architecture=arm64
```

DistributionCenter returns the newest published compatible release. Island
reads the matching artifact's `download_url`; this may be a public CDN URL or a
time-limited signed GET URL when `s3.publicURL` is not configured.

### Latest release display

Settings and onboarding use the published release listing endpoint:

```http
GET /api/products/{product_id}/releases
  ?channel=stable
  &platform=android
  &architecture=arm64
  &limit=1
```

Release notes come from `release_notes`, and artifacts come from the release's
`artifacts` list.

### Platform and architecture matching

Island reports these values:

- Android: `android` plus the first supported ABI mapped to `arm64`,
  `armeabi-v7a`, `x86_64`, or `x86`.
- Windows: `windows` plus `amd64` or `arm64`.
- Linux: `linux` plus `amd64`.
- macOS and iOS are recognized by the client, but they require corresponding
  published artifacts before an update can be offered.

A release without a compatible artifact is not offered as an update.

If either Dart define is missing, Island logs that Solsynth Express update
configuration is missing and skips the update request. This is expected for
local builds that do not configure a distribution product.

## Migration procedure

### 1. Keep the existing release available

Do not delete the old R2 objects or remove the old GitHub release metadata
before the first Solsynth Express release has been verified. Existing Island
versions may still depend on the old URLs.

### 2. Configure DistributionCenter

Create the product, upload key, and publish token. Configure the GitHub
variables and secrets listed above.

### 3. Deploy the updated Island client

Build Island with the Solsynth Express Dart defines. This client understands
DistributionCenter release metadata and artifact download URLs.

### 4. Upload a tagged canary release

Push a tag with a version newer than the installed client:

```sh
git tag v1.2.3
git push origin v1.2.3
```

Monitor the workflow:

```sh
gh run list --repo Solsynth/Solian --workflow build.yml
gh run watch --repo Solsynth/Solian
```

Confirm that the workflow completes the artifact upload steps and leaves the
release as a draft.
Review the draft artifacts, then publish the release manually using the
publisher tooling or API:

```http
POST /api/products/{product_id}/releases/{version}/publish
Authorization: Bearer <Sphere publisher token>
```

### 5. Verify the published release

Check the public product endpoint:

```sh
curl --fail-with-body \
  "$DISTRIBUTION_API_BASE_URL/products/$DISTRIBUTION_PRODUCT_ID/update?current_version=1.0.0&channel=stable&os=linux&architecture=amd64"
```

The response should contain:

```json
{
  "update_available": true,
  "release": {
    "version": "1.2.3",
    "artifacts": [
      {
        "platform": "linux",
        "architecture": "amd64",
        "download_url": "https://..."
      }
    ]
  }
}
```

Open the returned `download_url` and verify that it downloads the expected
artifact. Do not expose the upload or publish token in this request.

### 6. Verify Island update behavior

Install the previous Island version on a matching platform, trigger **Check
for Updates**, and confirm that:

- The Solsynth Express release version is displayed.
- The release notes are displayed.
- The platform-specific install action is present.
- The action downloads the artifact returned by DistributionCenter.

### 7. Retire the old workflow

After the canary succeeds and existing clients have had time to migrate:

- Remove R2 upload credentials from the Island repository.
- Remove the old R2 upload steps from the workflow.
- Retain old R2 objects until the minimum supported Island version no longer
  references them.

## Troubleshooting

### The upload action returns 401 or 403

Check that `DISTRIBUTION_UPLOAD_KEY` is the plaintext key created for the same
product UUID. Upload keys are product-scoped and are not interchangeable with
Sphere publisher tokens.

### The draft is not visible as an update

Draft releases are intentionally excluded from public update responses. A
publisher must review the artifact set and publish the release manually using
the release version:

```http
POST /api/products/{product_id}/releases/{version}/publish
Authorization: Bearer <Sphere publisher token>
```

The version path is resolved by DistributionCenter; the publisher does not
need the internal release UUID.

### Island reports no update

Check the following in order:

1. The release status is `published`, not `draft`.
2. The release version is newer than the installed version.
3. `DISTRIBUTION_API_BASE_URL` includes `/api`.
4. `DISTRIBUTION_PRODUCT_ID` identifies the Island product.
5. The release has an artifact matching the device platform and architecture.
6. The artifact has a non-empty `download_url`.
7. The release uses the `stable` channel.

### Signed download URLs expire

Signed URLs are intentionally time-limited. Island requests a fresh update
response when checking for updates. Do not persist a signed URL as a permanent
application setting.

## Security notes

- Store upload and publish credentials only in GitHub secrets.
- Never pass either credential through `--dart-define`.
- Revoke and replace upload keys when a CI environment is compromised.
- Pin `SolsynthExpressUpload` to a full commit SHA when the repository's supply
  chain policy requires immutable action references instead of `@v1`.
- Keep old storage credentials until the supported client population has moved
  to Solsynth Express, then revoke them.
