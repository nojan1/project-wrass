module pixel_generator (
    input rst,
    input pixel_clk,
    input clk,
    input vga_blank,
    input [2:0] divider_count,
    input [9:0] cycle,
    input [8:0] scanline,
    input [7:0] tile_memory_read_data,
    input [7:0] attribute_memory_read_data,
    input [7:0] color_memory_read_data,

    output reg [10:0] tile_memory_read_addr,
    output reg tile_memory_read_enable,
    output reg [11:0] attribute_memory_read_addr,
    output reg attribute_memory_read_enable,
    output reg [3:0] color_memory_read_addr,
    output reg color_memory_read_enable,
    output [7:0] pixel_data
);

reg [7:0] tileNumber;
reg [7:0] tileData;
reg [7:0] colorAttribute;
reg [7:0] color;

wire [9:0] offsetCycle = cycle[9:1] + 0;
wire [8:0] offsetScanline = scanline[8:1] + 0;

wire [5:0] charColumn = offsetCycle >> 3;
wire [4:0] charRow = offsetScanline >> 3;

wire [2:0] charRenderColumn = offsetCycle & 3'h7;
wire [2:0] charRenderRow = offsetScanline & 3'h7;

// There will be 3 clk between each pixel_clk, use these clock cycles to fetch stuff from RAM
always @ (negedge clk or negedge rst) begin
    if(rst == 0) begin
        color <= 0;
        tile_memory_read_addr <= 0;
        tileNumber <= 0;
        tileData <= 0;
        colorAttribute <= 0;
        tile_memory_read_enable <= 0;
    end else begin
        case (divider_count)
            0: begin
                tile_memory_read_addr = {charRow, charColumn};
                tile_memory_read_enable = 1;

                attribute_memory_read_addr = {1'b0, charRow, charColumn};
                attribute_memory_read_enable = 1;
            end 
            1: begin
                tileNumber = tile_memory_read_data;
                colorAttribute = attribute_memory_read_data;

                attribute_memory_read_addr = {1'b1, tileNumber, charRenderRow};
                attribute_memory_read_enable = 1;
            end
            2: begin
                tileData = attribute_memory_read_data;

                color_memory_read_addr = tileData[charRenderColumn+:1] ? colorAttribute[7:4] : colorAttribute[3:0];
                color_memory_read_enable = 1;
            end
        endcase
    end
end

assign pixel_data = color_memory_read_data;

endmodule