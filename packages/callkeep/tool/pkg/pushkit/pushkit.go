package pushkit

import (
	"encoding/json"

	log "github.com/pion/ion-log"
	"github.com/sideshow/apns2"
	"github.com/sideshow/apns2/certificate"
)

func APNSPush(p12 string, token string, payload map[string]string) {

	cert, err := certificate.FromP12File(p12, "")
	if err != nil {
		log.Errorf("Cert Error: %v", err)
	}

	data, _ := json.Marshal(payload)
	notification := &apns2.Notification{}
	notification.DeviceToken = token
	notification.PushType = "voip"      // voip | alert
	notification.Payload = []byte(data) // See Payload section below

	// If you want to test push notifications for builds running directly from XCode (Development), use
	client := apns2.NewClient(cert).Development()
	// For apps published to the app store or installed as an ad-hoc distribution use Production()
	//client := apns2.NewClient(cert).Production()
	res, err := client.Push(notification)

	if err != nil {
		log.Errorf("Error: %v", err)
	}

	log.Infof("Push response: %v %v %v\n", res.StatusCode, res.ApnsID, res.Reason)
}
