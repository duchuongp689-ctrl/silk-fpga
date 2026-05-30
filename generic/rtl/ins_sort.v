module insertion_sort
  #(
     parameter DATA_WIDTH = 4,
     parameter NUM_ELEM   = 9
   )
   (
     input  wire clk,
     input  wire rst,

     input  wire [DATA_WIDTH-1:0] din,
     input  wire valid_in,

     output wire [NUM_ELEM*DATA_WIDTH-1:0] sorted_out,
     output wire done
   );

  // pipe_data_bus[0] là input từ ngoài
  // pipe_data_bus[i+1] là output từ PE thứ i
  wire [(NUM_ELEM+1)*DATA_WIDTH-1:0] pipe_data_bus;
  wire [NUM_ELEM:0]                  pipe_valid_bus;

  wire [NUM_ELEM*DATA_WIDTH-1:0]     hold_value_bus;
  wire [NUM_ELEM-1:0]                hold_valid_bus;

  assign pipe_data_bus[DATA_WIDTH-1 : 0] = din;
  assign pipe_valid_bus[0] = valid_in;

  assign sorted_out = hold_value_bus;

  // done = 1 khi tất cả PE đã giữ dữ liệu hợp lệ
  assign done = &hold_valid_bus;

  genvar i;

  generate
    for (i = 0; i < NUM_ELEM; i = i + 1)
    begin : GEN_PE

      ins_sort_pe #(
                    .DATA_WIDTH(DATA_WIDTH)
                  ) pe_inst (
                    .clk        (clk),
                    .rst        (rst),

                    .din        (pipe_data_bus[(i+1)*DATA_WIDTH-1 : i*DATA_WIDTH]),
                    .valid_in   (pipe_valid_bus[i]),

                    .dout       (pipe_data_bus[(i+2)*DATA_WIDTH-1 : (i+1)*DATA_WIDTH]),
                    .valid_out  (pipe_valid_bus[i+1]),

                    .hold_value (hold_value_bus[(i+1)*DATA_WIDTH-1 : i*DATA_WIDTH]),
                    .hold_valid (hold_valid_bus[i])
                  );

    end
  endgenerate

endmodule


// PE for insertion sort
module ins_sort_pe
  #(
     parameter DATA_WIDTH = 4
   )
   (
     input  wire                  clk,
     input  wire                  rst,

     input  wire [DATA_WIDTH-1:0] din,
     input  wire                  valid_in,

     output wire [DATA_WIDTH-1:0] dout,
     output wire                  valid_out,

     output wire [DATA_WIDTH-1:0] hold_value,
     output wire                  hold_valid
   );

  reg [DATA_WIDTH-1:0] d_reg;
  reg                  valid_reg;

  wire full;
  wire swap;

  assign full = valid_reg;

  // Nếu PE đã có dữ liệu và có input mới thì PE sẽ đẩy một giá trị ra sau
  assign valid_out = valid_in & full;

  // swap = 1 khi input mới nhỏ hơn giá trị đang giữ
  assign swap = valid_in & full & (din < d_reg);

  // Nếu swap: đẩy giá trị cũ ra sau
  // Nếu không swap: đẩy din ra sau
  // dout chỉ có ý nghĩa khi valid_out = 1
  assign dout = swap ? d_reg : din;

  assign hold_value = d_reg;
  assign hold_valid = valid_reg;

  always @(posedge clk)
  begin
    if (rst)
    begin
      d_reg     <= {DATA_WIDTH{1'b0}};
      valid_reg <= 1'b0;
    end
    else
    begin
      if (valid_in)
      begin
        if (!valid_reg)
        begin
          d_reg     <= din;
          valid_reg <= 1'b1;
        end
        else if (swap)
        begin
          d_reg <= din;
        end
      end
    end
  end

endmodule
