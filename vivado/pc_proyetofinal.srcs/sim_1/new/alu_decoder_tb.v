
`timescale 1ns / 1ps

module alu_decoder_tb;

    // Entradas del decodificador
    reg [6:0] opcode;
    reg [2:0] funct3;
    reg bit30;

    // Salida del decodificador
    wire [3:0] ALUC;

    // Conexion con nuestro modulo
    alu_decoder uut (
        .opcode(opcode),
        .funct3(funct3),
        .bit30(bit30),
        .ALUC(ALUC)
    );

    initial begin
    #10
        opcode= 7'b0110011;
        funct3= 3'b000;
        bit30=1'b0;
        #10
        opcode= 7'b0110011;
        funct3= 3'b000;
        bit30=1'b1;
        #10
        opcode= 7'b0110011;
        funct3= 3'b111;
        bit30=1'b0;
        #10
        opcode= 7'b0010011;
        funct3= 3'b000;
        bit30=1'b1;
        #10
        opcode= 7'b0010011;
        funct3= 3'b101;
        bit30=1'b1;
        #10
        opcode= 7'b1100011;
        funct3= 3'b000;
        bit30=1'b0;
        #10
        
        $finish;
    end

endmodule
