`timescale 1ns / 1ps

module ALU #(parameter ANCHO = 32)(
    input [ANCHO-1:0] A,
    input [ANCHO-1:0] B,
    input [3:0] operacion_alu,
    output reg [ANCHO-1:0] resultado,
    output zero
);

always @(*) begin

    case (operacion_alu)

        4'b0000: resultado = A + B;

        4'b0001: resultado = A - B;

        4'b0010: resultado = A & B;

        4'b0011: resultado = A | B;

        4'b0100: resultado = A ^ B;

        4'b0101: resultado = A << B[4:0];

        4'b0110: resultado = A >> B[4:0];

        4'b0111: resultado = $signed(A) >>> B[4:0];

        4'b1000: resultado = ($signed(A) < $signed(B));

        4'b1001: resultado = (A < B);

        default: resultado = {ANCHO{1'b0}};

    endcase

end

assign zero = (resultado == {ANCHO{1'b0}});

endmodule