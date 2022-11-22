`default_nettype none
`define DUMPSTR(x) `"x.vcd`"
`timescale 1ps / 10fs

module sync_generator_tb();

parameter DURATION = 10000000;

reg pixel_clk = 0;
reg rst = 0;
always #1 pixel_clk = ~pixel_clk;

wire [9:0] cycle;
wire [8:0] scanline;
wire vga_hs;
wire vga_vs;
wire vga_blank;

sync_generator uut (
    .pixel_clk(pixel_clk),
    .rst(rst),

    .cycle(cycle),
    .scanline(scanline),
    .vga_hs(vga_hs),
    .vga_vs(vga_vs),
    .vga_blank(vga_blank)
);

initial begin
    #0.1
    rst = 1'b0;
    #1
    rst = 1'b1;
end

initial begin
  $dumpfile(`DUMPSTR(`VCD_OUTPUT));
  $dumpvars(0, sync_generator_tb);

   #(DURATION) $display("End of simulation");
  $finish;
end

endmodule