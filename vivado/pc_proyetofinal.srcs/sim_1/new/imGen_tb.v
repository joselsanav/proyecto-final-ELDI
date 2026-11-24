`timescale 1ns / 1ps

module ImGen_tb;

    reg [31:0] instruccion;
    reg [2:0] tipo_inmediato;
    wire [31:0] inmediato_salida;

    immgen uut (
        .instruccion(instruccion),
        .tipo_inmediato(tipo_inmediato),
        .inmediato_salida(inmediato_salida)
    );

    initial begin

        instruccion = 32'h00500293;
        tipo_inmediato = 3'b000;
        #10;

        if (inmediato_salida !== 32'h00000005)
            $error("ERROR: formato I positivo");
        else
            $display("OK: formato I positivo");


        instruccion = 32'hFFF00293;
        tipo_inmediato = 3'b000;
        #10;

        if (inmediato_salida !== 32'hFFFFFFFF)
            $error("ERROR: formato I negativo");
        else
            $display("OK: formato I negativo");


        instruccion = 32'h00532423;
        tipo_inmediato = 3'b001;
        #10;

        if (inmediato_salida !== 32'h00000008)
            $error("ERROR: formato S");
        else
            $display("OK: formato S");


        instruccion = 32'h00000463;
        tipo_inmediato = 3'b010;
        #10;

        if (inmediato_salida !== 32'h00000008)
            $error("ERROR: formato B");
        else
            $display("OK: formato B");


        instruccion = 32'h123452B7;
        tipo_inmediato = 3'b011;
        #10;

        if (inmediato_salida !== 32'h12345000)
            $error("ERROR: formato U positivo");
        else
            $display("OK: formato U positivo");


        instruccion = 32'h800002B7;
        tipo_inmediato = 3'b011;
        #10;

        if (inmediato_salida !== 32'h80000000)
            $error("ERROR: formato U con bit alto en 1");
        else
            $display("OK: formato U con bit alto en 1");


        instruccion = 32'h008000EF;
        tipo_inmediato = 3'b100;
        #10;

        if (inmediato_salida !== 32'h00000008)
            $error("ERROR: formato J");
        else
            $display("OK: formato J");

        $finish;

    end

endmodule

