`timescale 1ns / 1ps

module tb_cpu_riesgos;

reg clok;
reg btnC;

wire [15:0] led;

integer escrituras_video;
reg vio_stall;

// ==========================================
// CPU COMPLETA
// ==========================================

top_cpu_basys3 dut (
    .clok(clok),
    .btnC(btnC),
    .led(led)
);

// ==========================================
// RELOJ
// ==========================================

initial clok = 1'b0;

always #5 clok = ~clok;

// ==========================================
// OBSERVACION DEL PIPELINE
// ==========================================

always @(posedge clok) begin

    if (!btnC) begin

        if (dut.sistema.procesador.detener_pipeline)
            vio_stall = 1'b1;

        if (dut.escribir_video) begin

            escrituras_video = escrituras_video + 1;

            $display(
                "Escritura VGA: direccion=%h dato=%h",
                dut.direccion_video,
                dut.dato_escritura_video
            );

            if (
                dut.direccion_video !== 32'h40000000 ||
                dut.dato_escritura_video !== 32'h00000011 ||
                dut.habilitar_bytes_video !== 4'b1111
            ) begin

                $display("ERROR: Escritura de video incorrecta");
                $finish;

            end

        end

    end

end

// ==========================================
// PRUEBA
// ==========================================

initial begin

    btnC = 1'b1;
    escrituras_video = 0;
    vio_stall = 1'b0;

    repeat (3) @(negedge clok);

    btnC = 1'b0;

    repeat (40) @(negedge clok);

    #1;

    if (escrituras_video != 1) begin

        $display("ERROR: Se esperaban exactamente 1 escritura");
        $display("Escrituras observadas: %0d", escrituras_video);
        $finish;

    end

    if (!vio_stall) begin

        $display("ERROR: No se detecto el stall LOAD-USE");
        $finish;

    end

    if (
        dut.sistema.memoria_datos.memoria[4]
        !== 32'd12
    ) begin

        $display("ERROR: La RAM no almaceno el valor 12");
        $finish;

    end

    if (led[5:0] !== 6'h11) begin

        $display("ERROR: El resultado final no es 17");
        $finish;

    end

    if (led[7] !== 1'b0) begin

        $display("ERROR: La CPU se detuvo");
        $display("Motivo: %b", led[10:8]);
        $finish;

    end

    $display("==================================");
    $display("PRUEBA 2 EXITOSA");
    $display("ADD: correcto");
    $display("RAM SW/LW: correcto");
    $display("STALL LOAD-USE: detectado");
    $display("FORWARDING: correcto");
    $display("BNE: salto correcto");
    $display("RESULTADO VGA: 00000011");
    $display("==================================");

    $finish;

end

endmodule
