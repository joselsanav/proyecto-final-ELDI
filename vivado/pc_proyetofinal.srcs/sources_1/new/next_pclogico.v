`timescale 1ns / 1ps

module next_pc_logic #(
    parameter ANCHO = 32
)(
    input wire [ANCHO-1:0] pc_actual,
    input wire [ANCHO-1:0] inmediato,
    input wire [ANCHO-1:0] resultado_jalr,
    input wire [1:0] seleccion_pc,
    output wire [ANCHO-1:0] pc_siguiente
);

    wire [ANCHO-1:0] pc_mas4;
    wire [ANCHO-1:0] pc_salto;
    wire [ANCHO-1:0] jalr_ajustado;

    assign pc_mas4 = pc_actual + 4;
    assign pc_salto = pc_actual + inmediato;
    assign jalr_ajustado = {resultado_jalr[ANCHO-1:1], 1'b0};

    mux4a1 #(.ANCHO(ANCHO)) mux_pc (
        .D0(pc_mas4),
        .D1(pc_salto),
        .D2(jalr_ajustado),
        .D3(pc_mas4),
        .sel(seleccion_pc),
        .Y(pc_siguiente)
    );

endmodule

