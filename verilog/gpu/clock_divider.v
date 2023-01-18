// Valid DIVISION is even multipliers of 2

module clock_divider #(
  parameter DIVISON = 2,
  parameter DIVISION_WIDTH = 2
)(
    input clk,
    input rst,

    output reg tick,
    output reg [DIVISION_WIDTH:0] sub_count
);

reg [DIVISION_WIDTH:0] count;

always @(posedge clk) begin
    if(tick == 1'b0 && count == (DIVISON / 2) - 1) begin
        sub_count <= 1'b0;
    end else begin
        sub_count <= sub_count + 1'b1;
    end

    if (rst == 0) begin
        count <= 1'b0;
        tick <= 1'b0;
        sub_count <= 1'b0;
    end else if (count == (DIVISON / 2) - 1) begin
        count <= 1'b0;
        tick <= ~tick;
    end else begin
        count <= count + 1'b1; 
    end
end

endmodule
