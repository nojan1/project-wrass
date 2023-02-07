module bus_interface (
    input [7:0] data,
    input [2:0] addr,
    input rw,
    input cs_clock,
    input clk,
    input rst,

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

reg [7:0] increment;
reg [15:0] internal_memory_address;

initial begin
    increment <= 1;
    internal_memory_address <= 16'h0;
end

always @ (negedge cs_clock or posedge clk) begin
    color_memory_write_enable <= 0;
    tile_memory_write_enable <= 0;
    attribute_memory_write_enable <= 0;

    if(rst == 1'b0) begin
        increment <= 1;
        internal_memory_address <= 16'h0;
    end else begin
        if(cs_clock == 1'b0) begin
            if(rw == 1'b0) begin
                // Write
                case (addr)
                    3: begin
                    increment <= data; 
                    end
                    4: begin
                        internal_memory_address <= { internal_memory_address[15:8], data };
                    end
                    5: begin
                        internal_memory_address <= { data, internal_memory_address[7:0] };
                    end
                    6: begin
                        // Perform memory op
                        if (internal_memory_address < 16'h0800) begin
                            // Write to framebuffer
                            tile_memory_write_enable = 1;
                            tile_memory_write_addr = internal_memory_address[10:0];
                            tile_memory_write_data = data;
                        end             

                        if (internal_memory_address >= 16'h0800 && internal_memory_address < 16'h1800 ) begin
                            // Write to color attributes or tile map
                            attribute_memory_write_enable = 1;
                            attribute_memory_write_addr = internal_memory_address - 16'h0800;
                            attribute_memory_write_data = data; 
                        end

                        if (internal_memory_address >= 16'h1800) begin
                            // Write to colors
                            color_memory_write_enable = 1;
                            color_memory_write_addr = internal_memory_address[3:0];
                            color_memory_write_data = data;
                        end

                        if (increment != 0) begin
                            internal_memory_address <= internal_memory_address + increment;
                        end
                    end            
                endcase
            end
        end
    end
end

// always @ (posedge cs_clock) begin 
//     data <= 8'bzzzzzzzz;
// end

endmodule