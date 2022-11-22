`default_nettype none
`define DUMPSTR(x) `"x.vcd`"
`timescale 100 ns / 10 ns

module clock_divider_tb();

parameter DURATION = 20;

reg clk = 0;
reg rst = 0;
always #0.5 clk = ~clk;

wire pixel_clk;

clock_divider #(.DIVISON(4), .DIVISION_WIDTH(3)) uut (
    .clk(clk),
    .rst(rst),
    .tick(pixel_clk)
);

initial begin
    #0.1
    rst = 1'b0;
    #1
    rst = 1'b1;
end

initial begin
  $dumpfile(`DUMPSTR(`VCD_OUTPUT));
  $dumpvars(0, clock_divider_tb);

   #(DURATION) $display("End of simulation");
  $finish;
end

endmodule