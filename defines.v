`define RstEnable 1'b1
`define RstDisable 1'b0
`define ZeroWord 32'h00000000
`define WriteEnable 1'b1
`define WriteDisable 1'b0
`define ReadEnable 1'b1
`define ReadDisable 1'b0
`define Opcode 6:0
`define Funct3  14:12
`define Funct7 31:25
`define Rs1 19:15
`define Rs2 24:20
`define Rd 11:7
`define True 1'b1
`define False 1'b0
`define ChipEnable 1'b1
`define ChipDisable 1'b0

`define Opcode_Iexe 7'b0010011
`define Opcode_Imem 7'b0100011
`define Opcode_R 7'b0110011
`define Opcode_B 7'b1100011
`define Opcode_jal 7'b1101111
`define Opcode_jalr 7'b1100111
`define Opcode_lui 7'b0110111
`define Opcode_auipc 7'b0010111
`define Opcode_Iload 7'b0000011
`define Opcode_S 7'b0100011

`define Funct3_ori 3'b110
`define Funct3_andi 3'b111
`define Funct3_xori 3'b100
`define Funct3_slti 3'b010
`define Funct3_sltiu 3'b011
`define Funct3_addi 3'b000
`define Funct3_slli 3'b001
`define Funct3_beq 3'b000
`define Funct3_bne 3'b001
`define Funct3_blt 3'b100
`define Funct3_bge 3'b101
`define Funct3_bltu 3'b110
`define Funct3_bgeu 3'b111
`define Funct7_srli 7'b0000000
`define Funct7_srai 7'b0100000


`define Funct3_sll 3'b001
`define Funct3_slt 3'b010
`define Funct3_sltu 3'b011
`define Funct3_xor 3'b100
`define Funct3_or 3'b110
`define Funct3_and 3'b111
`define Funct7_0 7'b0000000
`define Funct7_1 7'b0100000

`define Funct3_lb 3'b000
`define Funct3_lh 3'b001
`define Funct3_lw 3'b010
`define Funct3_lbu 3'b100
`define Funct3_lhu 3'b101
`define Funct3_sb 3'b000
`define Funct3_sh 3'b001
`define Funct3_sw 3'b010

//指令存储器inst_rom
`define InstAddrBus 31:0
`define InstBus 31:0
`define InstMemNum 131071
`define InstMemNumLog2 17
`define AluOpBus 5:0
 
//通用寄存器regfile
`define RegAddrBus 4:0
`define RegBus 31:0
`define RegWidth 32
`define RegNum 32

//指令
`define Ori 6'd1
`define Andi 6'd2
`define Xori 6'd3
`define Addi 6'd4
`define Slti 6'd5
`define Sltiu 6'd6
`define Slli 6'd7
`define Srli 6'd8
`define Srai 6'd9
`define Add 6'd10
`define Sub 6'd11
`define Sll 6'd12
`define Slt 6'd13
`define Sltu 6'd14
`define Xor 6'd15
`define Srl 6'd16
`define Sra 6'd17
`define Or 6'd18
`define And 6'd19
`define Jal 6'd20
`define Jalr 6'd21
`define Lb 6'd22
`define Lh 6'd23
`define Lw 6'd24
`define Lbu 6'd25
`define Lhu 6'd26
`define Sb 6'd27
`define Sh 6'd28
`define Sw 6'd29
`define Lui 6'd30
`define Auipc 6'd31
`define Nop 6'd32
