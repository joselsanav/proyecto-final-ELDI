`timescale 1ns / 1ps

module ALU_tb;

parameter ANCHO = 32;

reg [ANCHO-1:0] A;
reg [ANCHO-1:0] B;
reg [3:0] operacion_alu;

wire [ANCHO-1:0] resultado;
wire zero;

ALU #(ANCHO) alutest (
    .A(A),
    .B(B),
    .operacion_alu(operacion_alu),
    .resultado(resultado),
    .zero(zero)
);

initial begin

    A = 32'hFFFFFFFF;
    B = 32'd1;

    operacion_alu = 4'b0000;
    #10;

    operacion_alu = 4'b0001;
    #10;

    operacion_alu = 4'b0010;
    #10;

    operacion_alu = 4'b0011;
    #10;

    operacion_alu = 4'b0100;
    #10;

    operacion_alu = 4'b0101;
    #10;

    operacion_alu = 4'b0110;
    #10;

    operacion_alu = 4'b0111;
    #10;

    operacion_alu = 4'b1000;
    #10;

    operacion_alu = 4'b1001;
    #10;

    operacion_alu = 4'b1011;
    #10;

    $finish;

end

endmodule