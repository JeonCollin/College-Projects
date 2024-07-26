`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/08 22:29:38
// Design Name: 
// Module Name: CNN_Single_Layer
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

`define image_w 32
`define image_h 32

`define filter_w 3
`define filter_h 3

`define image_whole 1024
`define filter_whole 9

//convolution shifting counter
module num_counter (clk, reset, count);

    input clk, reset;

    output reg[9:0] count;

    always @(posedge clk or negedge reset) begin
        
        if(reset == 0) begin // initialization
            
            count <= 0;

        end

        else if(count%32 == 29 && count!=0) begin
            
            count <= count + `filter_w;// chage row every 29, 61, 93...(end of the image)

        end

        else begin
            
            count <= count + 1; // shift to left, stride = 1

        end

    end

    
endmodule

//---------------------------------------------------------------------------------

//image shifter + multiplier
module image_shifter(clk, count, reset, filter, dout0, dout1, dout2, dout3, dout4, dout5, dout6, dout7, dout8);


    input clk, reset;
    input [9:0] count;
    input [0:71] filter; // 8bit filter, 9x9 = 2D matrix to 1D matrix

    //result of multiply
    output reg[15:0] dout0;
    output reg[15:0] dout1;
    output reg[15:0] dout2;
    output reg[15:0] dout3;
    output reg[15:0] dout4;
    output reg[15:0] dout5;
    output reg[15:0] dout6;
    output reg[15:0] dout7;
    output reg[15:0] dout8;

    reg [7:0] Image[0:1023]; //input image

    initial $readmemh("sobel_input.mem", Image); // call input image

    always @(posedge clk or negedge reset) begin

        if(reset == 0) begin // initialization

            dout8 <= 16'bx;
            dout7 <= 16'bx;
            dout6 <= 16'bx;
            dout5 <= 16'bx;         
            dout4 <= 16'bx;    
            dout3 <= 16'bx;
            dout2 <= 16'bx;   
            dout1 <= 16'bx;       
            dout0 <= 16'bx;

        end

        else begin //multiply image and filter

            //count makes image shift to left row or down column
            dout0 <= Image[0*`image_w + count]                  * filter[0:7]; // row1 x filter[0], [1], [2] // size = 8bit
            dout1 <= Image[0*`image_w + 1 + count]              * filter[8:15];
            dout2 <= Image[0*`image_w + `filter_w - 1 + count]  * filter[16:23];
            dout3 <= Image[1*`image_w + count]                  * filter[24:31]; // row2 x filter[3], [4], [5]
            dout4 <= Image[1*`image_w + 1 + count]              * filter[32:39];
            dout5 <= Image[1*`image_w + `filter_w - 1 + count]  * filter[40:47];
            dout6 <= Image[2*`image_w + count]                  * filter[48:55]; // row3 x filter[6], [7], [8]
            dout7 <= Image[2*`image_w + 1 + count]              * filter[56:63];
            dout8 <= Image[2*`image_w + `filter_w - 1 + count]  * filter[64:71];

            end
        end
    
endmodule

//---------------------------------------------------------------------------------

// sum 9 pixels = 1 convolution ended
module ADDER2D(count, ConvResultEn, dout0, dout1, dout2, dout3, dout4, dout5, dout6, dout7, dout8, ConvResult);

    input[9:0] count;
    input [15:0] dout0, dout1, dout2, dout3, dout4, dout5, dout6, dout7, dout8;

    output [15:0] ConvResult;
    output ConvResultEn;

    //sum of dout, it is convolution result
    assign ConvResult =(-dout0) + dout1 + dout2
                        - dout3 + dout4 + dout5
                        - dout6 + dout7 + dout8;
    
    assign ConvResultEn = (ConvResult >= 0) ? 1'b1: 1'b0; // EN = 1 if first convolution ended
    

endmodule

//---------------------------------------------------------------------------------

module register2D(ConvResult, clk, reset, ConvResultEn, ReadReg, ReadData);
    
    integer i = 0;
    integer j;

    input [15:0] ConvResult; 
    input clk, reset, ConvResultEn;
    input [9:0] ReadReg;
    output [15:0] ReadData;

    reg [15:0] memout[0:899];
   
    always @(posedge clk or negedge reset) begin
        if (reset == 0) begin
            i <= 0;
            // memout initialization
            for (j = 0; j < 900; j = j + 1) begin
                memout[j] <= 16'b0;
            end
        end
        
        else begin
            if (ConvResultEn == 1) begin
                memout[i] <= ConvResult; // write convolution result temporary
                i <= i + 1;
            end
            // write at Output.mem
            if (i == 900) begin
                $writememh("Output.mem", memout);
            end
        end
    end
    
    assign ReadData = memout[ReadReg];

endmodule   
            
//---------------------------------------------------------------------------------

module CNN_Single_Layer(clk, reset, filter, ReadData, ReadReg);

    input clk, reset;
    input signed [0:71] filter ;
    input [9:0] ReadReg;

    output[15:0] ReadData;

    wire[9:0] count;
    wire[15:0] dout0, dout1, dout2, dout3, dout4, dout5, dout6, dout7, dout8;
    wire [15:0] ConvResult;
    wire ConvResultEn;
    wire [9:0] ReadReg;

    num_counter counter(.clk(clk), .reset(reset), .count(count));

    image_shifter shifter(.count(count), .filter(filter), .clk(clk), .reset(reset),
    .dout0(dout0), .dout1(dout1), .dout2(dout2), .dout3(dout3), .dout4(dout4), .dout5(dout5), .dout6(dout6), .dout7(dout7), .dout8(dout8));

    ADDER2D Adder(.count(count), .ConvResultEn(ConvResultEn), .ConvResult(ConvResult),
    .dout0(dout0), .dout1(dout1), .dout2(dout2), .dout3(dout3), .dout4(dout4), .dout5(dout5), .dout6(dout6), .dout7(dout7), .dout8(dout8));

    register2D register(.ConvResult(ConvResult), .reset(reset), .clk(clk), .ConvResultEn(ConvResultEn), .ReadReg(ReadReg), .ReadData(ReadData));
    
endmodule