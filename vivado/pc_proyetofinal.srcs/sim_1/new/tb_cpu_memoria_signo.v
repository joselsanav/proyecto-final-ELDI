`timescale 1ns / 1ps

module tb_cpu_memoria_signo;

reg clok;
reg btnC;

wire [15:0] led;

integer escrituras;
reg error_detectado;

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
            0: esperado = 32'h000000FF;
            1: esperado = 32'hFFFFFFFF;
            2: esperado = 32'h0000FF80;
            3: esperado = 32'hFFFFFF80;
            4: esperado = 32'hFF80FF00;
            5: esperado = 32'h00000001;
            6: esperado = 32'h00000000;
            7: esperado = 32'h0FFFFFF8;
            8: esperado = 32'hFFFFFFF8;
            default: esperado = 32'hXXXXXXXX;
        endcase
    end

endfunction

// ==========================================
// SUPERVISION DE ESCRITURAS VGA
// ==========================================

always @(posedge clok) begin

    if (!btnC && dut.escribir_video) begin

        $display(
            "Escritura %0d: dato=%h esperado=%h",
            escrituras + 1,
            dut.dato_escritura_video,
            esperado(escrituras)
        );

        if (
            dut.direccion_video !== 32'h40000000 ||
            dut.habilitar_bytes_video !== 4'b1111 ||
            escrituras >= 9 ||
            dut.dato_escritura_video !== esperado(escrituras)
        ) begin

            error_detectado = 1'b1;
            $display("ERROR: Escritura incorrecta");

        end

        escrituras = escrituras + 1;

    end

end

// ==========================================
// SECUENCIA DE PRUEBA
// ==========================================

initial begin

    btnC = 1'b1;
    escrituras = 0;
    error_detectado = 1'b0;

    repeat (3) @(negedge clok);

    btnC = 1'b0;

    repeat (70) @(negedge clok);

    #1;

    // Comprobar RAM:
    // byte3=FF byte2=80 byte1=FF byte0=00

    if (
        dut.sistema.memoria_datos.memoria[4]
        !== 32'hFF80FF00
    ) begin

        error_detectado = 1'b1;
        $display("ERROR: Contenido incorrecto en RAM");

    end

    if (escrituras != 9) begin

        error_detectado = 1'b1;
        $display(
            "ERROR: Se esperaban 9 escrituras, llegaron %0d",
            escrituras
        );

    end

    if (led[5:0] !== 6'h38) begin

        error_detectado = 1'b1;
        $display("ERROR: Color final incorrecto");

    end

    if (led[7] !== 1'b0) begin

        error_detectado = 1'b1;
        $display(
            "ERROR: CPU detenida, motivo=%b",
            led[10:8]
        );

    end

    $display("================================");

    if (!error_detectado) begin

        $display("PRUEBA 3 EXITOSA");
        $display("SB / SH / LW: correctos");
        $display("LB / LBU: correctos");
        $display("LH / LHU: correctos");
        $display("SLTI / SLTIU: correctos");
        $display("SRLI / SRAI: correctos");
        $display("Escrituras VGA: 9");

    end

    else begin

        $display("PRUEBA 3 FALLIDA");

    end

    $display("================================");

    $finish;

end

endmodule
