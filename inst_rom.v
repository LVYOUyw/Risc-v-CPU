`include "defines.v"

module inst_rom(

	input wire clk,
	input wire ce,
	input wire[`InstAddrBus] addr,
	
);

	reg[`InstBus]  inst_mem[0:`InstMemNum-1];

	initial 
	begin 
		$readmemb ( "C:/Users/18617/Desktop/CPU/CPU/inst_rom.data", inst_mem);
		$display("%b",inst_mem[0]);
		$display("%b",inst_mem[1]);
		$display("%b",inst_mem[2]);
		$display("%b",inst_mem[3]);
		$display("%b",inst_mem[4]);
		$display("%b",inst_mem[5]);
		$display("%b",inst_mem[6]);
	end

	always @ (*) begin
		if (ce == `ChipDisable) begin
			inst <= `ZeroWord;
	  end else begin
		  inst <= inst_mem[addr[`InstMemNumLog2+1:2]];
		//  inst <= 32'h00226293;
		end
	end

endmodule