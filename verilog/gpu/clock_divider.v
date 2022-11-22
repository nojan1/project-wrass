module clock_divider #(
  parameter DIVISON = 2,
  parameter DIVISION_WIDTH = 2
)(
    input clk,
    input rst,

    output reg tick
);

reg [DIVISION_WIDTH:0] count;

always @(posedge clk or negedge rst) begin
    if (rst == 0) begin
        count <= 1'b0;
        tick <= 1'b0;
    end else if (count == DIVISON - 1) begin
        count <= 1'b0;
        tick <= ~tick;
    end else begin
        count <= count + 1'b1; 
    end
end

endmodule
