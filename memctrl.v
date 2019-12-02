`include "defines.v"
module memctrl(
    input wire rst,
    input wire rdy,
    input wire[`InstAddrBus] mem_addr_i,
    input wire[`InstAddrBus] if_addr_i,
    input wire mem_request, 
    input wire if_request,
    input wire write_i,
    input wire[7:0] wdata_i,
    output reg[`InstAddrBus] mem_addr_o,
    output reg[7:0] wdata_o,
    output reg write_o
);

always @ (*)
begin
    if (rst == `True || rdy == `False) 
    begin
        mem_addr_o <= `ZeroWord;
        wdata_o <= 0;
        write_o <= 0;
    end
    else if (if_request == `True) 
    begin
        write_o <= 0;
        mem_addr_o <= if_addr_i;
    end
    else if (mem_request == `True) 
    begin
        write_o <= write_i;
        mem_addr_o <= mem_addr_i;
        wdata_o <= wdata_i;
    end
    else 
    begin
        mem_addr_o <= `ZeroWord;
        wdata_o <= 0;
        write_o <= 0;
    end
end

endmodule 