// RISCV32I CPU top module
// port modification allowed for debugging purposes
`include "defines.v"
module cpu(
    input  wire                 clk_in,			// system clock signal
    input  wire                 rst_in,			// reset signal
	input  wire					rdy_in,			// ready signal, pause cpu when low

    input  wire [ 7:0]          mem_din,		// data input bus
    output wire [ 7:0]          mem_dout,		// data output bus
    output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
    output wire                 mem_wr,			// write/read signal (1 for write)

	output wire [31:0]			dbgreg_dout		// cpu register output (debugging demo)
);
//if_in
wire if_jump;
wire[`InstAddrBus] if_jump_addr;
wire if_req_i;
wire[6:0] stall;
wire[6:0] stall_o;
wire[`InstBus] cache_inst_i;
wire pdd;
wire hittt;
wire iff;

// id_in
wire[`InstAddrBus] pc;
wire[`InstAddrBus] id_pc_i;
wire[`InstBus] id_inst_i;
wire id_ignore_i;
wire hit;

//id_out
wire[`AluOpBus] id_aluop_o;
wire[`RegBus] id_reg1_o;
wire[`RegBus] id_reg2_o;
wire id_wreg_o;
wire[`RegAddrBus] id_wd_o;
wire id_next_ignore_o;
wire id_current_ignore;
wire[`InstAddrBus] id_pc_store_o;
wire[`RegBus] id_immt;
wire w_cache_o;
wire[`InstBus] cache_inst;
wire[`InstAddrBus] cache_pc;


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
wire[`RegBus] ex_mem_addr;
wire[`AluOpBus] ex_mem_aluop;
wire[`RegBus] ex_immt;

//mem_in
wire mem_wreg_i;
wire[`RegAddrBus] mem_wd_i;
wire[`RegBus] mem_data_i;
wire[`RegBus] mem_mem_addr;
wire[`AluOpBus] mem_mem_aluop;

//mem_out
wire mem_wreg_o;
wire[`RegAddrBus] mem_wd_o;
wire[`RegBus] mem_data_o;
wire mem_wmem_o;

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

//mcu
wire mcu_mem_req;
wire[`InstAddrBus] mcu_addr_o;
wire[7:0] mem_write_data;

pc_reg pc_reg0(
    .clk(clk_in), 
    .rst(rst_in),
    .pc(pc),
    .hit(hit),
    .pd(pdd),
    .jump(if_jump),
    .ifing(iff),
    .stall_i(stall),
    .stall_o(stall_o),
    .hitt(hittt),
    .jump_addr(if_jump_addr)
);


if_id if_id0(
    .clk(clk_in),
    .rst(rst_in),
    .if_request(if_req_i), 
    .if_pc(pc),
    .hit(hit),
    .lasthit(hittt),
    .if_inst(mem_din),
    .inst_i(cache_inst_i),
    .jump(if_jump),
    .stall_i(stall_o),
    .stttt(stall),
    .id_pc(id_pc_i),
    .id_inst(id_inst_i),
    .pd(pdd),
    .ifing(iff)
);

id id0(
    .rst(rst_in),
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
    .immt(id_immt),

    //id to icache
    .w_cache(w_cache_o),
    .inst_o(cache_inst),
    .pc_o(cache_pc),
    
    //id to if
    .jump_o(if_jump),
    .jump_addr_o(if_jump_addr),
    .stall_o(stall)
);

regfile regfile0(
    .clk(clk_in),
    .rst(rst_in),
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
    .clk(clk_in),
    .rst(rst_in),

    .id_aluop(id_aluop_o),
    .id_reg1(id_reg1_o),
    .id_reg2(id_reg2_o),
    .id_wd(id_wd_o),
    .id_wreg(id_wreg_o),
    .ignore_i(id_next_ignore_o),
    .id_pc_store(id_pc_store_o),
    .immt_i(id_immt),

    .ex_aluop(ex_aluop_i),
    .ex_reg1(ex_reg1_i),
    .ex_reg2(ex_reg2_i),
    .ex_wd(ex_wd_i),
    .ex_wreg(ex_wreg_i),
    .ignore_id(id_current_ignore),
    .ex_pc_store(ex_pc_store_i),
    .immt_o(ex_immt)
    
);

ex ex0(
    .rst(rst_in),

    .aluop_i(ex_aluop_i),
    .reg1_i(ex_reg1_i),
    .reg2_i(ex_reg2_i),
    .wd_i(ex_wd_i),
    .wreg_i(ex_wreg_i),
    .pc_store_i(ex_pc_store_i),
    .immt(ex_immt),

    .mem_addr_o(ex_mem_addr),
    .aluop_o(ex_mem_aluop),
    .wd_o(ex_wd_o),
    .wreg_o(ex_wreg_o),
    .data_o(ex_data_o)
);

ex_mem ex_mem0(
    .clk(clk_in),
    .rst(rst_in),

    .ex_wd(ex_wd_o),
    .ex_wreg(ex_wreg_o),
    .ex_data(ex_data_o),
    .mem_addr_i(ex_mem_addr),
    .aluop_i(ex_mem_aluop),

    .mem_addr_o(mem_mem_addr),
    .aluop_o(mem_mem_aluop),
    .mem_wd(mem_wd_i),
    .mem_wreg(mem_wreg_i),
    .mem_data(mem_data_i)
); 

mem mem0(
    .rst(rst_in),
    .clk(clk_in),
    .wd_i(mem_wd_i),
    .wreg_i(mem_wreg_i),
    .data_i(mem_data_i),
    .mem_addr_i(mem_mem_addr),
    .aluop_i(mem_mem_aluop),
    .mem_data_i(mem_din),

    .wd_o(mem_wd_o),
    .wreg_o(mem_wreg_o),
    .data_o(mem_data_o),
    .mem_req_o(mcu_mem_req),
    .mem_addr_o(mcu_addr_o),
    .wmem_o(mem_wmem_o),
    .wmemd_o(mem_write_data)
);

mem_wb mem_wb0(
    .clk(clk_in),
    .rst(rst_in),

    .mem_wd(mem_wd_o),
    .mem_wreg(mem_wreg_o),
    .mem_data(mem_data_o),

    .wb_wd(wb_wd_i),
    .wb_wreg(wb_wreg_i),
    .wb_data(wb_data_i)
);

memctrl memctrl0(
    .rst(rst_in),
    .rdy(rdy_in),
    .if_addr_i(pc),
    .if_request(if_req_i),
    .mem_request(mcu_mem_req),
    .mem_addr_i(mcu_addr_o),
    .mem_addr_o(mem_a),
    .write_i(mem_wmem_o),
    .write_o(mem_wr),
    .wdata_i(mem_write_data),
    .wdata_o(mem_dout)
);

icache icache0(
    .clk(clk_in),
    .rst(rst_in),
    .rdy(rdy_in),
    .pc_write(cache_pc),
    .pc_read(pc),
    .inst_i(cache_inst),
    .write_i(w_cache_o),
    .hit(hit),
    .inst_o(cache_inst_i)
);

endmodule