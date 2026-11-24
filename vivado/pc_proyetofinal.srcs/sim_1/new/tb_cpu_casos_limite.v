`timescale 1ns / 1ps

module tb_cpu_casos_limite;

reg clok;
reg btnC;

wire [15:0] led;

integer fase;
integer errores;
integer escrituras_1;
integer escrituras_2;
integer i;

reg vio_stall;
reg vio_salto;

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
// MONITOREO
// ==========================================

always @(posedge clok) begin

    if (!btnC) begin

        if (fase == 1) begin

            if (dut.sistema.procesador.detener_pipeline)
                vio_stall = 1'b1;

            if (dut.sistema.procesador.salto_efectivo)
                vio_salto = 1'b1;

        end

        if (dut.escribir_video) begin

            case (fase)

                1: begin

                    escrituras_1 = escrituras_1 + 1;

                    if (
                        dut.direccion_video !== 32'h40000000 ||
                        dut.dato_escritura_video !== 32'h00000027 ||
                        dut.habilitar_bytes_video !== 4'b1111
                    ) begin

                        errores = errores + 1;
                        $display("ERROR: video incorrecto en caso 1");

                    end

                end

                2: begin

                    escrituras_2 = escrituras_2 + 1;

                    if (
                        dut.direccion_video !== 32'h40000000 ||
                        dut.dato_escritura_video !== 32'h00000009 ||
                        dut.habilitar_bytes_video !== 4'b1111
                    ) begin

                        errores = errores + 1;
                        $display("ERROR: video incorrecto en caso 2");

                    end

                end

                default: begin
                    errores = errores + 1;
                    $display("ERROR: escritura fuera de la prueba");
                end

            endcase

        end

    end

end

// ==========================================
// PRUEBA PRINCIPAL
// ==========================================

initial begin

    btnC = 1'b1;
    fase = 0;
    errores = 0;
    escrituras_1 = 0;
    escrituras_2 = 0;
    vio_stall = 1'b0;
    vio_salto = 1'b0;

    #1;

    // ======================================
    // CASO 1: DEPENDENCIAS ENCADENADAS
    // ======================================

    for (i = 0; i < 256; i = i + 1)
        dut.sistema.rom_programa.memoria[i] =
            32'h00000013;

    dut.sistema.rom_programa.memoria[0]  = 32'h00500093;
    dut.sistema.rom_programa.memoria[1]  = 32'h00308113;
    dut.sistema.rom_programa.memoria[2]  = 32'h001101B3;
    dut.sistema.rom_programa.memoria[3]  = 32'h00218233;
    dut.sistema.rom_programa.memoria[4]  = 32'h003202B3;
    dut.sistema.rom_programa.memoria[5]  = 32'h04000313;
    dut.sistema.rom_programa.memoria[6]  = 32'h00532023;
    dut.sistema.rom_programa.memoria[7]  = 32'h0000000F;
    dut.sistema.rom_programa.memoria[8]  = 32'h00032383;
    dut.sistema.rom_programa.memoria[9]  = 32'h00538463;
    dut.sistema.rom_programa.memoria[10] = 32'h00032023;
    dut.sistema.rom_programa.memoria[11] = 32'h00138433;
    dut.sistema.rom_programa.memoria[12] = 32'h400004B7;
    dut.sistema.rom_programa.memoria[13] = 32'h0084A023;
    dut.sistema.rom_programa.memoria[14] = 32'h00000013;

    repeat (3) @(negedge clok);

    fase = 1;
    btnC = 1'b0;

    repeat (45) @(negedge clok);

    #1;

    if (
        dut.sistema.memoria_datos.memoria[16]
        !== 32'd34
    ) begin

        errores = errores + 1;
        $display("ERROR: RAM[16] no contiene 34");

    end
    else
        $display("CASO 1: RAM[16] = 34 (correcto)");

    if (!vio_stall) begin

        errores = errores + 1;
        $display("ERROR: no se detecto stall LOAD-BRANCH");

    end
    else
        $display("CASO 1: stall LOAD-BRANCH detectado");

    if (!vio_salto) begin

        errores = errores + 1;
        $display("ERROR: no se detecto salto tomado");

    end
    else
        $display("CASO 1: salto tomado detectado");

    if (escrituras_1 != 1) begin

        errores = errores + 1;

        $display(
            "ERROR: caso 1 tuvo %0d escrituras VGA",
            escrituras_1
        );

    end

    if (led[5:0] !== 6'h27) begin

        errores = errores + 1;
        $display("ERROR: resultado final caso 1");

    end

    if (led[7] !== 1'b0) begin

        errores = errores + 1;
        $display("ERROR: CPU detenida en caso 1");

    end

    // ======================================
    // CASO 2: RESET Y REGISTRO x0
    // ======================================

    fase = 0;
    btnC = 1'b1;

    #1;

    if (
        dut.sistema.procesador.pc_observado
        !== 32'b0
    ) begin

        errores = errores + 1;
        $display("ERROR: PC no vuelve a cero");

    end
    else
        $display("CASO 2: reset del PC correcto");

    if (led[5:0] !== 6'b0) begin

        errores = errores + 1;
        $display("ERROR: color no se reinicio");

    end

    for (i = 0; i < 256; i = i + 1)
        dut.sistema.rom_programa.memoria[i] =
            32'h00000013;

    dut.sistema.rom_programa.memoria[0] = 32'h07B00013;
    dut.sistema.rom_programa.memoria[1] = 32'h00700093;
    dut.sistema.rom_programa.memoria[2] = 32'h0000000F;
    dut.sistema.rom_programa.memoria[3] = 32'h00208113;
    dut.sistema.rom_programa.memoria[4] = 32'h400001B7;
    dut.sistema.rom_programa.memoria[5] = 32'h0021A023;
    dut.sistema.rom_programa.memoria[6] = 32'h00000013;

    repeat (3) @(negedge clok);

    fase = 2;
    btnC = 1'b0;

    repeat (25) @(negedge clok);

    #1;

    if (escrituras_2 != 1) begin

        errores = errores + 1;

        $display(
            "ERROR: caso 2 tuvo %0d escrituras VGA",
            escrituras_2
        );

    end

    if (led[5:0] !== 6'h09) begin

        errores = errores + 1;

        $display(
            "ERROR: caso 2 obtuvo %h en vez de 09",
            led[5:0]
        );

    end
    else
        $display("CASO 2: x0 y resultado 9 correctos");

    if (led[7] !== 1'b0) begin

        errores = errores + 1;
        $display("ERROR: CPU detenida en caso 2");

    end

    // ======================================
    // RESULTADO FINAL
    // ======================================

    $display("================================");

    if (errores == 0) begin

        $display("PRUEBA 7 EXITOSA");
        $display("FORWARDING ENCADENADO: correcto");
        $display("LOAD-BRANCH Y STALL: correctos");
        $display("FLUSH POR BRANCH: correcto");
        $display("FENCE EN MEMORIA ORDENADA: correcto");
        $display("RESET Y REGISTRO x0: correctos");

    end
    else begin

        $display(
            "PRUEBA 7 FALLIDA: %0d errores",
            errores
        );

    end

    $display("================================");

    $finish;

end

endmodule