wifi.setmode(wifi.STATION)
wifi.setphymode(wifi.PHYMODE_B)
gpio.mode(1, gpio.OUTPUT)
gpio.write(1, gpio.LOW)
function listap()
	tmr.stop(0)
	dofile('setup.lua')
end

scan_cfg = {}
scan_cfg.ssid = "configuration_network_name"
scan_cfg.show_hidden = 1
wifi.sta.getap(scan_cfg, 1, listap)


function checkvolt()
x = adc.read(0)
print (x)
	if x < 528 then
		print("low battery, sleeping longer")
		node.dsleep(960000000)
	end
end
checkvolt()
function sleeping()
node.dsleep(600000000)
end



tmr.alarm(0,11000,0,sleeping)

ClientID = 'Node Zero'
m = mqtt.Client(ClientID, 120)

m:connect("your_MQTT_broker_address", 1883, 0, function(client)
  print("connected")
  client:subscribe("/your_control_channel_name", 0, function(client) print("subscribe success") end)
 end)
		
m:on("message", function(client, topic, data) 
  print(topic .. ":" ) 
  if data ~= nil then
    print(data)
	if data == "n0 on" then
		tmr.unregister(0)
		dofile('active.lua')
		m:close()
				end
		
  end
		end)
