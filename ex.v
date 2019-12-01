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
wire[`RegBus] reg1_i_abs;
wire[`RegBus] reg2_i_abs;
wire reg1_slt_reg2;

assign reg1_i_abs = ~reg1_i + 1'b1;
assign reg2_i_abs = ~reg2_i + 1'b1;
assign reg1_slt_reg2 = (!reg1_i[31] && reg2_i[31]) || (reg1_i[31] && reg2_i[31] && reg1_i_abs > reg2_i_abs)
                        || (!reg1_i[31] && !reg2_i[31] && reg1_i_abs < reg2_i_abs);

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
                data_o <= reg1_i | reg2_i;
            `Andi:
                data_o <= reg1_i & reg2_i;
            `Xori:
                data_o <= reg1_i ^ reg2_i;
            `Addi:
                data_o <= reg1_i + reg2_i;
            `Slti:
                data_o <= reg1_slt_reg2;
            `Sltiu:
                data_o <= reg1_slt_reg2;
            `Slli:
                data_o <= reg1_i << reg2_i;
            `Srli:
                data_o <= reg1_i >> reg2_i;
            `Srai:
                data_o <= (({32{reg1_i[31]}}) << (6'd32 - reg2_i)) | (reg1_i >> reg2_i); 
            `Add:
                data_o <= reg1_i + reg2_i;
            `Sub:
                data_o <= reg1_i + reg2_i;
            `Sll:
                data_o <= reg1_i << reg2_i;
            `Slt:
                data_o <= reg1_slt_reg2;
            `Sltu:
                data_o <= (reg1_i < reg2_i);
            `Xor:
                data_o <= reg1_i ^ reg2_i;
            `Srl:
                data_o <= reg1_i >> reg2_i;
            `Sra:
                data_o <= (({32{reg1_i[31]}}) << (6'd32 - reg2_i)) | (reg1_i >> reg2_i); 
            `Or:
                data_o <= reg1_i | reg2_i;
            `And:
                data_o <= reg1_i & reg2_i;    
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

