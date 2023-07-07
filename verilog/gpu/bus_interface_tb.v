`default_nettype none
`define DUMPSTR(x) `"x.vcd`"
`timescale 1ns / 10ps

module bus_interface_tb();

reg CLK100MHz = 1;

reg [7:0] data = 0;
reg [2:0] addr = 0;
reg rw = 1;
reg cs = 1;
reg cpu_clk = 0;

reg tile_memory_read_enable;
reg [10:0] tile_memory_read_addr;
wire [7:0] tile_memory_read_data;
wire tile_memory_write_enable;
wire [10:0] tile_memory_write_addr;
wire [7:0] tile_memory_write_data;

reg attribute_memory_read_enable;
reg [11:0] attribute_memory_read_addr;
wire [7:0] attribute_memory_read_data;
wire attribute_memory_write_enable;
wire [11:0] attribute_memory_write_addr;
wire [7:0] attribute_memory_write_data;

reg color_memory_read_enable;
reg [3:0] color_memory_read_addr;
wire [7:0] color_memory_read_data;
wire color_memory_write_enable;
wire [3:0] color_memory_write_addr;
wire [7:0] color_memory_write_data;

wire cpu_clk_inv = ~cpu_clk;

memory #(
    .ADDRESS_WIDTH(11),
    .INIT_FILE("tile_mem.txt")
) tile_memory (
    .read_clk(CLK100MHz),
    .read_enable(tile_memory_read_enable),
    .read_addr(tile_memory_read_addr),
    .read_data(tile_memory_read_data),

    .write_clk(cpu_clk_inv),
    .write_enable(tile_memory_write_enable),
    .write_data(tile_memory_write_data),
    .write_addr(tile_memory_write_addr)
);

memory #(
    .ADDRESS_WIDTH(12),
    .INIT_FILE("attribute_mem.txt")
) attribute_memory (
    .read_clk(CLK100MHz),
    .read_enable(attribute_memory_read_enable),
    .read_addr(attribute_memory_read_addr),
    .read_data(attribute_memory_read_data),

    .write_clk(cpu_clk_inv),
    .write_enable(attribute_memory_write_enable),
    .write_data(attribute_memory_write_data),
    .write_addr(attribute_memory_write_addr)
);

memory #(
    .ADDRESS_WIDTH(4),
    .INIT_FILE("color_mem.txt")
) color_memory (
    .read_clk(CLK100MHz),
    .read_enable(color_memory_read_enable),
    .read_addr(color_memory_read_addr),
    .read_data(color_memory_read_data),

    .write_clk(cpu_clk_inv),
    .write_enable(color_memory_write_enable),
    .write_data(color_memory_write_data),
    .write_addr(color_memory_write_addr)
);

bus_interface uut (
    .data(data),
    .addr(addr),
    .rw(rw),
    .cs(cs),
    .cpu_clk(cpu_clk),
    .clk(CLK100MHz),

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

always #0.5 CLK100MHz = ~CLK100MHz;

initial begin
$dumpfile(`DUMPSTR(`VCD_OUTPUT));
    $dumpvars(0, bus_interface_tb);

    #2

    cs = 0;

    // Write aa to 0100
    #1 addr = 4'h4; data = 8'h00; rw = 0; cpu_clk = 0; #1 cpu_clk = 1;
    #1 addr = 4'h5; data = 8'h01; rw = 0; cpu_clk = 0; #1 cpu_clk = 1;
    #1 addr = 4'h6; data = 8'haa; rw = 0; cpu_clk = 0; #1 cpu_clk = 1;

    // Write 0e to 0900
    #1 addr = 4'h4; data = 8'h00; rw = 0; cpu_clk = 0; #1 cpu_clk = 1;
    #1 addr = 4'h5; data = 8'h09; rw = 0; cpu_clk = 0; #1 cpu_clk = 1;
    #1 addr = 4'h6; data = 8'h0e; rw = 0; cpu_clk = 0; #1 cpu_clk = 1;
    
    // Write be to 1802
    #1 addr = 4'h4; data = 8'h02; rw = 0; cpu_clk = 0; #1 cpu_clk = 1;
    #1 addr = 4'h5; data = 8'h18; rw = 0; cpu_clk = 0; #1 cpu_clk = 1;
    #1 addr = 4'h6; data = 8'hbe; rw = 0; cpu_clk = 0; #1 cpu_clk = 1;

    // Read from 0100 in tile_memory, should be aa
    #1 tile_memory_read_addr = 11'h0100; tile_memory_read_enable = 1;

    // Read from 0100 in attribute_memory, should be 0e
    #2 attribute_memory_read_addr = 12'h0100; attribute_memory_read_enable = 1;

    // Read from 2 in color_memory, should be be
    #2 color_memory_read_addr = 4'h2; color_memory_read_enable = 1;

    #2 

    $display("End of simulation");
    $finish;
end

endmodule
