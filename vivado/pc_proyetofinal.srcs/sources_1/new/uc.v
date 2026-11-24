`timescale 1ns / 1ps

module uc (
    input wire [6:0] opcode,
    output reg escribir_registro,
    output reg tipo_seg_operando,
    output reg [2:0] tipo_inmediato,
    output reg escribir_memoria,
    output reg [1:0] origen_resultado,
    output reg alu_usa_pc,
    output reg salto_condicional,
    output reg salto,
    output reg jalr
);

always @(*) begin

    escribir_registro = 1'b0;
    tipo_seg_operando = 1'b0;
    tipo_inmediato = 3'b000;
    escribir_memoria = 1'b0;
    origen_resultado = 2'b00;
    alu_usa_pc = 1'b0;
    salto_condicional = 1'b0;
    salto = 1'b0;
    jalr = 1'b0;

    case (opcode)

        // TIPO I
        7'b0010011: begin
            escribir_registro = 1'b1;
            tipo_seg_operando = 1'b1;
            tipo_inmediato = 3'b000;
            escribir_memoria = 1'b0;
            origen_resultado = 2'b00;

            alu_usa_pc = 1'b0;
            salto_condicional = 1'b0;
            salto = 1'b0;
            jalr = 1'b0;
        end

        // TIPO R
        7'b0110011: begin
            escribir_registro = 1'b1;
            tipo_seg_operando = 1'b0;
            escribir_memoria = 1'b0;
            origen_resultado = 2'b00;

            alu_usa_pc = 1'b0;
            salto_condicional = 1'b0;
            salto = 1'b0;
            jalr = 1'b0;
        end

        // LOAD
        7'b0000011: begin
            escribir_registro = 1'b1;
            tipo_seg_operando = 1'b1;
            tipo_inmediato = 3'b000;
            origen_resultado = 2'b01;

            alu_usa_pc = 1'b0;
            salto_condicional = 1'b0;
            salto = 1'b0;
            jalr = 1'b0;
        end

        // STORE
        7'b0100011: begin
            escribir_registro = 1'b0;
            tipo_seg_operando = 1'b1;
            tipo_inmediato = 3'b001;
            escribir_memoria = 1'b1;

            alu_usa_pc = 1'b0;
            salto_condicional = 1'b0;
            salto = 1'b0;
            jalr = 1'b0;
        end

        // BRANCH
        7'b1100011: begin
            escribir_registro = 1'b0;
            tipo_seg_operando = 1'b0;
            tipo_inmediato = 3'b010;
            escribir_memoria = 1'b0;
            origen_resultado = 2'b00;

            alu_usa_pc = 1'b0;
            salto_condicional = 1'b1;
            salto = 1'b0;
            jalr = 1'b0;
        end

        // JAL
        7'b1101111: begin
            escribir_registro = 1'b1;
            tipo_inmediato = 3'b100;
            escribir_memoria = 1'b0;
            origen_resultado = 2'b10;

            alu_usa_pc = 1'b0;
            salto_condicional = 1'b0;
            salto = 1'b1;
            jalr = 1'b0;
        end

        // JALR
        7'b1100111: begin
            escribir_registro = 1'b1;
            tipo_seg_operando = 1'b1;
            tipo_inmediato = 3'b000;
            escribir_memoria = 1'b0;
            origen_resultado = 2'b10;

            alu_usa_pc = 1'b0;
            salto_condicional = 1'b0;
            salto = 1'b0;
            jalr = 1'b1;
        end

        // LUI
        7'b0110111: begin
            escribir_registro = 1'b1;
            tipo_inmediato = 3'b011;
            escribir_memoria = 1'b0;
            origen_resultado = 2'b11;

            alu_usa_pc = 1'b0;
            salto_condicional = 1'b0;
            salto = 1'b0;
            jalr = 1'b0;
        end

        // AUIPC
        7'b0010111: begin
            escribir_registro = 1'b1;
            tipo_seg_operando = 1'b1;
            tipo_inmediato = 3'b011;
            escribir_memoria = 1'b0;
            origen_resultado = 2'b00;

            alu_usa_pc = 1'b1;
            salto_condicional = 1'b0;
            salto = 1'b0;
            jalr = 1'b0;
        end

        default: begin
        end

    endcase

end

endmodule
