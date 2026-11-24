module pc1_tb;

    parameter ANCHO = 32;

    reg clok;
    reg reset;
    reg hab_paso;
    reg [ANCHO-1:0] pc_siguiente;
    wire [ANCHO-1:0] pc_actual;

    pc1 #(ANCHO) uut (
        .clok(clok),
        .reset(reset),
        .hab_paso(hab_paso),
        .pc_siguiente(pc_siguiente),
        .pc_actual(pc_actual)
    );

    initial begin
        clok = 0;
        forever #5 clok = ~clok;
    end

    initial begin

        reset = 0;
        hab_paso = 0;
        pc_siguiente = 0;

        #12;
        pc_siguiente = 4;
        hab_paso = 1;
        reset = 1;

        #10;
        hab_paso = 1;
        pc_siguiente = 32'd4;

        #10;
        pc_siguiente = 32'd8;

        #10;
        hab_paso = 0;

        #10;
        pc_siguiente = 32'd100;

        #10;
        hab_paso = 1;

        #10;
        pc_siguiente = 32'd132;

        #5
        reset = 0;

        #4;
        reset = 1;

        #20;
        $finish;

    end

endmodule