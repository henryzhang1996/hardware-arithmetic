module cordic
(
input               clk,
input               rst,
input               start,
input   [3:0]       mode, //0:circle roatation mode / 1: multi /2:divide
input   [13:0]      x_in,
input   [13:0]      y_in,
input   [13:0]      z_in,
output reg [13:0]   x_out,
output reg [13:0]   y_out,
output reg [13:0]   z_out,
output reg          finish
);

reg signed  [14:0]      z_temp;
reg signed  [14:0]      x_temp;
reg signed  [14:0]      y_temp;
reg         [5:0]       i;
reg signed  [1:0]       d;
reg                     status;
reg                     finish_temp;
reg  signed [14:0]      x_compute;
reg  signed [14:0]      y_compute;
reg  signed [14:0]      z_compute;

always@(*)begin
    if(mode == 'd0)
        finish_temp =   (((z_temp < 'sd10 ) || (z_temp > -'sd10)) && (i >= 'd12)) && (status == 'd1);
    else if ((mode == 'd1) || (mode == 'd2))
        finish_temp =   (i >= 'd20) && (status == 'd1);
    else
        finish_temp =   'd0;
end

always@(*)begin
    if(mode == 'd0)begin
        x_compute   =   (i > 'd0)?  ((d == 'sd1)? (x_temp - (y_temp >>> (i - 1))) : (d == -'sd1)? (x_temp + (y_temp >>> (i - 1))) : 'sd0) : 'sd0;
        y_compute   =   (i > 'd0)?  ((d == 'sd1)? (y_temp + (x_temp >>> (i - 1))) : (d == -'sd1)? (y_temp - (x_temp >>> (i - 1))) : 'sd0) : 'sd0;
        z_compute   =   (i > 'd0)?  ((d == 'sd1)? (z_temp - ang(i-1)) : (d == -'sd1)? (z_temp + ang(i-1)) : 'sd0) : 'sd0;
    end else if ((mode == 'd1) || (mode == 'd2))begin
        x_compute   =   x_in;
        y_compute   =   (i > 'd0)?  ((d == 'sd1)? (y_temp + (x_temp >>> i)) : (d == -'sd1)? (y_temp - (x_temp >>> i)) : 'sd0) : 'sd0;
        z_compute   =   (i > 'd0)?  ((d == 'sd1)? (z_temp - (15'sh2000 >>> i)) : (d == -'sd1)? (z_temp + (15'h2000 >>> i)) : 'sd0) : 'sd0;
    end else begin
        x_compute   =   'd0;
        y_compute   =   'd0;
        z_compute   =   'd0;
    end
end

always@(posedge clk or posedge rst)begin
    if(rst)begin
        status      <=  'd0;
    end else begin
        if(finish)
            status      <=  'd0;
        else if (start)
            status      <=  'd1;
    end
end

always@(posedge clk or posedge rst)begin
    if(rst)begin
        x_temp      <=  'sd0;
        y_temp      <=  'sd0;
        x_out       <=  'sd0;
        y_out       <=  'sd0;
        z_out       <=  'sd0;
        i           <=  'd0;
        d           <=  'sd1;
        finish      <=  'd0;
    end else begin
        finish      <=  'd0;
        if((start && (i == 'd0)) || (i > 'd0))begin
            i   <=  i   +   'd1;
        end

        if(i == 'd0)begin
            x_temp  <=  x_in;
            y_temp  <=  y_in;
            z_temp  <=  z_in;
            if(mode == 'd2)
                d   <=  (x_in[13] ^ y_in[13])? 'sd1 : -'sd1;
            else
                d   <=  (z_in > 'sd0)? 'sd1 : -'sd1;
        end else if(status)begin
            x_temp  <=  x_compute;
            y_temp  <=  y_compute;
            z_temp  <=  z_compute;
            if(mode == 'd2)
                d   <=  (x_compute[13] ^ y_compute[13])? 'sd1 : -'sd1;
            else
                d   <=  (z_compute > 'sd0)? 'sd1 : -'sd1;
        end

        if(finish_temp)begin
            finish  <=  'd1;
            x_out   <=  x_compute;
            y_out   <=  y_compute;
            z_out   <=  z_compute;
            i       <=  'd0;
        end
    end
end

function [13:0] ang;
input   [3:0]   i;
case(i)
    'd0:        ang = 'd4500;
    'd1:        ang = 'd2657;
    'd2:        ang = 'd1404;
    'd3:        ang = 'd713;
    'd4:        ang = 'd358;
    'd5:        ang = 'd179;
    'd6:        ang = 'd90;
    'd7:        ang = 'd45;
    'd8:        ang = 'd22;
    'd9:        ang = 'd11;
    'd10:       ang = 'd6;
    'd11:       ang = 'd3;
    'd12:       ang = 'd1;
    default:    ang = 'd0;
endcase
endfunction

endmodule
