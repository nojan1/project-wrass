module pixel_generator (
    input rst,
    input pixel_clk,
    input clk,
    input [9:0] cycle,
    input [8:0] scanline,
    input [7:0] clk_read_data,

    output reg [14:0] clk_read_addr,
    output [7:0] pixel_data
);

reg [9:0] offsetCycle;
reg [8:0] offsetScanline;

reg [1:0] step;
reg [7:0] tileNumber;
reg pixelOn;
reg [7:0] color;

// There will be 3 clk between each pixel_clk, use these clock cycles to fetch stuff from RAM
always @ (posedge clk or negedge rst) begin
    if(rst == 0) begin
        step <= 0;
    end else begin
        case (step)
            1: begin
                clk_read_addr <= (cycle << 4) | (scanline >> 3);
            end 
            2: begin
                tileNumber <= clk_read_data;
                clk_read_addr <= 16'h4000 + (cycle & 7) + (tileNumber << 3);
            end
            3: begin
                // tileData = clk_read_data;
                pixelOn <= (clk_read_data >> (scanline & 7)) & 1;
                clk_read_addr <= 16'h2000 + (cycle << 4) | (scanline >> 3); 
            end
        endcase

        if (step < 3) begin
            step <= step + 1;
        end else begin
            step <= 0;
        end
    end
end

always @ (posedge pixel_clk) begin
    color = clk_read_addr[7:0];
    // if(pixelOn) begin
    //     color <= 0;
    // end else begin
    //     color <= 255;
    // end
end

assign pixel_data = color;

endmodule