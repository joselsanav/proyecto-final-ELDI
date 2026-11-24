`timescale 1ns / 1ps

module ram_datos (
    input wire clok,

    input wire habilitar_lectura,
    input wire habilitar_escritura,

    input wire [31:0] direccion_datos,
    input wire [31:0] dato_escritura_bus,
    input wire [3:0] habilitar_bytes,

    output wire [31:0] dato_leido
);

reg [31:0] memoria [0:255];

wire [7:0] posicion_memoria;

assign posicion_memoria = direccion_datos[9:2];

// Lectura de memoria
assign dato_leido = habilitar_lectura
                  ? memoria[posicion_memoria]
                  : 32'b0;

// Escritura por bytes
always @(posedge clok) begin

    if (habilitar_escritura) begin

        if (habilitar_bytes[0])
            memoria[posicion_memoria][7:0]
                <= dato_escritura_bus[7:0];

        if (habilitar_bytes[1])
            memoria[posicion_memoria][15:8]
                <= dato_escritura_bus[15:8];

        if (habilitar_bytes[2])
            memoria[posicion_memoria][23:16]
                <= dato_escritura_bus[23:16];

        if (habilitar_bytes[3])
            memoria[posicion_memoria][31:24]
                <= dato_escritura_bus[31:24];

    end

end

endmodule