`timescale 1ns / 1ps

module tb_cpu_excepciones;

reg clok;
reg btnC;

wire [15:0] led;

integer errores;
integer casos_aprobados;

top_cpu_basys3 dut (
    .clok(clok),
    .btnC(btnC),
    .led(led)
);

// ==========================================
// RELOJ DE 100 MHz
// ==========================================

initial clok = 1'b0;
always #5 clok = ~clok;

// ==========================================
// DETECTAR ESCRITURAS INDEBIDAS
// ==========================================

always @(posedge clok) begin

    if (!btnC && dut.escribir_video) begin

        $display(
            "ERROR: escritura inesperada en video, dato=%h",
            dut.dato_escritura_video
        );

        errores = errores + 1;

    end

end

// ==========================================
// EJECUTAR UN CASO DE EXCEPCION
// ==========================================

task probar_error;

    input integer numero;
    input [31:0] instruccion0;
    input [31:0] instruccion1;
    input [2:0] motivo_esperado;
    input [31:0] pc_esperado;

    integer i;

    begin

        // Reiniciar el procesador
        btnC = 1'b1;

        repeat (3) @(negedge clok);

        // Limpiar la ROM para este caso
        for (i = 0; i < 256; i = i + 1) begin

            dut.sistema.rom_programa.memoria[i] =
                32'h00000013;

        end

        // Cargar instrucciones del caso
        dut.sistema.rom_programa.memoria[0] =
            instruccion0;

        dut.sistema.rom_programa.memoria[1] =
            instruccion1;

        @(negedge clok);
        btnC = 1'b0;

        // Dar tiempo para detectar la excepcion
        repeat (16) @(negedge clok);

        #1;

        // Comprobar detencion, causa y PC
        if (
            dut.sistema.procesador.detenido !== 1'b1 ||
            dut.sistema.procesador.motivo_detencion
                !== motivo_esperado ||
            dut.sistema.procesador.pc_detencion
                !== pc_esperado
        ) begin

            errores = errores + 1;

            $display(
                "CASO %0d FALLIDO",
                numero
            );

            $display(
                "Detenido: %b",
                dut.sistema.procesador.detenido
            );

            $display(
                "Motivo: %0d, esperado: %0d",
                dut.sistema.procesador.motivo_detencion,
                motivo_esperado
            );

            $display(
                "PC fallo: %h, esperado: %h",
                dut.sistema.procesador.pc_detencion,
                pc_esperado
            );

        end

        else begin

            casos_aprobados = casos_aprobados + 1;

            $display(
                "CASO %0d CORRECTO: motivo=%0d PC=%h",
                numero,
                motivo_esperado,
                pc_esperado
            );

        end

    end

endtask

// ==========================================
// PRUEBA PRINCIPAL
// ==========================================

initial begin

    btnC = 1'b1;
    errores = 0;
    casos_aprobados = 0;

    #1;

    // Caso 1: instruccion ilegal
    probar_error(
        1,
        32'hFFFFFFFF,
        32'h00000013,
        3'd1,
        32'h00000000
    );

    // Caso 2: ECALL
    probar_error(
        2,
        32'h00000073,
        32'h00000013,
        3'd2,
        32'h00000000
    );

    // Caso 3: EBREAK
    probar_error(
        3,
        32'h00100073,
        32'h00000013,
        3'd3,
        32'h00000000
    );

    // Caso 4: JAL a PC+2, desalineado
    probar_error(
        4,
        32'h0020006F,
        32'h00000013,
        3'd4,
        32'h00000000
    );

    // Caso 5: LW x1, 1(x0), desalineado
    probar_error(
        5,
        32'h00102083,
        32'h00000013,
        3'd5,
        32'h00000000
    );

    // Caso 6: SW x0, 2(x0), desalineado
    probar_error(
        6,
        32'h00002123,
        32'h00000013,
        3'd6,
        32'h00000000
    );

    // Caso 7: lectura fuera del mapa
    // LUI x2, 0x50000
    // LW x1, 0(x2)
    probar_error(
        7,
        32'h50000137,
        32'h00012083,
        3'd7,
        32'h00000004
    );

    // Caso 8: escritura fuera del mapa
    // LUI x2, 0x50000
    // SW x0, 0(x2)
    probar_error(
        8,
        32'h50000137,
        32'h00012023,
        3'd7,
        32'h00000004
    );

    $display("================================");

    if (errores == 0 && casos_aprobados == 8) begin

        $display("PRUEBA 6 EXITOSA");
        $display("8 excepciones comprobadas");
        $display("Causas y PC correctos");
        $display("Sin escrituras inesperadas");

    end

    else begin

        $display(
            "PRUEBA 6 FALLIDA: %0d errores",
            errores
        );

        $display(
            "Casos aprobados: %0d de 8",
            casos_aprobados
        );

    end

    $display("================================");

    $finish;

end

endmodule