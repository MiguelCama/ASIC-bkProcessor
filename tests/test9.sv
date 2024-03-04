`timescale 10ns/1ps

module test9;
// Interface to conmmunicate with the DUT 


reg clk;
reg rst;
reg [6:0] cmdin;
reg [7:0] din_1;
reg [7:0] din_2;
reg [7:0] din_3;
wire [7:0] dout_low;
wire [7:0] dout_high;
wire zero;
wire error;

//Device  under test instatiation

bkProcessor U1 (   .clk(clk), .rst(rst), .cmdin(cmdin), .din_1(din_1), .din_2(din_2),
                .din_3(din_3), .dout_low(dout_low), .dout_high(dout_high), .zero(zero), .error(error)
);

initial 
begin //Test program

    #5	rst = 1'b0 ;    cmdin = $urandom_range(0,128); 	din_1 = $urandom_range(0,256); din_2 = $urandom_range(0,256); din_3 = $urandom_range(0,256) ; 
    for (int i=1; i<15; ++i) begin
        #40     cmdin = $urandom_range(0,128); 	din_1 = $urandom_range(0,256); din_2 = $urandom_range(0,256); din_3 = $urandom_range(0,256) ;
    end
    
    for (int i=1; i<15; ++i) begin
        #40     cmdin = $urandom_range(0,128); 	din_1 = $urandom_range(0,256); din_2 = $urandom_range(0,256); din_3 = $urandom_range(0,256) ;
        #40     cmdin = {$urandom_range(0,16),3'b110} ; din_1 = i; din_2 = $urandom_range(0,256); din_3 = $urandom_range(0,256) ;
    end
    for (int i=1; i<15; ++i) begin
        #40     cmdin = {$urandom_range(0,16),3'b101} ; din_1 = i; din_2 = $urandom_range(0,256); din_3 = $urandom_range(0,256) ;
    end
/*
    for (int i=1; i<15; ++i) begin
        #10 a = $urandom_range(0,) ;
    end
*/
	#10 
	$finish;
end

initial
begin
	clk = 0;
	forever	#5 clk = ~clk;	
end

initial
begin //Monitor the simulation
	$dumpvars;
	/*$display(" | selA | selB | opcode | " );
	$monitor(" | %b | %b | %b |" , U1.U1.in_select_a, U1.U1.in_select_b,U1.U1.opcode);*/
	$display(" | clk | rst | cmd | d1 | d2 | d3 | dOH | dOL | z | opcode | " );
	$monitor(" | %b | %b | %b | %b | %b | %b | %b | %b | %b | %b |" , clk , rst , cmdin , din_1, din_2, din_3 , dout_high , dout_low , zero , error);
end
endmodule