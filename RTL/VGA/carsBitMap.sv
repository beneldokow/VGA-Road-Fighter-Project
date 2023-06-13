// System-Verilog 'written by Alex Grinshpun May 2018
// New bitmap dudy February 2021
// (c) Technion IIT, Department of Electrical Engineering 2021 



module	CarsBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX1, //offsets of the bitmaps from the left side of the screen of all the objects
					input logic	[10:0] offsetY1,
					input logic	[10:0] offsetX2,
					input logic	[10:0] offsetY2,
					input logic	[10:0] offsetX3,
					input logic	[10:0] offsetY3,
					input logic	[10:0] offsetX4,
					input logic	[10:0] offsetY4,
					input logic [10:0] offsetX5,
					input logic [10:0] offsetY5,
					input logic [10:0] offsetX6,
					input logic [10:0] offsetY6,
					input logic [10:0] offsetX7,
					input logic [10:0] offsetY7,
					input logic [10:0] offsetX8,
					input logic [10:0] offsetY8,
					input logic [10:0] offsetX9,
					input logic [10:0] offsetY9,
					input logic	[8:0]InsideRectangle,//1 if theres input from the object

					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout,  //rgb value from the bitmap 
					output	logic	truckCollision, //output that there was a collision with the truck
					output	logic	fuelCollision, //output that there was a collision with the fuel
					output	logic	specialCollision//output that there was a collision with the special object
);

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hff ;// RGB value in the bitmap representing a transparent pixel 

