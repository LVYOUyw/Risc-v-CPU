`include "defines.v" 
module mem(
    input wire rst,
    input wire clk,
    input wire[`RegAddrBus] wd_i,
    input wire[`RegBus] data_i,
    input wire wreg_i,
    input wire[7:0] mem_data_i,
    input wire[`InstAddrBus] mem_addr_i,
    input wire[`AluOpBus] aluop_i,

    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg wmem_o,
    output reg[7:0] wmemd_o,
    output reg[`RegBus] data_o,
    output reg mem_req_o,
    output reg[`InstAddrBus] mem_addr_o,
    output reg mem_req_stall
);
reg mem_done;
reg[2:0] cnt;
reg[7:0] data1;
reg[7:0] data2;
reg[7:0] data3;
reg[31:0] curaddr;
reg[`RegAddrBus] wd;
reg wreg;
reg[`AluOpBus] aluop;
reg wmem;


always @ (posedge clk)
begin
    if (rst == `RstEnable) 
    begin
        cnt <= 3'b111;
        data1 <= 0;
        data2 <= 0;
        data3 <= 0;
        mem_done <= 1;
        mem_req_o <= 0;
        mem_req_stall <= 0;
        wd <= 0;
        wreg <= 0;
        wmem_o <= 0;
        wmemd_o <= `ZeroWord;
    end
    else 
    begin
        if (mem_req_o == `True) 
            case (cnt)
                3'b111:
                    begin
                        cnt <= 3'b100;
                        curaddr <= mem_addr_i;
                        mem_done <= 0;
                        mem_addr_o <= mem_addr_i;
                        wmemd_o <= data_i[7:0];
                        wmem_o <= (aluop_i >= 27 && aluop_i <= 29) ? 1'b1 : 1'b0;
                        wd <= wd_i;
                        wreg <= wreg_i;
                        aluop <= aluop_i;
                        wmem <= (aluop_i >= 27 && aluop_i <= 29) ? 1'b1 : 1'b0;
                        data1 <= data_i[15:8];
                        data2 <= data_i[23:16];
                        data3 <= data_i[31:24];
                    end    
                3'b100:
                    begin
                        cnt <= 3'b000;
                        mem_addr_o <= curaddr + 1;
                        wmemd_o <= data1;
                        if (aluop == `Sb) wmem_o <= 0;
                    end   
                3'b000:
                    begin
                        case (aluop) 
                            `Lb:
                                begin
                                    if (mem_data_i[7] == 1'b0) 
                                        data_o <= {24'b0, mem_data_i};
                                    else data_o <= {24'b111111111111111111111111, mem_data_i};
                                    mem_done <= 1;
                                    cnt <= 3'b111;
                                    wd_o <= wd;
                                    wreg_o <= wreg;
                                end
                            `Lbu:
                                begin
                                    data_o <= {24'b0, mem_data_i};
                                    mem_done <= 1;
                                    cnt <= 3'b111;
                                    wd_o <= wd;
                                    wreg_o <= wreg;
                                end
                            `Sb:
                                begin
                                    mem_done <= 1;
                                    data_o <= `ZeroWord;
                                    cnt <= 3'b111;
                                    wd_o <= wd;
                                    wreg_o <= wreg;
                                    wmem_o <= 0;
                                end
                            default:
                                begin  
                                    cnt <= 3'b001;
                                    data1 <= mem_data_i;
                                    mem_addr_o <= curaddr + 2;
                                    wmemd_o <= data2;
                                    if (aluop == `Sh) wmem_o <= 0;
                                    //$display("Assign: %b %b",data1, mem_data_i);
                                end
                        endcase
                    end
                3'b001:
                    begin
                        case (aluop) 
                            `Lh:
                                begin
                                    if (mem_data_i[7] == 1'b0) 
                                        data_o <= {12'b0, mem_data_i, data1};
                                    else data_o <= {12'b111111111111, mem_data_i, data1};
                                    mem_done <= 1;
                                    cnt <= 3'b111;
                                    wd_o <= wd;
                                    wreg_o <= wreg;
                                end
                            `Lhu:
                                begin
                                    data_o <= {12'b0, mem_data_i, data1};
                                    mem_done <= 1;
                                    cnt <= 3'b111;
                                    wd_o <= wd;
                                    wreg_o <= wreg;
                                end
                            `Sh:
                                begin
                                    mem_done <= 1;
                                    data_o <= `ZeroWord;
                                    cnt <= 3'b111;
                                    wd_o <= wd;
                                    wreg_o <= wreg;
                                    wmem_o <= 0;
                                end
                            default:
                                begin
                                    data2 <= mem_data_i;
                                    cnt <= 3'b010;
                                    mem_addr_o <= curaddr + 3;
                                    wmemd_o <= data3;
                                end
                        endcase
                    end
                3'b010:
                    begin
                        data3 <= mem_data_i;
                        cnt <= 3'b011;
                    end    
                3'b011:
                    begin
                        data_o <= {mem_data_i, data3, data2, data1};
                        mem_done <= 1;
                        cnt <= 3'b111;
                        wd_o <= wd;
                        wreg_o <= wreg;
                        wmem_o <= 0;
                    end
                
            endcase
        else 
            mem_done <= 1;
    end
end
 
always @ (*) 
begin
    if (rst == `True) 
    begin
        mem_req_o <= 0;
        mem_req_stall <= 0;
    end
    else if (mem_done) 
    begin
        mem_req_o <= (aluop_i >= 22 && aluop_i <= 29) ? 1'b1 : 1'b0;
        mem_req_stall <= mem_req_o;
    end
    else if (!mem_done) 
    begin
        mem_req_o <= 1;
        mem_req_stall <= 1;
    end
end

always @ (*) 
begin
    if (rst == `True) 
    begin
        wd_o <= 0;
        data_o <= 0;
        wreg_o <= 0;
        wmem_o <= 0;
        wmemd_o <= `ZeroWord;
    end
    else 
    begin
        wd_o <= wd_i;
        if (aluop_i < 22 || aluop_i > 29) data_o <= data_i;
        wreg_o <= wreg_i;
    end    
end
endmodule