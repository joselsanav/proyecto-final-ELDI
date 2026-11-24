`timescale 1ns / 1ps

module uc_tb;

    reg [6:0] opcode;

    wire escribir_registro;
    wire tipo_seg_operando;
    wire [2:0] tipo_inmediato;
    wire escribir_memoria;
    wire [1:0] origen_resultado;
    wire alu_usa_pc;
    wire salto_condicional;
    wire salto;
    wire jalr;

    uc uut (
        .opcode(opcode),
        .escribir_registro(escribir_registro),
        .tipo_seg_operando(tipo_seg_operando),
        .tipo_inmediato(tipo_inmediato),
        .escribir_memoria(escribir_memoria),
        .origen_resultado(origen_resultado),
        .alu_usa_pc(alu_usa_pc),
        .salto_condicional(salto_condicional),
        .salto(salto),
        .jalr(jalr)
    );

    initial begin

        // TIPO R
        opcode = 7'b0110011;
        #10;

        if (escribir_registro !== 1'b1 ||
            tipo_seg_operando !== 1'b0)
            $error("ERROR: Tipo R");
        else
            $display("OK: Tipo R");


        // TIPO I
        opcode = 7'b0010011;
        #10;

        if (escribir_registro !== 1'b1 ||
            tipo_seg_operando !== 1'b1 ||
            tipo_inmediato !== 3'b000)
            $error("ERROR: Tipo I");
        else
            $display("OK: Tipo I");


        // LOAD
        opcode = 7'b0000011;
        #10;

        if (escribir_registro !== 1'b1 ||
            origen_resultado !== 2'b01)
            $error("ERROR: Tipo LOAD");
        else
            $display("OK: Tipo LOAD");


        // STORE
        opcode = 7'b0100011;
        #10;

        if (escribir_registro !== 1'b0 ||
            escribir_memoria !== 1'b1 ||
            tipo_inmediato !== 3'b001)
            $error("ERROR: Tipo STORE");
        else
            $display("OK: Tipo STORE");


        // BRANCH
        opcode = 7'b1100011;
        #10;

        if (salto_condicional !== 1'b1 ||
            tipo_inmediato !== 3'b010)
            $error("ERROR: Tipo BRANCH");
        else
            $display("OK: Tipo BRANCH");


        // JAL
        opcode = 7'b1101111;
        #10;

        if (salto !== 1'b1 ||
            origen_resultado !== 2'b10)
            $error("ERROR: Tipo JAL");
        else
            $display("OK: Tipo JAL");


        // JALR
        opcode = 7'b1100111;
        #10;

        if (jalr !== 1'b1 ||
            origen_resultado !== 2'b10)
            $error("ERROR: Tipo JALR");
        else
            $display("OK: Tipo JALR");


        // LUI
        opcode = 7'b0110111;
        #10;

        if (tipo_inmediato !== 3'b011 ||
            origen_resultado !== 2'b11)
            $error("ERROR: Tipo LUI");
        else
            $display("OK: Tipo LUI");


        // AUIPC
        opcode = 7'b0010111;
        #10;

        if (alu_usa_pc !== 1'b1 ||
            tipo_inmediato !== 3'b011)
            $error("ERROR: Tipo AUIPC");
        else
            $display("OK: Tipo AUIPC");

        #10;

        $finish;

    end

endmodule