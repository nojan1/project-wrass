module sync_generator (
    input pixel_clk, 
    input rst,

    output reg [9:0] cycle,
    output reg [8:0] scanline,
    output vga_hs,
    output vga_vs,
    output reg vga_blank
);

always @ (posedge pixel_clk or negedge rst) begin
    if (rst == 1'b0) begin
        cycle = 0;
        scanline = 0;
    end else begin
        cycle = cycle + 1'b1;

        if (cycle == 800) begin
            cycle = 0;
            scanline = scanline + 1;

            if (scanline == 525) begin
                scanline = 0;
            end
        end
    
        if (cycle >= 640 || scanline >= 480) begin
            vga_blank = 1'b1;
        end else begin
            vga_blank = 1'b0;
        end
    end
end

assign vga_hs = ~(cycle >= (640 + 16) && cycle < (640 + 16 + 96));
assign vga_vs = ~(scanline >= (480 + 10) && scanline < (480 + 10 + 2)); 

endmodule
