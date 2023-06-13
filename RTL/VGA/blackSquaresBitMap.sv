// System-Verilog 'written by Alex Grinshpun May 2018
// New bitmap dudy February 2021
// (c) Technion IIT, Department of Electrical Engineering 2021 


// This module controls the bitmap of the black square covers in the game.
module	blackSquaresBitMap	(	
					input	  logic	clk,
					input	  logic	resetN,
					input	  logic	[3:0]InsideRectangle,// 4 bits for 4 rectangles
					input	  logic gameReq,// input that the game is running
					input     logic winReq,// input that the game is won
					input     logic loseReq,// input that the game is lost	

					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout //output the color of the pixel 
 ) ;

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// RGB value in the bitmap representing a transparent pixel 

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'hff;

	end
	else begin
		RGBout <= TRANSPARENT_ENCODING;// default value is transparent
		
		if (gameReq) begin
			RGBout <= TRANSPARENT_ENCODING;	//while the game is running the bitmap is transparent
		end
		
		else if (winReq) begin // if the game is won, the bitmap is black except for the winning rectangle
			for(int i=0; i<4; i=i+1) begin
				if (InsideRectangle[i] && i != 1) begin
					RGBout <= 8'h00;
				end
			end
		end
		else if (loseReq) begin // if the game is lost, the bitmap is black except for the losing rectangle
			for(int i=0; i<4; i=i+1) begin
				if (InsideRectangle[i] && i != 2) begin
					RGBout <=	8'h00;
				end
			end
		end

		else begin // if the game is not running, the bitmap is black except for the rectangle that is currently being played
			for(int i=0; i<4; i=i+1) begin 
				if (InsideRectangle[i] && i != 3) begin
					RGBout <=	8'h00;
				end
			end
		end
	end	
end

//////////--------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   

endmodule