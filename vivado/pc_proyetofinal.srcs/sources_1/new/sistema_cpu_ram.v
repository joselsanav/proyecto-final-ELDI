`timescale 1ns / 1ps

module sistema_cpu_ram (
    input wire clok,
    input wire reset,

    input wire [31:0] dato_lectura_video,

    output wire [31:0] direccion_video,
    output wire [31:0] dato_escritura_video,
    output wire escribir_video,
    output wire leer_video,
    output wire [3:0] habilitar_bytes_video,

    output wire [31:0] pc_observado,
    output wire acceso_desalineado,

    output wire detenido,
    output wire [2:0] motivo_detencion,
    output wire [31:0] pc_detencion
);

// ==========================================
// BUS DE INSTRUCCIONES
// ==========================================

wire [31:0] direccion_instruccion;
wire [31:0] instruccion_bus;

memoria_instrucciones rom_programa (
    .direccion_instruccion(direccion_instruccion),
    .instruccion_bus(instruccion_bus)
);

// ==========================================
// BUS DE DATOS
// ==========================================

wire [31:0] direccion_datos;
wire [31:0] dato_escritura_bus;
wire [31:0] dato_lectura_bus;

wire escribir_memoria_bus;
wire leer_memoria_bus;

wire [3:0] habilitar_bytes;

// ==========================================
// DECODIFICACION DE DIRECCIONES
// ==========================================

wire seleccion_ram;
wire seleccion_video;
wire fallo_direccion_bus;

wire [31:0] dato_leido_ram;

// RAM: 0x00000000 - 0x000003FF
assign seleccion_ram =
    (direccion_datos[31:10] == 22'b0);

// VIDEO: 0x40000000 - 0x400000FF
assign seleccion_video =
    (direccion_datos[31:8] == 24'h400000);

// ==========================================
// DETECCION DE DIRECCIONES INVALIDAS
// ==========================================

assign fallo_direccion_bus =
    (leer_memoria_bus || escribir_memoria_bus) &&
    !seleccion_ram &&
    !seleccion_video;

// ==========================================
// CPU
// ==========================================

cpu_bus procesador (
    .clok(clok),
    .reset(reset),

    .instruccion_bus(instruccion_bus),
    .direccion_instruccion(direccion_instruccion),

    .dato_lectura_bus(dato_lectura_bus),
    .fallo_direccion_bus(fallo_direccion_bus),

    .direccion_datos(direccion_datos),
    .dato_escritura_bus(dato_escritura_bus),

    .escribir_memoria_bus(escribir_memoria_bus),
    .leer_memoria_bus(leer_memoria_bus),

    .habilitar_bytes(habilitar_bytes),
    .acceso_desalineado(acceso_desalineado),

    .pc_observado(pc_observado),

    .detenido(detenido),
    .motivo_detencion(motivo_detencion),
    .pc_detencion(pc_detencion)
);

// ==========================================
// RAM DE DATOS
// ==========================================

ram_datos memoria_datos (
    .clok(clok),

    .habilitar_lectura(
        leer_memoria_bus && seleccion_ram
    ),

    .habilitar_escritura(
        escribir_memoria_bus && seleccion_ram
    ),

    .direccion_datos(direccion_datos),
    .dato_escritura_bus(dato_escritura_bus),

    .habilitar_bytes(habilitar_bytes),

    .dato_leido(dato_leido_ram)
);

// ==========================================
// DATOS LEIDOS POR LA CPU
// ==========================================

assign dato_lectura_bus =
    seleccion_ram
    ? dato_leido_ram
    : seleccion_video
    ? dato_lectura_video
    : 32'b0;

// ==========================================
// INTERFAZ HACIA VIDEO
// ==========================================

assign direccion_video = direccion_datos;

assign dato_escritura_video =
    dato_escritura_bus;

assign escribir_video =
    escribir_memoria_bus && seleccion_video;

assign leer_video =
    leer_memoria_bus && seleccion_video;

assign habilitar_bytes_video =
    escribir_video
    ? habilitar_bytes
    : 4'b0000;

endmodule
