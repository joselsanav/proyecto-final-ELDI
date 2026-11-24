`timescale 1ns / 1ps

module immgen (
    input wire [31:0] instruccion,
    input wire [2:0] tipo_inmediato,
    output reg [31:0] inmediato_salida
);

always @(*) begin

    case (tipo_inmediato)

        // Formato I
        3'b000: inmediato_salida = {{20{instruccion[31]}}, instruccion[31:20]};

        // Formato S
        3'b001: inmediato_salida = {{20{instruccion[31]}}, instruccion[31:25], instruccion[11:7]};

        // Formato B
        3'b010: inmediato_salida = {{19{instruccion[31]}}, instruccion[31], instruccion[7], instruccion[30:25], instruccion[11:8], 1'b0};

        // Formato U
        3'b011: inmediato_salida = {instruccion[31:12], 12'b0};

        // Formato J
        3'b100: inmediato_salida = {{11{instruccion[31]}}, instruccion[31], instruccion[19:12], instruccion[20], instruccion[30:21], 1'b0};

        default: inmediato_salida = 32'b0;

    endcase

end

endmodule