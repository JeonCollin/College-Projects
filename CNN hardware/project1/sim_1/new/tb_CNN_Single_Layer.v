`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/08 22:30:59
// Design Name: 
// Module Name: tb_CNN_Single_Layer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_Single_Layer();

    reg clk;
    reg reset;
    reg signed [0:71] filter;
    reg [9:0] ReadReg;

    wire [15:0] ReadData;

    initial begin

    clk = 0; reset = 1;
    
    filter={8'd1, 8'd0, 8'd1,
            8'd2, 8'd0, 8'd2,
            8'd1, 8'd0, 8'd1};
    #2; reset = 0;
    #2; reset = 1;

    end
    
    always #0.5 clk = ~clk;
    
    CNN_Single_Layer cq(
    .clk(clk),
    .reset(reset),
    .filter(filter),
    .ReadData(ReadData),
    .ReadReg(ReadReg)
    );

endmodule