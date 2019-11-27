`include "defines.v"
module ex(
    input wire rst,
    input wire[`AluOpBus] aluop_i,
    input wire[`RegBus] reg1_i,
    input wire[`RegBus] reg2_i,
    input wire[`RegAddrBus] wd_i,
    input wire wreg_i,
    input wire[`InstAddrBus] pc_store_i,
 
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] data_o
);

reg[`RegBus] ans;

always @ (*) 
begin
    if (rst == `RstEnable) 
        ans <= `ZeroWord;
    else 
    begin
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        case (aluop_i) 
            `Ori:
                begin
                    ans <= reg1_i | reg2_i;
                    data_o <= ans;
                end
            `Andi:
                begin
                    ans <= reg1_i & reg2_i;
                    data_o <= ans;
                end
            `Xori:
                begin
                    ans <= reg1_i ^ reg2_i;
                    data_o <= ans;
                end
            `Addi:
                begin
                    ans <= reg1_i + reg2_i;
                    data_o <= ans;
                end
            `Slti:
                begin
                    if (reg1_i < reg2_i) ans <= 1'b1; else ans <= 1'b0; //unsigned < 
                    data_o <= ans;
                end
            `Sltiu:
                begin
                    if (reg1_i < reg2_i) ans <= 1'b1; else ans <= 1'b0; //unsigned < 
                    data_o <= ans;
                end
            `Slli:
                begin
                    ans <= reg1_i << reg2_i;
                    data_o <= ans;
                end
            `Srli:
                begin
                    ans <= reg1_i >> reg2_i;
                    data_o <= ans;
                end
            `Srai:
                begin
                    ans <= (({32{reg1_i[31]}}) << (6'd32 - reg2_i)) | (reg1_i >> reg2_i); 
                    data_o <= ans;
                end
            `Jal:
                data_o <= pc_store_i;
            `Jalr:
                data_o <= pc_store_i;
            default:
                begin
                end
        endcase
    end
end

endmodule

