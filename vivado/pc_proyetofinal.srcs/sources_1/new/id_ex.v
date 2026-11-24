`timescale 1ns / 1ps

module id_ex (
    input wire clok,
    input wire reset,
    input wire hab_paso,
    input wire anular_etapa,

    input wire escribir_registro_entrada,
    output reg escribir_registro_salida,

    input wire tipo_seg_operando_entrada,
    output reg tipo_seg_operando_salida,

    input wire escribir_memoria_entrada,
    output reg escribir_memoria_salida,

    input wire [1:0] origen_resultado_entrada,
    output reg [1:0] origen_resultado_salida,

    input wire alu_usa_pc_entrada,
    output reg alu_usa_pc_salida,

    input wire salto_condicional_entrada,
    output reg salto_condicional_salida,

    input wire salto_entrada,
    output reg salto_salida,

    input wire jalr_entrada,
    output reg jalr_salida,

    input wire [3:0] operacion_alu_entrada,
    output reg [3:0] operacion_alu_salida,

    input wire [31:0] pc_entrada,
    input wire [31:0] instruccion_entrada,
    input wire [31:0] valor_rs1_entrada,
    input wire [31:0] valor_rs2_entrada,
    input wire [31:0] inmediato_entrada,

    output reg [31:0] pc_salida,
    output reg [31:0] instruccion_salida,
    output reg [31:0] valor_rs1_salida,
    output reg [31:0] valor_rs2_salida,
    output reg [31:0] inmediato_salida
);

always @(posedge clok or negedge reset) begin

    if (reset == 1'b0) begin

        pc_salida <= 32'b0;
        instruccion_salida <= 32'h00000013;
        valor_rs1_salida <= 32'b0;
        valor_rs2_salida <= 32'b0;
        inmediato_salida <= 32'b0;

        escribir_registro_salida <= 1'b0;
        tipo_seg_operando_salida <= 1'b0;
        escribir_memoria_salida <= 1'b0;
        origen_resultado_salida <= 2'b00;
        alu_usa_pc_salida <= 1'b0;
        salto_condicional_salida <= 1'b0;
        salto_salida <= 1'b0;
        jalr_salida <= 1'b0;
        operacion_alu_salida <= 4'b0000;

    end

    else if (anular_etapa == 1'b1) begin

        pc_salida <= 32'b0;
        instruccion_salida <= 32'h00000013;
        valor_rs1_salida <= 32'b0;
        valor_rs2_salida <= 32'b0;
        inmediato_salida <= 32'b0;

        escribir_registro_salida <= 1'b0;
        tipo_seg_operando_salida <= 1'b0;
        escribir_memoria_salida <= 1'b0;
        origen_resultado_salida <= 2'b00;
        alu_usa_pc_salida <= 1'b0;
        salto_condicional_salida <= 1'b0;
        salto_salida <= 1'b0;
        jalr_salida <= 1'b0;
        operacion_alu_salida <= 4'b0000;

    end

    else if (hab_paso == 1'b1) begin

        pc_salida <= pc_entrada;
        instruccion_salida <= instruccion_entrada;
        valor_rs1_salida <= valor_rs1_entrada;
        valor_rs2_salida <= valor_rs2_entrada;
        inmediato_salida <= inmediato_entrada;

        escribir_registro_salida <= escribir_registro_entrada;
        tipo_seg_operando_salida <= tipo_seg_operando_entrada;
        escribir_memoria_salida <= escribir_memoria_entrada;
        origen_resultado_salida <= origen_resultado_entrada;
        alu_usa_pc_salida <= alu_usa_pc_entrada;
        salto_condicional_salida <= salto_condicional_entrada;
        salto_salida <= salto_entrada;
        jalr_salida <= jalr_entrada;
        operacion_alu_salida <= operacion_alu_entrada;

    end

end

endmodule