
`timescale 1ns / 1ps

module tb_cpu_dibujo;

reg clok = 0;
reg btnC = 1;

wire [15:0] led;

wire [3:0] vgaRed;
wire [3:0] vgaGreen;
wire [3:0] vgaBlue;

wire Hsync;
wire Vsync;

integer i;
integer escrituras_fondo = 0;
integer escrituras_pixel = 0;

reg pixel_rojo_visto = 0;
reg fondo_azul_visto = 0;

// ==========================================
// RELOJ DE 100 MHz
// ==========================================

always #5 clok = ~clok;

// ==========================================
// SISTEMA COMPLETO
// ==========================================

top_cpu_vga_basys3 dut (
    .clok(clok),
    .btnC(btnC),
    .led(led),
    .vgaRed(vgaRed),
    .vgaGreen(vgaGreen),
    .vgaBlue(vgaBlue),
    .Hsync(Hsync),
    .Vsync(Vsync)
);

// ==========================================
// COMPROBAR ESCRITURAS DE LA CPU
// ==========================================

always @(posedge clok) begin

    if (!btnC && dut.escribir_video) begin

        $display(
            "Tiempo=%0t Direccion=%h Dato=%h",
            $time,
            dut.direccion_video,
            dut.dato_escritura_video
        );

        if (dut.direccion_video == 32'h40000000) begin

            if (
                dut.dato_escritura_video !== 32'h00000003 ||
                dut.habilitar_bytes_video !== 4'b1111
            )
                $fatal(1,
                    "ERROR: escritura de fondo incorrecta");

            escrituras_fondo = escrituras_fondo + 1;

            $display("PASS: CPU escribio fondo azul");

        end

        else if (
            dut.direccion_video == 32'h40000004
        ) begin

            if (
                dut.dato_escritura_video !== 32'h0060280A ||
                dut.habilitar_bytes_video !== 4'b1111
            )
                $fatal(1,
                    "ERROR: comando de pixel incorrecto");

            escrituras_pixel = escrituras_pixel + 1;

            $display("PASS: CPU envio pixel rojo");

        end

        else begin

            $fatal(1,
                "ERROR: direccion inesperada %h",
                dut.direccion_video);

        end

    end

end

// ==========================================
// COMPROBAR COLORES DE SALIDA VGA
// ==========================================

always @(negedge clok) begin

    if (!btnC &&
        dut.controlador_vga.v_count == 40) begin

        // Pixel rojo en posicion fisica (21,40)

        if (
            dut.controlador_vga.h_count == 21 &&
            !pixel_rojo_visto
        ) begin

            if (
                {vgaRed, vgaGreen, vgaBlue}
                !== 12'hF00
            )
                $fatal(1,
                    "ERROR: pixel rojo no visible");

            pixel_rojo_visto = 1;

            $display(
                "PASS: VGA muestra pixel rojo");

        end

        // Fondo azul fuera del pixel dibujado

        if (
            dut.controlador_vga.h_count == 25 &&
            !fondo_azul_visto
        ) begin

            if (
                {vgaRed, vgaGreen, vgaBlue}
                !== 12'h00F
            )
                $fatal(1,
                    "ERROR: fondo azul incorrecto");

            fondo_azul_visto = 1;

            $display(
                "PASS: VGA muestra fondo azul");

        end

    end

end

// ==========================================
// PROGRAMA RISC-V Y SECUENCIA PRINCIPAL
// ==========================================

initial begin

    #1;

    // LIMPIAR TODA LA ROM DE SIMULACION
    // PARA ELIMINAR INSTRUCCIONES DEL P05

    for (i = 0; i < 256; i = i + 1) begin
        dut.sistema.rom_programa.memoria[i] =
            32'h00000013;
    end

    // ======================================
    // PROGRAMA DE DIBUJO
    // ======================================

    // LUI x1, 0x40000
    // x1 = 0x40000000

    dut.sistema.rom_programa.memoria[0] =
        32'h400000B7;

    // ADDI x3, x0, 3
    // Color azul RGB222

    dut.sistema.rom_programa.memoria[1] =
        32'h00300193;

    // SW x3, 0(x1)
    // Configurar fondo azul

    dut.sistema.rom_programa.memoria[2] =
        32'h0030A023;

    // LUI x2, 0x00603

    dut.sistema.rom_programa.memoria[3] =
        32'h00603137;

    // ADDI x2, x2, -2038
    // x2 = 0x0060280A

    dut.sistema.rom_programa.memoria[4] =
        32'h80A10113;

    // SW x2, 4(x1)
    // Dibujar pixel rojo en (10,20)

    dut.sistema.rom_programa.memoria[5] =
        32'h0020A223;

    // JAL x0, 0
    // Bucle sin nuevas escrituras

    dut.sistema.rom_programa.memoria[6] =
        32'h0000006F;

    // ======================================
    // RESET INICIAL
    // ======================================

    repeat (4) @(negedge clok);

    btnC = 0;

    $display("==============================");
    $display("INICIO PRUEBA CPU + DIBUJO VGA");
    $display("==============================");

    // Recorrer suficientes lineas VGA
    // para alcanzar la coordenada Y=40

    repeat (150000) @(negedge clok);

    #1;

    // ======================================
    // COMPROBACIONES FINALES
    // ======================================

    if (escrituras_fondo !== 1)
        $fatal(1,
            "ERROR: escrituras de fondo=%0d",
            escrituras_fondo);

    if (escrituras_pixel !== 1)
        $fatal(1,
            "ERROR: escrituras de pixel=%0d",
            escrituras_pixel);

    if (dut.color_registro !== 6'h03)
        $fatal(1,
            "ERROR: fondo almacenado");

    // Direccion memoria = 20*320 + 10 = 6410
    // Bit valido=1 y color rojo=0x30

    if (dut.graficos.framebuffer[6410] !== 7'h70)
        $fatal(1,
            "ERROR: pixel no almacenado");

    if (!pixel_rojo_visto)
        $fatal(1,
            "ERROR: no se observo pixel rojo");

    if (!fondo_azul_visto)
        $fatal(1,
            "ERROR: no se observo fondo azul");

    if (led[7] !== 1'b0)
        $fatal(1,
            "ERROR: CPU detenida, motivo=%b",
            led[10:8]);

    // ======================================
    // RESULTADO
    // ======================================

    $display("==============================");
    $display("P10: CPU DIBUJA EN VGA");
    $display("PRUEBA EXITOSA");
    $display("Escrituras fondo: %0d",
             escrituras_fondo);
    $display("Escrituras pixel: %0d",
             escrituras_pixel);
    $display("Errores: 0");
    $display("==============================");

    $finish;

end

endmodule

