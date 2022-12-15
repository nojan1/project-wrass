module pixel_generator (
    input rst,
    input pixel_clk,
    input clk,
    input [9:0] cycle,
    input [8:0] scanline,
    input [7:0] clk_read_data,

    output reg [12:0] clk_read_addr,
    output [7:0] pixel_data
);

reg [1:0] step;
reg [7:0] tileNumber;
reg [7:0] tileData;
reg [7:0] colorAttribute;
reg pixelOn;
reg [7:0] color;

wire [9:0] offsetCycle = ((cycle >> 1) + (0)) & 9'h1ff;
wire [8:0] offsetScanline = ((scanline >> 1) + (0)) & 8'hff;

wire [5:0] charColumn = offsetCycle >> 3;
wire [4:0] charRow = offsetCycle >> 3;

wire [2:0] charRenderColumn = offsetCycle & 3'h7;
wire [2:0] charRenderRow = offsetScanline & 3'h7;

// There will be 3 clk between each pixel_clk, use these clock cycles to fetch stuff from RAM
always @ (posedge clk or negedge rst) begin
    if(rst == 0) begin
        step <= 0;
        pixelOn <= 0;
        color <= 0;
    end else begin
        case (step)
            0: begin
                
                clk_read_addr = {2'b00, charRow, charColumn};
                tileNumber = clk_read_data;
                step = step + 1;
            end 
            1: begin
                clk_read_addr = {2'b10, charRenderRow + (tileNumber << 3)};
                tileData = clk_read_data;
                step = step + 1;
            end
            2: begin
                pixelOn = (tileData >> charRenderColumn) & 1;
                clk_read_addr = {2'b01, charRow, charColumn};
                colorAttribute = clk_read_data;
                step = step + 1;
            end
            3: begin
                if(pixelOn == 1) begin
                    clk_read_addr = 13'h1800 + colorAttribute[7:4];
                end else begin
                    clk_read_addr = 13'h1800 + colorAttribute[3:0];
                end

                color = clk_read_data;
                step = 0;
            end
        endcase
    end
end

assign pixel_data = color;

endmodule