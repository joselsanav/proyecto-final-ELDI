`timescale 1ns / 1ps

module ex_mem (

    // Señales generales
    input wire clok,
    input wire reset,
    input wire hab_paso,
    input wire anular_etapa,

    // Resultado de la ALU
    input wire [31:0] resultado_alu_entrada,
    output reg [31:0] resultado_alu_salida,

    // Dato para escribir en memoria
    input wire [31:0] dato_para_memoria_entrada,
    output reg [31:0] dato_para_memoria_salida,

    // Direccion de retorno para JAL/JALR
    input wire [31:0] pc_mas_4_entrada,
    output reg [31:0] pc_mas_4_salida,

    // Registro destino
    input wire [4:0] rd_entrada,
    output reg [4:0] rd_salida,

    // Tipo de acceso a memoria
    input wire [2:0] funct3_entrada,
    output reg [2:0] funct3_salida,

    // Habilitacion de escritura en registros
    input wire escribir_registro_entrada,
    output reg escribir_registro_salida,

    // Habilitacion de escritura en memoria
    input wire escribir_memoria_entrada,
    output reg escribir_memoria_salida,

    // Seleccion de resultado para WB
    input wire [1:0] origen_resultado_entrada,
    output reg [1:0] origen_resultado_salida,

    // Valor inmediato para LUI
    input wire [31:0] inmediato_entrada,
    output reg [31:0] inmediato_salida
);

always @(posedge clok or negedge reset) begin

    if (reset == 1'b0) begin

        resultado_alu_salida <= 32'b0;
        dato_para_memoria_salida <= 32'b0;
        pc_mas_4_salida <= 32'b0;
        rd_salida <= 5'b0;
        funct3_salida <= 3'b0;
        escribir_registro_salida <= 1'b0;
        escribir_memoria_salida <= 1'b0;
        origen_resultado_salida <= 2'b0;
        inmediato_salida <= 32'b0;

    end

    else if (anular_etapa == 1'b1) begin

        resultado_alu_salida <= 32'b0;
        dato_para_memoria_salida <= 32'b0;
        pc_mas_4_salida <= 32'b0;
        rd_salida <= 5'b0;
        funct3_salida <= 3'b0;
        escribir_registro_salida <= 1'b0;
        escribir_memoria_salida <= 1'b0;
        origen_resultado_salida <= 2'b0;
        inmediato_salida <= 32'b0;

    end

    else if (hab_paso == 1'b1) begin

        resultado_alu_salida <= resultado_alu_entrada;
        dato_para_memoria_salida <= dato_para_memoria_entrada;
        pc_mas_4_salida <= pc_mas_4_entrada;
        rd_salida <= rd_entrada;
        funct3_salida <= funct3_entrada;
        escribir_registro_salida <= escribir_registro_entrada;
        escribir_memoria_salida <= escribir_memoria_entrada;
        origen_resultado_salida <= origen_resultado_entrada;
        inmediato_salida <= inmediato_entrada;

    end

end

endmodule

