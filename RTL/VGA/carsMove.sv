// (c) Technion IIT, Department of Electrical Engineering 2023 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updated Eyal Lev April 2023
// updated to state machine Dudy March 2023 


module	carsMove	(	
					
					input logic onesec, // 1 sec pulse
					input logic	clk,
					input logic	resetN,
					input logic	startOfFrame,  // short pulse every start of frame 30Hz 
					input logic [3:0] playerspeed, //players speed
					input logic [10:0] carXinitial,// initial position of the car
					input logic releasecar, //1 when the car should be released
					input logic [10:0] redXfinal,// final position of the red car

					output    logic ready, // 1 when the car is ready to be released
					output	 logic signed 	[10:0]	topLeftX, // output the top left corner 
					output	 logic signed	[10:0]	topLeftY  // can be negative , if the object is partliy outside  
					
);  

parameter int cartype = 0; // 0 - yellowcar, 1 - redcar, 2 - bluetruck, 3 - stable
const int Yspeed = 3; //y speed of the yellow and red car
const int redXspeed = 1; //x speed of the red car
const int bluetruckSpeed = 3; // y speed of the blue truck
const int stableSpeed = 3;// y speed of the stable object

// movement limits 
const int   OBJECT_HIGHT_Y = 32; // object hight in pixels
const int	y_FRAME_TOP		=	0; // frame limits
const int	y_FRAME_BOTTOM	=	479; 

enum  logic [2:0] {IDLE_ST, // initial state
					MOVE_ST, // moving no colision 
					POSITION_LIMITS_ST //check if inside the frame  
					}  SM_PS, 
						SM_NS ;
						
 const int   yellowcar = 0;
 const int   redcar = 1;
 const int   bluetruck = 2;
 const int   stable = 3;

 const int initialY = -32; // initial y position of the car out of frame
 
 logic movementCounter; // counter for the movement of the car
 logic [1:0] randCounter; // counter for the random movement of the red car

 int Xspeed_PS,  Xspeed_NS  ; // speed    
 int Yspeed_PS,  Yspeed_NS  ; 
 int Xposition_PS, Xposition_NS ; //position   
 int Yposition_PS, Yposition_NS ; 
 int redX; // random x position to be of the red car


 //---------
 
 always_ff @(posedge clk or negedge resetN)
		begin : fsm_sync_proc
			if (resetN == 1'b0) begin 
				SM_PS <= IDLE_ST ; 
				Xspeed_PS <= 0   ; 
				Yspeed_PS <= 0  ; 
				Xposition_PS <= carXinitial  ; 
				Yposition_PS <= initialY  ; 
				randCounter <= 0;
			
			end 	
			else begin 
				SM_PS  <= SM_NS ;
				Xspeed_PS   <=  Xspeed_NS    ; 
				Yspeed_PS  <=   Yspeed_NS  ; 
				Xposition_PS <=  Xposition_NS    ; 
				Yposition_PS <=  Yposition_NS    ; 

				if(onesec) begin
					randCounter <= randCounter + 1'b1; // increment the random counter every second
				end
				
				if (startOfFrame && releasecar && (SM_PS == IDLE_ST))begin // if the car is ready to be released, set the random x position of the red car
					redX <= redXfinal;
				end
				
			end ; 
		end // end fsm_sync

 
 ///-----------------
 
 
always_comb 
begin
	// set default values 
		 SM_NS = SM_PS  ;
		 Xspeed_NS  = Xspeed_PS ; 
		 Yspeed_NS  = Yspeed_PS  ; 
		 Xposition_NS = Xposition_PS ; 
		 Yposition_NS = Yposition_PS  ;
		 ready = 1'b0;

	case(SM_PS)
//------------
		IDLE_ST: begin
//------------
		 if(cartype == yellowcar) begin // setting the speed of the car according to its type
				Yspeed_NS = Yspeed;
		 end
		 else if(cartype == redcar) begin
				Yspeed_NS = Yspeed;
				Xspeed_NS = redXspeed;
		 end
		 else if(cartype == bluetruck) begin
				Yspeed_NS = bluetruckSpeed;
		 end
		 else if(cartype == stable) begin
				Yspeed_NS = stableSpeed;
		 end
		  
		 ready = 1'b1; // the car is ready to be released

		 if (startOfFrame && releasecar)begin // if the car is to be released, set the initial position of the car
				SM_NS = MOVE_ST ;
				Xposition_NS = carXinitial; 
				Yposition_NS = initialY;
		 end
 	
	end
	
//------------
		MOVE_ST:  begin   
//------------
		 
			if (startOfFrame) begin //every frame, move the car according to its speed

					Yposition_NS = Yposition_PS - Yspeed_PS + playerspeed;
					
					if(!randCounter && cartype == redcar) begin // if the random counter is 0, change the x position of the red car
						if(Xposition_PS < redX) begin
							Xposition_NS = Xposition_PS + Xspeed_PS;
						end
						else if(Xposition_PS > redX) begin
							Xposition_NS = Xposition_PS - Xspeed_PS;
						end
						else
							Xposition_NS = Xposition_PS;
					end
					
					SM_NS = POSITION_LIMITS_ST; // check if the car is inside the frame
			end
			 
		end 
//------------------------
		POSITION_LIMITS_ST : begin 
//------------------------
					
				 if (Yposition_PS + OBJECT_HIGHT_Y < y_FRAME_TOP ) // if the car is out of the frame, set the car to idle state
						begin  
								SM_NS = IDLE_ST;
						end  
	
				 else if (Yposition_PS > y_FRAME_BOTTOM) 
						begin  
								SM_NS = IDLE_ST;
						end 
				 else
								SM_NS = MOVE_ST;
		end
		
endcase  
end		

  
assign 	topLeftX = Xposition_PS;
assign 	topLeftY = Yposition_PS;    

	

endmodule	
//---------------
 
