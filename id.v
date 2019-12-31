`include "defines.v"
module id(
    input wire rst,
    input wire[`InstAddrBus] pc_i,
    input wire[`InstBus] inst_i,
    input wire[`RegBus] data1_i,
    input wire[`RegBus] data2_i,
    input wire ignore_i,
 
    input wire ex_wreg_i,
    input wire[`RegBus] ex_wdata_i,
    input wire[`RegAddrBus] ex_wd_i,
    input wire mem_wreg_i,
    input wire[`RegBus] mem_wdata_i,
    input wire[`RegAddrBus] mem_wd_i,

    output reg  reg1_read_o,
    output reg  reg2_read_o,
    output reg[`RegAddrBus] reg1_addr_o,
    output reg[`RegAddrBus] reg2_addr_o,

    output reg[5:0] aluop_o,
    output reg[`RegBus]  reg1_o,
    output reg[`RegBus] reg2_o,
    output reg[`RegAddrBus] wd_o, //write register address 
    output reg wreg_o,
    output reg[`RegBus] immt,

    output reg w_cache,
    output reg[`InstBus] inst_o,
    output reg[`InstAddrBus] pc_o,

    output reg jump_o,
    output reg[`InstAddrBus] jump_addr_o,
    output reg next_ignore_o,
    output reg[6:0] stall_o,
    output reg[`InstAddrBus] pc_store_o
);

wire [6:0] opcode = inst_i[`Opcode];
wire [2:0] funct3 = inst_i[`Funct3];
wire [6:0] funct7 = inst_i[`Funct7];

