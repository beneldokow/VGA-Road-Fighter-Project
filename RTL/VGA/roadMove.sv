// (c) Technion IIT, Department of Electrical Engineering 2023 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updated Eyal Lev April 2023
// updated to state machine Dudy March 2023 


module	roadMove	(	
 
					input	logic	clk,
					input	logic	resetN,
					input	logic	startOfFrame,  // short pulse every start of frame 30Hz
					input   logic gas_button, // gas button is pressed
					input   logic brake_button, // brake button is pressed
					input   logic turbo, // turbo button is pressed
					input   logic road_collision, // road collision
																
					output  logic [3:0] road_speed
					
);

enum  logic 	  {IDLE_ST, // initial state
						MOVE_ST // moving no colision  //check if inside the frame  
					  }SM_PS, 
						SM_NS ;

// local parameters
localparam int min_speed = 0 ;
localparam int max_speed = 5 ;
localparam int turbo_max_speed = 10; 
 
int speed_ps,speed_ns;


 
 always_ff @(posedge clk or negedge resetN)
		begin : fsm_sync_proc
			if (resetN == 1'b0) begin 
				SM_PS <= IDLE_ST ;
				speed_ps <= 1'b0;
			
			end 	
			else begin 
				SM_PS  <= SM_NS ;
				speed_ps <= speed_ns;
			end ; 
		end // end fsm_sync

 
 ///-----------------
 
 
always_comb 
begin
	// set default values 
		 SM_NS = SM_PS;
		 speed_ns = speed_ps;

	case(SM_PS)
//------------
		IDLE_ST: begin
//------------

		 if (startOfFrame) 
				SM_NS = MOVE_ST ;
	end
	
//------------
		MOVE_ST:  begin     // moving no colision 
//------------
		 if (startOfFrame) begin
				if(road_collision) //if collision then stop
						speed_ns = min_speed;
				
				else if(gas_button && brake_button) //if both pressed then dont do anything
						speed_ns = speed_ps;
				
				else if(gas_button) begin //if gas pressed then increase speed
						if(turbo) begin //if turbo pressed then increase speed with higher limit
							if (speed_ps < turbo_max_speed) //if speed is lower than turbo max speed then increase speed
								speed_ns = speed_ps + 1;
							else //if speed isnt lower than turbo max speed then dont do anything
								speed_ns = speed_ps;
						end
						//if turbo isnt pressed then increase speed with normal limit
						else if(speed_ps > max_speed) //if speed is higher than max speed then decrease speed
								speed_ns = speed_ps - 1;
						else if(speed_ps < max_speed)//if speed is lower than max speed then increase speed
								speed_ns = speed_ps + 1;
					   else //if speed is equal to max speed then dont do anything
								speed_ns = speed_ps;
				end
						
				else if(brake_button && speed_ps > min_speed) begin //if brake pressed then decrease speed faster
						if(speed_ps == 1'b1)
							speed_ns = speed_ps - 1;
						else
							speed_ns = speed_ps - 2;
				end
				
				else if(speed_ps > min_speed) //if brake isnt pressed and gas isnt pressed then decrease speed noramlly
						speed_ns = speed_ps - 1;
				
				else //if speed is equal to min speed then dont do anything
						speed_ns = speed_ps;
						
				
		end
		
		else //if nothing is pressed then dont do anything
				speed_ns = speed_ps; 
	end
	endcase
end	
     
assign   road_speed = speed_ps;

	

endmodule	
//---------------
 
