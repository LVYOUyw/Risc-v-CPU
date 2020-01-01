`include "defines.v"
module if_id(
    input wire clk,
    input wire rst,
    input wire rdy,
    input wire[`InstAddrBus] if_pc,
    input wire[7:0] if_inst,
    input wire[31:0] inst_i,
    input wire jump,
    input wire last_jump,

    input wire[6:0] stall_i,
    input wire[6:0] stttt,
    input wire hit,
    input wire lasthit,
    output reg[`InstAddrBus] id_pc,
    output reg[`InstBus] id_inst,
    output reg if_request,
    output reg pd,
    output reg ifing
);
reg[3:0] cnt;
reg[7:0] inst1;
reg[7:0] inst2;
reg[7:0] inst3;
reg[3:0] tmp;
reg[6:0] stall;
reg stt;
 
always @ (posedge clk) 
begin
    if (rst == `RstEnable || rdy != `True) 
    begin
        id_pc <= `ZeroWord;
        id_inst <= `ZeroWord;
        cnt <= 3'b100;
        if_request <= 0;
        tmp <= 3'b000;
        stall <= 0;
        pd <= 0;
        ifing <= 0;
        stt <= 0;
    end 
    else if (stall == 0) 
    begin
        id_pc <= 0;
        id_inst <= 0;
        stall <= stall_i;
        stt <= stttt == 0 ? 0 : 1;
        pd <= 0;
        if (hit == 1'b1 && ifing != 1'b1) 
        begin
            id_inst <= stt == 0  ? inst_i : 0;
            id_pc <= stt == 0  ? if_pc + 4 : 0;     //need to test
            pd <= stt == 0 ? 0 : 1;
            cnt <= 3'b110;
        end 
        else if (lasthit == 1'b1 && stt != 0) pd <= 1;
        else case (cnt) 
                3'b000:
                    begin
                        inst1 <= if_inst;
                        cnt <= 3'b001;
                        ifing <= 1;
                    end
                3'b001:
                    begin
                        inst2 <= if_inst;
                        cnt <= 3'b010;
                        tmp <= 3'b010;
                        ifing <= 1;
                    end
                3'b010:
                    begin
                        inst3 <= if_inst;
                        cnt <= 3'b011;
                        tmp <= 3'b011;
                        ifing <= 1;
                    end   
                3'b011:
                    begin
                        if (stall == 0) id_inst <= {if_inst, inst3, inst2, inst1};else id_inst <= 0;
                        id_pc <= if_pc;
                        cnt <= 3'b000;
                        tmp <= 3'b000;
                        ifing <= 0;
                    end   
                3'b100:
                    cnt <= 3'b110;
                3'b110:
                    cnt <= 3'b000;
                3'b101:
                        cnt <= tmp;
                3'b111:
                    begin
                        cnt <= 3'b101;
                    end
                default:
                    begin
                    end
            endcase    
        if (last_jump == `True) 
        begin
            cnt <= 3'b000;
            ifing <= 0;
        end 
        if (jump == `True)
        begin
            cnt <= 3'b110;    
            ifing <= 0;
        end
        if_request <= `True;
    end 
    else 
    begin
        stall <= stall >> 1;
        id_inst <= 0;
        id_pc <= 0;
        pd <= 0;
    end
end

endmodule