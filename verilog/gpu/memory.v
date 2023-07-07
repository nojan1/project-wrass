module memory #(
     parameter  INIT_FILE = "",
     parameter  ADDRESS_WIDTH = 10,
     parameter  DATA_WIDTH = 8
) (
    input read_clk,
    input [ADDRESS_WIDTH - 1:0] read_addr,
    input read_enable,
    
    input write_clk,
    input [ADDRESS_WIDTH - 1:0] write_addr,
    input write_enable,
    input [DATA_WIDTH - 1:0] write_data, 

    output reg [DATA_WIDTH - 1:0] read_data
);

    reg [7:0] mem [0:(2**ADDRESS_WIDTH) - 1];
    
    // Interact with the memory block
    always @ (posedge read_clk) begin
        // Read from memory
        if(read_enable == 1'b1) begin
            read_data <= mem[read_addr];
        end
    end

    always @ (posedge write_clk) begin
	// Write to memory
        if (write_enable == 1'b1) begin
            mem[write_addr] <= write_data;
        end
    end

    initial if (INIT_FILE) begin
        $readmemh(INIT_FILE, mem);
    end

endmodule
