`timescale 1ns / 1ps

module unidad_riesgos (
    input wire [31:0] instruccion_id,

    input wire [4:0] rd_ex,
    input wire escribir_registro_ex,
    input wire [1:0] origen_resultado_ex,

    output wire detener_pipeline
);

wire [6:0] opcode_id;
wire [4:0] rs1_id;
wire [4:0] rs2_id;

reg usa_rs1;
reg usa_rs2;

assign opcode_id = instruccion_id[6:0];
assign rs1_id = instruccion_id[19:15];
assign rs2_id = instruccion_id[24:20];

// ==========================================
// REGISTROS UTILIZADOS EN ID
// ==========================================

always @(*) begin

    usa_rs1 = 1'b0;
    usa_rs2 = 1'b0;

    case (opcode_id)

        // Operaciones tipo R
        7'b0110011: begin
            usa_rs1 = 1'b1;
            usa_rs2 = 1'b1;
        end

        // STORE
        7'b0100011: begin
            usa_rs1 = 1'b1;
            usa_rs2 = 1'b1;
        end

        // BRANCH
        7'b1100011: begin
            usa_rs1 = 1'b1;
            usa_rs2 = 1'b1;
        end

        // Operaciones tipo I
        7'b0010011: begin
            usa_rs1 = 1'b1;
        end

        // LOAD
        7'b0000011: begin
            usa_rs1 = 1'b1;
        end

        // JALR
        7'b1100111: begin
            usa_rs1 = 1'b1;
        end

        default: begin
            usa_rs1 = 1'b0;
            usa_rs2 = 1'b0;
        end

    endcase

end

// ==========================================
// DETECCION LOAD-USE
// ==========================================

assign detener_pipeline =
    escribir_registro_ex &&
    (origen_resultado_ex == 2'b01) &&
    (rd_ex != 5'b00000) &&
    (
        (usa_rs1 && (rs1_id == rd_ex)) ||
        (usa_rs2 && (rs2_id == rd_ex))
    );

endmodule