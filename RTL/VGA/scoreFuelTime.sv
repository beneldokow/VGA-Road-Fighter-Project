//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// System-Verilog Alex Grinshpun May 2018
// New coding convention dudy December 2018
// (c) Technion IIT, Department of Electrical Engineering 2021 


module	scoreFuelTime	(	
					input	 logic	clk,
					input	 logic	resetN,
					input	 logic startOfFrame,
					input    logic onesec, // 1 sec pulse
					input    logic collision, //input is 1 when collision
					input    logic fueltank, //input is 1 when fuel tank reached
					input 	 logic [3:0] playerSpeed,
					
					//values digits
					output 	logic	[3:0] fuelLsb,
					output 	logic	[3:0] fuelMsb,
					output 	logic	[4:0] scoreLLsb,
					output 	logic	[3:0] scoreLMsb,
					output 	logic	[3:0] scoreMLsb,
					output 	logic	[3:0] scoreMMsb,
					output	logic	[3:0]	speedLsb,
					output	logic	[3:0]	speedMidb,
					output	logic	[3:0]	speedMsb,
					output 	logic fuel_zero, // 1 when fuel is zero
					output  	logic win // 1 when target score is reached
);

//constants
const int initialFuel = 9; 
const int maxSpeed = 5;
parameter int targetScore = 0;

logic collisionWait;  //collisionWait is a flag that prevents the collision from being detected more than once
logic [8:0]speed; //speed value
logic [12:0] score; //score value

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		scoreLLsb <= 0;
		scoreLMsb <= 0;
		scoreMLsb <= 0;
		scoreMMsb <= 0;
		collisionWait <= 1;
		speed <= 0;
		speedLsb <= 0;	
		speedMidb <= 0;
		speedMsb <= 0;
		fuelMsb <= initialFuel;
		fuelLsb <= initialFuel;
		fuel_zero <= 0;
		win <= 0;
		score <= 0;
		
	end
	else begin
		if(collision && collisionWait) begin //if collision then put into effect relevant changes and values
			speed <= 0;
			speedLsb <= 0;	
			speedMidb <= 0;
			speedMsb <= 0;

			//changing digits according to decimal values
			if(fuelMsb > 0)
				fuelMsb <= fuelMsb - 1'b1;
			else if(fuelLsb > 0)
				fuelLsb <= 0;
			collisionWait <= 0; //collisionWait is a flag that prevents the collision from being detected more than once
		end
		
		//changing digits according to decimal values
		if(fueltank && fuelMsb < 9)
			fuelMsb <= fuelMsb + 1'b1;
		else if(fueltank && fuelMsb == 9)
			fuelLsb <= initialFuel;
		
		if(fuelMsb == 0 && fuelLsb == 0) //if fuel is zero then fuel_zero is 1
			fuel_zero <= 1;
			
		if(score >= targetScore) //if score is equal or greater than targetScore then win is 1
			win <= 1;
		

		if(startOfFrame) begin
		
			if(speed < (((playerSpeed << 3) + (playerSpeed << 1)) << 2)) begin //updating speed every frame
					speed <= speed + 2'h2;
					speedLsb <= speedLsb + 2'h2;

					//changing digits according to decimal values
					if(speedLsb == 4'h8) begin
							speedLsb <= 0;
							speedMidb <= speedMidb + 1'b1;
							
							if(speedMidb == 4'h9) begin
									speedMidb <= 0;
									speedMsb <= speedMsb + 1'b1;
							end
					end
			end
			
			else if(speed > (((playerSpeed << 3) + (playerSpeed << 1)) << 2)) begin
					speed <= speed - 2'h2;
					
					if(speedLsb == 0) begin
							speedLsb <= 4'h8;
							
							if(speedMidb == 0) begin
									speedMidb <= 4'h9;
									
									if(speedMsb > 0)
											speedMsb <= speedMsb - 1'b1;
							end
							
							else
									speedMidb <= speedMidb - 1'b1;
					end
					else
							speedLsb <= speedLsb - 2'h2;
			end
			
			//uping fuel if fueltank is reached
			if(fueltank) begin
						fuelMsb <= fuelMsb + 2'h2; 
			end
							
		end	
		
		if(onesec) begin
			
			if(!collision) //resetting collisionWait flag after 1 sec and end of collision
				collisionWait <= 1;
			
			if(fuelLsb || fuelMsb) begin //if there is fuel then continue game

				//decreasing fuel according to speed
				if(playerSpeed > maxSpeed) begin
					if(fuelLsb <= 2'h3 && !fuelMsb)
						fuelLsb <= 0;
					else if(fuelLsb > 2'h2)
						fuelLsb <= fuelLsb - 2'h3;
					else begin
						fuelLsb <= fuelLsb + 4'h7;
						fuelMsb <= fuelMsb - 1'b1; 
					end	
				end
				
				else if(playerSpeed > 0) begin
					if(fuelLsb <= 2'h2 && !fuelMsb)
						fuelLsb <= 0;
					else if(fuelLsb > 2'h1)
						fuelLsb <= fuelLsb - 2'h2;
					else begin
						fuelLsb <= fuelLsb + 4'h8;
						fuelMsb <= fuelMsb - 1'b1; 
					end
				end
				
				else begin
					if(fuelLsb > 0)
						fuelLsb <= fuelLsb - 1'b1;
					else begin
						fuelLsb <= 4'h9;
						fuelMsb <= fuelMsb - 1'b1; 
					end
				end
				
			end
			
			score <= score + playerSpeed; //updating score every second according to speed
			
			//changing digits according to decimal values
			if(scoreLLsb + playerSpeed > 4'h9) begin
				scoreLLsb <= scoreLLsb + playerSpeed - 4'hA;
				if(scoreLMsb + 1'b1 > 4'h9) begin
					scoreLMsb <= scoreLMsb + 1'b1 - 4'hA;
					if(scoreMLsb + 1'b1 > 4'h9) begin
						scoreMLsb <= scoreMLsb + 1'b1 - 4'hA;
						if(scoreMMsb + 1'b1 > 4'h9)
							scoreMMsb <= scoreMMsb + 1'b1 - 4'hA;
						else
							scoreMMsb <= scoreMMsb + 1'b1;
					end
					else
						scoreMLsb <= scoreMLsb + 1'b1;
				end
				else
					scoreLMsb <= scoreLMsb + 1'b1;
			end
			else
				scoreLLsb <= scoreLLsb + playerSpeed;

		end	
	end
end
	
endmodule 