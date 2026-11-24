`timescale 1ns / 1ps

module tb_periferico_grafico;

reg clok;
reg reset;

reg [31:0] direccion_video;
reg [31:0] dato_escritura_video;
reg escribir_video;
reg leer_video;
reg [3:0] habilitar_bytes_video;

reg [9:0] pixel_x;
reg [9:0] pixel_y;
reg [5:0] color_fondo;

wire [5:0] pixel_rgb;
wire [31:0] dato_lectura_video;

integer pruebas;

// ==========================================
// MODULO BAJO PRUEBA
// ==========================================

periferico_grafico dut (
    .clok(clok),
    .reset(reset),

    .direccion_video(direccion_video),
    .dato_escritura_video(dato_escritura_video),
    .escribir_video(escribir_video),
    .leer_video(leer_video),
    .habilitar_bytes_video(habilitar_bytes_video),

    .pixel_x(pixel_x),
    .pixel_y(pixel_y),
    .color_fondo(color_fondo),

    .pixel_rgb(pixel_rgb),
    .dato_lectura_video(dato_lectura_video)
);

// ==========================================
// RELOJ 100 MHz
// ==========================================

always #5 clok = ~clok;

// ==========================================
// CODIFICACION DE COMANDO
// ==========================================

function [31:0] comando;
    input [8:0] x;
    input [7:0] y;
    input [5:0] color;

    begin
        comando = {9'b0, color, y, x};
    end
endfunction

// ==========================================
// ESCRITURA DE UN PIXEL
// ==========================================

task escribir_pixel;
    input [8:0] x;
    input [7:0] y;
    input [5:0] color;

    begin
        @(negedge clok);

        direccion_video = 32'h40000004;
        dato_escritura_video = comando(x, y, color);
        habilitar_bytes_video = 4'b1111;
        escribir_video = 1'b1;

        @(negedge clok);
        escribir_video = 1'b0;
    end
endtask

// ==========================================
// VERIFICACION DEL COLOR LEIDO
// ==========================================

task comprobar_color;
    input [9:0] x;
    input [9:0] y;
    input [5:0] esperado;

    begin
        @(negedge clok);

        pixel_x = x;
        pixel_y = y;

        @(posedge clok);
        #1;

        if (pixel_rgb !== esperado) begin
            $fatal(1,
                "ERROR: pixel (%0d,%0d), esperado=%h, recibido=%h",
                x, y, esperado, pixel_rgb);
        end

        pruebas = pruebas + 1;
    end
endtask

// ==========================================
// SECUENCIA DE PRUEBAS
// ==========================================

initial begin

    clok = 0;
    reset = 0;

    direccion_video = 0;
    dato_escritura_video = 0;
    escribir_video = 0;
    leer_video = 0;
    habilitar_bytes_video = 0;

    pixel_x = 0;
    pixel_y = 0;
    color_fondo = 6'h03;

    pruebas = 0;

    repeat (3) @(negedge clok);
    reset = 1;

    $display("INICIO PRUEBA PERIFERICO GRAFICO");

    // PRUEBA 1: COLOR DE FONDO

    comprobar_color(20, 40, 6'h03);

    $display("PASS: color de fondo");

    // PRUEBA 2: DIBUJAR PIXEL ROJO

    escribir_pixel(9'd10, 8'd20, 6'h30);

    comprobar_color(20, 40, 6'h30);
    comprobar_color(21, 41, 6'h30);

    $display("PASS: escritura y escalado 2x2");

    // PRUEBA 3: PIXEL VECINO SIN MODIFICAR

    comprobar_color(22, 40, 6'h03);

    $display("PASS: pixel vecino");

    // PRUEBA 4: SOBRESCRIBIR UN PIXEL

    escribir_pixel(9'd10, 8'd20, 6'h03);

    color_fondo = 6'h0C;

    comprobar_color(20, 40, 6'h03);
    comprobar_color(22, 40, 6'h0C);

    $display("PASS: sobrescritura y fondo");

    // PRUEBA 5: LECTURA DEL ULTIMO COMANDO

    @(negedge clok);
    direccion_video = 32'h40000004;
    leer_video = 1'b1;

    #1;

    if (dato_lectura_video !==
        comando(9'd10, 8'd20, 6'h03))
        $fatal(1, "ERROR: lectura del comando");

    pruebas = pruebas + 1;
    leer_video = 1'b0;

    $display("PASS: lectura del comando");

    // PRUEBA 6: MASCARA DE BYTES INVALIDA

    @(negedge clok);
    direccion_video = 32'h40000004;
    dato_escritura_video =
        comando(9'd10, 8'd20, 6'h30);
    habilitar_bytes_video = 4'b0011;
    escribir_video = 1'b1;

    @(negedge clok);
    escribir_video = 1'b0;

    comprobar_color(20, 40, 6'h03);

    $display("PASS: mascara de escritura");

    // PRUEBA 7: COORDENADA X FUERA DE RANGO

    escribir_pixel(9'd320, 8'd20, 6'h3F);

    comprobar_color(0, 42, 6'h0C);

    $display("PASS: coordenada X invalida");

    // PRUEBA 8: COORDENADA Y FUERA DE RANGO

    escribir_pixel(9'd10, 8'd240, 6'h3F);

    comprobar_color(20, 40, 6'h03);

    $display("PASS: coordenada Y invalida");

    // PRUEBA 9: RESET DEL CONTROL

    @(negedge clok);
    reset = 0;

    repeat (2) @(negedge clok);
    reset = 1;

    comprobar_color(20, 40, 6'h03);

    $display("PASS: memoria conservada tras reset");

    // ======================================
    // RESULTADO
    // ======================================

    $display("==============================");
    $display("PRUEBA PERIFERICO EXITOSA");
    $display("Comprobaciones: %0d", pruebas);
    $display("Errores: 0");
    $display("==============================");

    $finish;

end

endmodule