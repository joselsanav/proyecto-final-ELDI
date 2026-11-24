
`timescale 1ns / 1ps

module tb_programa_rectangulo;

reg clok = 0;
reg btnC = 1;

wire [15:0] led;
wire [3:0] vgaRed;
wire [3:0] vgaGreen;
wire [3:0] vgaBlue;
wire Hsync;
wire Vsync;

integer escrituras_fondo = 0;
integer escrituras_pixel = 0;

integer esperado_x = 80;
integer esperado_y = 80;

reg [31:0] comando_esperado;

// ==========================================
// RELOJ 100 MHz
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
// MONITOR DEL BUS DE VIDEO
// ==========================================

always @(posedge clok) begin

    if (!btnC && dut.escribir_video) begin

        if (dut.direccion_video === 32'h40000000) begin

            if (
                dut.dato_escritura_video !== 32'h00000003 ||
                dut.habilitar_bytes_video !== 4'b1111
            )
                $fatal(1,
                    "ERROR: escritura de fondo incorrecta");

            escrituras_fondo = escrituras_fondo + 1;

            if (escrituras_fondo != 1)
                $fatal(1,
                    "ERROR: fondo escrito varias veces");

            $display("PASS: fondo azul configurado");

        end

        else if (dut.direccion_video === 32'h40000004) begin

            comando_esperado =
                32'h00600000 |
                (esperado_y << 9) |
                esperado_x;

            if (
                dut.dato_escritura_video !== comando_esperado
            ) begin

                $fatal(1,
                    "ERROR PIXEL (%0d,%0d): esperado=%h recibido=%h",
                    esperado_x,
                    esperado_y,
                    comando_esperado,
                    dut.dato_escritura_video);

            end

            if (dut.habilitar_bytes_video !== 4'b1111)
                $fatal(1,
                    "ERROR: mascara de bytes incorrecta");

            escrituras_pixel = escrituras_pixel + 1;

            // Siguiente coordenada esperada

            if (esperado_x == 239) begin
                esperado_x = 80;
                esperado_y = esperado_y + 1;
            end

            else begin
                esperado_x = esperado_x + 1;
            end

            if (escrituras_pixel % 1000 == 0) begin

                $display(
                    "PROGRESO: %0d / 12800 pixeles",
                    escrituras_pixel);

            end

            if (escrituras_pixel > 12800)
                $fatal(1,
                    "ERROR: demasiadas escrituras");

        end

        else begin

            $fatal(1,
                "ERROR: direccion inesperada %h",
                dut.direccion_video);

        end

    end

end

// ==========================================
// SECUENCIA PRINCIPAL
// ==========================================

initial begin

    // Permitir carga inicial de ROM desde programa.mem
    #2;

    // Verificar que se cargo el programa nuevo
    // No modificar la ROM desde este testbench

    if (
        dut.sistema.rom_programa.memoria[0]
        !== 32'h400000B7
    )
        $fatal(1,
            "ERROR: programa.mem no tiene el inicio esperado");

    if (
        dut.sistema.rom_programa.memoria[7]
        !== 32'h05000293
    )
        $fatal(1,
            "ERROR: programa.mem no tiene el bucle esperado");

    if (
        dut.sistema.rom_programa.memoria[16]
        !== 32'h0000006F
    )
        $fatal(1,
            "ERROR: programa.mem incompleto o antiguo");

    $display("==============================");
    $display("PROGRAMA.MEM CARGADO");
    $display("INICIO PRUEBA RECTANGULO");
    $display("==============================");

    // RESET INICIAL

    repeat (4) @(negedge clok);
    btnC = 0;

    // Esperar a completar las 12800 escrituras

    wait (escrituras_pixel == 12800);

    repeat (20) @(negedge clok);
    #1;

    // ======================================
    // COMPROBACIONES FINALES
    // ======================================

    if (escrituras_fondo !== 1)
        $fatal(1,
            "ERROR: numero de escrituras del fondo");

    if (escrituras_pixel !== 12800)
        $fatal(1,
            "ERROR: numero de pixeles dibujados");

    if (esperado_y !== 160)
        $fatal(1,
            "ERROR: filas incompletas");

    if (dut.color_registro !== 6'h03)
        $fatal(1,
            "ERROR: fondo no es azul");

    // Esquina superior izquierda: (80,80)

    if (
        dut.graficos.framebuffer[25680]
        !== 7'h70
    )
        $fatal(1,
            "ERROR: primera esquina del rectangulo");

    // Centro: (160,120)

    if (
        dut.graficos.framebuffer[38560]
        !== 7'h70
    )
        $fatal(1,
            "ERROR: centro del rectangulo");

    // Esquina inferior derecha: (239,159)

    if (
        dut.graficos.framebuffer[51119]
        !== 7'h70
    )
        $fatal(1,
            "ERROR: ultima esquina del rectangulo");

    // Posiciones exteriores sin dibujar

    if (
        dut.graficos.framebuffer[25679]
        !== 7'h00
    )
        $fatal(1,
            "ERROR: pixel exterior izquierdo");

    if (
        dut.graficos.framebuffer[51120]
        !== 7'h00
    )
        $fatal(1,
            "ERROR: pixel exterior derecho");

    if (led[7] !== 1'b0)
        $fatal(1,
            "ERROR: CPU detenida, motivo=%b",
            led[10:8]);

    $display("==============================");
    $display("PRUEBA RECTANGULO EXITOSA");
    $display("Fondo: RGB222 = 03");
    $display("Pixeles escritos: %0d",
             escrituras_pixel);
    $display("Rectangulo: X=80..239 Y=80..159");
    $display("CPU detenida: 0");
    $display("Errores: 0");
    $display("==============================");

    $finish;

end

// ==========================================
// PROTECCION CONTRA BUCLES INFINITOS
// ==========================================

initial begin
    #5000000;

    $fatal(1,
        "TIMEOUT: solo se dibujaron %0d de 12800 pixeles",
        escrituras_pixel);
end

endmodule
