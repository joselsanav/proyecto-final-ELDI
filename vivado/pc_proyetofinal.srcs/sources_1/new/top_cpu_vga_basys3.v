
`timescale 1ns / 1ps

module top_cpu_vga_basys3 (
    input wire clok,
    input wire btnC,
    output wire [15:0] led,

    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue,
    output wire Hsync,
    output wire Vsync
);

// ==========================================
// RESET
// ==========================================

wire reset;
assign reset = ~btnC;

// ==========================================
// BUS DE VIDEO
// ==========================================

wire [31:0] direccion_video;
wire [31:0] dato_escritura_video;
wire [31:0] dato_lectura_video;

wire escribir_video;
wire leer_video;
wire [3:0] habilitar_bytes_video;

// ==========================================
// DIAGNOSTICO DE CPU
// ==========================================

wire [31:0] pc_observado;
wire acceso_desalineado;

wire detenido;
wire [2:0] motivo_detencion;
wire [31:0] pc_detencion;

// ==========================================
// COLOR DE FONDO
// ==========================================

reg [5:0] color_registro;

always @(posedge clok or negedge reset) begin

    if (!reset)
        color_registro <= 6'b000000;

    else if (
        escribir_video &&
        direccion_video == 32'h40000000 &&
        habilitar_bytes_video[0]
    )
        color_registro <= dato_escritura_video[5:0];

end

// ==========================================
// CPU + RAM + ROM
// ==========================================

sistema_cpu_ram sistema (
    .clok(clok),
    .reset(reset),

    .dato_lectura_video(dato_lectura_video),

    .direccion_video(direccion_video),
    .dato_escritura_video(dato_escritura_video),

    .escribir_video(escribir_video),
    .leer_video(leer_video),

    .habilitar_bytes_video(habilitar_bytes_video),

    .pc_observado(pc_observado),
    .acceso_desalineado(acceso_desalineado),

    .detenido(detenido),
    .motivo_detencion(motivo_detencion),
    .pc_detencion(pc_detencion)
);

// ==========================================
// SEÑALES DEL CONTROLADOR VGA
// ==========================================

wire [9:0] pixel_x;
wire [9:0] pixel_y;

wire hsync_bruto;
wire vsync_bruto;
wire video_activo_bruto;

wire [5:0] rgb_pixel_mem;

// ==========================================
// PERIFERICO GRAFICO
// ==========================================

periferico_grafico graficos (
    .clok(clok),
    .reset(reset),

    .direccion_video(direccion_video),
    .dato_escritura_video(dato_escritura_video),

    .escribir_video(escribir_video),
    .leer_video(leer_video),

    .habilitar_bytes_video(habilitar_bytes_video),

    .pixel_x(pixel_x),
    .pixel_y(pixel_y),

    .color_fondo(color_registro),

    .pixel_rgb(rgb_pixel_mem),

    .dato_lectura_video(dato_lectura_video)
);

// ==========================================
// VGA 640x480
// ==========================================

vga_640x480 controlador_vga (
    .clk(clok),
    .reset(btnC),

    .pixel_rgb(rgb_pixel_mem),

    .h_count(),
    .v_count(),

    .pixel_x(pixel_x),
    .pixel_y(pixel_y),

    .hsync(hsync_bruto),
    .vsync(vsync_bruto),

    .video_active(video_activo_bruto),

    .red(),
    .green(),
    .blue()
);

// ==========================================
// ALINEACION TEMPORAL
// ==========================================

reg hsync_alineado;
reg vsync_alineado;
reg video_activo_alineado;

always @(posedge clok) begin

    if (btnC) begin
        hsync_alineado <= 1'b1;
        vsync_alineado <= 1'b1;
        video_activo_alineado <= 1'b0;
    end

    else begin
        hsync_alineado <= hsync_bruto;
        vsync_alineado <= vsync_bruto;
        video_activo_alineado <= video_activo_bruto;
    end

end

// ==========================================
// SALIDAS VGA
// ==========================================

assign Hsync = hsync_alineado;
assign Vsync = vsync_alineado;

assign vgaRed =
    video_activo_alineado
    ? {rgb_pixel_mem[5:4], rgb_pixel_mem[5:4]}
    : 4'b0000;

assign vgaGreen =
    video_activo_alineado
    ? {rgb_pixel_mem[3:2], rgb_pixel_mem[3:2]}
    : 4'b0000;

assign vgaBlue =
    video_activo_alineado
    ? {rgb_pixel_mem[1:0], rgb_pixel_mem[1:0]}
    : 4'b0000;

// ==========================================
// DIAGNOSTICO LED
// ==========================================

assign led[5:0] = color_registro;

assign led[6] = escribir_video;

assign led[7] = detenido;

assign led[10:8] = motivo_detencion;

assign led[11] = acceso_desalineado;

assign led[15:12] = pc_observado[5:2];

endmodule