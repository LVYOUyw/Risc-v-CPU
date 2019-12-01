`include "defines.v"
module if_id(
    input wire clk,
    input wire rst,
    input wire[`InstAddrBus] if_pc,
    input wire[7:0] if_inst,
    input wire jump,
    output reg[`InstAddrBus] id_pc,
    output reg[`InstBus] id_inst
);
reg[3:0] cnt;
reg[7:0] inst1;
reg[7:0] inst2;
reg[7:0] inst3;
 
always @ (posedge clk) 
begin
    if (rst == `RstEnable) 
    begin
        id_pc <= `ZeroWord;
        id_inst <= `ZeroWord;
        cnt <= 3'b100;
    end 
    else 
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
                end
            3'b010:
                begin
                    inst3 <= if_inst;
                    cnt <= 3'b011;
                end   
            3'b011:
                begin
                    id_inst <= {if_inst, inst3, inst2, inst1};
                    id_pc <= if_pc;
                    inst1 <= 0;
                    inst2 <= 0;
                    inst3 <= 0;
                    cnt <= 3'b000;
                    if (id_inst[0] == 1'b1)  $display("%b",id_inst);
                end   
            3'b100:
                cnt <= 3'b101;
            3'b101:
                cnt <= 3'b000;
            default:
                begin
                end
        endcase
        if (jump == `True) cnt <= 3'b101;    
        //id_pc <= if_pc;
        //id_inst <= if_inst;
    end
end

endmodule