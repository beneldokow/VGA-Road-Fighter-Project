
// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018

//-- Eyal Lev 31 Jan 2021

//		--------	Clock Input	
module objects_mux(
 	
					input		logic	clk,
					input		logic	resetN,
					input    logic blackReq, //black squares request
					input 	logic [7:0] blackRGB,
					input		logic	playerRequest, //player bitmap request
					input		logic	[7:0] playerRGB, 
					input 	logic roadcarsRequest, //roadcars bitmap request
					input		logic [7:0] roadcarsRGB,
					input   	logic roadRequest, //road bitmap request
					input		logic	[7:0] roadRGB,   
					input		logic	valuesRequest, //values bitmap request
					input		logic	[7:0] valuesRGB, 
					input		logic	[7:0] RGB_MIF, //BG MIF bitmap request
			  
				   	output		logic	[7:0] RGBOut
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut	<= 8'b0;
	end
	
	else begin
		if(blackReq)
			RGBOut <= blackRGB; //first priority
		else if (playerRequest == 1'b1 )
			RGBOut <= playerRGB;  //second priority
		else if(roadcarsRequest)
			RGBOut <= roadcarsRGB; //third priority
		else if (roadRequest == 1'b1)
			RGBOut <= roadRGB; //fourth priority
		else if (valuesRequest == 1'b1)
			RGBOut <= valuesRGB; //fifth priority
		else 
			RGBOut <= RGB_MIF ;// last priority	
	end 
end

endmodule


