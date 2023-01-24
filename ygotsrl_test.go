package ygotsrl

import (
	"fmt"
	"testing"

	"github.com/openconfig/ygot/ygot"
)

func TestDevice(t *testing.T) {
	device := &Device{}
	device.GetOrCreateInterface("mgmt0")
	device.Interface["mgmt0"].GetOrCreateSubinterface(*ygot.Uint32(0))
	device.Interface["mgmt0"].Subinterface[*ygot.Uint32(0)].GetOrCreateIpv4()
	device.Interface["mgmt0"].Subinterface[*ygot.Uint32(0)].Ipv4.GetOrCreateDhcpClient()

	j, err := ygot.EmitJSON(device, &ygot.EmitJSONConfig{
		Format: ygot.RFC7951,
		Indent: "  ",
		RFC7951Config: &ygot.RFC7951JSONConfig{
			AppendModuleName: true,
		},
		// debug
		SkipValidation: false,
	})
	if err != nil {
		return
	}
	fmt.Println(j)
}
