/*
mode0 : pencil and paper algorithm  data_in/sqr_root/remainder reflect read data
mode1 : restoring shift/subtract algorithm   
        now correct to 7 decimal places(binary)
        data_in[15:14] reflect integer part,data_in[13:0] reflect decimal part
        sqr_root[15] = 1 ,sqr_root[14:0] reflects decimal part
        reminder[15:14] reflect integer part,data_in[13:0] reflect decimal part
*/

module square
(
input               clk,
input               rst,
input   [2:0]       mode,
input   [15:0]      data_in,
input               start,
output  reg [15:0]   sqr_root,
output  reg [15:0]   remainder,
output  reg         finish
);

reg  [1:0]          data_field [7:0];
reg  [16:0]         temp_q; //mode0 : ,mode1: temp s
reg  [15:0]         temp_result; // mode0: ,mode1: temp q
reg  [3:0]          compute_cnt;
reg                 status;
reg  [5:0]          finish_status;
wire [4:0]          first_one_field;

/* find first field */
assign first_one_field = find_first_one_field(data_in);

/* finish */
always@(*)begin
case(mode)
    'd0:        finish_status   = (first_one_field == 'b11111)? 'd1 : (first_one_field + 1); 
    'd1:        finish_status   = 'd7; //tentative   
    default:    finish_status   = 'd0;
endcase
end
/* field corresponding */
generate
    genvar i;
    for (i=0; i<8; i=i+1) begin
        always@(*)begin
            data_field[i] = data_in[(2*i)+:2];
        end
    end
endgenerate

always @(posedge clk or posedge rst) begin
    if(rst)begin
        compute_cnt   <=  'd0;
        status        <=  'd0;
        finish        <=  'd0;
        sqr_root      <=  'd0;
        remainder     <=  'd0;
    end else begin
        if(compute_cnt == finish_status)begin
            status        <=  'd0;
            compute_cnt   <=  'd0;
            sqr_root      <=  temp_result;
            if(mode == 'd1)
                remainder   <=  {6'b0,temp_q[15:6]};
            else
                remainder   <=  temp_q[15:0];
        end else if (start)begin
            status        <=  'd1;
            compute_cnt   <=  'd0;
        end else if(status == 'd1)begin
            compute_cnt   <=  compute_cnt + 'd1;
        end

        if(compute_cnt == finish_status)begin
            finish        <=  'd1;
        end else begin
            finish        <=  'd0;
        end

    end
end

/* compute process */
always @(posedge clk or posedge rst) begin
    if(rst)begin
        temp_q        <=  'd0;
        temp_result   <=  'd0;
    end else begin
        if(mode == 'd0)begin
            if(status == 'd1)begin
                if(first_one_field == 'b11111)begin
                    temp_q        <=  'd0;
                    temp_result   <=  'd0;
                end else begin
                    if(compute_cnt == 'd0)begin
                        if(data_field[first_one_field] > 'd0)begin
                            temp_result                   <=  'b1;
                            if(first_one_field > 'd0)
                                temp_q                    <=  {(data_field[first_one_field]-'h01),data_field[first_one_field - 1]};
                            else
                                temp_q                    <=  (data_field[first_one_field]-'h01);
                        end else begin
                            temp_result                   <=  'b0;
                            if(first_one_field > 'd0)
                                temp_q                    <=  {data_field[first_one_field - 1]};
                        end
                    end else begin
                        if(temp_q >= {temp_result,2'b01})begin
                            temp_result                   <=  {temp_result,1'b1};
                            if(compute_cnt == first_one_field)
                                temp_q                        <=  (temp_q - {temp_result,2'b01});
                            else if(compute_cnt < first_one_field)
                                temp_q                        <=  {(temp_q - {temp_result,2'b01}),data_field[first_one_field - compute_cnt - 'd1]};
                        end else begin
                            temp_result                   <=  {temp_result,1'b0};
                            if(compute_cnt < first_one_field)
                                temp_q                        <=  {temp_q,data_field[first_one_field - compute_cnt - 'd1]};
                        end
                    end
                end
            end else begin
                temp_q        <=  'd0;
                temp_result   <=  'd0;
            end
        end else if(mode == 'd1)begin
            if(status == 'd1)begin
                temp_result[15] <= 1'b1; //q[15] stable 1
                if(compute_cnt == 'd0)begin
                    temp_q  <=  data_in - {1'b1,14'b0};
                end else begin
                    if({temp_q[15:0],1'b0} >= (temp_result + (1 << (14 - compute_cnt))))begin
                        temp_result <=  temp_result + (1 << (15 - compute_cnt));
                        temp_q      <=  {temp_q[15:0],1'b0} - (temp_result + (1 << (14 - compute_cnt)));
                    end else begin
                        temp_q      <=  {temp_q[15:0],1'b0}; //restore
                    end
                end
            end else begin
                temp_q        <=  'd0;
                temp_result   <=  'd0;
            end
        end
    end
end

function  [4:0] find_first_one_field;
input   [15:0]  data_in;
integer i;
begin:LOOP
    for(i=15;i>=0;i=i-1)begin
        if(data_in[i] == 1)begin
            find_first_one_field = i >> 1;
            disable LOOP;
        end else if(i == 'd0)begin
            find_first_one_field = 'b11111;
        end
    end
end
endfunction

endmodule
