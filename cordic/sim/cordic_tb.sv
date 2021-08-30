`timescale 1ns/100ps
module cordic_tb ;
parameter simulation_cycle = 10;
bit SystemClock;
/* signals */
reg clk;
reg rst;
reg start;
reg [3:0] mode;
reg [13:0] x_in;
reg [13:0] y_in;
reg [13:0] z_in;
wire [13:0] x_out;
wire [13:0] y_out;
wire [13:0] z_out;
wire finish;


/* dut instance */
cordic cordic(
.clk(clk),
.rst(rst),
.start(start),
.mode(mode),
.x_in(x_in),
.y_in(y_in),
.z_in(z_in),
.x_out(x_out),
.y_out(y_out),
.z_out(z_out),
.finish(finish)
);


initial begin
    SystemClock = 0;
    clk = 0;
    forever begin
        #(simulation_cycle/2);
        SystemClock = ~SystemClock;
        clk = ~clk;
    end
end

initial begin
    rst = 0;
    start = 0;
    x_in = 'd0;
    y_in = 'd0;
    mode = 'd0;
    z_in = 'd0;

    #1000;
    rst = 1;
    #1000;
    rst = 0;
    #1000;
    //sincos('d0000);
    //sincos('d3000);
    //sincos('d6000);
    //sincos('d9000);
    //sincos('d4500);
    //sincos('d4000);
    //sincos('d8000);
    //multi('d4000,'d4096); //4000 * 0.5
    //multi('d3000,'d8192); //3000 * 1
    //multi('d2000,'d2048); //2000 * 0.25
    //multi('d1111,'d1111); //1111 * 0.1356 = 151
    //multi('d1234,'d4321); //1234 * 0.527 = 650
    //div('d3000,'d60); // 60 / 3000 = 200 
    //div('d8000,'d800); //800 / 8000 = 1000
    //div('d4321,'d1234); //800 / 8000 = 1000
end

initial begin
    #5000000;
    $finish;
end

/* generate wave */
initial begin
    $shm_open("cordic_tb.shm");
    $shm_probe("AMCTF");
end

task sincos;
input [13:0] angle;
    x_in = 'd6073;
    y_in = 'd0;
    z_in = angle;
    mode = 'd0;
    #100;
    @(negedge clk);
    start = 'd1;
    @(negedge clk);
    start = 'd0;
    @(posedge finish);
    $display("x_out:%d",x_out);
    $display("y_out:%d",y_out);
    $display("z_out:%d",z_out);
    #1000;
endtask

task multi;
input   [13:0]  x;
input   [13:0]  z;
    x_in = x;
    y_in = 'd0;
    z_in = z;
    mode = 'd1;
    #100;
    @(negedge clk);
    start = 'd1;
    @(negedge clk);
    start = 'd0;
    @(posedge finish);
    $display("true y_out    :%0d",x*z/8192);
    $display("result y_out  :%0d",y_out);
    #1000;
endtask

task div;
input   [13:0]  x;
input   [13:0]  y;
    x_in = x;
    y_in = y;
    z_in = 'd0;
    mode = 'd2;
    #100;
    @(negedge clk);
    start = 'd1;
    @(negedge clk);
    start = 'd0;
    @(posedge finish);
    $display("true answer   :%0f",1000*y/x);
    $display("result z_out  :%0f",z_out*1000/14'h2000);
    #1000;
endtask

endmodule