reg[`RegBus] imm;
wire reg1_slt_reg2;
wire [`InstAddrBus] pc_plus_4;
wire [`InstAddrBus] goal1;
wire [`InstAddrBus] goal2;
wire[`RegBus] reg1_o_f;
wire[`RegBus] reg2_o_f;
wire[`InstAddrBus] pc_sub_4;

assign pc_plus_4 = pc_i;
assign pc_sub_4 = pc_i - 4;
assign goal1 = pc_i + imm - 4;
assign goal2 = reg1_o + imm;
assign reg1_o_f = ~reg1_o + 1'b1;
assign reg2_o_f = ~reg2_o + 1'b1;
assign reg1_slt_reg2 = (reg1_o[31] && !reg2_o[31]) || (reg1_o[31] && reg2_o[31] && reg1_o_f > reg2_o_f)
                        || (!reg1_o[31] && !reg2_o[31] && reg1_o < reg2_o);            


always @ (*) 
begin
    if (rst == `RstEnable || ignore_i == 1'b1) //ignore not use
    begin
        aluop_o <= 0;
        wd_o <= 0;
        wreg_o <= `WriteDisable;
        reg1_addr_o <= 0;
        reg2_addr_o <= 0;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        imm <= 32'h0;
        next_ignore_o <= `False;
        jump_o <= `False;
        jump_addr_o <= `ZeroWord;
        pc_store_o <= `ZeroWord;
        immt <= `ZeroWord;
        w_cache <= 0;
        inst_o <= 0;
        pc_o <= 0;
        stall_o <= 0;
    end
    else 
    begin
        aluop_o <= 0;
        stall_o <= 0;
        wd_o <= inst_i[`Rd];
        wreg_o <= `WriteDisable;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= inst_i[`Rs1];
        reg2_addr_o <= inst_i[`Rs2];
        imm <= `ZeroWord;
        immt <= `ZeroWord;
        jump_addr_o <= `ZeroWord;
        pc_store_o <= `ZeroWord;
        next_ignore_o <= `False;
        jump_o <= `False;
        if (inst_i != 32'b0) 
        begin
            w_cache <= 1;
            inst_o <= inst_i;
            pc_o <= pc_sub_4;
        end
        else begin
            w_cache <= 0;
            inst_o <= 0;
            pc_o <= 0;
        end
        if (opcode == `Opcode_Iexe)
        begin        
            wreg_o <= 1'b1;
            reg1_read_o <= 1'b1;
            reg2_read_o <= 1'b0;
            if (inst_i[31] == 1'b0) imm <= {20'b0, inst_i[31:20]};
            else imm <= {20'b11111111111111111111, inst_i[31:20]};
            case (funct3) 
                `Funct3_ori: 
                    aluop_o <= `Ori;
                `Funct3_andi:
                    aluop_o <= `Andi;
                `Funct3_xori:
                    aluop_o <= `Xori;
                `Funct3_addi:
                    aluop_o <= `Addi;
                `Funct3_slti:
                    aluop_o <= `Slti;
                `Funct3_sltiu:
                    aluop_o <= `Sltiu;
                `Funct3_slli:
                    begin
                        imm <= {26'b0, inst_i[25:25], inst_i[`Rs2]};
                        aluop_o <= `Slli;
                    end
                3'b101:
                    begin
                        if (funct7 == `Funct7_srli) 
                            begin
                                imm <= {26'b0, inst_i[25:25], inst_i[`Rs2]};
                                aluop_o <= `Srli;    
                            end
                        else if (funct7 == `Funct7_srai)  
                            begin
                                imm <= {26'b0, inst_i[25:25], inst_i[`Rs2]};
                                aluop_o <= `Srai;
                            end
                        else 
                            begin
                                wreg_o <= 1'b0;
                                reg1_read_o <= 1'b0;
                                reg2_read_o <= 1'b0;
                                imm <= `ZeroWord;
                            end
                    end
                default:
                    begin
                        wreg_o <= 1'b0;
                        reg1_read_o <= 1'b0;
                        reg2_read_o <= 1'b0;
                        imm <= `ZeroWord;
                    end
            endcase
        end
        else if (opcode == `Opcode_R) 
        begin
            wreg_o <= 1'b1;
            reg1_read_o <= 1'b1;
            reg2_read_o <= 1'b1;
            case (funct3)  
                `Funct3_sll:
                    aluop_o <= `Sll; 
                `Funct3_slt:
                    aluop_o <= `Slt;
                `Funct3_sltu:
                    aluop_o <= `Sltu;
                `Funct3_xor:
                    aluop_o <= `Xor;
                `Funct3_or:
                    aluop_o <= `Or;
                `Funct3_and: 
                    aluop_o <= `And;
                3'b000:
                    if (funct7 == `Funct7_0) aluop_o <= `Add;
                    else if (funct7 == `Funct7_1) aluop_o <= `Sub;
                    else 
                    begin
                        wreg_o <= 1'b0;
                        reg1_read_o <= 1'b0;
                        reg2_read_o <= 1'b0;
                        imm <= `ZeroWord;
                    end
                3'b101:
                    if (funct7 == `Funct7_0) aluop_o <= `Srl;
                    else if (funct7 == `Funct7_1) aluop_o <= `Sra;
                    else 
                    begin
                        wreg_o <= 1'b0;
                        reg1_read_o <= 1'b0;
                        reg2_read_o <= 1'b0;
                        imm <= `ZeroWord;
                    end
                default:
                    begin
                    end
             endcase
        end
        else if (opcode == `Opcode_jal) 
        begin
            wreg_o <= 1'b1;
            reg1_read_o <= 1'b0;
            reg2_read_o <= 1'b0;
            if (inst_i[31] == 1'b0) 
                imm <= {11'b0, inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
            else 
                imm <= {11'b11111111111, inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
            pc_store_o <= pc_plus_4;
            jump_addr_o <=  goal1;
            jump_o <= `True;
            next_ignore_o <= `True;
            aluop_o <= `Jal;
        end
        else if (opcode == `Opcode_jalr) 
        begin
            wreg_o <= 1'b1;
            reg1_read_o <= 1'b1;
            reg2_read_o <= 1'b0;
            if (inst_i[31] == 1'b0) imm <= {20'b0, inst_i[31:20]};
            else imm <= {20'b11111111111111111111, inst_i[31:20]};
            pc_store_o <= pc_plus_4;
            jump_addr_o <= goal2 & (~(32'b1));
            jump_o <= `True;
            next_ignore_o <= `True;
            aluop_o <= `Jalr;
        end
        else if (opcode == `Opcode_B)
        begin 
            reg1_read_o <= 1'b1;
            reg2_read_o <= 1'b1;
            if (inst_i[31] == 1'b0)
                imm <= {19'b0, inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
            else 
                imm <= {19'b1111111111111111111, inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
            case (funct3) 
                `Funct3_beq:
                    if (reg1_o == reg2_o) 
                    begin 
                        next_ignore_o <= `True;
                        jump_addr_o <= goal1;
                        jump_o <= `True;
                    end
                `Funct3_bne:
                    if (reg1_o != reg2_o) 
                    begin
                        next_ignore_o <= `True;
                        jump_addr_o <= goal1;
                        jump_o <= `True;
                    end
                `Funct3_blt:
                    if (reg1_slt_reg2 == 1'b1)  //signed 
                    begin 
                        next_ignore_o <= `True;
                        jump_addr_o <= goal1;
                        jump_o <= `True;
                    end
                `Funct3_bge:
                    if (reg1_slt_reg2 == 1'b0) //signed
                    begin
                        next_ignore_o <= `True;
                        jump_addr_o <= goal1;
                        jump_o <= `True;
                    end
                `Funct3_bltu:
                    if (reg1_o < reg2_o) //unsigned 
                    begin
                        next_ignore_o <= `True;
                        jump_addr_o <= goal1;
                        jump_o <= `True;
                    end
                `Funct3_bgeu:
                    if (reg1_o >= reg2_o) //unsigned 
                    begin
                        next_ignore_o <= `True;
                        jump_addr_o <= goal1;
                        jump_o <= `True;
                    end
            endcase
        end 
        else if (opcode == `Opcode_Iload)
        begin
            wreg_o <= 1;
            reg1_read_o <= 1;
            if (inst_i[31] == 1'b0) imm <= {20'b0, inst_i[31:20]};
            else imm <= {20'b11111111111111111111, inst_i[31:20]};
            case (funct3)
                `Funct3_lb:
                    begin
                        aluop_o <= `Lb;
                        stall_o <= 6'b001000;
                        next_ignore_o <= `True;
                    end
                `Funct3_lh:
                    begin
                        aluop_o <= `Lh;
                        stall_o <= 6'b010000;
                        next_ignore_o <= `True;
                    end
                `Funct3_lw:
                    begin
                        aluop_o <= `Lw;
                        stall_o <= 7'b1000000;
                        next_ignore_o <= `True;
                    end
                `Funct3_lbu:
                    begin
                        aluop_o <= `Lbu;
                        stall_o <= 6'b001000;
                        next_ignore_o <= `True;
                    end
                `Funct3_lhu:
                    begin
                        aluop_o <= `Lhu;
                        stall_o <= 6'b010000;
                        next_ignore_o <= `True;
                    end
            endcase
        end
        else if (opcode == `Opcode_S)
        begin
            reg1_read_o <= 1;
            reg2_read_o <= 1;
            wreg_o <= 0;
            if (inst_i[31] == 1'b0) immt <= {20'b0, inst_i[31:25], inst_i[11:7]};
            else immt <= {20'b11111111111111111111, inst_i[31:25], inst_i[11:7]};
            case (funct3) 
                `Funct3_sb:
                    begin
                        aluop_o <= `Sb;
                        stall_o <= 6'b001000;
                        next_ignore_o <= `True;
                    end
                `Funct3_sh:
                    begin
                        aluop_o <= `Sh;
                        stall_o <= 6'b010000;
                        next_ignore_o <= `True;
                    end
                `Funct3_sw:
                    begin
                        aluop_o <= `Sw;
                        stall_o <= 7'b1000000;
                        next_ignore_o <= `True;
                    end

            endcase
        end
        else if (opcode == `Opcode_lui) 
        begin
            wreg_o <= 1;
            reg1_read_o <= 0;
            reg2_read_o <= 0;
            aluop_o <= `Lui;
            immt <= {inst_i[31:12], 12'b0};
        end
        else if (opcode == `Opcode_auipc) 
        begin
            wreg_o <= 1;
            reg1_read_o <= 0;
            reg2_read_o <= 0;
            aluop_o <= `Auipc;
            imm <= pc_plus_4 - 4;
            immt <= {inst_i[31:12], 12'b0};
        end
    end
end

always @ (*) 
begin
    if (rst == `RstEnable) 
        reg1_o <= `ZeroWord;
    else if ((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg1_addr_o)) 
        reg1_o <= ex_wdata_i;
    else if ((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg1_addr_o)) 
        reg1_o <= mem_wdata_i;
    else if (reg1_read_o == 1'b1) 
        reg1_o <= data1_i;
    else if (reg1_read_o == 1'b0) 
        reg1_o <= imm;
    else 
        reg1_o <= `ZeroWord;
end

always @ (*) 
begin
    if (rst == `RstEnable) 
        reg2_o <= `ZeroWord;
    else if ((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg2_addr_o)) 
        reg2_o <= ex_wdata_i;
    else if ((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg2_addr_o)) 
        reg2_o <= mem_wdata_i;
    else if (reg2_read_o == 1'b1) 
        reg2_o <= data2_i;
    else if (reg2_read_o == 1'b0) 
        reg2_o <= imm;
    else 
        reg2_o <= `ZeroWord;
end
endmodule