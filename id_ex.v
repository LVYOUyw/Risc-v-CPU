`include "defines.v"
module id_ex(
    input wire clk,
    input wire rst,
    input wire rdy,
    input wire[5:0] id_aluop, 
    input wire[`RegBus] id_reg1,
    input wire[`RegBus] id_reg2,
    input wire[`RegAddrBus] id_wd,
    input wire id_wreg,
    input wire ignore_i,
    input wire[`InstAddrBus] id_pc_store,
    input wire[`RegBus] immt_i,

    output reg[5:0] ex_aluop,
    output reg[`RegBus] ex_reg1,
    output reg[`RegBus] ex_reg2,
    output reg[`RegAddrBus] ex_wd,
    output reg ex_wreg,
    output reg[`InstAddrBus] ex_pc_store,
    output reg ignore_id,
    output reg[`RegBus] immt_o
);

always @ (posedge clk) 
begin
    if (rst == `RstEnable || rdy != `True) 
    begin
        ex_aluop <= 0;
        ex_reg1 <= 0;
        ex_reg2 <= 0;
        ex_wd <= 0;
        ex_wreg <= 0;
        ex_pc_store <= 0;
        immt_o <= `ZeroWord;
    end
    else 
    begin
        ex_aluop <= id_aluop;
        ex_reg1 <= id_reg1;
        ex_reg2 <= id_reg2;
        ex_wd <= id_wd;
        ex_wreg <= id_wreg;
        ignore_id <= ignore_i;
        ex_pc_store <= id_pc_store;
        immt_o <= immt_i;
    end
end
endmodule