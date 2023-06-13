// HartsMatrixBitMap File 
// A two level bitmap. dosplaying harts on the screen Apr  2023  
// (c) Technion IIT, Department of Electrical Engineering 2023 



module	roadBitMap	(	
					input	logic	clk, 
					input logic slowclk, // slow clock for the speed of the road
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 
					input logic [3:0]speed, // speed of the road

					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout  //rgb value from the bitmap 
 ) ;
 
localparam logic [7:0] TRANSPARENT_ENCODING = 8'hff ;// RGB value in the bitmap representing a transparent pixel 

logic [3:0] counter; // counter for the speed of the road
logic [0:15] [0:31] [7:0] roadBitMap = 
{
{8'h78, 8'h78, 8'h78, 8'h78, 8'hb6, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hdf, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hdf, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hb6, 8'hfd, 8'hfd, 8'h1f},
{8'h78, 8'h78, 8'h78, 8'h78, 8'hb6, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hdf, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hdf, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hb6, 8'hfd, 8'hfd, 8'h1f},
{8'h78, 8'he4, 8'h78, 8'h78, 8'hb6, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hb6, 8'hfd, 8'hfd, 8'h1f},
{8'he4, 8'he4, 8'he4, 8'h78, 8'hb6, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hdf, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hdf, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hb6, 8'hfd, 8'hfd, 8'h1f},
{8'hfc, 8'hfc, 8'hfc, 8'h78, 8'hb6, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hb6, 8'hfd, 8'hfd, 8'h1f},
{8'hfc, 8'h4b, 8'hfc, 8'h78, 8'hb6, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hb6, 8'hfd, 8'hfd, 8'h1f},
{8'hfc, 8'hfc, 8'hfc, 8'h78, 8'hb6, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hdf, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hdf, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hb6, 8'hfd, 8'hfd, 8'h1f},
{8'h78, 8'h78, 8'h78, 8'h78, 8'hb6, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hb6, 8'hfd, 8'hfd, 8'h1f},
{8'h78, 8'h78, 8'h78, 8'h78, 8'hb6, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hdf, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hdf, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hb6, 8'hfd, 8'hfd, 8'h1f},
{8'h78, 8'h78, 8'h78, 8'h78, 8'hb6, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hdf, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hdf, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hb6, 8'hfd, 8'hfd, 8'h1f},
{8'h78, 8'he4, 8'h78, 8'h78, 8'hb6, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hb6, 8'hfd, 8'hfd, 8'h1f},
{8'he4, 8'h4b, 8'he4, 8'h78, 8'hb6, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hb6, 8'hfd, 8'hfd, 8'h1f},
{8'hfc, 8'hfc, 8'hfc, 8'h78, 8'hb6, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hdf, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hdf, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hb6, 8'hfd, 8'hfd, 8'h1f},
{8'hfc, 8'hfc, 8'hfc, 8'h78, 8'hb6, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hb6, 8'hfd, 8'hfd, 8'h1f},
{8'hfc, 8'hfc, 8'hfc, 8'h78, 8'hb6, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hdf, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hdf, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hb6, 8'hfd, 8'hfd, 8'h1f},
{8'h78, 8'h78, 8'h78, 8'h78, 8'hb6, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'h6d, 8'hb6, 8'hfd, 8'hfd, 8'h1f}
};

// pipeline (ff) to get the pixel color from the array 	 

//==----------------------------------------------------------------------------------------------------------------=


always_ff@(posedge clk or negedge resetN)
begin
	
	if(!resetN) begin
		RGBout <=	8'h00;
		counter <= 3'b000;
	end
	else begin
		RGBout <= TRANSPARENT_ENCODING ;
		
		if(slowclk) begin //increment counter every slowclk cycle according to the speed
					counter <= counter + speed;
		end
		
		if(InsideRectangle == 1'b1) // initating road movement with counter and printing with offsets
						RGBout <= roadBitMap[(offsetY[7:4])-counter][offsetX[7:3]] ; 
		end
end


//==----------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   
endmodule

