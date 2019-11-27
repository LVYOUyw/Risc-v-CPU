`include "defines.v" 
module regfile(
    input wire clk,
    input wire rst,

//  write port 
    input wire we,
    input wire[`RegAddrBus] waddr,
    input wire[`RegBus] wdata,

// read port 1
    input wire re1,
    input wire[`RegAddrBus] raddr1,
    output reg[`RegBus] rdata1,

// read port 2
    input wire re2,
    input wire[`RegAddrBus] raddr2,
    output reg[`RegBus] rdata2
);

reg[`RegBus] regs[0:`RegNum-1];

    
initial 
begin
    regs[0] = 0;
    regs[1] = 0;
    regs[2] = 0;
    regs[3] = 0;
    regs[4] = 0;
    regs[5] = 0;
    regs[6] = 0;
end

always @ (posedge clk)              //write
begin
    if (rst == `RstDisable) 
        if ((we == `WriteEnable) && (waddr != 5'h0)) 
        begin
            regs[waddr] <= wdata;
           // $display("waddr: %d\n",waddr);
           // $display("wdata: %d\n",wdata);
        end
end

always @ (*) 
begin
    if (rst == `RstEnable) 
        rdata1 <= `ZeroWord;
    else if (raddr1 == 5'h0) 
        rdata1 <= `ZeroWord;
    else if ((raddr1 == waddr) && (we == `WriteEnable) && (re1 == `ReadEnable)) //forword
        rdata1 <= wdata;
    else if (re1 == `ReadEnable) 
        rdata1 <= regs[raddr1];
    else 
        rdata1 <= `ZeroWord;
end

always @ (*) 
begin
    if (rst == `RstEnable) 
        rdata2 <= `ZeroWord;
    else if (raddr2 == 5'h0) 
        rdata2 <= `ZeroWord;
    else if ((raddr2 == waddr) && (we == `WriteEnable) && (re2 == `ReadEnable)) //forword
        rdata2 <= wdata;
    else if (re2 == `ReadEnable) 
        rdata2 <= regs[raddr2];
    else 
        rdata2 <= `ZeroWord;
end

endmodule 