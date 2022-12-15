`default_nettype none
`define DUMPSTR(x) `"x.vcd`"
`timescale 1ns / 10ps

module pixel_generator_tb();

parameter DURATION = 20;

wire pixel_clk = 0;
reg CLK100MHz = 0;
reg rst = 0;
wire [7:0] pixel_data;

reg [9:0] cycle;
reg [8:0] scanline;

wire [14:0] clk_read_addr;
wire [7:0] clk_read_data;

always #1 CLK100MHz = ~CLK100MHz;

clock_divider #(.DIVISON(2)) vga_div (
    .clk(CLK100MHz),
    .rst(rst),
    .tick(pixel_clk)
);

pixel_generator uut (
    .rst(rst),
    .pixel_clk(pixel_clk),
    .clk(CLK100MHz),
    .cycle(cycle),
    .scanline(scanline),

    .clk_read_addr(clk_read_addr),
    .clk_read_data(clk_read_data),

    .pixel_data(pixel_data)
);

initial begin
    #0.1 rst = 1'b0;
    cycle = 50;
    scanline = 2;
    #1 rst = 1'b1;
end

initial begin
  $dumpfile(`DUMPSTR(`VCD_OUTPUT));
  $dumpvars(0, pixel_generator_tb);

   #(DURATION) $display("End of simulation");
  $finish;
end

endmodule