logic[0:31][0:31][7:0] yellow_car = {
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfe,8'hf9,8'hd8,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hfe,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfe,8'hf9,8'hf8,8'hb0,8'h6c,8'h64,8'h24,8'h64,8'h24,8'h64,8'h8c,8'hd9,8'hfc,8'hfd,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf8,8'hff,8'hff,8'hfd,8'hfc,8'hfd,8'h91,8'hfd,8'h91,8'hfd,8'hfc,8'hfe,8'hff,8'hfe,8'hf8,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf8,8'hfc,8'hfc,8'hfc,8'hfc,8'hf8,8'h6c,8'hf8,8'h6c,8'hf8,8'hfc,8'hfc,8'hfc,8'hfc,8'hf8,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'hf8,8'hfc,8'hfc,8'hfc,8'hf8,8'hf8,8'h6c,8'hf8,8'h6c,8'hf8,8'hf8,8'hfc,8'hfc,8'hfc,8'hf8,8'h6d,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'hf8,8'hfc,8'hfc,8'hf8,8'hf8,8'hf8,8'h6c,8'hf8,8'h6d,8'hf8,8'hf8,8'hf8,8'hfc,8'hfc,8'hf8,8'h20,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'hf8,8'hfc,8'hf8,8'hf8,8'hf8,8'hf8,8'h6c,8'hf8,8'h6d,8'hf8,8'hf8,8'hf8,8'hfc,8'hfc,8'hf8,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'hf8,8'hfc,8'hf8,8'h6c,8'h24,8'h24,8'h6d,8'h6c,8'h24,8'h24,8'h24,8'hd4,8'hfc,8'hfc,8'hf8,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'hf8,8'hfc,8'h24,8'h24,8'h24,8'h6d,8'h6d,8'h24,8'h24,8'h24,8'h24,8'h64,8'hb4,8'hfc,8'hf8,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf8,8'h24,8'h24,8'h24,8'h6d,8'h6d,8'h20,8'h24,8'h24,8'h24,8'h6d,8'h6d,8'h24,8'h6c,8'hf8,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf8,8'h24,8'h65,8'h6d,8'h24,8'h24,8'h20,8'h24,8'h24,8'h6d,8'h6d,8'h24,8'h24,8'h6c,8'hf8,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf8,8'hf8,8'hf8,8'hfc,8'hfd,8'hfd,8'h8d,8'hfd,8'h91,8'hfd,8'hfd,8'hf8,8'hf8,8'hf8,8'hf8,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf8,8'h64,8'hfd,8'hfc,8'hfc,8'hfd,8'h6c,8'hfd,8'h6c,8'hfd,8'hfc,8'hfc,8'hd4,8'h8c,8'hf8,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf8,8'h24,8'hfd,8'hfc,8'hfc,8'hfd,8'h6c,8'hfd,8'h6c,8'hfd,8'hfc,8'hfc,8'hb4,8'h6c,8'hf8,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf8,8'h24,8'hfd,8'hfc,8'hfc,8'hfd,8'h6c,8'hfd,8'h6c,8'hfd,8'hfc,8'hfc,8'hb4,8'h6c,8'hf8,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf8,8'h24,8'hfd,8'hfc,8'hfc,8'hfd,8'h6c,8'hfd,8'h6c,8'hfd,8'hfc,8'hfc,8'hb4,8'h6c,8'hf8,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf8,8'h24,8'hfd,8'hfc,8'hfc,8'hfd,8'h6c,8'hfd,8'h6c,8'hfd,8'hfc,8'hfc,8'hb4,8'h6c,8'hf8,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf8,8'h24,8'hfd,8'hfc,8'hfc,8'hfd,8'h6c,8'hfd,8'h6c,8'hfd,8'hfc,8'hfc,8'hd4,8'h6c,8'hf8,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6c,8'hf8,8'hf8,8'hfc,8'hfc,8'hf8,8'hf8,8'h6c,8'hf8,8'h6c,8'hf8,8'hf8,8'hfc,8'hfc,8'hf8,8'hf8,8'h6d,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'hf8,8'hf8,8'hf8,8'h6c,8'h24,8'h24,8'h24,8'h20,8'h20,8'h24,8'h24,8'hd4,8'hf8,8'hf8,8'hf8,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'hfd,8'hd8,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h20,8'h24,8'h24,8'h8c,8'hf8,8'hfd,8'h20,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'hfd,8'hf4,8'hd4,8'hf8,8'hf4,8'hd4,8'h24,8'hd4,8'h64,8'hd4,8'hf8,8'hf8,8'hf4,8'hf8,8'hfd,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'hfd,8'hd4,8'hd4,8'hd4,8'hd4,8'hb4,8'h24,8'hd4,8'h24,8'hd4,8'hd4,8'hd4,8'hd4,8'hd8,8'hfd,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf8,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hf8,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf8,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hf8,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf4,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hf4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}};


logic [0:31][0:31][7:0] blue_car =  {
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h73,8'h73,8'h73,8'h33,8'h73,8'h33,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hdf,8'hdf,8'h2e,8'h2e,8'h0e,8'h0e,8'h2e,8'h0e,8'hdf,8'hdf,8'hdf,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hbb,8'h2e,8'h0f,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h0f,8'h0f,8'h2e,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h13,8'h9f,8'h9f,8'h3b,8'h13,8'h9f,8'h9f,8'h33,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfc,8'h32,8'h33,8'h13,8'h33,8'h9f,8'h9f,8'h3b,8'h13,8'h9f,8'h9f,8'h33,8'h13,8'h13,8'h33,8'hfc,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'h0f,8'h33,8'h33,8'h33,8'h0f,8'h9f,8'h9f,8'h37,8'h0f,8'h9f,8'h9f,8'h0f,8'h33,8'h33,8'h33,8'h0f,8'h6d,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h20,8'h0f,8'h33,8'h13,8'h0f,8'h0f,8'h9f,8'h9f,8'h37,8'h0f,8'h9f,8'h9f,8'h0f,8'h0f,8'h0f,8'h33,8'h0f,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'h0f,8'h33,8'h13,8'h0f,8'h0f,8'h9f,8'h9f,8'h37,8'h0f,8'h9f,8'h9f,8'h0f,8'h0f,8'h0f,8'h33,8'h0f,8'h20,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'h0f,8'h33,8'h13,8'h0f,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h24,8'h2f,8'h0f,8'h13,8'h0f,8'h20,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h0f,8'h33,8'h2e,8'h04,8'h24,8'h6d,8'h6d,8'h24,8'h20,8'h00,8'h00,8'h20,8'h6d,8'h2d,8'h13,8'h0f,8'h20,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h0f,8'h33,8'h2e,8'h20,8'h6d,8'h6d,8'h24,8'h24,8'h20,8'hb6,8'h00,8'h2c,8'h6d,8'h2d,8'h13,8'h0f,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h0f,8'h05,8'h05,8'h33,8'h2f,8'hbf,8'hbf,8'h77,8'h0e,8'h9f,8'h9f,8'h2e,8'h33,8'h33,8'h00,8'h0f,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h0f,8'h05,8'h0d,8'h33,8'h2f,8'h9f,8'h9f,8'h37,8'h0e,8'h9f,8'h7f,8'h2f,8'h33,8'h33,8'h04,8'h0f,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h0f,8'h33,8'h33,8'h33,8'h2f,8'h9f,8'h9f,8'h37,8'h0f,8'h9f,8'h9f,8'h2f,8'h2f,8'h2f,8'h33,8'h0f,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h0f,8'h32,8'h2f,8'h2f,8'h2f,8'h9f,8'h9f,8'h37,8'h0f,8'h9f,8'h9f,8'h2f,8'h2f,8'h2f,8'h32,8'h0f,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h0f,8'h05,8'h25,8'h2f,8'h2f,8'h9f,8'h9f,8'h37,8'h0f,8'h9f,8'h9f,8'h2f,8'h2f,8'h2f,8'h04,8'h0f,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h0f,8'h05,8'h05,8'h2f,8'h2f,8'h9f,8'h9f,8'h37,8'h0f,8'h9f,8'h9f,8'h2f,8'h2f,8'h2f,8'h04,8'h0f,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h0f,8'h05,8'h05,8'h2f,8'h2f,8'h9f,8'h9f,8'h37,8'h0f,8'h9f,8'h9f,8'h2f,8'h2f,8'h2f,8'h04,8'h0f,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h0f,8'h05,8'h05,8'h07,8'h2f,8'h9f,8'h9f,8'h37,8'h0f,8'h9f,8'h9f,8'h2f,8'h07,8'h06,8'h04,8'h0f,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'h0f,8'h07,8'h07,8'h07,8'h07,8'h1b,8'h1b,8'h13,8'h07,8'h1b,8'h1b,8'h07,8'h07,8'h07,8'h07,8'h0f,8'h6d,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'h0f,8'h07,8'h07,8'h07,8'h07,8'h1b,8'h1b,8'h13,8'h07,8'h1b,8'h1b,8'h07,8'h07,8'h07,8'h06,8'h0f,8'h20,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h20,8'h37,8'h06,8'h06,8'h06,8'h06,8'h1b,8'h1b,8'h13,8'h06,8'h1b,8'h1b,8'h06,8'h06,8'h06,8'h06,8'h37,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h37,8'h06,8'h06,8'h06,8'h06,8'h17,8'h17,8'h0e,8'h06,8'h17,8'h17,8'h06,8'h06,8'h06,8'h06,8'h37,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h20,8'h37,8'h06,8'h06,8'h06,8'h06,8'h2f,8'h2f,8'h06,8'h02,8'h2f,8'h2f,8'h06,8'h06,8'h06,8'h06,8'h37,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h0f,8'h37,8'h37,8'h37,8'h37,8'h9f,8'h9f,8'h7b,8'h37,8'h9f,8'h9f,8'h37,8'h37,8'h37,8'h37,8'h0f,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h06,8'h2f,8'h2f,8'h0f,8'h0f,8'h9f,8'h9f,8'h37,8'h0f,8'h9f,8'h9f,8'h0f,8'h2f,8'h2f,8'h2f,8'h06,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hdb,8'h06,8'h07,8'h07,8'h07,8'h3b,8'h3b,8'h12,8'h06,8'h3b,8'h3b,8'h07,8'h07,8'h07,8'h07,8'hdb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6e,8'h2e,8'h2e,8'h06,8'h7b,8'h7b,8'h32,8'h2e,8'h7b,8'h7b,8'h06,8'h6e,8'h2e,8'h6e,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}};

