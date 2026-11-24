`timescale 1ns / 1ps

module unidad_forwarding (
    input wire [4:0] rs1_ex,
    input wire [4:0] rs2_ex,

    input wire [4:0] rd_mem,
    input wire [4:0] rd_wb,

    input wire escribir_registro_mem,
    input wire escribir_registro_wb,

    input wire [1:0] origen_resultado_mem,

    output reg [1:0] seleccion_rs1,
    output reg [1:0] seleccion_rs2
);

wire disponible_mem;

assign disponible_mem =
    escribir_registro_mem &&
    (rd_mem != 5'b00000) &&
    (origen_resultado_mem != 2'b01);

always @(*) begin

    seleccion_rs1 = 2'b00;
    seleccion_rs2 = 2'b00;

    // Forwarding para rs1
    if (disponible_mem && (rd_mem == rs1_ex)) begin
        seleccion_rs1 = 2'b10;
    end
    else if (
        escribir_registro_wb &&
        (rd_wb != 5'b00000) &&
        (rd_wb == rs1_ex)
    ) begin
        seleccion_rs1 = 2'b01;
    end

    // Forwarding para rs2
    if (disponible_mem && (rd_mem == rs2_ex)) begin
        seleccion_rs2 = 2'b10;
    end
    else if (
        escribir_registro_wb &&
        (rd_wb != 5'b00000) &&
        (rd_wb == rs2_ex)
    ) begin
        seleccion_rs2 = 2'b01;
    end

end

endmodule