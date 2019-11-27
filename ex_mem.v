`include "defines.v"
module ex_mem(
    input wire clk,
    input wire rst,

    input wire[`RegAddrBus] ex_wd,
    input wire ex_wreg,
    input wire[`RegBus] ex_data,

    output reg[`RegAddrBus] mem_wd,
    output reg mem_wreg,
    output reg[`RegBus] mem_data
);

always @ (posedge clk)  
begin
    if (rst == `RstEnable) 
    begin
        mem_wd <= 0;
        mem_wreg <= 0;
        mem_data <= 0;
    end
    else 
    begin
        mem_wd <= ex_wd;
        mem_wreg <= ex_wreg;
        mem_data <= ex_data;
    end
end
endmodule