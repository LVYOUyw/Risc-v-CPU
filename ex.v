`include "defines.v"
module ex(
    input wire rst,
    input wire[`AluOpBus] aluop_i,
    input wire[`RegBus] reg1_i,
    input wire[`RegBus] reg2_i,
    input wire[`RegAddrBus] wd_i,
    input wire wreg_i,
    input wire[`InstAddrBus] pc_store_i,
    input wire[`RegBus] immt,
 
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] data_o,
    output reg[`AluOpBus] aluop_o,
    output reg[`InstAddrBus] mem_addr_o
);

reg[`RegBus] ans;
reg tmp;
wire[`RegBus] reg1_i_f;
wire[`RegBus] reg2_i_f;
wire reg1_slt_reg2;
reg[2:0] cnt;

assign reg1_i_f = ~reg1_i + 1'b1;
assign reg2_i_f = ~reg2_i + 1'b1;
assign reg1_slt_reg2 = (!reg1_i[31] && reg2_i[31]) || (reg1_i[31] && reg2_i[31] && reg1_i_f > reg2_i_f)
                        || (!reg1_i[31] && !reg2_i[31] && reg1_i < reg2_i);

always @ (*) 
begin
    if (rst == `RstEnable) 
    begin
        data_o <= `ZeroWord;
        wd_o <= 0;
        wreg_o <= 0;
        cnt <= 0;
        aluop_o <= 0;
        tmp <= 0;
        mem_addr_o <= `ZeroWord;
    end
    else 
    begin
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        aluop_o <= aluop_i;  
        mem_addr_o <= `ZeroWord;
        data_o <= `ZeroWord;
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
                data_o <= reg1_i < reg2_i;
            `Slli:
                data_o <= reg1_i << reg2_i;
            `Srli:
                data_o <= reg1_i >> reg2_i;
            `Srai:
                data_o <= (({32{reg1_i[31]}}) << (6'd32 - reg2_i)) | (reg1_i >> reg2_i); 
            `Add:
                data_o <= reg1_i + reg2_i;
            `Sub:
                data_o <= reg1_i - reg2_i;
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
                data_o <= (({32{reg1_i[31]}}) << (6'd32 - reg2_i[4:0])) | (reg1_i >> reg2_i[4:0]); 
            `Or:
                data_o <= reg1_i | reg2_i;
            `And:
                data_o <= reg1_i & reg2_i;    
            `Jal:
                data_o <= pc_store_i;
            `Jalr:
                data_o <= pc_store_i;
            `Lb:
                mem_addr_o <= reg1_i + reg2_i;
            `Lh:
                mem_addr_o <= reg1_i + reg2_i;
            `Lw:
                mem_addr_o <= reg1_i + reg2_i;
            `Lbu:
                mem_addr_o <= reg1_i + reg2_i;
            `Lhu:
                mem_addr_o <= reg1_i + reg2_i;
            `Sb:
                begin
                    mem_addr_o <= reg1_i + immt;
                    data_o <= reg2_i;
                end
            `Sh:
                begin
                    mem_addr_o <= reg1_i + immt;
                    data_o <= reg2_i;
                end
            `Sw:
                begin
                    mem_addr_o <= reg1_i + immt;
                    data_o <= reg2_i;
                end
            `Lui:
                data_o <= immt;
            `Auipc:
                data_o <= reg1_i + immt;
            default:
                begin
                end
        endcase
    end
end

endmodule

