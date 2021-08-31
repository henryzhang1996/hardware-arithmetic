module square
(
input               clk,
input               rst,
input   [2:0]       mode,
input   [15:0]      data_in,
input               start,
output  reg [7:0]   sqr_root,
output  reg [8:0]   remainder,
output  reg         finish
);

reg  [1:0]          data_field [7:0];
reg  [15:0]         paper_temp_q;
reg  [15:0]         paper_temp_result;
reg  [3:0]          paper_compute_cnt;
reg                 paper_status;
wire [5:0]          finish_status;
wire [4:0]          first_one_field;

/* find first field */
assign first_one_field = find_first_one_field(data_in);

/* finish */
assign finish_status = (first_one_field == 'b11111)? 'd1 : (first_one_field + 1); 

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
        paper_compute_cnt   <=  'd0;
        paper_status        <=  'd0;
        finish              <=  'd0;
        sqr_root            <=  'd0;
        remainder           <=  'd0;
    end else begin
        if(paper_compute_cnt == finish_status)begin
            paper_status        <=  'd0;
            paper_compute_cnt   <=  'd0;
            sqr_root            <=  paper_temp_result;
            remainder           <=  paper_temp_q;
        end else if (start)begin
            paper_status        <=  'd1;
            paper_compute_cnt   <=  'd0;
        end else if(paper_status == 'd1)begin
            paper_compute_cnt   <=  paper_compute_cnt + 'd1;
        end

        if(paper_compute_cnt == finish_status)begin
            finish              <=  'd1;
        end else begin
            finish              <=  'd0;
        end

    end
end

always @(posedge clk or posedge rst) begin
    if(rst)begin
        paper_temp_q        <=  'd0;
        paper_temp_result   <=  'd0;
    end else begin
        if(mode == 'd0)begin
            if(paper_status == 'd1)begin
                if(first_one_field == 'b11111)begin
                    paper_temp_q        <=  'd0;
                    paper_temp_result   <=  'd0;
                end else begin
                    if(paper_compute_cnt == 'd0)begin
                        if(data_field[first_one_field] > 'd0)begin
                            paper_temp_result                   <=  'b1;
                            if(first_one_field > 'd0)
                                paper_temp_q                    <=  {(data_field[first_one_field]-'h01),data_field[first_one_field - 1]};
                            else
                                paper_temp_q                    <=  (data_field[first_one_field]-'h01);
                        end else begin
                            paper_temp_result                   <=  'b0;
                            if(first_one_field > 'd0)
                                paper_temp_q                    <=  {data_field[first_one_field - 1]};
                        end
                    end else begin
                        if(paper_temp_q >= {paper_temp_result,2'b01})begin
                            paper_temp_result                   <=  {paper_temp_result,1'b1};
                            if(paper_compute_cnt == first_one_field)
                                paper_temp_q                        <=  (paper_temp_q - {paper_temp_result,2'b01});
                            else if(paper_compute_cnt < first_one_field)
                                paper_temp_q                        <=  {(paper_temp_q - {paper_temp_result,2'b01}),data_field[first_one_field - paper_compute_cnt - 'd1]};
                        end else begin
                            paper_temp_result                   <=  {paper_temp_result,1'b0};
                            if(paper_compute_cnt < first_one_field)
                                paper_temp_q                        <=  {paper_temp_q,data_field[first_one_field - paper_compute_cnt - 'd1]};
                        end
                    end
                end
            end else begin
                paper_temp_q        <=  'd0;
                paper_temp_result   <=  'd0;
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
