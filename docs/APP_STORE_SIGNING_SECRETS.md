# App Store signing secrets

This document describes every GitHub Actions secret used by the macOS App Store archive workflow:

- [`macos-appstore.yml`](../.github/workflows/macos-appstore.yml)

The workflows archive the app, export a signed package, and optionally upload it to App Store Connect.

## Before you start

You need access to:

- The Apple Developer team for `W7HPZ53V6B`.
- The Apple Developer Certificates, Identifiers & Profiles portal.
- An App Store Connect account with permission to create API keys and upload builds.
- The GitHub repository's **Settings → Secrets and variables → Actions** page.

Use **repository secrets**, not repository variables. Never commit certificates, provisioning profiles, `.p8` keys, passwords, or their unencoded files.

## Secret checklist

### Shared secrets

| Secret | Obtained from | Used by |
| --- | --- | --- |
| `APPLE_TEAM_ID` | Apple Developer membership or App Store Connect team settings | macOS signing/export |
| `ASC_KEY_ID` | App Store Connect API key details | App Store Connect upload |
| `ASC_ISSUER_ID` | App Store Connect API key details | App Store Connect upload |
| `ASC_API_KEY_P8_BASE64` | Downloaded App Store Connect API `.p8` private key | App Store Connect upload |

### macOS secrets

| Secret | Obtained from |
| --- | --- |
| `MACOS_APP_STORE_CERTIFICATE_P12_BASE64` | Exported Mac App Store distribution certificate and private key (`.p12`) |
| `MACOS_APP_STORE_CERTIFICATE_PASSWORD` | Password chosen while exporting the `.p12` |
| `MACOS_APP_STORE_PROVISIONING_PROFILE_BASE64` | Mac App Store provisioning profile for `dev.solsynth.solian` |
| `MACOS_APP_STORE_SIGNING_IDENTITY` | Exact certificate identity shown by `security find-identity` |

`APPLE_BUILD_KEYCHAIN_PASSWORD` is not required. The macOS workflow generates a random temporary keychain password on the GitHub runner.

## 1. Find the Apple Team ID

The team ID for this project is:

```text
W7HPZ53V6B
```

Confirm it in one of these locations:

- Apple Developer → **Account** → **Membership details** → **Team ID**.
- App Store Connect → **Users and Access** → **Team information**.

Create the GitHub secret:

```text
Name:  APPLE_TEAM_ID
Value: W7HPZ53V6B
```

## 2. Create the macOS distribution certificate

The macOS workflow needs a Mac App Store distribution certificate, not an Apple Development certificate and not a Developer ID certificate.

1. Open the Apple Developer **Certificates, Identifiers & Profiles** portal.
2. Open **Certificates** and create a **Mac App Distribution** certificate.
3. On the Mac used to create the certificate request, open **Keychain Access**.
4. Locate the certificate with its associated private key under **My Certificates**.
5. Export the certificate and private key as a `.p12` file, for example:

   ```text
   macos-app-store-distribution.p12
   ```

6. Choose a strong export password. This becomes:

   ```text
   MACOS_APP_STORE_CERTIFICATE_PASSWORD
   ```

7. Encode the `.p12` file:

   ```bash
   base64 < macos-app-store-distribution.p12 | tr -d '\n' | pbcopy
   ```

8. Create this GitHub secret from the clipboard:

   ```text
   MACOS_APP_STORE_CERTIFICATE_P12_BASE64
   ```

9. Create the password secret:

   ```text
   MACOS_APP_STORE_CERTIFICATE_PASSWORD
   ```

   Its value is the password used in step 6, not the Base64 value.

### Find the macOS signing identity

On a Mac where the certificate is installed, run:

```bash
security find-identity -v -p codesigning
```

Use the complete matching **Mac App Store distribution** identity as:

```text
MACOS_APP_STORE_SIGNING_IDENTITY
```

For example, the identity may look like:

```text
3rd Party Mac Developer Application: JunYang Jiang (W7HPZ53V6B)
```

Use the exact output from your machine. Do not use `Apple Development` or `Developer ID Application` for this workflow.

## 3. Create the macOS provisioning profile

1. In Apple Developer, open **Profiles**.
2. Create a **Mac App Store** distribution profile.
3. Select the App ID:

   ```text
   dev.solsynth.solian
   ```

4. Select the Mac App Distribution certificate created above.
5. Download the `.provisionprofile` file.
6. Encode it:

   ```bash
   base64 < Solian.provisionprofile | tr -d '\n' | pbcopy
   ```

7. Create this GitHub secret using the clipboard contents:

   ```text
   MACOS_APP_STORE_PROVISIONING_PROFILE_BASE64
   ```


## 4. Create App Store Connect API credentials

The upload steps use an App Store Connect API key instead of an Apple ID password.

1. Open App Store Connect.
2. Go to **Users and Access** → **Integrations** → **API Keys**.
3. Create a key with a role that can upload builds, normally **App Manager** or an equivalent role.
4. Record the **Key ID** as:

   ```text
   ASC_KEY_ID
   ```

5. Record the **Issuer ID** shown on the API Keys page as:

   ```text
   ASC_ISSUER_ID
   ```

6. Download the `.p8` private key. Apple only allows this download once. Keep the original file securely.
7. Encode it:

   ```bash
   base64 < AuthKey_XXXXXXXXXX.p8 | tr -d '\n' | pbcopy
   ```

8. Create:

   ```text
   ASC_API_KEY_P8_BASE64
   ```

Do not use the `.p8` filename as the secret value. The value must be the Base64-encoded file contents.

## 5. Add the secrets to GitHub

For every secret:

1. Open the GitHub repository.
2. Go to **Settings** → **Secrets and variables** → **Actions**.
3. Select **New repository secret**.
4. Enter the exact secret name from this document.
5. Paste or type the value.
6. Select **Add secret**.

GitHub does not show secret values after saving them. If a value is wrong, create a replacement secret with the same name.

## 6. Verify locally before running CI

Check the installed signing identities:

```bash
security find-identity -v -p codesigning
```

Inspect provisioning profile bundle IDs and names:

```bash
security cms -D -i path/to/profile.mobileprovision > /tmp/profile.plist
/usr/libexec/PlistBuddy -c 'Print :Entitlements:application-identifier' /tmp/profile.plist
/usr/libexec/PlistBuddy -c 'Print :Name' /tmp/profile.plist
/usr/libexec/PlistBuddy -c 'Print :UUID' /tmp/profile.plist
```

Check that the encoded value can be decoded again:

```bash
base64 < path/to/file | tr -d '\n' | base64 -D > /tmp/decoded-file
cmp path/to/file /tmp/decoded-file
```

`cmp` should produce no output and exit successfully.

## 7. Run the workflow

Run the **macOS App Store** workflow manually from GitHub Actions.

Use upload disabled for the first run. After archive and export succeed, enable upload or push a matching macOS release tag:

- macOS: `v*`

A failed archive usually means the certificate, profile, bundle identifier, or signing identity does not match. A failed upload usually means the App Store Connect API key lacks upload permission or the app version/build is not acceptable to App Store Connect.
