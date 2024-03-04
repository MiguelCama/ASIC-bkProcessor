module bkProcessor #(

parameter WIDTH= 8
) (
input   wire clk,
input   wire rst,
input   wire [6:0] cmdin,
input   wire [WIDTH-1:0] din_1,
input   wire [WIDTH-1:0] din_2,
input   wire [WIDTH-1:0] din_3,
output  wire [WIDTH-1:0] dout_low,
output  wire [WIDTH-1:0] dout_high,
output  wire zero,
output  wire error
);

wire[6:0] regDataIn_control_cmdin ;
wire[1:0] control_mux4_selectA ;
wire[1:0] control_mux4_selectB ;
wire[0:0] control_regDataIn, control_regAluIn , control_regAluOut ;
wire[0:0] control_mux2_selecAluMen;
wire[2:0] control_alu_opcode;
wire[0:0] control_alu_nvalidata;
wire[0:0] regAluOutA_control_perror;
wire[0:0] control_mem_memWrite,control_mem_memRead;

wire[7:0] mux4A_regAluInA, mux4B_regAluInB;
wire[7:0] regAluInA_AluA, regAluInB_AluB;

wire[2*WIDTH-1:0] aluOut_mux2InA;
wire[2*WIDTH-1:0] memDataOut_mux2InB;

wire[2*WIDTH-1:0] mux2OutA_regAluOutB;
wire[1:0] alu_regAluOutA;

wire[2*WIDTH-1:0] regAluOutB_mem;
wire[1:0] regAluOutA_out;

bkController U1 (    .clk(clk),  .rst(rst),
                .cmd_in(regDataIn_control_cmdin),
                .p_error(regAluOutA_control_perror),
                .aluin_reg_en(control_regAluIn), .aluout_reg_en(control_regAluOut), .datain_reg_en(control_regDataIn),
                .memoryWrite(control_men_memWrite), .memoryRead(control_mem_memRead), .selmux2(control_mux2_selecAluMen),
                .in_select_a(control_mux4_selectA), .in_select_b(control_mux4_selectB),
                .opcode(control_alu_opcode),
                .nvalid_data(control_alu_nvalidata) 

);
bkAlu U2 (        .in1(regAluInA_AluA), .in2(regAluInB_AluB),
                .opcode(control_alu_opcode),
                .invalid_data(control_alu_nvalidata),
                .zero(alu_regAluOutA[1]),
                .error(alu_regAluOutA[0]),	
                .out(aluOut_mux2InA)
);

bkMemory U3   (   .clk(clk), .memoryWrite(control_mem_memWrite) , .memoryRead(control_mem_memRead),
                .memoryWriteData(regAluOutB_mem),
                .memoryAddress(din_1),
                .memoryOutData(memDataOut_mux2InB) 
);

// Register data_in
bkRegBank #(.WIDTH(7)) U4 (.clk(clk),
                    .rst(rst),
                    .wr_en(control_regDataIn),
                    .in(cmdin),
                    .out(regDataIn_control_cmdin)
);

// Registers alu_in
bkRegBank U5 (  .clk(clk),
                    .rst(rst),
                    .wr_en(control_regAluIn),
                    
                    .in(mux4A_regAluInA),
                    .out(regAluInA_AluA)
);
bkRegBank U6 (  .clk(clk),
                    .rst(rst),
                    .wr_en(control_regAluIn),
                    .in(mux4B_regAluInB),
                    .out(regAluInB_AluB)
);

// Registers alu_out
bkRegBank #(.WIDTH(2)) U7 (  .clk(clk),
                    .rst(rst),
                    .wr_en(control_regAluOut),
                    .in(alu_regAluOutA),
                    .out(regAluOutA_out)
);
bkRegBank #(.WIDTH(16)) U8 (  .clk(clk),
                    .rst(rst),
                    .wr_en(control_regAluOut),
                    .in(mux2OutA_regAluOutB),
                    .out(regAluOutB_mem)
);

// Multiplexors

bkMux4 U9 (   .din1(din_1) , .din2(din_2) , .din3(din_3) , .din4(dout_high) ,
            .select(control_mux4_selectA) ,
            .dout(mux4A_regAluInA)
);

bkMux4 U10 (  .din1(din_1) , .din2(din_2) , .din3(din_3) , .din4(dout_low) ,
            .select(control_mux4_selectB) ,
            .dout(mux4B_regAluInB)
);

bkMux2 #(.WIDTH(16)) U11 (  .din1(aluOut_mux2InA) , .din2(memDataOut_mux2InB) ,
            .select(control_mux2_selecAluMen) ,
            .dout(mux2OutA_regAluOutB)
);

assign	    regAluOutA_control_perror = regAluOutA_out[0];
assign      zero = regAluOutA_out[1];
assign      error = regAluOutA_out[0];

assign      dout_high   = regAluOutB_mem[15:8];
assign      dout_low    = regAluOutB_mem[7:0];

endmodule
