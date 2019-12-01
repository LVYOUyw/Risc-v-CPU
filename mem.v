`include "defines.v" 
module mem(
    input wire rst,

    input wire[`RegAddrBus] wd_i,
    input wire[`RegBus] data_i,
    input wire wreg_i,
    input wire[`RegBus] mem_data_i,

    output reg[`RegAddrBus] wd_o,
    output reg[`RegBus] data_o,
    output reg wreg_o,
    output reg mem_we_o,
    output reg[2:0] mem_sel_o,
    output reg[`RegBus] mem_data_o,
    output reg mem_ce_o
);

always @ (*) 
begin
    if (rst == `RstEnable) 
    begin
        wd_o <= 0;
        data_o <= 0;
        wreg_o <= 0;
    end
    else 
    begin
        wd_o <= wd_i;
        data_o <= data_i;
        wreg_o <= wreg_i;
    end
end
endmodule