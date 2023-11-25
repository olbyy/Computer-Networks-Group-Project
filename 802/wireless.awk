BEGIN{
	recvSize = 0
	startTime = 0
	stopTime = 0
}
{
	event = $1
	time = $2
	node_id = $3
	packetSize = $8
	level = $7
	
	if(level == "cbr" && event == "r" && packetSize >= 100){
		if(time < startTime){
			startTime = time
		}
	}
	
	if(level == "cbr" && event == "r" && packetSize >= 100){
		if(time > stopTime){
			stopTime = time
		}
		recvSize += packetSize
	}
	if(stopTime != -nan)
	printf("%.2f %.2f\n", stopTime, (recvSize/(stopTime-startTime))*(8/1000))
}
END{
}
