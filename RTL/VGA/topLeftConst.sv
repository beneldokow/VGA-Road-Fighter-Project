// (c) Technion IIT, Department of Electrical Engineering 2023 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updated Eyal Lev April 2023
// updated to state machine Dudy March 2023 


module	topLeftConst(									

					output logic	[10:0]	topLeft
					
);

parameter int value = 0;

assign topLeft = value;

endmodule	
//---------------
 
