`timescale 1ns / 1ps

module regfile_tb;

    parameter ANCHO = 32;

    reg clok;
    reg escribir_registro;

    reg [4:0] rs1;
    reg [4:0] rs2;
    reg [4:0] rd;

    reg [ANCHO-1:0] dato_escritura;

    wire [ANCHO-1:0] valor_rs1;
    wire [ANCHO-1:0] valor_rs2;

    regfile #(ANCHO) regfiletest (
        .clok(clok),
        .escribir_registro(escribir_registro),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .dato_escritura(dato_escritura),
        .valor_rs1(valor_rs1),
        .valor_rs2(valor_rs2)
    );

    initial begin
        clok = 0;
        forever #5 clok = ~clok;
    end

    initial begin

        escribir_registro = 0;

        rs1 = 5'd0;
        rs2 = 5'd0;
        rd  = 5'd0;

        dato_escritura = 32'd0;
        #10;

        rs1 = 5'd0;
        rs2 = 5'd0;
        rd = 5'd7;
        dato_escritura = 32'd7;
        #10;

        escribir_registro = 2'b1;
        rd = 5'd7;
        dato_escritura = 32'd16;
        #10;

        escribir_registro = 0;
        rs1 = 5'd7;

        #10;
        rs1 = 5'd0;
        rs2 = 5'd7;

        #10;

        escribir_registro = 1'b1;
        rd = 5'd0;
        dato_escritura = 32'd100;
        rs1 = 5'd0;
        rs2 = 5'd7;

        #10;

        if (valor_rs1 !== 32'd0)
            $error("ERROR: x0 no deberia cambiar");
        else
            $display("OK: x0 sigue en cero");


        // PRUEBA 2: Retencion con escritura deshabilitada

        escribir_registro = 1'b0;
        rd = 5'd7;
        dato_escritura = 32'd50;
        rs1 = 5'd7;
        rs2 = 5'd7;

        #10;

        if (valor_rs1 !== 32'd16 || valor_rs2 !== 32'd16)
            $error("ERROR: x7 cambio con escritura deshabilitada");
        else
            $display("OK: x7 conserva el valor 16");


        // PRUEBA 3: Escribir dos registros diferentes

        // Guardar 150 en x5

        escribir_registro = 1'b1;
        rd = 5'd5;
        dato_escritura = 32'd150;
        rs1 = 5'd5;
        rs2 = 5'd8;

        #10;

        // Guardar 25 en x8

        rd = 5'd8;
        dato_escritura = 32'd25;

        #10;

        if (valor_rs1 !== 32'd150 || valor_rs2 !== 32'd25)
            $error("ERROR: lectura de x5 y x8 incorrecta");
        else
            $display("OK: x5 = 150 y x8 = 25");

        escribir_registro = 1'b0;

        #10;

        $finish;

    end

endmodule
