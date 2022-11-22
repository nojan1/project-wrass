module gpu (
    input CLK100MHz,
    input rst,
    input [7:0] data,
    input [3:0] addr,
    input rw,
    input cs_clock,

    output wire vga_hs,
    output wire vga_vs,
    output wire [2:0] vga_r,
    output wire [2:0] vga_g,
    output wire [2:0] vga_b,
    output wire irq
);

wire pixel_clk;
wire vga_blank;
wire [9:0] cycle;
wire [8:0] scanline;

clock_divider #(.DIVISON(4)) vga_div (
    .clk(CLK100MHz),
    .rst(rst),
    .tick(pixel_clk)
);

sync_generator sync_gen (
    .pixel_clk(pixel_clk),
    .rst(rst),

    .cycle(cycle),
    .scanline(scanline),
    .vga_hs(vga_hs),
    .vga_vs(vga_vs),
    .vga_blank(vga_blank)
);

assign vga_r = (vga_blank == 1) ? 0 : cycle[2:0]; 
assign vga_g = (vga_blank == 1) ? 0 : cycle[5:2]; 
assign vga_b = (vga_blank == 1) ? 0 : cycle[8:5]; 

endmodule
