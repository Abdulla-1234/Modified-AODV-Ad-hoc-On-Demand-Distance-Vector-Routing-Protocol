BEGIN{

	count = 0
	avg_pkt_len = 0
	total_len_count = 0
	received_packet_size = 0
	startTime = 1
	stopTime = 0
	packets_sent=0
	packets_received=0
	packets_dropped=0
	ack=0
}

{
	pkt_len = $21
	event = $1
	time = $2
	node_id = $3
	pkt_size = $8
	level = $4
	connection = $7
	
	if(pkt_len > 0) {
		
		count++
	}
	
	total_len_count = total_len_count + pkt_len 
	
	if (level == "RTR" && event == "s" ) {
        packets_sent++	
        
		if (time < startTime) {
			startTime = time
			}
	}
	
	if ( event == "D" ) {
        packets_dropped++	
		if (time < startTime) {
			startTime = time
			}
	}
	
	if (level == "RTR" && event == "r" ) {
	    packets_received++ 

		if (time > stopTime) {
			stopTime = time
			}
			
        }
	
}

END{

	printf("\nTotal Acknowledgements = %d", count)
	printf("\nAverage Packet Length  = %.2f (Bytes)", (total_len_count / count))
	printf("\nPackets Sent = %d",packets_sent);	
	printf("\nPackets Received = %d",packets_received);
	printf("\nPackets Dropped = %d",packets_dropped);
	printf("\n \n")
}
