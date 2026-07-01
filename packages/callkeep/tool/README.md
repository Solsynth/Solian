# CallKeep test tool

This tool is used to demonstrate the basic push process for verifying callkeep. written in golang.

prepare to run:

`cd tools && go mod tidy`

## For iOS APNS

please refer to `https://developer.apple.com/account/resources/certificates/add`.

Choose `VoIP Services Certificate` to create a push certificate, download `voip_services.cer` and install it to the keychain tool, export its private key rename it to `callkeep-apns.p12`

`go run cmd/main.go -i +8618612345678 -p apns -d $ios_device_token`

## For Android FCM

please refer to `https://console.firebase.google.com/project/[your project]/settings/serviceaccounts/adminsdk`

Select the `go` sdk format under your fcm project to download `serviceAccountKey.json` and rename it to `callkeep-fcm.json`

`go run cmd/main.go -i +8618612345678 -p fcm -d $android_fcm_token`
