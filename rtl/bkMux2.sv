module bkMux2 #(
	parameter WIDTH=8
	) (
	input  wire 	[WIDTH-1:0] 	din1, din2,
	input  wire  	[0:0]		select,
	output reg	[WIDTH-1:0] 	dout
);


always_comb
begin
	case(select)
		1'b0:  	dout = din1;
		1'b1: 	dout = din2;

	endcase	
end 
endmodule