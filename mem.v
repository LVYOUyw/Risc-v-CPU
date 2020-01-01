`include "defines.v" 
module mem(
    input wire rst,
    input wire rdy,
    input wire clk,
    input wire[`RegAddrBus] wd_i,
    input wire[`RegBus] data_i,
    input wire wreg_i,
    input wire[7:0] mem_data_i,
    input wire[`InstAddrBus] mem_addr_i,
    input wire[`AluOpBus] aluop_i,

   // input wire hit,
   // input wire[`InstAddrBus] cache_data,

    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg wmem_o,
    output reg[7:0] wmemd_o,
    output reg[`RegBus] data_o,
    output reg mem_req_o,

  //  output reg write_cache,

    output reg[`InstAddrBus] mem_addr_o
);
reg mem_done;
reg[2:0] cnt;
reg state;
reg[7:0] data1;
reg[7:0] data2;
reg[7:0] data3;
reg[31:0] curaddr;
reg[`RegAddrBus] wd;
reg wreg;
reg[`AluOpBus] aluop;
reg[31:0] data;


always @ (posedge clk)
begin
    if (rst == `RstEnable || rdy != `True) 
    begin
        cnt <= 3'b111;
        data1 <= 0;
        data2 <= 0;
        data3 <= 0;
        data <= 0;
        mem_done <= 1;
        wd <= 0;
        wreg <= 0;
        state <= 0;
        wmem_o <= 0;
        wmemd_o <= `ZeroWord;
        mem_addr_o <= 0;
    end
    else 
    begin
        if (mem_req_o == `True) 
            case (cnt)
                3'b111:
                    begin
                        cnt <= 3'b100;
                        state <= 1'b1;
                        curaddr <= mem_addr_i;
                        mem_done <= 0; 
                        wmem_o <= (aluop_i >= 27 && aluop_i <= 29) ? 1'b1 : 1'b0;
                        mem_addr_o <= mem_addr_i;
                        wmemd_o <= data_i[7:0];
                        wd <= wd_i;
                        wreg <= wreg_i;
                        aluop <= aluop_i;
                        data1 <= data_i[15:8];
                        data2 <= data_i[23:16];
                        data3 <= data_i[31:24];
                    end    
                3'b100:
                    begin
                        if (aluop == `Sb || aluop == `Lb || aluop == `Lbu) 
                        begin
                            //if (aluop == `Sb) $display("Sb %x %x",curaddr,wmem_o);
                            wmem_o <= 0;
                            mem_addr_o <= 0;
                            wmemd_o <= 0;
                        end
                        else 
                        begin
                            mem_addr_o <= curaddr + 1;
                            wmemd_o <= data1;
                        end
                        cnt <= 3'b000; 
                    end   
                3'b000:
                    begin
                        case (aluop) 
                            `Lb:
                                begin
                                    if (mem_data_i[7] == 1'b0) 
                                        data <= {24'b0, mem_data_i};
                                    else data <= {24'b111111111111111111111111, mem_data_i};
                              //      $display("Lb %x %x",curaddr,data);
                                    mem_done <= 1;
                                    cnt <= 3'b111;
                                end
                            `Lbu:
                                begin
                                    data <= {24'b0, mem_data_i};
                             //       $display("Lb %x %x",curaddr,data);
                                    mem_done <= 1;
                                    cnt <= 3'b111;
                                end
                            `Sb:
                                begin 
                                    wmem_o <= 0;
                                    mem_done <= 1;
                                    mem_addr_o <= 0;
                                    data <= `ZeroWord;
                                    cnt <= 3'b111; 
                                end
                            default:
                                begin  
                                    cnt <= 3'b001;
                                    if (aluop == `Sh) wmem_o <= 0;
                                    data1 <= mem_data_i;
                                    mem_addr_o <= curaddr + 2;
                                    wmemd_o <= data2;
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
                                        data <= {12'b0, mem_data_i, data1};
                                    else data <= {12'b111111111111, mem_data_i, data1};
                                    mem_done <= 1;
                                    cnt <= 3'b111;
                                end
                            `Lhu:
                                begin
                                    data <= {12'b0, mem_data_i, data1};
                                    mem_done <= 1;
                                    cnt <= 3'b111;
                                end
                            `Sh:
                                begin
                                    mem_done <= 1;
                                    data <= `ZeroWord;
                                    cnt <= 3'b111;
                                    wmem_o <= 0;
                                    mem_addr_o <= 0;
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
                        data <= {mem_data_i, data3, data2, data1};
                    //    if (aluop == `Lw) $display("LW %x %x",curaddr,data);
                   //     else if (aluop == `Sw) $display("SW %x %x",curaddr,data);
                        mem_done <= 1;
                        cnt <= 3'b111; 
                        wmem_o <= 0;
                        wmemd_o <= 0;
                        mem_addr_o <= 0;                       
                    end
                
            endcase
        else 
        begin
            mem_done <= 1;
            state <= 1'b0;
        end
    end
end
 
always @ (*) 
begin
    if (rst == `True || rdy != `True) 
    begin
        mem_req_o <= 0;
    end
    else if (mem_done) 
    begin
        mem_req_o <= (aluop_i >= 22 && aluop_i <= 29) ? 1'b1 : 1'b0;
    end
    else if (!mem_done) 
    begin
        mem_req_o <= 1;
    end
end

always @ (*) 
begin
    if (rst == `True || rdy != `True) 
    begin
        wd_o <= 0;
        data_o <= 0;
        wreg_o <= 0;
    end
    else 
    begin
        if (state == 1'b0)
        begin
            data_o <= data_i; 
            wd_o <= wd_i;
            wreg_o <= wreg_i;
        end
        else 
        begin
            data_o <= data;
            wd_o <= wd;
            wreg_o <= wreg;
        end
    end    
end
endmodule