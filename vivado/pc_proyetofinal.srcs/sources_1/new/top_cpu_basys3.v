`timescale 1ns / 1ps

module top_cpu_basys3 (
    input wire clok,
    input wire btnC,
    output wire [15:0] led
);

// ==========================================
// RESET ACTIVO EN BAJO
// ==========================================

wire reset;

assign reset = ~btnC;

// ==========================================
// INTERFAZ INTERNA DE VIDEO
// ==========================================

wire [31:0] direccion_video;
wire [31:0] dato_escritura_video;

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
// REGISTRO TEMPORAL DE COLOR
// ==========================================

reg [5:0] color_registro;

always @(posedge clok or negedge reset) begin

    if (!reset) begin
        color_registro <= 6'b000000;
    end

    else if (
        escribir_video &&
        direccion_video == 32'h40000000 &&
        habilitar_bytes_video[0]
    ) begin

        color_registro <= dato_escritura_video[5:0];

    end

end

// ==========================================
// SISTEMA CPU + RAM + ROM
// ==========================================

sistema_cpu_ram sistema (
    .clok(clok),
    .reset(reset),

    .dato_lectura_video({
        26'b0,
        color_registro
    }),

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
// SALIDAS DE DIAGNOSTICO
// ==========================================

assign led[5:0] = color_registro;

assign led[6] = escribir_video;

assign led[7] = detenido;

assign led[10:8] = motivo_detencion;

assign led[11] = acceso_desalineado;

assign led[15:12] = pc_observado[5:2];

endmodule
