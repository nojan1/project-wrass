module memory #(
     parameter   INIT_FILE = "mem.txt"
) (
    input clk,
    input [12:0] clk_read_addr,
    
    output reg [7:0] clk_read_data
);

    reg [7:0] mem [0:7000];
    
    // Interact with the memory block
    always @ (posedge clk) begin
    
        // // Write to memory
        // if (w_en == 1'b1) begin
        //     mem[w_addr] <= w_data;
        // end
        
        // // Read from memory
        // if (r_en == 1'b1) begin
        //     r_data <= mem[r_addr];
        // end

        clk_read_data = mem[clk_read_addr];
    end

    initial if (INIT_FILE) begin
        $readmemh(INIT_FILE, mem);
    end

endmodule