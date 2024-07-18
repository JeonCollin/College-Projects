`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/21 15:30:54
// Design Name: 
// Module Name: tb_sharp_CNN2D_quick
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


module tb_sharp_CNN2D_quick();

    reg clk;
    reg reset;
    reg signed [0:71] filter;
    reg signed [0:143] filter_2;
    reg [9:0] ReadReg;

    wire [31:0] ReadData;

    initial begin
    clk = 0; reset = 1;

    filter={8'd1, 8'd1, 8'd1,
            8'd1, 8'd9, 8'd1,
            8'd1, 8'd1, 8'd1};

    filter_2={16'd1, 16'd1, 16'd1,
            16'd1, 16'd9, 16'd1,
            16'd1, 16'd1, 16'd1};
            
    #2; reset = 0;
    #2; reset = 1;

    end
    
    always #0.2 clk = ~clk;
    
    sharp_CNN2D_quick scq(
    .clk(clk),
    .reset(reset),
    .filter(filter),
    .filter_2(filter_2),
    .ReadData(ReadData),
    .ReadReg(ReadReg)
    );

endmodule