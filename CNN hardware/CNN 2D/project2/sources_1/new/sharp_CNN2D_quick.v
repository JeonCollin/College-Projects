`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/21 15:27:22
// Design Name: 
// Module Name: sharp_CNN2D_quick
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

`define image2_w 30
`define image2_h 30

`define filter2_w 3
`define filter2_h 3

`define image2_whole 900
`define filter2_whole 9


//convolution shifting counter
module sharp_num_counter (clk, reset, count);

    input clk, reset;

    output reg[9:0] count;

    always @(posedge clk or negedge reset) begin
        
        if(reset == 0) begin // initialization
            
            count <= 0;

        end

        else if(count%32==29 && count!=0) begin
            
            count <= count + `filter_w;//29+3=32 chage row when convolution met end of the image

        end

        else begin
            
            count <= count + 1; // shift to left, stride = 1

        end

    end

endmodule

//---------------------------------------------------------------------------------

module sharp_num_counter_2 (clk, reset, count_2);//for second convolution

    input clk, reset;

    output reg[9:0] count_2;

    always @(posedge clk or negedge reset) begin
        
        if(reset == 0) begin // initialization
            
            count_2 <= 0;

        end

        else if(count_2%30==27 && count_2!=0) begin
            
            count_2 <= count_2 + `filter_w;//27+3=30 chage row when convolution met end of the image

        end

        else begin
            
            count_2 <= count_2 + 1; // shift to left, stride = 1

        end

    end

    
endmodule

//---------------------------------------------------------------------------------

//image shifter + multiplier
module sharp_image_shifter(clk, count, count_2, reset, filter, filter_2, ConvResult_2, ConvResultEn);

    input clk, reset;
    input [9:0] count, count_2;
    input [0:71] filter; // 8bit filter, 9x9 = 2D matrix to 1D matrix
    input [0:143] filter_2;
    integer k, j;

    //result of multiply
    reg [15:0] dout0, dout1, dout2,dout3,dout4,dout5,dout6,dout7,dout8;
    reg [31:0] dout0_2, dout1_2, dout2_2, dout3_2, dout4_2, dout5_2, dout6_2, dout7_2, dout8_2;
    reg [7:0] Image[0:1023]; //input image
    reg [15:0] mem1 [0:899];
    reg [31:0] memout[0:783];

    wire [15:0] ConvResult;

    output reg [31:0] ConvResult_2;
    output ConvResultEn;

    // call input image
    initial $readmemh("sharpening_input.mem", Image);

    always@(*)begin

    if(reset==0)begin

        dout0=16'bx;
        dout1=16'bx;
        dout2=16'bx;
        dout3=16'bx;
        dout4=16'bx;
        dout5=16'bx;
        dout6=16'bx;
        dout7=16'bx;
        dout8=16'bx;

    end

    //convolution
    else begin
            dout0 = Image[0*`image_w + count]                  * filter[0:7]; // row1 x filter[0], [1], [2] // size = 8bit
            dout1 = Image[0*`image_w + 1 + count]              * filter[8:15];
            dout2 = Image[0*`image_w + `filter_w - 1 + count]  * filter[16:23];
            dout3 = Image[1*`image_w + count]                  * filter[24:31]; // row2 x filter[3], [4], [5]
            dout4 = Image[1*`image_w + 1 + count]              * filter[32:39];
            dout5 = Image[1*`image_w + `filter_w - 1 + count]  * filter[40:47];
            dout6 = Image[2*`image_w + count]                  * filter[48:55]; // row3 x filter[6], [7], [8]
            dout7 = Image[2*`image_w + 1 + count]              * filter[56:63];
            dout8 = Image[2*`image_w + `filter_w - 1 + count]  * filter[64:71];
    end

    end

    assign ConvResult = - dout0 - dout1 - dout2
                        - dout3 + dout4 - dout5
                        - dout6 - dout7 - dout8;

    //memwrite    
        always@(posedge clk) begin
            if(reset==0) k<=0;
            else begin
                mem1[k]<=ConvResult;
                k<=k+1;
                if(k==900) $writememh("conv1.mem", mem1);
            end
        end

        //second convolution
    always@(*) begin

    if (k >= 900) begin
        dout0_2 = $signed(mem1[0*30 + count_2])                  * $signed(filter_2[0:15]); // row1 x filter[0], [1], [2]
        dout1_2 = $signed(mem1[0*30 + 1 + count_2])              * $signed(filter_2[16:31]);
        dout2_2 = $signed(mem1[0*30 + `filter_w - 1 + count_2])  * $signed(filter_2[32:47]);
        dout3_2 = $signed(mem1[1*30 + count_2])                  * $signed(filter_2[48:63]); // row2 x filter[3], [4], [5]
        dout4_2 = $signed(mem1[1*30 + 1 + count_2])              * $signed(filter_2[64:79]);
        dout5_2 = $signed(mem1[1*30 + `filter_w - 1 + count_2])  * $signed(filter_2[80:95]);
        dout6_2 = $signed(mem1[2*30 + count_2])                  * $signed(filter_2[96:111]); // row3 x filter[6], [7], [8]
        dout7_2 = $signed(mem1[2*30 + 1 + count_2])              * $signed(filter_2[112:127]);
        dout8_2 = $signed(mem1[2*30 + `filter_w - 1 + count_2])  * $signed(filter_2[128:143]);
        ConvResult_2 = - dout0_2 - dout1_2 - dout2_2
                        - dout3_2 + dout4_2 - dout5_2
                        - dout6_2 - dout7_2 - dout8_2;
    end
    
    else begin

        dout0_2 = 32'bx;
        dout1_2 = 32'bx;
        dout2_2 = 32'bx;
        dout3_2 = 32'bx;
        dout4_2 = 32'bx;
        dout5_2 = 32'bx;
        dout6_2 = 32'bx;
        dout7_2 = 32'bx;
        dout8_2 = 32'bx;
        ConvResult_2 = 32'bx;

    end
