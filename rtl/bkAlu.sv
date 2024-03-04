module bkAlu #(
	parameter WIDTH = 8
	) (
	    input  	wire 	[WIDTH-1:0] in1, in2,
    	input  	wire 	[2:0] opcode,
	    output 	reg		invalid_data,
    	output  reg 	zero,
    	output  reg 	error,	//inout  logic  	[WIDTH-1:0] out_ff,
    	output 	reg 	[2*WIDTH-1:0] out
);

always_comb 
begin
case (opcode)
        3'd0:   begin
            out     = {8'd0,in1} + {8'd0,in2}; 	
            error   = 1'b0;
            invalid_data = 1'b0;
        end //addition
        3'd1:   begin
            out     = {8'd0,in1} - {8'd0,in2};  	
            error   = 1'b0;
            invalid_data = 1'b0;
        end //subtration
        3'd2: begin
            out     = in1 * in2;  	
            error   = 1'b0;  
            invalid_data = 1'b0;
        end//multiplication
        3'd3: begin
            error   = (in2 == 8'd0) ? (1'b1) : (1'b0) ;
            out     = (in2 == 8'd0) ? (-16'b1): ( {8'd0,in1}/{8'd0,in2});
            invalid_data = 1'b0 ;
        end
        default: begin
            error   = 1'b1;
            out     = -16'b1;
            invalid_data = 1'b1 ;
        end
    endcase
    zero = (out == 16'd0) ? (1'b1) : (1'b0) ;
end 
endmodule