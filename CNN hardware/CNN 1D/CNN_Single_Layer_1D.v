`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/23 11:16:02
// Design Name: 
// Module Name: CNN_Single_Layer_1D
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

module Multiplicator(Start, din0, din1, dout);

    input Start;
    input [3:0] din0;
    input [3:0] din1;

    output [7:0] dout;
    
    assign dout = Start ? din0 * din1 : 7'b000_0000; //start가 1이면 곱한 값 채용
    
endmodule

//---------------------------------------------------------------------------------

module RingCounter(count, clk, reset, en);
        
    input clk, reset, en;

    output reg [14:0] count;
    
    always @(posedge clk or negedge reset) begin
        if(reset == 0)
            count <= 15'b100_0000_0000_0000; //reset일 때 링카운터 초기상태
        
        else
            if(en == 1)
                count <= {count[13:0], count[14]}; //en에서 한 칸씩 왼쪽으로 shift하며 순환

    end
    
endmodule

//---------------------------------------------------------------------------------

module RingCounterX3(clk,reset, en, count);
	
	parameter Init = 14;
	
    input clk, reset, en;

    output reg [14:0] count;
    
    always @(posedge clk or negedge reset) begin
        if(reset == 0)
            count <= 15'b100_0000_0000_0000; //reset에서 링카운터3 초기상태
        
        else
            if(en == 1)
                count <= {count[Init-3:0], count[Init:Init-2]}; // en에서 세 칸씩 왼쪽으로 shift하며 순환
    end
 
endmodule

//---------------------------------------------------------------------------------

module AddressEncoder(AddrIn, AddrOut);
    
    input [14:0] AddrIn;

    output reg [3:0]AddrOut;
    
    always @(*) begin
        
        case (AddrIn) //15비트 인코더를 위한 one hot
        15'b000_0000_0000_0001: AddrOut = 4'b0001;
        15'b000_0000_0000_0010: AddrOut = 4'b0010;
        15'b000_0000_0000_0100: AddrOut = 4'b0011;
        15'b000_0000_0000_1000: AddrOut = 4'b0100;

        15'b000_0000_0001_0000: AddrOut = 4'b0101;
        15'b000_0000_0010_0000: AddrOut = 4'b0110;
        15'b000_0000_0100_0000: AddrOut = 4'b0111;
        15'b000_0000_1000_0000: AddrOut = 4'b1000;

        15'b000_0001_0000_0000: AddrOut = 4'b1001;
        15'b000_0010_0000_0000: AddrOut = 4'b1010;
        15'b000_0100_0000_0000: AddrOut = 4'b1011;
        15'b000_1000_0000_0000: AddrOut = 4'b1100;

        15'b001_0000_0000_0000: AddrOut = 4'b1101;
        15'b010_0000_0000_0000: AddrOut = 4'b1110;
        15'b100_0000_0000_0000: AddrOut = 4'b0000;
            default: AddrOut = 4'b0000;
        endcase
    end

endmodule

//---------------------------------------------------------------------------------

module ReadAddressCounter(
clk, reset, ReadEn, ReadReg
    );
    parameter Init = 14;

    input clk;
    input reset;
    input ReadEn;

    output [3:0] ReadReg;
    
    wire [Init:0] w1; //링카운터3과 인코더를 w1으로 연결

    RingCounterX3 RC3R(.count(w1), .clk(clk), .reset(reset), .en(ReadEn)); 
    AddressEncoder AER(.AddrIn(w1), .AddrOut(ReadReg));

endmodule

//---------------------------------------------------------------------------------

module WriteAddressCounter(
clk, reset, Start, WriteReg
    );
    
    input clk;
    input reset;
    input Start;

    output[3:0] WriteReg;
    
    wire[14:0] w1; //링카운터와 인코더를 w1으로 연결

    RingCounter RCW(.count(w1), .clk(clk), .reset(reset), .en(Start));
    AddressEncoder AEW(.AddrIn(w1), .AddrOut(WriteReg));

endmodule

//---------------------------------------------------------------------------------

module AddressCounter (
    ReadEn, Start, clk, reset, ReadReg1, ReadReg2, ReadReg3, WriteReg
);
    input ReadEn, Start, clk, reset;

    output[3:0] ReadReg1, ReadReg2, ReadReg3, WriteReg;

    wire[3:0] w1, w2, w3;

//세 개의 read카운터 병렬배치
    ReadAddressCounter RA1(.clk(clk), .reset(reset), .ReadEn(ReadEn), .ReadReg(w1));
    ReadAddressCounter RA2(.clk(clk), .reset(reset), .ReadEn(ReadEn), .ReadReg(w2));
    ReadAddressCounter RA3(.clk(clk), .reset(reset), .ReadEn(ReadEn), .ReadReg(w3));

    assign ReadReg1 = w1; //0,3,6,...,12
    assign ReadReg2 = w2 + 4'b0001;//1,4,...,13
    assign ReadReg3 = w3 + 4'b0010;//2,5,...,14

//한 개의 write 카운터
    WriteAddressCounter WA(.clk(clk), .reset(reset), .Start(Start), .WriteReg(WriteReg));

endmodule

//---------------------------------------------------------------------------------

module RegisterFile (clk, reset, ReadReg1, ReadReg2, ReadReg3,
WriteReg, WriteEn, WriteData, ReadEn, ReadData1, ReadData2, ReadData3);

    parameter M = 4;   // number of address bits
    parameter N = 16;  // number of words, N = 2**M
    parameter W = 8;   // number of bits in a word
    
    input clk, reset;
    input WriteEn;
    input ReadEn;
    input[W-1:0] WriteData;
    input[M-1:0] ReadReg1, ReadReg2, ReadReg3;
    input[M-1:0] WriteReg; 

    output reg [W-1:0] ReadData1, ReadData2, ReadData3;

    reg[W-1:0] regi[0:N-1]; //순서 대로 비트수, 깊이

    initial begin
       $readmemh("note.mem", regi); //메모장을 레지스터 공간으로 활용
    end

//write
    always @(posedge clk) begin
        if(WriteEn == 1)
            regi[WriteReg] <= WriteData;
            
    end

//read1
    always @(posedge clk or negedge reset) begin

        if(reset == 0)
            ReadData1 <= 0;

        else
            if(ReadEn == 1)
                ReadData1 <= regi[ReadReg1];

    end

//read2    
    always @(posedge clk or negedge reset) begin

        if(reset == 0)
            ReadData2 <= 0;

        else
            if(ReadEn == 1)
                ReadData2 <= regi[ReadReg2];

    end

//read3
    always @(posedge clk or negedge reset) begin

        if(reset == 0)
            ReadData3 <= 0;

        else
            if(ReadEn == 1)
                ReadData3 <= regi[ReadReg3];

    end
endmodule

//---------------------------------------------------------------------------------

module ADDER(
clk, reset, data1, data2, data3, out
    );

    input clk;
    input reset;
    input [7:0] data1, data2, data3;

    output reg [9:0] out;
    
    always @(posedge clk or negedge reset) begin
        if(reset == 0)
            out <= 0;

        else
            out <= data1 + data2 + data3;

    end
    
endmodule

//---------------------------------------------------------------------------------

module CNN_Single_Layer_1D(
clk, reset, Start, Image, Filter, ReadEn, ConvResult
    );
    
    input clk;
    input reset;
    input Start;
    input [3:0] Image;
    input [3:0] Filter;
    input ReadEn;
    
    output [9:0] ConvResult;

    wire [7:0] MultValue;
    
    wire [14:0] WriteRegCnt;
    wire [3:0] WriteReg;
    
    wire [14:0] ReadRegCnt1, ReadRegCnt2, ReadRegCnt3;
    wire [3:0] ReadReg1, ReadReg2, ReadReg3;
    wire [7:0] ReadData1, ReadData2, ReadData3;

    
    // ���� ���, ��� bit�� ����
    // MultValue = Image * Filter
    Multiplicator Multiplicator (.Start(Start), .din0(Image), .din1(Filter), .dout(MultValue));   // ���� ��� = Partial Sum (PSum)
   
   // Register File Read/Write �ּ� ��� 
   /*
    1. WriteReg : 0, 1, 2, ..., 14...
    2. ReadReg1 : 0, 3, 6, 9, 12, 0, 3, ...
    3. ReadReg2 : 1, 4, 7, 10, 13, 1, 4, ...
    4. ReadReg3 : 2, 5, 8, 11, 14, 2, 5, ...
   */
     AddressCounter AddressCounter (.clk(clk), .reset(reset), .Start(Start), .WriteReg(WriteReg), .ReadEn(ReadEn),
        .ReadReg1(ReadReg1), .ReadReg2(ReadReg2), .ReadReg3(ReadReg3));
    
    // ������� ���� �� ���� Partial Sum���� �����ϱ� ���� Register File
    /*
    1.  Register File ���� (Write) ����     
        1) WriteReg : Partial Sum�� Register File�� ������ �� �ּҰ� 
        2) MultValue : Partial Sum�� Register File�� ������ �� ������ ��
        3) Start : Start = 1�� ���� Register File�� ������ ����
    
    2.  Register File �б� (Read) ����
        1) ReadReg1, ReadReg2, ReadReg3 : Register File���� �����͸� �о�� �� �ּҰ� (���ÿ� 3�� �����͸� �о��)
        2) ReadData1, ReadData2, ReadData3 : Register File���� �����͸� �о�� �� �������� �� (���ÿ� 3�� �����͸� �о��)
        3) ReadEn : ReadEn = 1�� ���� �����͸� �о��

    3.  Register File�� ����
        1) Number of address bits = 4
        2) Number of words = 15
        3) Number of bits in a word = 8
    */
    //외부사정에 맞춰 파라미터 설정
    RegisterFile #(.M(4), .N(15), .W(8)) 
        RegisterFile (.clk(clk), .reset(reset), .WriteEn(Start), .WriteReg(WriteReg), .WriteData(MultValue),
        .ReadEn(ReadEn), .ReadReg1(ReadReg1), .ReadReg2(ReadReg2), .ReadReg3(ReadReg3),
        .ReadData1(ReadData1), .ReadData2(ReadData2), .ReadData3(ReadData3));
    
    // ���� ���, ��� bit�� ����
    // ConvResult = ReadData1 + ReadData2 + ReadData3
    ADDER ADDER(.clk(clk), .reset(reset), .data1(ReadData1), .data2(ReadData2), .data3(ReadData3), .out(ConvResult));
    
endmodule
