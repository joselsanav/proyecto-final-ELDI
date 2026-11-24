
`timescale 1ns / 1ps

module tb_top_cpu_vga_basys3;

// ==========================================
// ENTRADAS Y SALIDAS
// ==========================================

reg clok;
reg btnC;

wire [15:0] led;

wire [3:0] vgaRed;
wire [3:0] vgaGreen;
wire [3:0] vgaBlue;

wire Hsync;
wire Vsync;

// ==========================================
// VARIABLES DE VERIFICACION
// ==========================================

integer escrituras_video;
integer muestras_color;
integer muestras_blanking;
integer muestras_hsync_bajo;

reg [9:0] h;
reg [9:0] v;

reg activo_esperado;
reg hsync_esperado;
reg vsync_esperado;

reg [3:0] rojo_esperado;
reg [3:0] verde_esperado;
reg [3:0] azul_esperado;

// ==========================================
// INSTANCIA CPU + VGA
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
// RELOJ 100 MHz
// ==========================================

initial clok = 1'b0;

always #5 clok = ~clok;

// ==========================================
// MONITOREO DEL BUS DE VIDEO
// ==========================================

always @(posedge clok) begin

    if (!btnC && dut.escribir_video) begin

        escrituras_video = escrituras_video + 1;

        $display("================================");
        $display("ESCRITURA DE VIDEO DETECTADA");
        $display("Tiempo: %0t ns", $time);
        $display("Direccion: %h", dut.direccion_video);
        $display("Dato: %h", dut.dato_escritura_video);
        $display("Bytes: %b", dut.habilitar_bytes_video);
        $display("================================");

        if (
            dut.direccion_video !== 32'h40000000 ||
            dut.dato_escritura_video !== 32'h0000002A ||
            dut.habilitar_bytes_video !== 4'b1111
        ) begin

            $fatal(1,
                "ERROR: escritura incorrecta en bus VGA");

        end

    end

end

// ==========================================
// VERIFICACION DE SALIDAS VGA
// ==========================================

always @(negedge clok) begin

    if (!btnC) begin

        h = dut.controlador_vga.h_count;
        v = dut.controlador_vga.v_count;

        // Zona visible 640x480

        activo_esperado =
            (h < 640) && (v < 480);

        // Sincronismo horizontal

        hsync_esperado =
            !((h >= 656) && (h < 752));

        // Sincronismo vertical

        vsync_esperado =
            !((v >= 490) && (v < 492));

        // Comprobar sincronismos

        if (Hsync !== hsync_esperado)
            $fatal(1, "ERROR: HSYNC incorrecto");

        if (Vsync !== vsync_esperado)
            $fatal(1, "ERROR: VSYNC incorrecto");

        // Comprobar zona visible

        if (
            dut.controlador_vga.video_active
            !== activo_esperado
        )
            $fatal(1,
                "ERROR: zona visible incorrecta");

        // Color esperado a partir del registro CPU

        rojo_esperado = activo_esperado
            ? {dut.color_registro[5:4],
               dut.color_registro[5:4]}
            : 4'b0000;

        verde_esperado = activo_esperado
            ? {dut.color_registro[3:2],
               dut.color_registro[3:2]}
            : 4'b0000;

        azul_esperado = activo_esperado
            ? {dut.color_registro[1:0],
               dut.color_registro[1:0]}
            : 4'b0000;

        // Comprobar RGB

        if (
            vgaRed   !== rojo_esperado ||
            vgaGreen !== verde_esperado ||
            vgaBlue  !== azul_esperado
        ) begin

            $fatal(1,
                "ERROR: color VGA incorrecto");

        end

        // Contar muestras de color correcto

        if (
            activo_esperado &&
            dut.color_registro === 6'h2A &&
            {vgaRed, vgaGreen, vgaBlue}
                === 12'hAAA
        ) begin

            muestras_color = muestras_color + 1;

        end

        // Contar muestras de blanking

        if (!activo_esperado)
            muestras_blanking =
                muestras_blanking + 1;

        // Detectar pulso horizontal

        if (Hsync === 1'b0)
            muestras_hsync_bajo =
                muestras_hsync_bajo + 1;

    end

end

// ==========================================
// SECUENCIA PRINCIPAL
// ==========================================

initial begin

    btnC = 1'b1;

    escrituras_video = 0;
    muestras_color = 0;
    muestras_blanking = 0;
    muestras_hsync_bajo = 0;

    // RESET INICIAL

    repeat (3) @(negedge clok);

    btnC = 1'b0;

    $display("CPU + VGA: inicio de simulacion");

    // Ejecutar 4000 ciclos de reloj.
    // Tiempo aproximado: 40 us.
    // Permite verificar una linea VGA completa.

    repeat (4000) @(negedge clok);

    #1;

    // ======================================
    // COMPROBACIONES FINALES
    // ======================================

    if (escrituras_video !== 1)
        $fatal(1,
            "ERROR: numero de escrituras=%0d",
            escrituras_video);

    if (dut.color_registro !== 6'h2A)
        $fatal(1,
            "ERROR: registro de color incorrecto");

    if (led[5:0] !== 6'h2A)
        $fatal(1,
            "ERROR: LED de color incorrecto");

    if (led[7] !== 1'b0)
        $fatal(1,
            "ERROR: CPU detenida, motivo=%b",
            led[10:8]);

    if (muestras_color == 0)
        $fatal(1,
            "ERROR: VGA no mostro el color esperado");

    if (muestras_blanking == 0)
        $fatal(1,
            "ERROR: no se detecto blanking");

    if (muestras_hsync_bajo == 0)
        $fatal(1,
            "ERROR: no se detecto pulso HSYNC");

    if (dut.controlador_vga.v_count < 1)
        $fatal(1,
            "ERROR: VGA no avanzo a segunda linea");

    // ======================================
    // RESULTADO FINAL
    // ======================================

    $display("================================");
    $display("PRUEBA CPU + VGA EXITOSA");
    $display("================================");

    $display("Escrituras CPU: %0d",
             escrituras_video);

    $display("Color final: %h",
             dut.color_registro);

    $display("Muestras RGB correctas: %0d",
             muestras_color);

    $display("Muestras de blanking: %0d",
             muestras_blanking);

    $display("Muestras HSYNC bajo: %0d",
             muestras_hsync_bajo);

    $display("CPU detenida: %b", led[7]);

    $display("================================");

    $finish;

end

endmodule

