`include "defines.v"
module BTB(
    input wire clk,
    input wire rst,
    input wire rdy,
    input wire[`InstAddrBus] pc_read,
    input wire[`InstAddrBus] pc_write,
    input wire[`InstBus] addr_i,
    input wire write_i,

    output reg hit,
    output reg[`InstAddrBus] addr_o

);
wire[7:0] index_w;
wire[7:0] index_r;
reg[31:0] BTB_addr[255:0]; //8 bit
reg[8:0] BTB_tag[255:0]; //9 bit
reg BTB_vaild[255:0]; //1 bit
assign index_w = pc_write[7:0];
assign index_r = pc_read[7:0];
integer i;

always @(posedge clk) 
begin
    if (rst == `True || rdy != `True) 
    begin
        for (i = 0; i < 256; i = i + 1) BTB_vaild[i] <= 0;
    end
    else if (write_i == `True) 
    begin
        /*if (!BTB_vaild[index_w]) 
        begin*/
            BTB_vaild[index_w] <= 1'b1;
            BTB_addr[index_w] <= addr_i;
            BTB_tag[index_w] <= pc_write[16:8];
       /* end
        else if (!BTB_vaild[index_w | 1])
        begin
            BTB_vaild[index_w | 1] <= 1'b1;
            BTB_addr[index_w | 1] <= addr_i;
            BTB_tag[index_w | 1] <= pc_write[16:8];
        end
        else 
        begin
            if (pc_write[1] == 1'b0) 
            begin
                BTB_vaild[index_w] <= 1'b1;
                BTB_addr[index_w] <= addr_i;
                BTB_tag[index_w] <= pc_write[16:8];
            end
            else 
            begin
                BTB_vaild[index_w | 1] <= 1'b1;
                BTB_addr[index_w | 1] <= addr_i;
                BTB_tag[index_w | 1] <= pc_write[16:8];
            end
        end*/
    end
end

always @ (*)
begin
    if (rst == `True || rdy != `True) 
    begin
        hit <= 0;
        addr_o <= 0;
    end
    else  
    begin
        if (BTB_vaild[index_r] == 1'b1 && BTB_tag[index_r] == pc_read[16:8])
        begin
            hit <= 1'b1;
            addr_o <= BTB_addr[index_r];
        end
       /* else if (BTB_vaild[index_r | 1] == 1'b1 && BTB_tag[index_r | 1] == pc_read[16:8])
        begin
            hit <= 1'b1;
            addr_o <= BTB_addr[index_r | 1];
        end*/
        else 
        begin
            hit <= 1'b0;
            addr_o <= 0;
        end
    end
end

endmodule
