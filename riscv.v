module riscv(

    input wire clk,
    input wire rst,

    input wire[`RegBus] rom_data_i,
    output wire[`RegBus] rom_addr_o,
    output wire rom_ce_o
);
//if_in
wire if_jump;
wire[`InstAddrBus] if_jump_addr;

// id_in
wire[`InstAddrBus] pc;
wire[`InstAddrBus] id_pc_i;
wire[`InstBus] id_inst_i;
wire id_ignore_i;

//id_out
wire[`AluOpBus] id_aluop_o;
wire[`RegBus] id_reg1_o;
wire[`RegBus] id_reg2_o;
wire id_wreg_o;
wire[`RegAddrBus] id_wd_o;
wire id_next_ignore_o;
wire id_current_ignore;
wire[`InstAddrBus] id_pc_store_o;

//ex_in
wire[`AluOpBus] ex_aluop_i;
wire[`RegBus] ex_reg1_i;
wire[`RegBus] ex_reg2_i;
wire ex_wreg_i;
wire[`RegAddrBus] ex_wd_i;
wire next_ignore_i;
wire[`InstAddrBus] ex_pc_store_i;

//ex_out
wire ex_wreg_o;
wire[`RegAddrBus] ex_wd_o;
wire[`RegBus] ex_data_o;

//mem_in
wire mem_wreg_i;
wire[`RegAddrBus] mem_wd_i;
wire[`RegBus] mem_data_i;

//mem_out
wire mem_wreg_o;
wire[`RegAddrBus] mem_wd_o;
wire[`RegBus] mem_data_o;

//wb_in
wire wb_wreg_i;
wire[`RegAddrBus] wb_wd_i;
wire[`RegBus] wb_data_i;

//id - regfile
wire reg1_read;
wire reg2_read;
wire[`RegBus] reg1_data;
wire[`RegBus] reg2_data;
wire[`RegAddrBus] reg1_addr;
wire[`RegAddrBus] reg2_addr;

pc_reg pc_reg0(
    .clk(clk), 
    .rst(rst),
    .pc(pc),
    .ce(rom_ce_o),
    .jump(if_jump),
    .jump_addr(if_jump_addr)
);

assign rom_addr_o = pc;

if_id if_id0(
    .clk(clk),
    .rst(rst),
    .if_pc(pc),
    .if_inst(rom_data_i),
    .id_pc(id_pc_i),
    .id_inst(id_inst_i)
);

id id0(
    .rst(rst),
    .pc_i(id_pc_i),
    .inst_i(id_inst_i),
    .ignore_i(id_current_ignore),

    //ex to id
    .ex_wreg_i(ex_wreg_o),
    .ex_wd_i(ex_wd_o),
    .ex_wdata_i(ex_data_o),

    //mem to id
    .mem_wreg_i(mem_wreg_o),
    .mem_wd_i(mem_wd_o),
    .mem_wdata_i(mem_data_o),

    //regfile
    .data1_i(reg1_data),
    .data2_i(reg2_data),
    .reg1_read_o(reg1_read),
    .reg2_read_o(reg2_read),
    .reg1_addr_o(reg1_addr),
    .reg2_addr_o(reg2_addr),

    //id to ex
    .aluop_o(id_aluop_o),
    .reg1_o(id_reg1_o),
    .reg2_o(id_reg2_o),
    .wd_o(id_wd_o),
    .wreg_o(id_wreg_o),
    .next_ignore_o(id_next_ignore_o),
    .pc_store_o(id_pc_store_o),
    
    //id to if
    .jump_o(if_jump),
    .jump_addr_o(if_jump_addr)
);

regfile regfile0(
    .clk(clk),
    .rst(rst),
    .we(wb_wreg_i),
    .waddr(wb_wd_i),
    .wdata(wb_data_i),
    .re1(reg1_read),
    .re2(reg2_read),
    .raddr1(reg1_addr),
    .raddr2(reg2_addr),
    .rdata1(reg1_data),
    .rdata2(reg2_data)
);

id_ex id_ex0(
    .clk(clk),
    .rst(rst),

    .id_aluop(id_aluop_o),
    .id_reg1(id_reg1_o),
    .id_reg2(id_reg2_o),
    .id_wd(id_wd_o),
    .id_wreg(id_wreg_o),
    .ignore_i(id_next_ignore_o),
    .id_pc_store(id_pc_store_o),

    .ex_aluop(ex_aluop_i),
    .ex_reg1(ex_reg1_i),
    .ex_reg2(ex_reg2_i),
    .ex_wd(ex_wd_i),
    .ex_wreg(ex_wreg_i),
    .ignore_id(id_current_ignore),
    .ex_pc_store(ex_pc_store_i)
);

ex ex0(
    .rst(rst),

    .aluop_i(ex_aluop_i),
    .reg1_i(ex_reg1_i),
    .reg2_i(ex_reg2_i),
    .wd_i(ex_wd_i),
    .wreg_i(ex_wreg_i),
    .pc_store_i(ex_pc_store_i),

    .wd_o(ex_wd_o),
    .wreg_o(ex_wreg_o),
    .data_o(ex_data_o)
);

ex_mem ex_mem0(
    .clk(clk),
    .rst(rst),

    .ex_wd(ex_wd_o),
    .ex_wreg(ex_wreg_o),
    .ex_data(ex_data_o),

    .mem_wd(mem_wd_i),
    .mem_wreg(mem_wreg_i),
    .mem_data(mem_data_i)
); 

mem mem0(
    .rst(rst),

    .wd_i(mem_wd_i),
    .wreg_i(mem_wreg_i),
    .data_i(mem_data_i),

    .wd_o(mem_wd_o),
    .wreg_o(mem_wreg_o),
    .data_o(mem_data_o)
);

mem_wb mem_wb0(
    .clk(clk),
    .rst(rst),

    .mem_wd(mem_wd_o),
    .mem_wreg(mem_wreg_o),
    .mem_data(mem_data_o),

    .wb_wd(wb_wd_i),
    .wb_wreg(wb_wreg_i),
    .wb_data(wb_data_i)
);

endmodule