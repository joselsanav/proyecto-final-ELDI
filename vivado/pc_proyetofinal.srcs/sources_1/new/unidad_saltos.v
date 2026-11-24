`timescale 1ns / 1ps

module unidad_saltos (
    input wire [31:0] pc_instruccion,
    input wire [31:0] inmediato,

    input wire [31:0] valor_rs1,
    input wire [31:0] valor_rs2,

    input wire [2:0] funct3,

    input wire salto_condicional,
    input wire salto,
    input wire jalr,

    output wire tomar_salto,
    output wire [31:0] destino_salto
);

reg condicion_cumplida;

// ==========================================
// COMPARACION DE REGISTROS
// ==========================================

always @(*) begin

    condicion_cumplida = 1'b0;

    case (funct3)

        // BEQ
        3'b000:
            condicion_cumplida =
                (valor_rs1 == valor_rs2);

        // BNE
        3'b001:
            condicion_cumplida =
                (valor_rs1 != valor_rs2);

        // BLT
        3'b100:
            condicion_cumplida =
                ($signed(valor_rs1) <
                 $signed(valor_rs2));

        // BGE
        3'b101:
            condicion_cumplida =
                ($signed(valor_rs1) >=
                 $signed(valor_rs2));

        // BLTU
        3'b110:
            condicion_cumplida =
                (valor_rs1 < valor_rs2);

        // BGEU
        3'b111:
            condicion_cumplida =
                (valor_rs1 >= valor_rs2);

        default:
            condicion_cumplida = 1'b0;

    endcase

end

// ==========================================
// DECISION DEL SALTO
// ==========================================

assign tomar_salto =
    salto ||
    jalr ||
    (salto_condicional && condicion_cumplida);

// ==========================================
// DIRECCION DE DESTINO
// ==========================================

wire [31:0] destino_relativo;
wire [31:0] destino_jalr;

assign destino_relativo =
    pc_instruccion + inmediato;

assign destino_jalr =
    (valor_rs1 + inmediato) & 32'hFFFFFFFE;

assign destino_salto =
    jalr ? destino_jalr : destino_relativo;

endmodule