`include "defines.v" 
module mem_wb(
    input wire clk,
    input wire rst,
    input wire rdy,

    input wire[`RegAddrBus] mem_wd,
    input wire[`RegBus] mem_data,
    input wire mem_wreg,

    output reg[`RegAddrBus] wb_wd,
    output reg[`RegBus] wb_data,
    output reg wb_wreg
);

always @ (posedge clk) 
begin
    if (rst == `RstEnable || rdy != `True) 
    begin
        wb_wd <= 0;
        wb_data <= 0;
        wb_wreg <= 0;
    end
    else 
    begin
        wb_wd <= mem_wd;
        wb_data <= mem_data;
        wb_wreg <= mem_wreg;
    end
end
endmodule