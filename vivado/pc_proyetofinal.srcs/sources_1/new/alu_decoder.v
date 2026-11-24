`timescale 1ns / 1ps

module alu_decoder (
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire bit30,

    output reg [3:0] operacion_alu
);

// ==========================================
// CODIGOS DE OPERACION DE LA ALU
// ==========================================

localparam SUMA  = 4'b0000;
localparam RESTA = 4'b0001;
localparam AND   = 4'b0010;
localparam OR    = 4'b0011;
localparam XOR   = 4'b0100;
localparam SLL   = 4'b0101;
localparam SRL   = 4'b0110;
localparam SRA   = 4'b0111;
localparam SLT   = 4'b1000;
localparam SLTU  = 4'b1001;

// ==========================================
// DECODIFICACION DE OPERACIONES
// ==========================================

always @(*) begin

    operacion_alu = SUMA;

    case (opcode)

        // ==================================
        // INSTRUCCIONES TIPO R
        // ==================================

        7'b0110011: begin

            case (funct3)

                // ADD / SUB
                3'b000:
                    operacion_alu =
                        bit30 ? RESTA : SUMA;

                // SLL
                3'b001:
                    operacion_alu = SLL;

                // SLT
                3'b010:
                    operacion_alu = SLT;

                // SLTU
                3'b011:
                    operacion_alu = SLTU;

                // XOR
                3'b100:
                    operacion_alu = XOR;

                // SRL / SRA
                3'b101:
                    operacion_alu =
                        bit30 ? SRA : SRL;

                // OR
                3'b110:
                    operacion_alu = OR;

                // AND
                3'b111:
                    operacion_alu = AND;

            endcase

        end

        // ==================================
        // INSTRUCCIONES TIPO I
        // ==================================

        7'b0010011: begin

            case (funct3)

                // ADDI
                3'b000:
                    operacion_alu = SUMA;

                // SLLI
                3'b001:
                    operacion_alu = SLL;

                // SLTI
                3'b010:
                    operacion_alu = SLT;

                // SLTIU
                3'b011:
                    operacion_alu = SLTU;

                // XORI
                3'b100:
                    operacion_alu = XOR;

                // SRLI / SRAI
                3'b101:
                    operacion_alu =
                        bit30 ? SRA : SRL;

                // ORI
                3'b110:
                    operacion_alu = OR;

                // ANDI
                3'b111:
                    operacion_alu = AND;

            endcase

        end

        // ==================================
        // LOAD / STORE
        // ==================================

        7'b0000011,
        7'b0100011:
            operacion_alu = SUMA;

        // ==================================
        // BRANCH
        // ==================================

        7'b1100011: begin

            case (funct3)

                // BEQ / BNE
                3'b000,
                3'b001:
                    operacion_alu = RESTA;

                // BLT / BGE
                3'b100,
                3'b101:
                    operacion_alu = SLT;

                // BLTU / BGEU
                3'b110,
                3'b111:
                    operacion_alu = SLTU;

                default:
                    operacion_alu = SUMA;

            endcase

        end

        // ==================================
        // JALR / AUIPC
        // ==================================

        7'b1100111,
        7'b0010111:
            operacion_alu = SUMA;

        // ==================================
        // JAL / LUI
        // ==================================

        7'b1101111,
        7'b0110111:
            operacion_alu = SUMA;

        default:
            operacion_alu = SUMA;

    endcase

end

endmodule