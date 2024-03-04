module bkController # (parameter WIDTH = 8) (
    input wire          clk,
    input wire		    rst,
    input wire[6:0]     cmd_in,
    input wire          p_error,

    output reg          aluin_reg_en, aluout_reg_en, datain_reg_en,
    output reg          memoryWrite, memoryRead,selmux2,
    output reg[1:0]     in_select_a, in_select_b,
    output reg[2:0]     opcode,
    output reg          nvalid_data
);

typedef enum logic[2:0] { FETCH , DECODE , EXECUTE , LOAD , STORE , NOP , PAUSE} state_type;

state_type current_state, next_state;

reg[6:0] cmd_in_reg;
reg[6:0] opcode_reg;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        current_state <= FETCH ;     	// Move to IDLE State ---
	//cmd_in_reg = 7'd0;
        /**/
    end else begin
        current_state <= next_state ; 	// Move to next State ---
	//cmd_in_reg <= cmd_in;
    end
end

always_comb begin
	
    in_select_a = cmd_in_reg[6:5] ;      in_select_b = cmd_in_reg[4:3];  	opcode = cmd_in_reg[2:0]; 
    
    case(current_state)

	PAUSE : begin
            datain_reg_en = 1'b1 ;      aluin_reg_en = aluin_reg_en;        aluout_reg_en = aluout_reg_en;       
            memoryRead = memoryRead;    memoryWrite = memoryWrite ;         selmux2 = selmux2;
            nvalid_data = nvalid_data;

            cmd_in_reg = cmd_in;

            next_state = FETCH;
	    //next_state = DEFAULT;	
        end

        FETCH:begin
            datain_reg_en = 1'b1;  aluin_reg_en = 1'b0;   //aluout_reg_en = 1'b0;
            memoryRead = 1'b0;     memoryWrite = 1'b0;       selmux2 = 1'b0;
            nvalid_data = 1'b0;

            cmd_in_reg = cmd_in_reg;

            if (opcode[2] == 1'b0) begin
                aluout_reg_en = 1'b0;
            end else if (opcode[2:0] == 3'b101 ) begin      // Load 
                aluout_reg_en = 1'b0;
            end else if (opcode[2:0]  == 3'b110 ) begin     // Store
                aluout_reg_en = 1'b1;
            end else begin                                  // No Operation
                aluout_reg_en = 1'b0;
            end

            next_state = DECODE;
        end
        DECODE:begin
            datain_reg_en = 1'b0;  //aluin_reg_en = 1'b1;   aluout_reg_en = 1'b0;   
            memoryRead = 1'b0;     memoryWrite = 1'b0;       selmux2 = 1'b0;
            nvalid_data = 1'b0;

            cmd_in_reg = cmd_in_reg;	

            if (opcode[2] == 1'b0) begin
                aluin_reg_en = 1'b1;   aluout_reg_en = 1'b0; 
                next_state = EXECUTE; 
            end else if (opcode[2:0] == 3'b101 ) begin
                aluin_reg_en = 1'b1;   aluout_reg_en = 1'b0; 
                next_state =LOAD;
            end else if (opcode[2:0]  == 3'b110 ) begin
                aluin_reg_en = 1'b0;   aluout_reg_en = 1'b1; 
                next_state = STORE;
            end else if (opcode[2:0] == 3'b100 || opcode[2:0]  == 3'b111 ) begin
                aluin_reg_en = 1'b1;   aluout_reg_en = 1'b0; 
                next_state = NOP;
            end else begin
                aluin_reg_en = 1'b1;   aluout_reg_en = 1'b0; 
                next_state = NOP;
            end
        end
        EXECUTE : begin
            datain_reg_en = 1'b0;       aluin_reg_en = 1'b0;        aluout_reg_en = 1'b1;
            memoryRead = 1'b0;          memoryWrite = 1'b0;         selmux2 = 1'b0; 
            nvalid_data = 1'b0;

            cmd_in_reg = cmd_in_reg;

            //next_state = FETCH;
	    next_state = PAUSE;
        end

        LOAD : begin
            datain_reg_en = 1'b0;   aluin_reg_en = 1'b0;   aluout_reg_en = 1'b1;     
            memoryRead = 1'b1;      memoryWrite = 1'b0;    selmux2 = 1'b1;
            nvalid_data = 1'b0;

            cmd_in_reg = cmd_in_reg;

            //next_state = FETCH;
            next_state = PAUSE;
        end

        STORE : begin
            datain_reg_en = 1'b0;   aluin_reg_en = 1'b0;     aluout_reg_en = 1'b1;
            memoryRead = 1'b0;     memoryWrite = 1'b1;     selmux2 = 1'b1;
            nvalid_data = 1'b0;

            cmd_in_reg = cmd_in_reg;

            //next_state = FETCH;
	        next_state = PAUSE;

        end

        NOP : begin

            datain_reg_en = 1'b0;   aluin_reg_en = 1'b0;   aluout_reg_en = 1'b1;      
            memoryRead = 1'b0;     memoryWrite = 1'b0;     selmux2 = 1'b0;

            if (p_error == 1'b1) begin
                nvalid_data = 1'b1;
            end else begin
                nvalid_data = 1'b0;
            end
            cmd_in_reg = cmd_in_reg;

            //next_state = FETCH;
            next_state = PAUSE;
        end

	default : begin
        datain_reg_en = 1'd0 ;  aluin_reg_en = 1'd0;        aluout_reg_en = 1'd0;       
        memoryRead = 1'd0;      memoryWrite = 1'd0 ;         selmux2 = 1'd0;
        nvalid_data = 1'd0;

        cmd_in_reg = 7'd0;

        next_state = PAUSE;
	    //next_state = DEFAULT;	
    end

    endcase
end

endmodule