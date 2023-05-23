`default_nettype none
`define DUMPSTR(x) `"x.vcd`"
`timescale 1ps / 10fs

module gpu_tb();

parameter DURATION = 10000000;

reg CLK100MHz = 0;
reg rst = 0;
always #1 CLK100MHz = ~CLK100MHz;

wire [7:0] data = 0;
wire [2:0] addr = 0;
wire rw = 0;
wire cs = 1;
wire cpu_clk = 0;

wire [2:0] vga_r;
wire [2:0] vga_g;
wire [2:0] vga_b;
wire vga_hs;
wire vga_vs;

gpu uut (
    .CLK100MHz(CLK100MHz),
    .rst(rst),
    .data(data),
    .addr(addr),
    .rw(rw),
    .cs(cs),
    .cpu_clk(cpu_clk),

    .vga_hs(vga_hs),
    .vga_vs(vga_vs),
    .vga_r(vga_r),
    .vga_g(vga_g),
    .vga_b(vga_b)
);

initial begin
    #0.1
    rst = 1'b0;
    #1
    rst = 1'b1;
end

initial begin
  $dumpfile(`DUMPSTR(`VCD_OUTPUT));
  $dumpvars(0, gpu_tb);

   #(DURATION) $display("End of simulation");
  $finish;
end

endmodule