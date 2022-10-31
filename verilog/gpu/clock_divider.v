module clock_divider #(
  parameter DIVISON = 2
)(
    input clk,

    output tick
);

reg count = 0;

always @(posedge clk) begin
    if (count == DIVISON) begin
        count <= count + 1; 
    end else begin
        count <= 0;
        tick <= 1'b1;
    end
end

endmodule
