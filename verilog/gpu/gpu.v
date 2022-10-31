module gpu (

);

clock_divider #(.DIVISON(4)) vga_div (
    .clk(CLK100MHz)
);

endmodule
