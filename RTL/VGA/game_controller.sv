// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2021 
//updated --Eyal Lev 2021


module	game_controller	(	
			input logic	clk,
			input logic	resetN,
			input logic	startOfFrame,  // short pulse every start of frame 30Hz 
			input logic	playerReq, // player request for position
			input logic	carsReq, // cars request for position
			input logic totalCollision, //1 if theres a collision with any car or walls
			input logic fuelReq, //fuel request for position
			input logic specialReq, //special request for position
			input logic truckReq, //truck request for position
			input logic Enter,
			input logic zero_fuel, //1 if fuel is zero
			input logic onesec, //1 if 1 second passed
			input logic win, //1 if player won
			
			output logic collision, //1 if theres a collision which is not with fuel or special or truck
			output logic fuel, //1 if player and fuel are in the same place
			output logic special, //1 if player and special are in the same place
			output logic SingleHitPulse, // critical code, generating A single pulse in a frame 
			output logic game_resetN, // reset for the game modules to start the game
			output logic losingSeq, //1 if player lost
			output logic winningSeq, //1 if player won
			output logic gameSeq //1 if player is in game mode
);

assign fuel = playerReq && fuelReq; //1 if player and fuel are in the same place
assign specialCollision = playerReq && specialReq; //1 if player and special are in the same place
assign truckCollision = playerReq && truckReq; //1 if player and truck are in the same place
logic [1:0] counter; // counter for the start state
logic [3:0] specialCounter; // counter for the special state
logic enterWasPressed; // a flag to know if enter was pressed

						 						
logic flag ; // a semaphore to set the output only once per frame / regardless of the number of collisions 

enum  logic [2:0] {START_ST , // initial state
					GAME_ST, // moving no colision 
					WIN_ST, // winning state
					LOSE_ST, // losing state
				   SPECIAL_ST // special state	
					}  SM_PS, 
						SM_NS ;

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		SM_PS <= START_ST;
		flag	<= 1'b0;
		SingleHitPulse <= 1'b0 ; 
		counter <= 2'b00;
		specialCounter <= 2'b00;
		enterWasPressed <= 1'b0;
	end 
	else begin 
			if(Enter) //checking if enter was pressed
				enterWasPressed <= 1'b1;
			
			SM_PS <= SM_NS;
			
			//collision gets 1 if theres a collision which is not with fuel or special or truck and not in special state
			collision <= (playerReq && carsReq && !fuel && !specialCollision && !truckCollision && !special) || (totalCollision && !special);
			SingleHitPulse <= 1'b0 ; // default 
			
			//counter for the starting of the game after enter was pressed
			if (SM_PS != GAME_ST && (enterWasPressed || counter > 0) && onesec) begin
				counter <= counter + 1'b1;
			end

			//counter for the special state
			if(SM_PS == SPECIAL_ST && onesec) begin
				specialCounter <= specialCounter + 1'b1;
			end

			//reseting the counters
			if(SM_PS == GAME_ST) begin
				counter <= 2'b00;
				specialCounter <= 2'b00;
				enterWasPressed <= 1'b0;
			end

			//craeting a single pulse in a frame
			if(startOfFrame) begin
				flag <= 1'b0 ; // reset for next time 
			end
			
			if (playerReq  && (flag == 1'b0)) begin 
				flag	<= 1'b1; // to enter only once 
				SingleHitPulse <= 1'b1 ; 
			end 
	end 
	
end

always_comb 
begin 
		SM_NS = SM_PS;
		game_resetN = 1;
		losingSeq = 0;
		winningSeq = 0;
		gameSeq = 0;
		special = 0;

	case(SM_PS)
		START_ST: begin //initial state
			if(counter == 2'b11) begin
				game_resetN = 1'b0;
				SM_NS = GAME_ST;
			end
		end
		GAME_ST: begin //game state
			gameSeq = 1;
			if(zero_fuel || truckCollision) begin //if fuel is zero or there is a collision with truck then player loses
				SM_NS = LOSE_ST;
			end
			else if (specialCollision) begin //if there is a collision with special then player goes to special state
				SM_NS = SPECIAL_ST;
			end
			else if (win) begin //if player won then player goes to winning state
				SM_NS = WIN_ST;
			end
		end
		SPECIAL_ST: begin //special state
			special = 1;
			gameSeq = 1;
			if(zero_fuel) begin //if fuel is zero then player loses
				SM_NS = LOSE_ST;
			end
			else if (win) begin //if player won then player goes to winning state
				SM_NS = WIN_ST;
			end
			else if (specialCounter == 4'h9) begin //if 9 seconds passed then player goes to game state
				SM_NS = GAME_ST;
			end
		end
		WIN_ST: begin
			winningSeq = 1;
			if(counter == 2'b11) begin //if 2 seconds passed after enter then player goes to game state and the game resets
				game_resetN = 1'b0;
				SM_NS = GAME_ST;
			end
		end
		LOSE_ST: begin
			losingSeq = 1;
			if(counter == 2'b11) begin //if 2 seconds passed after enter then player goes to game state and the game resets
				game_resetN = 1'b0;
				SM_NS = GAME_ST;
			end
		end
	endcase
end	

endmodule