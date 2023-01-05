`default_nettype none
`define DUMPSTR(x) `"x.vcd`"
`timescale 1ns / 10ps

module pixel_generator_tb();

wire pixel_clk;
reg CLK100MHz = 1;
reg rst = 0;
wire [7:0] pixel_data;

reg [9:0] cycle;
reg [8:0] scanline;

wire tile_memory_read_enable;
wire [10:0] tile_memory_read_addr;
wire [7:0] tile_memory_read_data;

wire attribute_memory_read_enable;
wire [11:0] attribute_memory_read_addr;
wire [7:0] attribute_memory_read_data;

wire color_memory_read_enable;
wire [3:0] color_memory_read_addr;
wire [7:0] color_memory_read_data;

clock_divider #(.DIVISON(2)) vga_div (
    .clk(CLK100MHz),
    .rst(rst),
    .tick(pixel_clk)
);

memory #(
    .ADDRESS_WIDTH(11),
    .INIT_FILE("tile_mem.txt")
) tile_memory (
    .clk(CLK100MHz),
    .read_enable(tile_memory_read_enable),
    .read_addr(tile_memory_read_addr),
    .read_data(tile_memory_read_data),

    .write_enable(1'b0),
    .write_data(8'd0),
    .write_addr(11'b0)
);

memory #(
    .ADDRESS_WIDTH(12),
    .INIT_FILE("attribute_mem.txt")
) attribute_memory (
    .clk(CLK100MHz),
    .read_enable(attribute_memory_read_enable),
    .read_addr(attribute_memory_read_addr),
    .read_data(attribute_memory_read_data),

    .write_enable(1'b0),
    .write_data(8'd0),
    .write_addr(12'b0)
);

memory #(
    .ADDRESS_WIDTH(4),
    .INIT_FILE("color_mem.txt")
) color_memory (
    .clk(CLK100MHz),
    .read_enable(color_memory_read_enable),
    .read_addr(color_memory_read_addr),
    .read_data(color_memory_read_data),

    .write_enable(1'b0),
    .write_data(8'd0),
    .write_addr(4'b0)
);


pixel_generator uut (
    .rst(rst),
    .pixel_clk(pixel_clk),
    .clk(CLK100MHz),
    .cycle(cycle),
    .scanline(scanline),

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

initial begin
$dumpfile(`DUMPSTR(`VCD_OUTPUT));
    $dumpvars(0, pixel_generator_tb);

    #1 CLK100MHz = ~CLK100MHz;     #1 CLK100MHz = ~CLK100MHz; 
    rst = 1'b0;
    #1 CLK100MHz = ~CLK100MHz;     #1 CLK100MHz = ~CLK100MHz; 
    rst = 1'b1;

    cycle = 19;
    scanline = 1;

    #1 CLK100MHz = ~CLK100MHz;     #1 CLK100MHz = ~CLK100MHz;
    #1 CLK100MHz = ~CLK100MHz;     #1 CLK100MHz = ~CLK100MHz;
    #1 CLK100MHz = ~CLK100MHz;     #1 CLK100MHz = ~CLK100MHz;
    #1 CLK100MHz = ~CLK100MHz;     #1 CLK100MHz = ~CLK100MHz;

    cycle = 20;
    scanline = 2;

    #1 CLK100MHz = ~CLK100MHz;     #1 CLK100MHz = ~CLK100MHz;
    #1 CLK100MHz = ~CLK100MHz;     #1 CLK100MHz = ~CLK100MHz;
    #1 CLK100MHz = ~CLK100MHz;     #1 CLK100MHz = ~CLK100MHz;
    #1 CLK100MHz = ~CLK100MHz;     #1 CLK100MHz = ~CLK100MHz;

    #1 CLK100MHz = ~CLK100MHz;     #1 CLK100MHz = ~CLK100MHz;
    #1 CLK100MHz = ~CLK100MHz;     #1 CLK100MHz = ~CLK100MHz;
    #1 CLK100MHz = ~CLK100MHz;     #1 CLK100MHz = ~CLK100MHz;
    #1 CLK100MHz = ~CLK100MHz;     #1 CLK100MHz = ~CLK100MHz;

    $display("End of simulation");
    $finish;
end

endmodule