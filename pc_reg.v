`include "defines.v"
module pc_reg(
    input wire clk,
    input wire rst,
    input wire jump,
    input wire pd,
    input wire[`InstAddrBus] jump_addr,
    input wire[6:0] stall_i,
    input wire hit,
    input wire ifing,
    output reg[`InstAddrBus] pc,
    output reg hitt,
    output reg[6:0] stall_o,
    output reg ce
);
reg[6:0] stall;

always @ (posedge clk) 
begin
    if (rst == `RstEnable) ce <= `ChipDisable;
    else
    begin
        ce <= `ChipEnable;
    end
end

always @ (posedge clk) 
begin 
    if (ce == `ChipDisable) 
    begin
        pc <= 32'h00000000;
        stall <= 0;
    end
    else if (stall == 0)
    begin
        stall <= stall_i;
        if (hit == 1'b1 && stall == 0 && ifing != 1'b1) pc <= pc + 4;         // need to test
        else  if (hit == 1'b0) pc <= pc + 1; 
    end
    else 
    begin
        stall <= stall >> 1;
        if (pd == 1) pc <= pc - 8;
    end
    if (jump == `True) pc <= jump_addr;
    stall_o <= stall_i;
    hitt <= hit;
end

endmodule 