logic [0:31][0:31][7:0] red_car = {
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hc0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he5,8'he5,8'he5,8'h60,8'h60,8'h60,8'h60,8'h60,8'h60,8'hc5,8'he5,8'he5,8'he5,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hcd,8'hf1,8'hfa,8'hfa,8'hf6,8'hd5,8'hd9,8'hd5,8'hc4,8'hd9,8'hd9,8'hfa,8'hfa,8'hfa,8'hfa,8'hed,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hc4,8'hcc,8'hff,8'hff,8'hff,8'hfd,8'hfd,8'hfd,8'he4,8'hfd,8'hfd,8'hfe,8'hff,8'hff,8'hff,8'he4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfd,8'hf9,8'he4,8'he4,8'he4,8'hfd,8'hfd,8'hfd,8'he0,8'hfc,8'hfd,8'hec,8'he4,8'he4,8'he4,8'hfd,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'hc4,8'he0,8'he4,8'he4,8'he0,8'hfd,8'hfd,8'hfd,8'he0,8'hfc,8'hfd,8'he4,8'he0,8'he4,8'he4,8'he0,8'h85,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'he4,8'he0,8'he4,8'he0,8'he0,8'hfd,8'hfd,8'hfd,8'he0,8'hfd,8'hfd,8'he4,8'he0,8'he0,8'he4,8'he0,8'h20,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h20,8'he4,8'he0,8'he4,8'he0,8'he0,8'hfd,8'hfd,8'hfd,8'he0,8'hfd,8'hfd,8'he4,8'he0,8'he0,8'he4,8'he0,8'h60,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h20,8'he4,8'he0,8'he4,8'he0,8'h24,8'h24,8'h24,8'h6d,8'h6d,8'h24,8'h24,8'h24,8'h60,8'he0,8'he4,8'he0,8'h60,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h20,8'he4,8'he0,8'hed,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h24,8'h24,8'h24,8'h6d,8'he4,8'he0,8'h20,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hc0,8'hc4,8'h20,8'h24,8'h6d,8'h6d,8'h24,8'h24,8'h24,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h20,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hc0,8'hc0,8'h24,8'h6d,8'h6d,8'h24,8'h24,8'h24,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hc0,8'hc0,8'h20,8'hc0,8'he4,8'hfd,8'hfd,8'hfd,8'he4,8'hfd,8'hfd,8'hec,8'he4,8'hc0,8'h24,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hc0,8'he0,8'hc0,8'he4,8'he4,8'hfd,8'hfd,8'hfd,8'he4,8'hfd,8'hfd,8'he4,8'he4,8'he4,8'hc0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hc0,8'he0,8'h80,8'he4,8'he4,8'hfd,8'hfd,8'hfd,8'he4,8'hfd,8'hfd,8'he4,8'he4,8'he4,8'h80,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hc0,8'hc0,8'h20,8'he4,8'he4,8'hfd,8'hfd,8'hfd,8'he4,8'hfd,8'hfd,8'he4,8'he4,8'he4,8'h24,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hc0,8'hc0,8'h20,8'he4,8'he4,8'hfd,8'hfd,8'hfd,8'he4,8'hfd,8'hfd,8'he4,8'he4,8'he4,8'h24,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hc0,8'hc0,8'h20,8'he4,8'he4,8'hfd,8'hfd,8'hfd,8'he4,8'hfd,8'hfc,8'he4,8'he4,8'he4,8'h24,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hc0,8'hc4,8'h20,8'he4,8'he4,8'hfd,8'hfc,8'hfd,8'he4,8'hfc,8'hfc,8'hec,8'he4,8'he4,8'h24,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'he4,8'he0,8'he0,8'he4,8'he0,8'hf4,8'hf4,8'hf4,8'he0,8'hf4,8'hf4,8'hc0,8'he0,8'he4,8'he0,8'he0,8'h85,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h20,8'he4,8'he0,8'he0,8'he0,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h60,8'he0,8'he0,8'he0,8'h20,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h20,8'hf5,8'hf1,8'hc0,8'he0,8'he0,8'h20,8'h24,8'h24,8'h24,8'h24,8'h24,8'hc0,8'he0,8'he0,8'hc0,8'hf1,8'h20,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h20,8'hf5,8'hf1,8'hc0,8'hc0,8'hc0,8'hf4,8'hf4,8'hf4,8'hc0,8'hf4,8'hf4,8'hc0,8'hc0,8'hc0,8'hc0,8'hf1,8'h20,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h20,8'hf5,8'hf1,8'ha0,8'ha0,8'ha0,8'hf4,8'hf4,8'hf4,8'ha0,8'hf4,8'hf4,8'ha0,8'ha0,8'ha0,8'ha0,8'hf1,8'h20,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hc0,8'he4,8'hf1,8'hf1,8'hf1,8'hfd,8'hfd,8'hfd,8'hf1,8'hfd,8'hfd,8'hf5,8'hf1,8'hf1,8'hf1,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'ha0,8'hc0,8'he4,8'he4,8'he4,8'hfd,8'hfd,8'hfd,8'he4,8'hfd,8'hfd,8'hf1,8'hed,8'he4,8'he4,8'hc0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'ha0,8'hc0,8'he0,8'he0,8'he0,8'hf8,8'hf8,8'hf8,8'he0,8'hf8,8'hf8,8'hc4,8'he0,8'he0,8'he0,8'hc0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h84,8'ha4,8'ha0,8'ha4,8'ha0,8'hf9,8'hf8,8'hf9,8'ha4,8'hf8,8'hf8,8'ha4,8'ha0,8'ha0,8'ha4,8'ha0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'h6d,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}};

logic [0:31][0:31][7:0] pink_car = {
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hee,8'hee,8'hee,8'hee,8'hce,8'hce,8'hce,8'hce,8'hee,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf7,8'hd2,8'hff,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'hff,8'hee,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hd2,8'hfb,8'hff,8'hff,8'hd2,8'hdf,8'hdf,8'hf7,8'hdf,8'hdf,8'hf2,8'hff,8'hff,8'hee,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfd,8'hfe,8'hff,8'hee,8'hf3,8'hdf,8'hdf,8'hf7,8'hdf,8'hdf,8'hf3,8'hee,8'hff,8'hfd,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h91,8'hf5,8'hf6,8'hf7,8'hf3,8'hf3,8'hdf,8'hdf,8'hf7,8'hdf,8'hdf,8'hf3,8'hf3,8'hfb,8'hf1,8'hb1,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'hf2,8'hf3,8'hf3,8'hf3,8'hf3,8'hdf,8'hdf,8'hf7,8'hdf,8'hdf,8'hf3,8'hf3,8'hf7,8'hee,8'h64,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h20,8'hee,8'hf3,8'hf3,8'hf3,8'hf3,8'hdf,8'hdf,8'hf7,8'hdf,8'hdf,8'hf3,8'hf3,8'hf7,8'hee,8'h20,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf2,8'hf3,8'hf3,8'hf3,8'hd2,8'hdf,8'hdf,8'hf6,8'hdf,8'hdf,8'hf2,8'hf3,8'hf7,8'hee,8'h20,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf3,8'hf3,8'hf7,8'hd2,8'h24,8'h24,8'h6d,8'h6d,8'h24,8'h24,8'h24,8'hf2,8'hf7,8'hee,8'h20,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf2,8'hf3,8'hf6,8'h24,8'h24,8'h6d,8'h6d,8'h24,8'h24,8'h24,8'h24,8'h6d,8'hf7,8'hee,8'h20,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf2,8'ha5,8'h24,8'h24,8'h6d,8'h6d,8'h24,8'h24,8'h24,8'h24,8'h6d,8'h6d,8'h24,8'hee,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf2,8'hee,8'hd2,8'h6d,8'h6d,8'h24,8'h24,8'h24,8'h24,8'h6d,8'h6d,8'h24,8'hee,8'hee,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf2,8'ha5,8'h65,8'hee,8'hf7,8'hdf,8'hdf,8'hf7,8'hdf,8'hdf,8'hf7,8'hee,8'h24,8'hee,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf2,8'h85,8'h65,8'hee,8'hf7,8'hdf,8'hdf,8'hf7,8'hdf,8'hdf,8'hf7,8'hee,8'h24,8'hee,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf2,8'h85,8'h65,8'hee,8'hf7,8'hdf,8'hdf,8'hf7,8'hdf,8'hdf,8'hf7,8'hee,8'h24,8'hee,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf2,8'h85,8'h65,8'hee,8'hf7,8'hdf,8'hdf,8'hf7,8'hdf,8'hdf,8'hf7,8'hee,8'h24,8'hee,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf2,8'h85,8'h65,8'hf7,8'hf7,8'hdf,8'hdf,8'hf7,8'hdf,8'hdf,8'hf7,8'hf3,8'h24,8'hee,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf2,8'hee,8'hee,8'hf7,8'hf7,8'hdf,8'hdf,8'hf3,8'hdf,8'hdf,8'hf7,8'hf7,8'hee,8'hee,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'hee,8'hee,8'hee,8'hf3,8'hee,8'hdf,8'hdf,8'hee,8'hdf,8'hdf,8'hee,8'hf7,8'hee,8'hee,8'h8d,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf2,8'hee,8'hee,8'hee,8'hee,8'hdf,8'hdf,8'hee,8'hdf,8'hdf,8'hee,8'hee,8'hee,8'hee,8'h20,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h20,8'hf2,8'hee,8'hee,8'hee,8'hee,8'hdf,8'hdf,8'hee,8'hdf,8'hdf,8'hee,8'hee,8'hce,8'hee,8'h20,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h20,8'hf2,8'hee,8'hce,8'hce,8'hce,8'hdf,8'hdf,8'hce,8'hdf,8'hdf,8'hce,8'hce,8'hce,8'hee,8'h20,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h20,8'h20,8'h85,8'hce,8'hce,8'hce,8'hdf,8'hdf,8'hce,8'hdf,8'hdf,8'hce,8'hce,8'hce,8'h20,8'h20,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hce,8'hfb,8'hfb,8'hfb,8'hfb,8'hfb,8'hdf,8'hdf,8'hfb,8'hdf,8'hdf,8'hfb,8'hfb,8'hfb,8'hfb,8'hce,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hce,8'hfb,8'hf7,8'hf7,8'hf7,8'hf7,8'hf7,8'hdf,8'hdf,8'hf7,8'hdf,8'hdf,8'hf7,8'hf7,8'hf7,8'hf7,8'hfb,8'hce,8'hd6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hce,8'hf7,8'hf7,8'hf7,8'hf7,8'hf7,8'hf7,8'hdf,8'hdf,8'hf7,8'hdf,8'hdf,8'hf7,8'hf7,8'hf7,8'hf7,8'hf7,8'hce,8'hd6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hce,8'hf2,8'hf3,8'hf2,8'hf2,8'hf2,8'hf2,8'hdf,8'hdf,8'hf2,8'hdf,8'hdf,8'hf2,8'hf2,8'hf2,8'hf3,8'hf2,8'hce,8'hd6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hd6,8'hf6,8'hf2,8'hf6,8'hf2,8'hf6,8'hd6,8'hdf,8'hdf,8'hd6,8'hdf,8'hdf,8'hd6,8'hf6,8'hd2,8'hf2,8'hf2,8'hf2,8'hfb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}};

