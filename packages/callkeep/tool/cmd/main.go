package main

import (
	"encoding/json"
	"flag"
	"fmt"

	"github.com/flutter-webrtc/callkeep/tools/pkg/fcm"
	"github.com/flutter-webrtc/callkeep/tools/pkg/pushkit"
	log "github.com/pion/ion-log"
)

func pushCallKeep(provider string, token string, payload map[string]string) error {
	log.Infof("CallKeep Push Request")

	log.Infof("provider=%v", provider)
	log.Infof("token=%v", token)

	data, _ := json.MarshalIndent(payload, "", " ")
	log.Infof("payload=\n%v", string(data))

	switch provider {
	case "apns":
		pushkit.APNSPush("./callkeep-apns.p12", token, payload)
		return nil
	case "fcm":
		fcm.FCMPush("./callkeep-fcm.json", token, payload)
		return nil
	}
	return fmt.Errorf("%v provider not found", provider)
}

func main() {
	log.Init("info")
	h := false
	flag.BoolVar(&h, "h", false, "help")
	provider := ""
	flag.StringVar(&provider, "p", "fcm", "push provider type fcm | apns.")
	token := ""
	flag.StringVar(&token, "d", "", "device token.")
	cid := ""
	flag.StringVar(&cid, "i", "", "caller id.")
	flag.Parse()

	if h || len(token) == 0 || len(cid) == 0 {
		flag.Usage()
		return
	}

	log.Infof("try push")

	payload := map[string]string{
		"caller_id":      cid,
		"caller_name":    "push test",
		"caller_id_type": "number",
		"has_video":      "false",
	}

	err := pushCallKeep(provider, token, payload)
	if err != nil {
		log.Errorf("push failed %v", err)
	}
}
