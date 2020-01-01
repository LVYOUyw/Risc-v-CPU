`include "defines.v"
module pc_reg(
    input wire clk,
    input wire rst,
    input wire rdy,
    input wire jump,
    input wire pd,
    input wire[`InstAddrBus] jump_addr,
    input wire[6:0] stall_i,
    input wire hit, 

    input wire BTBhit,
    input wire[`InstAddrBus] BTBaddr,

    input wire ifing,
    output reg[`InstAddrBus] pc,
    output reg hitt,
    output reg last_jump,
    output reg[`InstAddrBus] BTBaddr_o,
    output reg[6:0] stall_o,
    output reg ce
);
reg[6:0] stall;
reg[`InstAddrBus] back1_pc;
reg[`InstAddrBus] back2_pc;

always @ (posedge clk) 
begin
    if (rst == `RstEnable || rdy != `True) ce <= `ChipDisable;
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
        last_jump <= 0;
        BTBaddr_o <= 0;
    end
    else if (stall == 0)
    begin
        last_jump <= 0;
        stall <= stall_i;
        if (hit == 1'b1 && stall == 0 && ifing != 1'b1) pc <= pc + 4;    
        else  if (hit == 1'b0) pc <= pc + 1; 
        if (BTBhit == `True && stall_i == 0 && hit == 1'b1)
        begin
            pc <= BTBaddr; 
            last_jump <= 1;
        end
        if (jump == `True) pc <= jump_addr;
    end
    else 
    begin
        stall <= stall >> 1;
        if (pd == 1)  pc <= pc - 8;
        last_jump <= 0;
    end
    stall_o <= stall_i;
    hitt <= hit;
    BTBaddr_o <= BTBaddr;
end

endmodule 

// consider lw bge sw may have problem