logic [0:31][0:31][7:0] gas_tank =  {
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h0f,8'h0e,8'h0e,8'h0e,8'h0e,8'h0e,8'h0e,8'h0e,8'h0e,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h0e,8'h0e,8'h0e,8'h0f,8'h13,8'h13,8'h13,8'h13,8'h13,8'h13,8'h0e,8'h0f,8'h0f,8'hf9,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h0e,8'h0f,8'h13,8'h13,8'h13,8'h13,8'h13,8'h13,8'h13,8'h13,8'h13,8'h13,8'h13,8'h13,8'h0e,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h76,8'h0f,8'h13,8'h13,8'h13,8'h13,8'h13,8'h13,8'h13,8'h13,8'h13,8'h13,8'h0f,8'h13,8'h0f,8'h0e,8'h0e,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h0f,8'h0e,8'h13,8'h13,8'h13,8'h13,8'h0f,8'h13,8'h13,8'h13,8'h13,8'h13,8'h13,8'h13,8'h13,8'h0f,8'h0e,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h0f,8'h0f,8'h13,8'h0f,8'h13,8'h13,8'h13,8'h13,8'h13,8'h13,8'h13,8'h13,8'h13,8'h13,8'h13,8'h13,8'h0e,8'h0e,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h0e,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h92,8'h92,8'h6d,8'h25,8'h0e,8'h0e,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h13,8'h13,8'h2e,8'h25,8'h2e,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h92,8'h92,8'h92,8'h92,8'h0e,8'h0e,8'h13,8'h13,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h25,8'h0f,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h92,8'h92,8'h92,8'h2e,8'h24,8'h0e,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h25,8'h0e,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h92,8'h92,8'h92,8'h92,8'h0f,8'h25,8'h0e,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h25,8'h25,8'h2e,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h92,8'h92,8'h92,8'h92,8'h92,8'h0e,8'h25,8'h0e,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h25,8'h25,8'h0e,8'h13,8'h13,8'h13,8'h0f,8'h13,8'h0f,8'h13,8'h13,8'h13,8'h13,8'h13,8'h0e,8'h25,8'h25,8'h0e,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h0e,8'h0e,8'h0f,8'h0f,8'h0f,8'h13,8'h0e,8'h13,8'h0e,8'h13,8'h0f,8'h13,8'h13,8'h13,8'h0e,8'h05,8'h25,8'h0e,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'h6d,8'h71,8'h71,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hba,8'h71,8'h71,8'h71,8'h6d,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h6d,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hba,8'h71,8'h71,8'h71,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hba,8'h71,8'h71,8'h71,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hba,8'h71,8'h71,8'h71,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h71,8'h71,8'h6d,8'h71,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hba,8'h71,8'h71,8'h71,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hba,8'h71,8'h71,8'h71,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hba,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hba,8'h71,8'h71,8'h71,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hba,8'h71,8'h71,8'h71,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hba,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hba,8'h71,8'h71,8'h71,8'h92,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'hba,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hba,8'h71,8'h71,8'h71,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'hba,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hba,8'h71,8'h71,8'h71,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hba,8'h71,8'h71,8'h71,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'hba,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hba,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hba,8'h6d,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'hba,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf5,8'hf5,8'hf5,8'hff,8'h25,8'h25,8'h25,8'h25,8'h25,8'h25,8'h25,8'hff,8'hff,8'hf5,8'hf5,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}};

// pipeline (ff) to get the pixel color from the array 	 

//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'hff;
		truckCollision <= 1'b0;
		specialCollision <= 1'b0;
		fuelCollision <= 1'b0;
	end

	else begin
		RGBout <= TRANSPARENT_ENCODING ; // default  
		truckCollision <= 1'b0;
		specialCollision <= 1'b0;
		fuelCollision <= 1'b0;


		// check if a car is inside the frame and if so, get the pixel color from the array
		if (InsideRectangle[0] == 1'b1) 
			RGBout <= yellow_car[offsetY1][offsetX1];
		else if (InsideRectangle[1] == 1'b1) 
			RGBout <= yellow_car[offsetY2][offsetX2];	
		else if (InsideRectangle[2] == 1'b1)
			RGBout <= yellow_car[offsetY3][offsetX3];
		else if (InsideRectangle[3] == 1'b1) 
			RGBout <= yellow_car[offsetY4][offsetX4];
		else if (InsideRectangle[4] == 1'b1)
			RGBout <= red_car[offsetY5][offsetX5];	
		else if (InsideRectangle[5] == 1'b1)
			RGBout <= red_car[offsetY6][offsetX6];
		else if (InsideRectangle[6] == 1'b1) begin
			RGBout <= blue_car[offsetY7][offsetX7];	
			truckCollision <= 1'b1;
		end	
		else if (InsideRectangle[7] == 1'b1) begin
			RGBout <= pink_car[offsetY8][offsetX8];
			specialCollision <= 1'b1;
		end
		else if (InsideRectangle[8] == 1'b1) begin
			RGBout <= gas_tank[offsetY9][offsetX9];
			fuelCollision <= 1'b1;
		end
	end		
end

//////////--------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap  

endmodule