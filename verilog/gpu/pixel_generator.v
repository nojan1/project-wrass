module pixel_generator (
    input rst,
    input pixel_clk,
    input clk,
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

reg gottenPixelClock;

reg [1:0] step;
reg [7:0] tileNumber;
reg [7:0] tileData;
reg [7:0] colorAttribute;
reg pixelOn;
reg [7:0] color;

reg [9:0] offsetCycle;
reg [8:0] offsetScanline;

reg [5:0] charColumn;
reg [4:0] charRow;

reg [2:0] charRenderColumn;
reg [2:0] charRenderRow;

// There will be 3 clk between each pixel_clk, use these clock cycles to fetch stuff from RAM
always @ (posedge clk or negedge rst) begin
    if(rst == 0) begin
        gottenPixelClock <= 0;
        step <= 0;
        pixelOn <= 0;
        color <= 0;
        offsetCycle <= 0;
        offsetScanline <= 0;
        charColumn <= 0;
        charRow <= 0;
        charRenderColumn <= 0;
        charRenderRow <= 0;
        tile_memory_read_addr <= 0;
        tileNumber <= 0;
        tileData <= 0;
        colorAttribute <= 0;
        tile_memory_read_enable <= 0;
    end else begin
        offsetCycle <= cycle[9:1] + 0;
        offsetScanline <= scanline[8:1] + 0;

        if(gottenPixelClock == 1 || pixel_clk == 1) begin
            gottenPixelClock = 1;

            case (step)
                0: begin
                    charColumn = offsetCycle >> 3; 
                    charRow = offsetScanline >> 3;

                    charRenderColumn = offsetCycle & 3'h7;
                    charRenderRow = offsetScanline & 3'h7;

                    tile_memory_read_addr = {charRow, charColumn};
                    tile_memory_read_enable = 1;

                    attribute_memory_read_addr = {1'b0, charRow, charColumn};
                    attribute_memory_read_enable = 1;
                    step = step + 1;
                end 
                1: begin
                    tileNumber = tile_memory_read_data;
                    colorAttribute = attribute_memory_read_data;

                    attribute_memory_read_addr = {1'b1, tileNumber, charRenderRow};
                    attribute_memory_read_enable = 1;
                    step = step + 1;
                end
                2: begin
                    tileData = attribute_memory_read_data;
                    pixelOn = (tileData >> charRenderColumn) & 1;

                    color_memory_read_addr = pixelOn == 1 ? colorAttribute[7:4] : colorAttribute[3:0];
                    color_memory_read_enable = 1;

                    step = 0;
                end
            endcase
        end
    end
end

assign pixel_data =  /* pixel_clk == 1 ? */ color_memory_read_data /* : 0 */;

endmodule