gpio.mode(1, gpio.OUTPUT)
gpio.write(1, gpio.HIGH)
tmr.unregister(0)

print("Node Active")

function dsleep()
node.dsleep(900000000)
end

ClientID = 'Node Zero'
m = mqtt.Client(ClientID, 120)

m:publish("/your_control_channel_name", "n0 awaiting instruction", 0, 1, function(client) print("sent") end)

function checkvolt()
x = adc.read(0)
xv = (x/155.15)
print ("voltage is " ..xv.. " units") 
m:publish("/your_control_channel_name", "Battery is at "..xv.." volts", 0, 1, function(client) print("sent") end)

	if x < 528 then
		gpio.write(1, gpio.LOW)
		m:close()
		tmr.alarm(1,5000,0,dsleep)
		print("battery low, sleeping in 5 seconds")
		end
		

end

tmr.alarm(1,30000,tmr.ALARM_AUTO,checkvolt)

m:connect("your_MQTT_broker_address", 1883, 0, function(client)
  print("connected")

  client:subscribe("/your_control_channel_name", 0, function(client) print("subscribe success") end)
  
end)
		
m:on("message", function(client, topic, data) 
  print(topic .. ":" ) 
  if data ~= nil then
    print(data)
	if data == "deactivate" then
		gpio.write(1, gpio.LOW)
		m:close()
		node.dsleep(600000000)
	end
  end
end)
