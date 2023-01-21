module gpu (
    input CLK100MHz,
    input rst,
    input [7:0] data,
    input [2:0] addr,
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
wire [2:0] divider_count;

wire tile_memory_read_enable;
wire [10:0] tile_memory_read_addr;
wire [7:0] tile_memory_read_data;
wire tile_memory_write_enable;
wire [10:0] tile_memory_write_addr;
wire [7:0] tile_memory_write_data;

wire attribute_memory_read_enable;
wire [11:0] attribute_memory_read_addr;
wire [7:0] attribute_memory_read_data;
wire attribute_memory_write_enable;
wire [11:0] attribute_memory_write_addr;
wire [7:0] attribute_memory_write_data;

wire color_memory_read_enable;
wire [3:0] color_memory_read_addr;
wire [7:0] color_memory_read_data;
wire color_memory_write_enable;
wire [3:0] color_memory_write_addr;
wire [7:0] color_memory_write_data;

memory #(
    .ADDRESS_WIDTH(11),
    .INIT_FILE("tile_mem.txt")
) tile_memory (
    .clk(CLK100MHz),
    .read_enable(tile_memory_read_enable),
    .read_addr(tile_memory_read_addr),
    .read_data(tile_memory_read_data),

    .write_enable(tile_memory_write_enable),
    .write_data(tile_memory_write_data),
    .write_addr(tile_memory_write_addr)
);

memory #(
    .ADDRESS_WIDTH(12),
    .INIT_FILE("attribute_mem.txt")
) attribute_memory (
    .clk(CLK100MHz),
    .read_enable(attribute_memory_read_enable),
    .read_addr(attribute_memory_read_addr),
    .read_data(attribute_memory_read_data),

    .write_enable(attribute_memory_write_enable),
    .write_data(attribute_memory_write_data),
    .write_addr(attribute_memory_write_addr)
);

memory #(
    .ADDRESS_WIDTH(4),
    .INIT_FILE("color_mem.txt")
) color_memory (
    .clk(CLK100MHz),
    .read_enable(color_memory_read_enable),
    .read_addr(color_memory_read_addr),
    .read_data(color_memory_read_data),

    .write_enable(color_memory_write_enable),
    .write_data(color_memory_write_data),
    .write_addr(color_memory_write_addr)
);


clock_divider #(.DIVISON(4)) vga_div (
    .clk(CLK100MHz),
    .rst(rst),
    .tick(pixel_clk),
    .sub_count(divider_count)
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
    .vga_blank(vga_blank),
    .divider_count(divider_count),

    .tile_memory_read_enable(tile_memory_read_enable),
    .tile_memory_read_addr(tile_memory_read_addr),
    .tile_memory_read_data(tile_memory_read_data),

    .attribute_memory_read_enable(attribute_memory_read_enable),
    .attribute_memory_read_addr(attribute_memory_read_addr),
    .attribute_memory_read_data(attribute_memory_read_data),

    .color_memory_read_enable(color_memory_read_enable),
    .color_memory_read_addr(color_memory_read_addr),
    .color_memory_read_data(color_memory_read_data),

    .pixel_data(pixel_data)
);

bus_interface bus_interface (
    .data(data),
    .addr(addr),
    .rw(rw),
    .cs_clock(cs_clock),

    .tile_memory_write_enable(tile_memory_write_enable),
    .tile_memory_write_addr(tile_memory_write_addr),
    .tile_memory_write_data(tile_memory_write_data),

    .attribute_memory_write_enable(attribute_memory_write_enable),
    .attribute_memory_write_addr(attribute_memory_write_addr),
    .attribute_memory_write_data(attribute_memory_write_data),

    .color_memory_write_enable(color_memory_write_enable),
    .color_memory_write_addr(color_memory_write_addr),
    .color_memory_write_data(color_memory_write_data) 
);

assign vga_r = (vga_blank == 1) ? 0 : pixel_data[2:0]; 
assign vga_g = (vga_blank == 1) ? 0 : pixel_data[5:3]; 
assign vga_b = (vga_blank == 1) ? 0 : {pixel_data[7:6], pixel_data[6]}; 

assign irq = pixel_clk;

endmodule