end

assign ConvResultEn = (ConvResult_2 >= 0) ? 1'b1: 1'b0;

endmodule

//---------------------------seconde memwrite------------------------------------------------------

module sharp_register2D(ConvResult_2, clk, reset, ReadReg, ReadData, ConvResultEn);
    
    integer n = 0;
    integer m;

    input [31:0] ConvResult_2; 
    input clk, reset;
    input [9:0] ReadReg;
    input ConvResultEn;

    output [31:0] ReadData;

    reg [31:0] memout[0:783];
    
    always @(posedge clk) begin
        
        if (reset == 0) begin
            n <= 0;

            // memout initialization
            for (m = 0; m < 784; m = m + 1) begin
                memout[m] <= 32'b0;
            end

        end
        
        else begin

            if (ConvResultEn == 1) begin
                memout[n] <= ConvResult_2; // write convolution result temporary
                n <= n + 1;
            end

            // write at conv2.mem
            if (n == 784) begin
                $writememh("conv2.mem", memout);
            end
        end
    end

    assign ReadData = memout[ReadReg];

endmodule 
            
//--------------------------------------------------------------------------------

module sharp_CNN2D_quick(clk, reset, filter,filter_2, ReadData, ReadReg);

    input clk, reset;
    input  [0:71] filter ;
    input [0:143] filter_2 ;
    input [9:0] ReadReg;

    output[15:0] ReadData;

    wire[9:0] count, count_2;
    wire [31:0] ConvResult_2;
    wire ConvResultEn;
    wire [9:0] ReadReg;

    sharp_num_counter nc(.clk(clk), .reset(reset), .count(count));

    sharp_num_counter_2 nc2(.clk(clk), .reset(reset), .count_2(count_2));

    sharp_image_shifter is(.clk(clk), .count(count), .count_2(count_2), 
    .reset(reset), .filter(filter),.filter_2(filter_2), .ConvResult_2(ConvResult_2), .ConvResultEn(ConvResultEn));

    sharp_register2D r2(.ConvResult_2(ConvResult_2), .reset(reset), .clk(clk), 
    .ConvResultEn(ConvResultEn), .ReadReg(ReadReg), .ReadData(ReadData));

endmodule