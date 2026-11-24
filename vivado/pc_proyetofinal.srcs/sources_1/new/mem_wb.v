`timescale 1ns / 1ps

module mem_wb (

    input wire clok,
    input wire reset,
    input wire hab_paso,
    input wire anular_etapa,

    input wire [31:0] resultado_alu_entrada,
    output reg [31:0] resultado_alu_salida,

    input wire [31:0] dato_leido_memoria_entrada,
    output reg [31:0] dato_leido_memoria_salida,

    input wire [31:0] pc_mas_4_entrada,
    output reg [31:0] pc_mas_4_salida,

    input wire [4:0] rd_entrada,
    output reg [4:0] rd_salida,

    input wire escribir_registro_entrada,
    output reg escribir_registro_salida,

    input wire [1:0] origen_resultado_entrada,
    output reg [1:0] origen_resultado_salida,

    input wire [31:0] inmediato_entrada,
    output reg [31:0] inmediato_salida

);

always @(posedge clok or negedge reset) begin

    if (reset == 1'b0) begin

        resultado_alu_salida <= 32'b0;
        dato_leido_memoria_salida <= 32'b0;
        pc_mas_4_salida <= 32'b0;
        rd_salida <= 5'b0;
        escribir_registro_salida <= 1'b0;
        origen_resultado_salida <= 2'b0;
        inmediato_salida <= 32'b0;

    end

    else if (anular_etapa == 1'b1) begin

        resultado_alu_salida <= 32'b0;
        dato_leido_memoria_salida <= 32'b0;
        pc_mas_4_salida <= 32'b0;
        rd_salida <= 5'b0;
        escribir_registro_salida <= 1'b0;
        origen_resultado_salida <= 2'b0;
        inmediato_salida <= 32'b0;

    end

    else if (hab_paso == 1'b1) begin

        resultado_alu_salida <= resultado_alu_entrada;
        dato_leido_memoria_salida <= dato_leido_memoria_entrada;
        pc_mas_4_salida <= pc_mas_4_entrada;
        rd_salida <= rd_entrada;
        escribir_registro_salida <= escribir_registro_entrada;
        origen_resultado_salida <= origen_resultado_entrada;
        inmediato_salida <= inmediato_entrada;

    end

end

endmodule
