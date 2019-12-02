`include "defines.v"
module pc_reg(
    input wire clk,
    input wire rst,
    input wire jump,
    input wire[`InstAddrBus] jump_addr,
    input wire if_stall, 
    input wire mem_stall,
    output reg[`InstAddrBus] pc,
    output reg ce
);

always @ (posedge clk) 
begin
    if (rst == `RstEnable) ce <= `ChipDisable;
    else ce <= `ChipEnable;
end

always @ (posedge clk) 
begin
    if (if_stall == `False && mem_stall == `False)
        if (ce == `ChipDisable) pc <= 32'h00000000;
        else if (jump == `True) pc <= jump_addr;
        else pc <= pc + 1;
end

endmodule 