`include "defines.v"
module ex_mem(
    input wire clk,
    input wire rst,
    input wire rdy,
    input wire[`RegAddrBus] ex_wd,
    input wire ex_wreg,
    input wire[`RegBus] ex_data,
    input wire[`RegBus] mem_addr_i,
    input wire[`AluOpBus] aluop_i,

    output reg[`RegAddrBus] mem_wd,
    output reg mem_wreg,
    output reg[`RegBus] mem_data,
    output reg[`InstAddrBus] mem_addr_o,
    output reg[`AluOpBus] aluop_o
);

always @ (posedge clk)  
begin
    if (rst == `RstEnable || rdy != `True) 
    begin
        mem_wd <= 0;
        mem_wreg <= 0;
        mem_data <= 0;
        mem_addr_o <= 0;
        aluop_o <= 0;
    end
    else 
    begin
        mem_wd <= ex_wd;
        mem_wreg <= ex_wreg;
        mem_data <= ex_data;
        mem_addr_o <= mem_addr_i;
        aluop_o <= aluop_i;
    end
end
endmodule