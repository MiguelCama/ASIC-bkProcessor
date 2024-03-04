module bkMemory #(
	parameter WIDTH = 8
	) (
        input 	wire    clk, memoryWrite , memoryRead,
        input 	wire    [2*WIDTH-1 : 0 ] memoryWriteData,	
        input 	wire	[WIDTH-1 : 0] memoryAddress,
        output 	reg    	[2*WIDTH-1 : 0] memoryOutData
);

reg [2*WIDTH-1:0] ram_bank [255:0];
always_comb begin
	memoryOutData = (memoryRead == 1'b1) ? (ram_bank[memoryAddress]):(16'd0) ;
end
always_ff @(posedge clk) begin
	ram_bank[memoryAddress] <= (memoryWrite == 1'b1) ? (memoryWriteData):(ram_bank[memoryAddress]);
end

endmodule