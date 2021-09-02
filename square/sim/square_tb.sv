`timescale 1ns/100ps
module square_tb ;
parameter simulation_cycle = 100;
bit SystemClock;
/* signals */
reg clk;
reg rst;
reg [2:0] mode;
reg [15:0] data_in;
reg start;
wire [7:0] sqr_root;
wire [8:0] remainder;
wire finish;
integer     i;  
reg         result;

/* dut instance */
square square(
.clk(clk),
.rst(rst),
.mode(mode),
.data_in(data_in),
.start(start),
.sqr_root(sqr_root),
.remainder(remainder),
.finish(finish)
);


/* generate clock  */
initial begin
    SystemClock = 0;
    clk         = 0;
    forever begin
        #(simulation_cycle/2);
        SystemClock = ~SystemClock;
        clk         = ~clk;
    end 
end

initial begin
    rst = 0;
    mode = 'd0;
    data_in = 'd0;
    start   = 'd0;
    result  = 'd0;
    #1000;
    rst = 1;
    #1000;
    rst = 0;
    #1000;
    //paper test 
//    for(i=0;i<65536;i++)begin
//        paper_test(i);
//    end
//    if(result == 1)begin
//        $display("test fail!!!");
//    end
     
    //restore test
//    for(i=16'b0100_0000_0000_0001;i<16'b1111_1111_1111_1111;i=i+16'b1_0000_0000)begin
//        restore_test(i);
//    end
//    if(result == 1)begin
//        $display("test fail!!!");
//    end

    #10000;
    $finish();
end

task paper_test;
input   [15:0]  in;
begin
    #1000;
    mode = 'd0;
    data_in =   in;
    $display("radicand: %d",in);
    @(negedge clk);
    start   =   'd1;
    @(negedge clk);
    start   =   'd0;
    @(finish);
    $display("sqr_root: %d,remainder: %d",sqr_root,remainder);
    if((sqr_root*sqr_root + remainder)!=in)begin
        $display("Error!!");
        result = 1;
    end
end
endtask

task restore_test;
input   [15:0]  in;
begin
    #1000;
    mode = 'd1;
    data_in =   in;
    $display("radicand: %b",in);
    @(negedge clk);
    start   =   'd1;
    @(negedge clk);
    start   =   'd0;
    @(finish);
    $display("root:%d,remainder:%d,in:%d",sqr_root[15:9],remainder[9:2],in[15:8]);
    if((sqr_root[15:9]*sqr_root[15:9] + remainder[9:2])!=in[15:8]*64)begin
        $display("Error!!");
        result = 1;
    end
end
endtask

/* generate wave */
initial begin
    $shm_open("square_tb.shm");
    $shm_probe("AMCTF");
end

endmodule
