`timescale 1ns / 1ps

module id_ex_tb;

    reg clok, reset, hab_paso, anular_etapa;

    reg [31:0] pc_entrada, instruccion_entrada;
    reg [31:0] valor_rs1_entrada, valor_rs2_entrada;
    reg [31:0] inmediato_entrada;

    reg escribir_registro_entrada;
    reg tipo_seg_operando_entrada;
    reg escribir_memoria_entrada;
    reg [1:0] origen_resultado_entrada;
    reg alu_usa_pc_entrada;
    reg salto_condicional_entrada;
    reg salto_entrada;
    reg jalr_entrada;
    reg [3:0] operacion_alu_entrada;

    wire [31:0] pc_salida, instruccion_salida;
    wire [31:0] valor_rs1_salida, valor_rs2_salida;
    wire [31:0] inmediato_salida;

    wire escribir_registro_salida;
    wire tipo_seg_operando_salida;
    wire escribir_memoria_salida;
    wire [1:0] origen_resultado_salida;
    wire alu_usa_pc_salida;
    wire salto_condicional_salida;
    wire salto_salida;
    wire jalr_salida;
    wire [3:0] operacion_alu_salida;

    id_ex uut (
        .clok(clok),
        .reset(reset),
        .hab_paso(hab_paso),
        .anular_etapa(anular_etapa),

        .pc_entrada(pc_entrada),
        .instruccion_entrada(instruccion_entrada),
        .valor_rs1_entrada(valor_rs1_entrada),
        .valor_rs2_entrada(valor_rs2_entrada),
        .inmediato_entrada(inmediato_entrada),

        .pc_salida(pc_salida),
        .instruccion_salida(instruccion_salida),
        .valor_rs1_salida(valor_rs1_salida),
        .valor_rs2_salida(valor_rs2_salida),
        .inmediato_salida(inmediato_salida),

        .escribir_registro_entrada(escribir_registro_entrada),
        .escribir_registro_salida(escribir_registro_salida),

        .tipo_seg_operando_entrada(tipo_seg_operando_entrada),
        .tipo_seg_operando_salida(tipo_seg_operando_salida),

        .escribir_memoria_entrada(escribir_memoria_entrada),
        .escribir_memoria_salida(escribir_memoria_salida),

        .origen_resultado_entrada(origen_resultado_entrada),
        .origen_resultado_salida(origen_resultado_salida),

        .alu_usa_pc_entrada(alu_usa_pc_entrada),
        .alu_usa_pc_salida(alu_usa_pc_salida),

        .salto_condicional_entrada(salto_condicional_entrada),
        .salto_condicional_salida(salto_condicional_salida),

        .salto_entrada(salto_entrada),
        .salto_salida(salto_salida),

        .jalr_entrada(jalr_entrada),
        .jalr_salida(jalr_salida),

        .operacion_alu_entrada(operacion_alu_entrada),
        .operacion_alu_salida(operacion_alu_salida)
    );

    // Reloj de 10 ns
    initial begin
        clok = 0;
        forever #5 clok = ~clok;
    end

    initial begin

        // Inicializacion
        reset = 0;
        hab_paso = 0;
        anular_etapa = 0;

        pc_entrada = 0;
        instruccion_entrada = 0;
        valor_rs1_entrada = 0;
        valor_rs2_entrada = 0;
        inmediato_entrada = 0;

        escribir_registro_entrada = 0;
        tipo_seg_operando_entrada = 0;
        escribir_memoria_entrada = 0;
        origen_resultado_entrada = 0;
        alu_usa_pc_entrada = 0;
        salto_condicional_entrada = 0;
        salto_entrada = 0;
        jalr_entrada = 0;
        operacion_alu_entrada = 0;

        // PRUEBA 1: RESET
        #10;

        if (pc_salida !== 32'd0 ||
            instruccion_salida !== 32'h00000013 ||
            escribir_registro_salida !== 1'b0 ||
            escribir_memoria_salida !== 1'b0)
            $error("ERROR: RESET");
        else
            $display("OK: RESET");


        // PRUEBA 2: GUARDAR ADD
        reset = 1;
        hab_paso = 1;

        pc_entrada = 32'd100;
        instruccion_entrada = 32'h007302B3;
        valor_rs1_entrada = 32'd12;
        valor_rs2_entrada = 32'd3;
        inmediato_entrada = 32'd0;

        escribir_registro_entrada = 1;
        tipo_seg_operando_entrada = 0;
        escribir_memoria_entrada = 0;
        operacion_alu_entrada = 4'b0000;

        #10;

        if (pc_salida !== 32'd100 ||
            instruccion_salida !== 32'h007302B3 ||
            valor_rs1_salida !== 32'd12 ||
            valor_rs2_salida !== 32'd3 ||
            escribir_registro_salida !== 1'b1)
            $error("ERROR: GUARDAR ADD");
        else
            $display("OK: GUARDAR ADD");


        // PRUEBA 3: MANTENER ADD
        hab_paso = 0;

        // Cambiamos TODAS las entradas a STORE
        pc_entrada = 32'd104;
        instruccion_entrada = 32'h00532423;
        valor_rs1_entrada = 32'd1000;
        valor_rs2_entrada = 32'd77;
        inmediato_entrada = 32'd8;

        escribir_registro_entrada = 0;
        tipo_seg_operando_entrada = 1;
        escribir_memoria_entrada = 1;
        origen_resultado_entrada = 2'b00;
        alu_usa_pc_entrada = 0;
        salto_condicional_entrada = 0;
        salto_entrada = 0;
        jalr_entrada = 0;
        operacion_alu_entrada = 4'b0000;

        #10;

        if (pc_salida !== 32'd100 ||
            instruccion_salida !== 32'h007302B3 ||
            escribir_registro_salida !== 1'b1 ||
            escribir_memoria_salida !== 1'b0)
            $error("ERROR: MANTENER");
        else
            $display("OK: MANTENER");


        // PRUEBA 4: GUARDAR STORE
        hab_paso = 1;
        #10;

        if (pc_salida !== 32'd104 ||
            instruccion_salida !== 32'h00532423 ||
            valor_rs1_salida !== 32'd1000 ||
            valor_rs2_salida !== 32'd77 ||
            inmediato_salida !== 32'd8 ||
            escribir_registro_salida !== 1'b0 ||
            tipo_seg_operando_salida !== 1'b1 ||
            escribir_memoria_salida !== 1'b1)
            $error("ERROR: STORE");
        else
            $display("OK: STORE");


        // PRUEBA 5: FLUSH CON ENABLE = 0
        hab_paso = 0;
        anular_etapa = 1;
        #10;

        if (pc_salida !== 32'd0 ||
            instruccion_salida !== 32'h00000013 ||
            valor_rs1_salida !== 32'd0 ||
            escribir_memoria_salida !== 1'b0 ||
            escribir_registro_salida !== 1'b0 ||
            operacion_alu_salida !== 4'b0000)
            $error("ERROR: FLUSH");
        else
            $display("OK: FLUSH");


        // PRUEBA 6: RECUPERAR
        anular_etapa = 0;
        hab_paso = 1;

        pc_entrada = 32'd108;
        instruccion_entrada = 32'h007302B3;
        valor_rs1_entrada = 32'd12;
        valor_rs2_entrada = 32'd3;
        inmediato_entrada = 0;

        escribir_registro_entrada = 1;
        tipo_seg_operando_entrada = 0;
        escribir_memoria_entrada = 0;

        #10;

        if (pc_salida !== 32'd108 ||
            instruccion_salida !== 32'h007302B3 ||
            escribir_registro_salida !== 1'b1 ||
            escribir_memoria_salida !== 1'b0)
            $error("ERROR: RECUPERAR");
        else
            $display("OK: RECUPERAR");


        // PRUEBA 7: RESET ASINCRONO
        #1;
        reset = 0;
        #1;

        if (pc_salida !== 32'd0 ||
            instruccion_salida !== 32'h00000013 ||
            escribir_registro_salida !== 1'b0 ||
            escribir_memoria_salida !== 1'b0)
            $error("ERROR: RESET ASINCRONO");
        else
            $display("OK: RESET ASINCRONO");

        $finish;
    end

endmodule