`timescale 1ns / 1ps

module tb_cpu_saltos;

reg clok;
reg btnC;

wire [15:0] led;

integer escrituras_video;
integer errores;

// ==========================================
// CPU COMPLETA
// ==========================================

top_cpu_basys3 dut (
    .clok(clok),
    .btnC(btnC),
    .led(led)
);

// ==========================================
// RELOJ 100 MHz
// ==========================================

initial clok = 1'b0;
always #5 clok = ~clok;

// ==========================================
// SUPERVISION DE ESCRITURAS VGA
// ==========================================

always @(posedge clok) begin

    if (!btnC && dut.escribir_video) begin

        escrituras_video = escrituras_video + 1;

        $display(
            "Video %0d: direccion=%h dato=%h bytes=%b",
            escrituras_video,
            dut.direccion_video,
            dut.dato_escritura_video,
            dut.habilitar_bytes_video
        );

        if (
            dut.direccion_video !== 32'h40000000 ||
            dut.dato_escritura_video !== 32'h0000002A ||
            dut.habilitar_bytes_video !== 4'b1111
        ) begin

            $display("ERROR: escritura inesperada en video");
            errores = errores + 1;

        end

    end

end

// ==========================================
// COMPROBACION DE RAM
// ==========================================

task comprobar_ram;

    input integer indice;
    input [31:0] esperado;

    begin

        if (
            dut.sistema.memoria_datos.memoria[indice]
            !== esperado
        ) begin

            $display(
                "ERROR RAM[%0d]: obtenido=%h esperado=%h",
                indice,
                dut.sistema.memoria_datos.memoria[indice],
                esperado
            );

            errores = errores + 1;

        end

        else begin

            $display(
                "RAM[%0d] = %h (correcto)",
                indice,
                esperado
            );

        end

    end

endtask

// ==========================================
// SECUENCIA PRINCIPAL
// ==========================================

initial begin

    btnC = 1'b1;
    escrituras_video = 0;
    errores = 0;

    repeat (3) @(negedge clok);

    btnC = 1'b0;

    repeat (150) @(negedge clok);

    #1;

    // Resultado de las ocho condiciones de BRANCH
    // 1 + 2 + 4 + 8 + 16 + 32 + 64 + 128 = 255

    comprobar_ram(0, 32'h000000FF);

    // JAL en PC=0x70
    // Registro enlace: PC+4 = 0x74

    comprobar_ram(1, 32'h00000074);

    // AUIPC x7 en PC=0x78

    comprobar_ram(2, 32'h00000078);

    // JALR en PC=0x84
    // Registro enlace: PC+4 = 0x88

    comprobar_ram(3, 32'h00000088);

    // AUIPC x8 en PC=0x7C
    // x8 = 0x7C + 21 = 0x91
    // JALR debe eliminar el bit menos significativo

    comprobar_ram(4, 32'h00000091);

    // ======================================
    // VERIFICACION DEL PERIFERICO
    // ======================================

    if (escrituras_video != 1) begin

        $display(
            "ERROR: se esperaba una escritura VGA, hubo %0d",
            escrituras_video
        );

        errores = errores + 1;

    end

    if (led[5:0] !== 6'h2A) begin

        $display(
            "ERROR: color final=%h, esperado=2A",
            led[5:0]
        );

        errores = errores + 1;

    end

    if (led[7] !== 1'b0) begin

        $display(
            "ERROR: CPU detenida, motivo=%b",
            led[10:8]
        );

        errores = errores + 1;

    end

    // ======================================
    // RESULTADO FINAL
    // ======================================

    $display("================================");

    if (errores == 0) begin

        $display("PRUEBA 4 EXITOSA");
        $display("BEQ BNE BLT BGE BLTU BGEU: correcto");
        $display("JAL JALR AUIPC: correcto");
        $display("FLUSH POR SALTOS: correcto");
        $display("Enlaces y resultado final: correctos");

    end

    else begin

        $display(
            "PRUEBA 4 FALLIDA: %0d errores",
            errores
        );

    end

    $display("================================");

    $finish;

end

endmodule