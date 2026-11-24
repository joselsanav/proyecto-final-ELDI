`timescale 1ns / 1ps

module control_top (
    input wire [31:0] instruccion,

    output wire escribir_registro,
    output wire tipo_seg_operando,
    output wire [2:0] tipo_inmediato,

    output wire escribir_memoria,
    output wire [1:0] origen_resultado,

    output wire alu_usa_pc,
    output wire salto_condicional,
    output wire salto,
    output wire jalr,

    output wire [3:0] operacion_alu,

    output reg instruccion_valida,

    output wire es_fence,
    output wire es_ecall,
    output wire es_ebreak,
    output wire instruccion_ilegal
);

// ==========================================
// CAMPOS DE LA INSTRUCCION
// ==========================================

wire [6:0] opcode;
wire [2:0] funct3;
wire [6:0] funct7;
wire bit30;

assign opcode = instruccion[6:0];
assign funct3 = instruccion[14:12];
assign funct7 = instruccion[31:25];
assign bit30 = instruccion[30];

// ==========================================
// IDENTIFICACION DE INSTRUCCIONES ESPECIALES
// ==========================================

assign es_fence =
    (opcode == 7'b0001111) &&
    (funct3 == 3'b000);

assign es_ecall =
    (instruccion == 32'h00000073);

assign es_ebreak =
    (instruccion == 32'h00100073);

assign instruccion_ilegal = !instruccion_valida;

// ==========================================
// SEÑALES INTERNAS DE CONTROL
// ==========================================

wire escribir_registro_uc;
wire tipo_seg_operando_uc;
wire [2:0] tipo_inmediato_uc;

wire escribir_memoria_uc;
wire [1:0] origen_resultado_uc;

wire alu_usa_pc_uc;
wire salto_condicional_uc;
wire salto_uc;
wire jalr_uc;

wire [3:0] operacion_alu_dec;

// ==========================================
// UNIDAD DE CONTROL PRINCIPAL
// ==========================================

uc control_principal (
    .opcode(opcode),

    .escribir_registro(escribir_registro_uc),
    .tipo_seg_operando(tipo_seg_operando_uc),
    .tipo_inmediato(tipo_inmediato_uc),

    .escribir_memoria(escribir_memoria_uc),
    .origen_resultado(origen_resultado_uc),

    .alu_usa_pc(alu_usa_pc_uc),
    .salto_condicional(salto_condicional_uc),
    .salto(salto_uc),
    .jalr(jalr_uc)
);

// ==========================================
// DECODIFICADOR DE LA ALU
// ==========================================

alu_decoder decodificador_alu (
    .opcode(opcode),
    .funct3(funct3),
    .bit30(bit30),

    .operacion_alu(operacion_alu_dec)
);

// ==========================================
// VALIDACION DE INSTRUCCIONES RV32I
// ==========================================

always @(*) begin

    instruccion_valida = 1'b0;

    case (opcode)

        // TIPO R
        7'b0110011: begin

            case (funct3)

                // ADD / SUB
                3'b000:
                    instruccion_valida =
                        (funct7 == 7'b0000000) ||
                        (funct7 == 7'b0100000);

                // SRL / SRA
                3'b101:
                    instruccion_valida =
                        (funct7 == 7'b0000000) ||
                        (funct7 == 7'b0100000);

                // Otras instrucciones tipo R
                default:
                    instruccion_valida =
                        (funct7 == 7'b0000000);

            endcase

        end

        // TIPO I ARITMETICO
        7'b0010011: begin

            case (funct3)

                // SLLI
                3'b001:
                    instruccion_valida =
                        (funct7 == 7'b0000000);

                // SRLI / SRAI
                3'b101:
                    instruccion_valida =
                        (funct7 == 7'b0000000) ||
                        (funct7 == 7'b0100000);

                // ADDI, SLTI, SLTIU,
                // XORI, ORI, ANDI
                default:
                    instruccion_valida = 1'b1;

            endcase

        end

        // LOAD
        7'b0000011: begin

            case (funct3)

                3'b000,
                3'b001,
                3'b010,
                3'b100,
                3'b101:
                    instruccion_valida = 1'b1;

                default:
                    instruccion_valida = 1'b0;

            endcase

        end

        // STORE
        7'b0100011: begin

            case (funct3)

                3'b000,
                3'b001,
                3'b010:
                    instruccion_valida = 1'b1;

                default:
                    instruccion_valida = 1'b0;

            endcase

        end

        // BRANCH
        7'b1100011: begin

            case (funct3)

                3'b000,
                3'b001,
                3'b100,
                3'b101,
                3'b110,
                3'b111:
                    instruccion_valida = 1'b1;

                default:
                    instruccion_valida = 1'b0;

            endcase

        end

        // JALR
        7'b1100111:
            instruccion_valida =
                (funct3 == 3'b000);

        // JAL
        7'b1101111:
            instruccion_valida = 1'b1;

        // LUI
        7'b0110111:
            instruccion_valida = 1'b1;

        // AUIPC
        7'b0010111:
            instruccion_valida = 1'b1;

        // FENCE
        7'b0001111:
            instruccion_valida = es_fence;

        // ECALL / EBREAK
        7'b1110011:
            instruccion_valida =
                es_ecall || es_ebreak;

        default:
            instruccion_valida = 1'b0;

    endcase

end

// ==========================================
// SALIDAS DE CONTROL VALIDADAS
// ==========================================

assign escribir_registro =
    instruccion_valida
    ? escribir_registro_uc
    : 1'b0;

assign tipo_seg_operando =
    instruccion_valida
    ? tipo_seg_operando_uc
    : 1'b0;

assign tipo_inmediato =
    instruccion_valida
    ? tipo_inmediato_uc
    : 3'b000;

assign escribir_memoria =
    instruccion_valida
    ? escribir_memoria_uc
    : 1'b0;

assign origen_resultado =
    instruccion_valida
    ? origen_resultado_uc
    : 2'b00;

assign alu_usa_pc =
    instruccion_valida
    ? alu_usa_pc_uc
    : 1'b0;

assign salto_condicional =
    instruccion_valida
    ? salto_condicional_uc
    : 1'b0;

assign salto =
    instruccion_valida
    ? salto_uc
    : 1'b0;

assign jalr =
    instruccion_valida
    ? jalr_uc
    : 1'b0;

assign operacion_alu =
    instruccion_valida
    ? operacion_alu_dec
    : 4'b0000;

endmodule