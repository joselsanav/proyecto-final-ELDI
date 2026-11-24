`timescale 1ns / 1ps

module control_top_tb;

    reg [31:0] instruccion;

    wire escribir_registro;
    wire tipo_seg_operando;
    wire [2:0] tipo_inmediato;

    wire escribir_memoria;
    wire [1:0] origen_resultado;

    wire alu_usa_pc;
    wire salto_condicional;
    wire salto;
    wire jalr;

    wire [3:0] operacion_alu;

    control_top uut (
        .instruccion(instruccion),
        .escribir_registro(escribir_registro),
        .tipo_seg_operando(tipo_seg_operando),
        .tipo_inmediato(tipo_inmediato),
        .escribir_memoria(escribir_memoria),
        .origen_resultado(origen_resultado),
        .alu_usa_pc(alu_usa_pc),
        .salto_condicional(salto_condicional),
        .salto(salto),
        .jalr(jalr),
        .operacion_alu(operacion_alu)
    );

    initial begin

        // PRUEBA 1: SUB

        instruccion = 32'h407302B3;
        #10;

        if (escribir_registro !== 1'b1 ||
            tipo_seg_operando !== 1'b0 ||
            operacion_alu !== 4'b0001)
            $error("ERROR: SUB");
        else
            $display("OK: SUB");


        // PRUEBA 2: ADDI

        instruccion = 32'h00A30293;
        #10;

        if (escribir_registro !== 1'b1 ||
            tipo_seg_operando !== 1'b1 ||
            tipo_inmediato !== 3'b000 ||
            operacion_alu !== 4'b0000)
            $error("ERROR: ADDI");
        else
            $display("OK: ADDI");


        // PRUEBA 3: BEQ

        instruccion = 32'h00000463;
        #10;

        if (salto_condicional !== 1'b1 ||
            tipo_inmediato !== 3'b010 ||
            operacion_alu !== 4'b0001)
            $error("ERROR: BEQ");
        else
            $display("OK: BEQ");


        // PRUEBA 4: JAL

        instruccion = 32'h008000EF;
        #10;

        if (salto !== 1'b1 ||
            escribir_registro !== 1'b1 ||
            origen_resultado !== 2'b10 ||
            tipo_inmediato !== 3'b100)
            $error("ERROR: JAL");
        else
            $display("OK: JAL");


        $finish;

    end

endmodule