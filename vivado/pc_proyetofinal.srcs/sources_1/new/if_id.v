`timescale 1ns / 1ps

module if_id (
    input wire clok,
    input wire reset,
    input wire hab_paso,
    input wire anular_etapa,

    input wire [31:0] pc_entrada,
    input wire [31:0] instruccion_entrada,

    output reg [31:0] pc_salida,
    output reg [31:0] instruccion_salida
);

always @(posedge clok or negedge reset) begin

    if (reset == 1'b0) begin
        pc_salida <= 32'b0;
        instruccion_salida <= 32'h00000013;
    end

    else if (anular_etapa == 1'b1) begin
        pc_salida <= 32'b0;
        instruccion_salida <= 32'h00000013;
    end

    else if (hab_paso == 1'b1) begin
        pc_salida <= pc_entrada;
        instruccion_salida <= instruccion_entrada;
    end

end

endmodule
