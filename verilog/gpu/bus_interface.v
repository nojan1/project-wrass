module bus_interface (
    input [7:0] data,
    input [2:0] addr,
    input rw,
    input cs_clock,

    output reg tile_memory_write_enable,
    output reg [10:0] tile_memory_write_addr,
    output reg [7:0] tile_memory_write_data,

    output reg attribute_memory_write_enable,
    output reg [11:0] attribute_memory_write_addr,
    output reg [7:0] attribute_memory_write_data,

    output reg color_memory_write_enable,
    output reg [3:0] color_memory_write_addr,
    output reg [7:0] color_memory_write_data
);
 
reg [7:0] registers [16:0];

wire [15:0] memory_address = { registers[5], registers[4] };

// TODO: Add support for RST
integer i;
initial begin
  for (i=0;i<=15;i=i+1)
    registers[i] = 0;
end

always @ (negedge cs_clock) begin
    if(rw == 1'b0) begin
        // Write
        if(addr == 6) begin 
            // Perform memory op
            if (memory_address < 16'h0800) begin
                // Write to framebuffer
                tile_memory_write_enable <= 1;
                tile_memory_write_addr <= memory_address[10:0];
                tile_memory_write_data <= data;
            end             

            if (memory_address >= 16'h0800 && memory_address < 16'h1800 ) begin
                // Write to color attributes or tile map
                attribute_memory_write_enable <= 1;
                attribute_memory_write_addr <= memory_address - 16'h0800;
                attribute_memory_write_data <= data; 
            end

            if (memory_address >= 16'h1800) begin
                // Write to colors
                color_memory_write_enable <= 1;
                color_memory_write_addr <= memory_address[3:0];
                color_memory_write_data <= data;
            end

            if (registers[3] != 0) begin
                registers[4] <= registers[4] + registers[3];
                // TODO: Handle wrap around on the high byte
            end
        end else begin
            registers[addr] <= data;
        end
    end
end

// always @ (posedge cs_clock) begin 
//     data <= 8'bzzzzzzzz;
// end

endmodule