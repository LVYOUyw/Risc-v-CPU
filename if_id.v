`include "defines.v"
module if_id(
    input wire clk,
    input wire rst,
    input wire[`InstAddrBus] if_pc,
    input wire[7:0] if_inst,
    input wire jump,
    input wire if_stall,
    output reg[`InstAddrBus] id_pc,
    output reg[`InstBus] id_inst,
    output reg if_request,
    output reg if_stall_req
);
reg[3:0] cnt;
reg[7:0] inst1;
reg[7:0] inst2;
reg[7:0] inst3;
reg[3:0] tmp;
reg stall;
 
always @ (posedge clk) 
begin
    if (rst == `RstEnable) 
    begin
        id_pc <= `ZeroWord;
        id_inst <= `ZeroWord;
        cnt <= 3'b100;
        if_request <= 0;
        tmp <= 3'b000;
        if_stall_req <= 0;
        stall <= `False;
    end 
    else if (stall == `False)
    begin
        id_pc <= 0;
        id_inst <= 0;
        case (cnt) 
            3'b000:
                begin
                    inst1 <= if_inst;
                    cnt <= 3'b001;
                end
            3'b001:
                begin
                    inst2 <= if_inst;
                    cnt <= 3'b010;
                    tmp <= 3'b010;
                end
            3'b010:
                begin
                    inst3 <= if_inst;
                    cnt <= 3'b011;
                    tmp <= 3'b011;
                end   
            3'b011:
                begin
                    id_inst <= {if_inst, inst3, inst2, inst1};
                    id_pc <= if_pc;
                    cnt <= 3'b000;
                    tmp <= 3'b000;
                end   
            3'b100:
                cnt <= 3'b110;
            3'b110:
                cnt <= 3'b000;
            3'b101:
                    cnt <= tmp;
            3'b111:
                begin
                    if_stall_req <= `False;
                    cnt <= 3'b101;
                end
            default:
                begin
                end
        endcase
        if (jump == `True) cnt <= 3'b110;    
        if (if_stall == `True) stall <= `True;
        if_request <= ~if_stall;
        //id_pc <= if_pc;
        //id_inst <= if_inst;
    end 
    else 
    begin
        if_request <= `False;
        if_stall_req <= `True;
        cnt <= 3'b111;
        stall <= if_stall;
    end
end

endmodule