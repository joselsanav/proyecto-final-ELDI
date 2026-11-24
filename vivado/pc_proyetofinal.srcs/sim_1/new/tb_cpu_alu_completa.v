`timescale 1ns / 1ps

module tb_cpu_alu_completa;

reg clok;
reg btnC;
wire [15:0] led;

integer errores;
integer escrituras_video;
integer indice;

top_cpu_basys3 dut (
    .clok(clok),
    .btnC(btnC),
    .led(led)
);

initial clok = 1'b0;
always #5 clok = ~clok;

// ==========================================
// RESULTADOS ESPERADOS
// ==========================================

function [31:0] esperado;
    input integer numero;

    begin
        case (numero)

             0: esperado = 32'h00000013; // SUB
             1: esperado = 32'h00000000; // AND
             2: esperado = 32'hFFFFFFF3; // OR
             3: esperado = 32'hFFFFFFF3; // XOR
             4: esperado = 32'h00000018; // SLL
             5: esperado = 32'h1FFFFFFE; // SRL
             6: esperado = 32'hFFFFFFFE; // SRA
             7: esperado = 32'h00000001; // SLT
             8: esperado = 32'h00000000; // SLTU
             9: esperado = 32'h00000000; // ANDI
            10: esperado = 32'h00000013; // ORI
            11: esperado = 32'h00000004; // XORI
            12: esperado = 32'h00000030; // SLLI
            13: esperado = 32'h0FFFFFFF; // SRLI
            14: esperado = 32'hFFFFFFFF; // SRAI
            15: esperado = 32'h00000001; // SLTI
            16: esperado = 32'h00000000; // SLTIU
            17: esperado = 32'h0000007B; // ADDI
            18: esperado = 32'h0000007E; // ADD
            19: esperado = 32'h00000003; // x0

            default: esperado = 32'hXXXXXXXX;

        endcase
    end
endfunction

// ==========================================
// VERIFICACION DEL BUS DE VIDEO
// ==========================================

always @(posedge clok) begin

    if (!btnC && dut.escribir_video) begin

        escrituras_video = escrituras_video + 1;

        $display(
            "VIDEO %0d: dir=%h dato=%h bytes=%b",
            escrituras_video,
            dut.direccion_video,
            dut.dato_escritura_video,
            dut.habilitar_bytes_video
        );

        if (
            dut.direccion_video !== 32'h40000000 ||
            dut.dato_escritura_video !== 32'h0000002A ||
            dut.habilitar_bytes_video !== 4'b1111
        ) begin

            errores = errores + 1;
            $display("ERROR: escritura incorrecta en video");

        end

    end

end

// ==========================================
// SECUENCIA PRINCIPAL
// ==========================================

initial begin

    btnC = 1'b1;
    errores = 0;
    escrituras_video = 0;

    repeat (3) @(negedge clok);

    btnC = 1'b0;

    repeat (80) @(negedge clok);

    #1;

    // Comprobar 20 resultados de la ALU
    // almacenados desde RAM[64] hasta RAM[83]

    for (indice = 0; indice < 20; indice = indice + 1) begin

        if (
            dut.sistema.memoria_datos.memoria[64 + indice]
            !== esperado(indice)
        ) begin

            errores = errores + 1;

            $display(
                "ERROR RAM[%0d]: obtenido=%h esperado=%h",
                64 + indice,
                dut.sistema.memoria_datos.memoria[64 + indice],
                esperado(indice)
            );

        end

        else begin

            $display(
                "RAM[%0d] = %h (correcto)",
                64 + indice,
                esperado(indice)
            );

        end

    end

    // ======================================
    // COMPROBACIONES ADICIONALES
    // ======================================

    if (escrituras_video != 1) begin

        errores = errores + 1;

        $display(
            "ERROR: escrituras en video=%0d, esperado=1",
            escrituras_video
        );

    end

    if (led[5:0] !== 6'h2A) begin

        errores = errores + 1;

        $display(
            "ERROR: color final=%h, esperado=2A",
            led[5:0]
        );

    end

    if (led[7] !== 1'b0) begin

        errores = errores + 1;

        $display(
            "ERROR: CPU detenida, motivo=%b",
            led[10:8]
        );

    end

    // ======================================
    // RESULTADO FINAL
    // ======================================

    $display("================================");

    if (errores == 0) begin

        $display("PRUEBA 5 EXITOSA");
        $display("20 resultados de ALU correctos");
        $display("Registro x0: correcto");
        $display("Una escritura de video: correcta");

    end

    else begin

        $display(
            "PRUEBA 5 FALLIDA: %0d errores",
            errores
        );

    end

    $display("================================");

    $finish;

end

endmodule