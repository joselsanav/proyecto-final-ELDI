`timescale 1ns / 1ps

module if_id_tb;

    reg clok;
    reg reset;
    reg hab_paso;
    reg anular_etapa;

    reg [31:0] pc_entrada;
    reg [31:0] instruccion_entrada;

    wire [31:0] pc_salida;
    wire [31:0] instruccion_salida;

    if_id pruebaid (
        .clok(clok),
        .reset(reset),
        .hab_paso(hab_paso),
        .anular_etapa(anular_etapa),
        .pc_entrada(pc_entrada),
        .pc_salida(pc_salida),
        .instruccion_entrada(instruccion_entrada),
        .instruccion_salida(instruccion_salida)
    );

    initial begin
        clok = 0;
        forever #5 clok = ~clok;
    end

    initial begin

        reset = 0;
        hab_paso = 0;
        anular_etapa = 0;
        pc_entrada = 32'd0;
        instruccion_entrada = 32'd0;

        #10;
        reset = 1;

        #10;
        hab_paso = 1;
        anular_etapa = 0;
        pc_entrada = 32'd100;
        instruccion_entrada = 32'h00A00293;

        #10;
        hab_paso = 0;
        anular_etapa = 0;
        pc_entrada = 32'd104;
        instruccion_entrada = 32'h00500313;

        #10;
        hab_paso = 1;
        anular_etapa = 0;
        pc_entrada = 32'd104;
        instruccion_entrada = 32'h00500313;

        #10;
        hab_paso = 1;
        anular_etapa = 1;
        pc_entrada = 32'd108;
        instruccion_entrada = 32'h006283B3;

        #10;
        hab_paso = 1;
        anular_etapa = 0;
        pc_entrada = 32'd108;
        instruccion_entrada = 32'h006283B3;

        #10;

        $finish;

    end

endmodule