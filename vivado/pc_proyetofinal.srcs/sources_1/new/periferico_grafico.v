`timescale 1ns / 1ps

module periferico_grafico (
    input wire clok,
    input wire reset,

    input wire [31:0] direccion_video,
    input wire [31:0] dato_escritura_video,
    input wire escribir_video,
    input wire leer_video,
    input wire [3:0] habilitar_bytes_video,

    input wire [9:0] pixel_x,
    input wire [9:0] pixel_y,
    input wire [5:0] color_fondo,

    output wire [5:0] pixel_rgb,
    output reg [31:0] dato_lectura_video
);

// ==========================================
// RESOLUCION LOGICA 320 x 240
// ==========================================

localparam integer ANCHO = 320;
localparam integer ALTO = 240;
localparam integer TOTAL = ANCHO * ALTO;

// ==========================================
// MEMORIA GRAFICA
// BIT 6: PIXEL VALIDO
// BITS 5:0: RGB222
// ==========================================

reg [6:0] framebuffer [0:TOTAL-1];

integer i;

initial begin
    for (i = 0; i < TOTAL; i = i + 1)
        framebuffer[i] = 7'b0000000;
end

// ==========================================
// DECODIFICACION DE COMANDOS
// ==========================================

wire comando_pixel;

assign comando_pixel =
    escribir_video &&
    direccion_video == 32'h40000004 &&
    habilitar_bytes_video == 4'b1111;

// ==========================================
// COORDENADAS DE ESCRITURA
// ==========================================

wire [8:0] x_escritura;
wire [7:0] y_escritura;
wire [5:0] color_escritura;

assign x_escritura = dato_escritura_video[8:0];
assign y_escritura = dato_escritura_video[16:9];
assign color_escritura = dato_escritura_video[22:17];

wire coordenadas_validas;

assign coordenadas_validas =
    (x_escritura < ANCHO) &&
    (y_escritura < ALTO);

wire [16:0] direccion_escritura;

assign direccion_escritura =
    (y_escritura * 17'd320) + x_escritura;

// ==========================================
// ESCRITURA EN FRAMEBUFFER
// ==========================================

always @(posedge clok) begin

    if (reset && comando_pixel && coordenadas_validas) begin
        framebuffer[direccion_escritura] <=
            {1'b1, color_escritura};
    end

end

// ==========================================
// COORDENADAS VGA A COORDENADAS LOGICAS
// ==========================================

wire [8:0] x_lectura;
wire [7:0] y_lectura;

assign x_lectura = pixel_x[9:1];
assign y_lectura = pixel_y[8:1];

wire dentro_pantalla;

assign dentro_pantalla =
    (pixel_x < 640) &&
    (pixel_y < 480);

wire [16:0] direccion_lectura;

assign direccion_lectura =
    dentro_pantalla
    ? ((y_lectura * 17'd320) + x_lectura)
    : 17'd0;

// ==========================================
// LECTURA SINCRONA DE MEMORIA
// ==========================================

reg [6:0] dato_pixel = 7'b0000000;

always @(posedge clok) begin
    dato_pixel <= framebuffer[direccion_lectura];
end

// ==========================================
// SELECCION DEL COLOR
// ==========================================

assign pixel_rgb =
    dato_pixel[6]
    ? dato_pixel[5:0]
    : color_fondo;

// ==========================================
// REGISTRO DEL ULTIMO COMANDO
// ==========================================

reg [31:0] ultimo_comando;

always @(posedge clok or negedge reset) begin

    if (!reset)
        ultimo_comando <= 32'b0;

    else if (comando_pixel)
        ultimo_comando <= dato_escritura_video;

end

// ==========================================
// LECTURAS DEL PERIFERICO
// ==========================================

always @(*) begin

    dato_lectura_video = 32'b0;

    if (leer_video) begin

        case (direccion_video)

            32'h40000000:
                dato_lectura_video = {26'b0, color_fondo};

            32'h40000004:
                dato_lectura_video = ultimo_comando;

            default:
                dato_lectura_video = 32'b0;

        endcase

    end

end

endmodule
