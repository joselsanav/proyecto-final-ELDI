`timescale 1ns / 1ps

module acceso_memoria (

    input wire [31:0] direccion_alu,
    input wire [31:0] dato_para_memoria,
    input wire [2:0] funct3,

    input wire escribir_memoria,
    input wire leer_memoria,

    input wire [31:0] dato_lectura_bus,

    output wire [31:0] direccion_datos,
    output wire [31:0] dato_escritura_bus,

    output wire escribir_memoria_bus,
    output wire leer_memoria_bus,

    output reg [3:0] habilitar_bytes,

    output reg [31:0] dato_leido_memoria,

    output wire acceso_desalineado
);

// ==========================================
// DIRECCION Y POSICION DEL BYTE
// ==========================================

wire [1:0] posicion_byte;
wire [31:0] dato_desplazado;

assign posicion_byte = direccion_alu[1:0];

assign direccion_datos = {
    direccion_alu[31:2],
    2'b00
};

assign dato_desplazado =
    dato_lectura_bus >> (posicion_byte * 8);

// ==========================================
// VALIDACION DEL TIPO DE ACCESO
// ==========================================

wire tipo_valido;

assign tipo_valido =
    escribir_memoria
    ? (
        (funct3 == 3'b000) ||
        (funct3 == 3'b001) ||
        (funct3 == 3'b010)
      )
    : (
        (funct3 == 3'b000) ||
        (funct3 == 3'b001) ||
        (funct3 == 3'b010) ||
        (funct3 == 3'b100) ||
        (funct3 == 3'b101)
      );

// ==========================================
// COMPROBACION DE ALINEACION
// ==========================================

wire error_alineacion;
wire acceso_solicitado;

assign acceso_solicitado =
    escribir_memoria || leer_memoria;

assign error_alineacion =
    (
        ((funct3 == 3'b001) ||
         (funct3 == 3'b101)) &&
        posicion_byte[0]
    )
    ||
    (
        (funct3 == 3'b010) &&
        (posicion_byte != 2'b00)
    );

assign acceso_desalineado =
    acceso_solicitado &&
    tipo_valido &&
    error_alineacion;

// ==========================================
// HABILITACION DEL BUS
// ==========================================

assign escribir_memoria_bus =
    escribir_memoria &&
    !leer_memoria &&
    tipo_valido &&
    !acceso_desalineado;

assign leer_memoria_bus =
    leer_memoria &&
    !escribir_memoria &&
    tipo_valido &&
    !acceso_desalineado;

// ==========================================
// ESCRITURA: SB, SH Y SW
// ==========================================

assign dato_escritura_bus =
    dato_para_memoria << (posicion_byte * 8);

always @(*) begin

    habilitar_bytes = 4'b0000;

    if (escribir_memoria_bus) begin

        case (funct3)

            // SB
            3'b000:
                habilitar_bytes =
                    4'b0001 << posicion_byte;

            // SH
            3'b001:
                habilitar_bytes =
                    4'b0011 << posicion_byte;

            // SW
            3'b010:
                habilitar_bytes = 4'b1111;

            default:
                habilitar_bytes = 4'b0000;

        endcase

    end

end

// ==========================================
// LECTURA: LB, LH, LW, LBU Y LHU
// ==========================================

always @(*) begin

    dato_leido_memoria = 32'b0;

    if (leer_memoria_bus) begin

        case (funct3)

            // LB
            3'b000:
                dato_leido_memoria = {
                    {24{dato_desplazado[7]}},
                    dato_desplazado[7:0]
                };

            // LH
            3'b001:
                dato_leido_memoria = {
                    {16{dato_desplazado[15]}},
                    dato_desplazado[15:0]
                };

            // LW
            3'b010:
                dato_leido_memoria =
                    dato_desplazado;

            // LBU
            3'b100:
                dato_leido_memoria = {
                    24'b0,
                    dato_desplazado[7:0]
                };

            // LHU
            3'b101:
                dato_leido_memoria = {
                    16'b0,
                    dato_desplazado[15:0]
                };

            default:
                dato_leido_memoria = 32'b0;

        endcase

    end

end

endmodule