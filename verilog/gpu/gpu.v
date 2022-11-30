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
wire [7:0] pixel_data;

wire [14:0] clk_read_addr;
wire [7:0] clk_read_data;

memory mem (
    .clk(CLK100MHz),
    .clk_read_addr(clk_read_addr),

    .clk_read_data(clk_read_data)
);

clock_divider #(.DIVISON(2)) vga_div (
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

pixel_generator pixel_gen (
    .rst(rst),
    .pixel_clk(pixel_clk),
    .clk(CLK100MHz),
    .cycle(cycle),
    .scanline(scanline),

    .clk_read_addr(clk_read_addr),
    .clk_read_data(clk_read_data),

    .pixel_data(pixel_data)
);

assign vga_r = (vga_blank == 1) ? 0 : pixel_data[2:0]; 
assign vga_g = (vga_blank == 1) ? 0 : pixel_data[4:2]; 
assign vga_b = (vga_blank == 1) ? 0 : pixel_data[7:5]; 

endmodule
