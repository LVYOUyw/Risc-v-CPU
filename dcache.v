`include "defines.v"
module icache(
    input wire clk,
    input wire rst,
    input wire rdy,
    input wire[`InstAddrBus] addr_read,
    input wire[`InstAddrBus] addr_write,
    input wire[7:0] data_i,
    input wire write_i,

    output reg hit,
    output reg[7:0] data_o

);
wire[6:0] index_w;
wire[6:0] index_r;
reg[7:0] byte_data[127:0]; //7 bit
reg[9:0] byte_tag[127:0]; //10 bit
reg byte_vaild[127:0]; //1 bit
assign index_w = addr_write[6:0];
assign index_r = addr_read[6:0];
integer i;

always @(posedge clk) 
begin
    if (rst == `True) 
    begin
        for (i = 0; i < 128; i = i + 1) 
            byte_vaild[i] <= 0;
    end
    else if (write_i == `True) 
    begin
        byte_vaild[index_w] <= 1'b1;
        byte_data[index_w] <= data_i;
        byte_tag[index_w] <= addr_write[16:8];
    end
end

always @ (*)
begin
    if (rst == `True || rdy != `True) 
    begin
        hit <= 0;
        data_o <= 0;
    end
    else  
    begin
        if (byte_vaild[index_r] == 1'b1 && byte_tag[index_r] == byte_read[16:8])
        begin
            hit <= 1'b1;
            data_o <= byte_data[index_r];
        end
        else 
        begin
            hit <= 1'b0;
            data_o <= 0;
        end
    end
end

endmodule
