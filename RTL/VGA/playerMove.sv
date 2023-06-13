// (c) Technion IIT, Department of Electrical Engineering 2023 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updated Eyal Lev April 2023
// updated to state machine Dudy March 2023 

module	playerMove	(	
					
					input 	logic 	onesec, // 1 sec pulse
					input	logic	clk,
					input	logic	resetN,
					input	logic	startOfFrame,  // short pulse every start of frame 30Hz  
					input	logic	move_r_key, // right key pressed
				   	input 	logic 	move_l_key, // left key pressed
					input 	logic 	collision,  // collision of player with object

					output	 logic signed 	[10:0]	topLeftX, // output the top left corner 
					output	 logic signed	[10:0]	topLeftY,  // can be negative , if the object is partliy outside 
					output 	 logic  totalCollision // output collision flag
); 


parameter int INITIAL_X = 303;
parameter int INITIAL_Y = 400;
parameter int rightoffset = 9;
parameter int leftoffset = 7;
parameter int X_SPEED = 2;
parameter int INITIAL_Y_SPEED = 0;


// movement limits 
const int   OBJECT_WIDTH_X = 32;
const int   OBJECT_HIGHT_Y = 32;
const int   border_l = 215;
const int   border_r = 399;
const int	SafetyMargin =	2;

enum  logic [2:0] {IDLE_ST, // initial state
					MOVE_ST, // moving no colision 
					WAIT_FOR_END_OF_COLLISION 
					}  SM_PS, 
						SM_NS ;

 logic [1:0] counter; // counter for 2 sec wait after collision

 int Xspeed_PS,  Xspeed_NS  ; // x speed    
 int Xposition_PS, Xposition_NS ; //position   
 int Yposition_PS, Yposition_NS ; 


 //---------
 
 always_ff @(posedge clk or negedge resetN)
		begin : fsm_sync_proc
			if (resetN == 1'b0) begin //beginning values
				SM_PS <= IDLE_ST ; 
				Xspeed_PS <= 0   ; 
				Xposition_PS <= INITIAL_X  ; 
				Yposition_PS <= INITIAL_Y  ; 
				counter <= 0;
			
			end 	
			else begin 
				SM_PS  <= SM_NS ;
				Xspeed_PS   <= Xspeed_NS    ; 
				Xposition_PS <=  Xposition_NS    ; 
				Yposition_PS <=  Yposition_NS    ; 
				
				if((SM_PS == WAIT_FOR_END_OF_COLLISION) && onesec) // 2 sec wait after collision
					counter <= counter + 1'b1;
				if(SM_PS == IDLE_ST) // reset counter
						counter <= 0;
				
			end ; 
		end // end fsm_sync

 
 ///-----------------
 
 
always_comb 
begin
	// set default values 
		 SM_NS = SM_PS  ;
		 Xspeed_NS  = 0 ; 
		 Xposition_NS =  Xposition_PS ; 
		 Yposition_NS = Yposition_PS  ; 
	 	 totalCollision = 1'b0;

	case(SM_PS)
//------------
		IDLE_ST: begin // initial state, initial values
//------------
		 Xspeed_NS  = 1'b0 ;  
		 Xposition_NS = INITIAL_X; 
		 Yposition_NS = INITIAL_Y; 

		 if (startOfFrame) 
				SM_NS = MOVE_ST ;
	end
	
//------------
		MOVE_ST:  begin     // moving no colision 
//------------
			if (collision) begin //in case of collision wait for 2 sec
					SM_NS = WAIT_FOR_END_OF_COLLISION;
					totalCollision = 1'b1; // collision flag
			end
			
			else if (move_l_key && move_r_key) begin // if both keys pressed, do nothing
						Xposition_NS = Xposition_PS;
			end
			
			else if (move_r_key && startOfFrame) begin // if right key pressed, move right
						if(Xposition_PS < (border_r - SafetyMargin - OBJECT_WIDTH_X + rightoffset)) begin // check if not out of bounds
						Xposition_NS = Xposition_PS + X_SPEED ;
						end
						
						else begin // if out of bounds, wait for 2 sec because of collision
						SM_NS = WAIT_FOR_END_OF_COLLISION;
						totalCollision = 1'b1;
						end
			end
						
			else if (move_l_key && startOfFrame)	begin  // if left key pressed, move left
					if(Xposition_PS > (border_l + SafetyMargin - leftoffset)) begin // check if not out of bounds
						Xposition_NS = Xposition_PS - X_SPEED ;
					end
					
					else begin // if out of bounds, wait for 2 sec because of collision
						SM_NS = WAIT_FOR_END_OF_COLLISION;
						totalCollision = 1'b1;
					end
			end
			
			else begin // if no key pressed, do nothing
						Xposition_NS = Xposition_PS;
			end
		end 			
//--------------------
		WAIT_FOR_END_OF_COLLISION: begin  // change speed already done once, now wait for EOF 
//--------------------
			totalCollision = 1'b1; // collision flag				
			if (startOfFrame && counter == 2'b11) begin // wait for 2 sec and then go back to initial state
				SM_NS = IDLE_ST ;
				totalCollision = 0;
			end
			
		end 

//--------------------
		
endcase  // case 
end		
  
assign 	topLeftX = Xposition_PS;  
assign 	topLeftY = Yposition_PS;    

	

endmodule	
//---------------
 
