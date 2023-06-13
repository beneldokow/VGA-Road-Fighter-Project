// System-Verilog 'written by Alex Grinshpun May 2018
// New bitmap dudy February 2021
// (c) Technion IIT, Department of Electrical Engineering 2021 



module	carReleaseLogic	(	
					input logic	clk,
					input logic	resetN,
					input logic onesec,// 1 sec clock
					input logic halfsec,// 0.5 sec clock
					input logic [8:0] ready,// 1 if any corresponding car is ready to be released			
					input logic [3:0] playerspeed, 

					output logic [8:0] releaseCar // 1 if corresponding car is to be released
 );

logic [1:0]random; // pseudo random releaser
logic [2:0] carsReleased = 0; // number of cars released
logic startCounter; // counter for start of game
logic [15:0] releaseCounter; // counter for release of cars
logic [3:0] seqCounter; // counter for sequential release
logic releaseClock; // clock for release of cars corresponding to speed

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		releaseCar <= 0;
		startCounter <= 0;
		releaseCounter <= 0;
		seqCounter <= 0;
		random <= 0;
	end

	else begin
		if(seqCounter == 9) 
			seqCounter <= 0;
		

		if(playerspeed > 4) begin //release cars only if speed is above 4
			random <= random + 1;
			
			if(releaseClock && random) begin // release cars every 1 or 0.5 sec corresponding to speed
				releaseCar <= 0; //default
				
				if(startCounter != 1) //wait for start of release
					startCounter <= startCounter + 1;

				else begin
					if(releaseCounter < 8'hc) begin // release first yellow cars
						for(int i=0; i<4; i=i+1) begin
							if(ready[i] == 1'b1) begin
								releaseCar[i] <= 1;
								break;
							end
						end
					end

					else if(releaseCounter < 8'h18) begin //also release first red cars and gas cars
						if(ready[8])
							releaseCar[8] <= 1;
						else begin
							for(int i=2; i<6; i=i+1) begin
								if(ready[i] == 1'b1) begin
									releaseCar[i] <= 1;
									break;
								end
							end
						end
					end

					else begin //sequential release
						if(ready[4] && seqCounter == 0)
							releaseCar[4] <= 1;
						else if(ready[2] && seqCounter == 1)
							releaseCar[2] <= 1;
						else if(ready[3] && seqCounter == 2)
							releaseCar[3] <= 1;
						else if(ready[8] && seqCounter == 3)
							releaseCar[8] <= 1;
						else if(ready[5] && seqCounter == 4)
							releaseCar[5] <= 1;
						else if(ready[6] && seqCounter == 5)
							releaseCar[6] <= 1;
						else if(ready[1] && seqCounter == 6)
							releaseCar[1] <= 1;
						else if(ready[7] && seqCounter == 7)
							releaseCar[7] <= 1;
						else if(ready[0] && seqCounter == 8)
							releaseCar[0] <= 1;
								
						seqCounter <= seqCounter + 1;
					end

					releaseCounter <= releaseCounter + 1;
				end
			end	
		end

		else begin // if speed is low, don't release cars
			releaseCar <= 0;
			startCounter <= 0;
		end
	end
end

always_comb begin
	if(playerspeed > 7) // release every 0.5 sec if speed is high
		releaseClock = halfsec;
	else // release every 1 sec if speed is low
		releaseClock = onesec;
end
endmodule