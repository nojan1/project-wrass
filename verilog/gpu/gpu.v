module gpu (

);

wire pixel_clk;

clock_divider #(.DIVISON(4)) vga_div (
    .clk(CLK100MHz)
    .tick(pixel_clk)
);

endmodule
