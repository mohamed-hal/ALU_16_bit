`timescale 1ns / 1ps
module ALU_16_bits(
    output reg[15:0]Result, output reg[5:0]Status, input [15:0] A,B, input[4:0]F, input Cin
    );
    reg Co15 ; // CARRY HOLDER
    parameter[4:0]
    INC=5'b00001, DEC=5'b00011, ADD=5'b00100, ADC=5'b00101,
    SUB=5'b00110, SBB=5'b00111, AND=5'b01000, OR=5'b01001,
    XOR=5'b01010, NOT=5'b01011, SHL=5'b10000, SHR=5'b10001,
    SAL=5'b10010, SAR=5'b10011, ROL=5'b10100, ROR=5'b10101,
    RCL=5'b10110, RCR=5'b10111;
    
    parameter CF=5, ZF=4, NF=3, VF=2, PF=1, AF=0;
    ///////////////////////////////////////////////////////////////////////////////OPERATIONS
    always @(*)begin
    casez(F)
    INC: {Co15,Result}=A+16'd1;
    DEC: {Co15,Result}=A+16'hffff;
    ADD: {Co15,Result}=A+B;
    ADC: {Co15,Result}=A+B+Cin;
    SUB: {Co15,Result}=A-B;
    SBB: {Co15,Result}=A-B-Cin;
    AND: Result=A&B;
    OR:  Result=A|B;
    XOR: Result=A^B;
    NOT: Result=~A;
    SHL: Result=A<<1;   
    SHR: Result=A>>1;   
    SAL: Result=A<<<1;   
    SAR: Result={A[15],A[15:1]};
    ROL: Result={A[14:0],A[15]};
    ROR: Result={A[0],A[15:1]};
    RCL: Result={A[14:0],Cin};
    RCR: Result={Cin,A[15:1]};
    default: Result=16'dx;
    endcase
    end
    /////////////////////////////////////////////////////////////////////////////////////////////////////////FLAGS
    always @(*)begin 
    //ZERO FLAG 
    Status[ZF]= Result==16'd0;
    //PARITY FLAG
    Status[PF]= ~(^Result); 
    //NEGATIVE FLAG
    Status[NF]= Result[15];
    //CARRY FLAG
    casez(F)
    INC,ADD,ADC: Status[CF]=Co15;
    DEC,SUB,SBB: Status[CF]=Co15;
    SHL,SAL,ROL,RCL: Status[CF]= A[15];
    SHR,SAR,ROR,RCR: Status[CF]=A[0];
    default: Status[CF]=1'bx;
    endcase
    //OVERFLOW FLAG
    casez(F)
    INC: Status[VF]= A==16'h7fff;
    ADD,ADC: Status[VF]= (A[15]==B[15])&&(A[15]!=Result[15]);
    DEC: Status[VF]= A==16'h8000;
    SUB,SBB: Status[VF]= (A[15]!=B[15])&&(A[15]!=Result[15]);
    default: Status[VF]=1'bx;
    endcase
    //AUX FLAG
    casez(F)
    INC: Status[AF]=  A[3:0]==4'hf;
    ADD: Status[AF]= {1'b0,A[3:0]}+{1'b0,B[3:0]}>4'hf;
    ADC: Status[AF]= {1'b0,A[3:0]}+{1'b0,B[3:0]}+Cin>4'hf;
    DEC: Status[AF]=  A[3:0]==4'h0;
    SUB: Status[AF]=  A[3:0]< B[3:0];
    SBB: Status[AF]=  A[3:0]< (B[3:0]+Cin);
    default: Status[AF]=1'bx;
    endcase
    end
endmodule
