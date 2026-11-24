`timescale 1ns / 1ps

module regfile #(
    parameter ANCHO = 32
)(
    input wire clok,
    input wire escribir_registro,

    input wire [4:0] rs1,
    input wire [4:0] rs2,
    input wire [4:0] rd,

    input wire [ANCHO-1:0] dato_escritura,

    output wire [ANCHO-1:0] valor_rs1,
    output wire [ANCHO-1:0] valor_rs2
);

reg [ANCHO-1:0] registros [0:31];

always @(posedge clok) begin
    if (escribir_registro && rd != 5'd0) begin
        registros[rd] <= dato_escritura;
    end
end

assign valor_rs1 = (rs1 == 5'd0)
                   ? {ANCHO{1'b0}}
                   : registros[rs1];

assign valor_rs2 = (rs2 == 5'd0)
                   ? {ANCHO{1'b0}}
                   : registros[rs2];

endmodule