module bkRegBank #(
	parameter WIDTH = 8

	) (
	input  wire 	clk,
	input  wire 	rst,
	input  wire 	wr_en,
	input  wire 	[WIDTH-1:0] in,
	output reg	[WIDTH-1:0] out
);

reg  	[WIDTH-1:0] out_ff;

always_ff @(posedge clk)
begin
	out_ff <= (rst) ? (WIDTH'('d0)):(in);
end

always_comb 
begin
	out = (wr_en) ? (out_ff):(WIDTH'('d0));
end 
endmodule