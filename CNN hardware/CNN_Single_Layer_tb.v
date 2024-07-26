`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/23 17:11:14
// Design Name: 
// Module Name: CNN_Single_Layer_tb
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


module CNN_Single_Layer_tb();
    
    reg clk;
    reg reset;
    reg Start;
    reg [3:0] Image;
    reg [3:0] Filter;
    reg ReadEn;

    wire [9:0] ConvResult;
    
    wire[7:0] MultValue;
    wire[3:0] WriteReg, ReadReg1, ReadReg2, ReadReg3;
    wire[7:0] WriteData, ReadData1, ReadData2, ReadData3;
    //wire[0:14][7:0] reg_File;
    wire[7:0] data1,data2, data3;

    initial begin
    clk = 0; reset = 1; Start = 0;  ReadEn = 0;  Image = 0; Filter = 0;   
    #10; reset = 0;
    #10; reset = 1;
        // Convolution Operation Start  
   #10; Image = 4'd1;     Filter = 4'd1;  Start = 1;
   #10; Image = 4'd2;     Filter = 4'd2;
   #10; Image = 4'd3;     Filter = 4'd3;
                                 
   #10; Image = 4'd2;     Filter = 4'd1;
   #10; Image = 4'd3;     Filter = 4'd2;
   #10; Image = 4'd4;     Filter = 4'd3;
                                 
   #10; Image = 4'd3;     Filter = 4'd1;
   #10; Image = 4'd4;     Filter = 4'd2;
   #10; Image = 4'd5;     Filter = 4'd3;
                                 
   #10; Image = 4'd4;     Filter = 4'd1;
   #10; Image = 4'd5;     Filter = 4'd2;
   #10; Image = 4'd6;     Filter = 4'd3;
                                 
   #10; Image = 4'd5;     Filter = 4'd1;
   #10; Image = 4'd6;     Filter = 4'd2;
   #10; Image = 4'd7;     Filter = 4'd3;
   
    // Convolution Operation Finish
   #10; Image = 4'd0;     Filter = 4'd0;  Start = 0;
   #10; ReadEn = 1;
   #70; $finish;
    end
    
    always #5 clk = ~clk;
    
    CNN_Single_Layer_1D uut(
    .clk(clk),
    .reset(reset),
    .Start(Start),
    .Image(Image),
    .Filter(Filter),
    .ReadEn(ReadEn),
    .ConvResult(ConvResult)
    );

endmodule
