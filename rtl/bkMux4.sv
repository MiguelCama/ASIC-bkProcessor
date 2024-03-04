module bkMux4 #(
	parameter WIDTH=8
	) (
	input  wire 	[WIDTH-1:0] 	din1, din2, din3, din4,
	input  wire  	[1:0]			select,
	output reg	[WIDTH-1:0] 	dout
);


always_comb
begin
	case(select)
		2'b00:  	dout = din1;
		2'b01: 		dout = din2;
		2'b10: 		dout = din3;
		2'b11: 		dout = din4;
	endcase	
end 
endmodule