`timescale 1ns/1ps

module tb_insertion_sort;

  localparam DATA_WIDTH = 4;
  localparam NUM_ELEM   = 4;
  localparam CLK_PERIOD = 10;

  reg clk;
  reg rst;

  reg  [DATA_WIDTH-1:0] din;
  reg                   valid_in;

  wire [NUM_ELEM*DATA_WIDTH-1:0] sorted_out;
  wire done;

  integer error_count;
  integer test_count;

  insertion_sort #(
                   .DATA_WIDTH(DATA_WIDTH),
                   .NUM_ELEM(NUM_ELEM)
                 ) dut (
                   .clk(clk),
                   .rst(rst),
                   .din(din),
                   .valid_in(valid_in),
                   .sorted_out(sorted_out),
                   .done(done)
                 );

  initial
  begin
    clk = 1'b0;
    forever
      #(CLK_PERIOD/2) clk = ~clk;
  end

  initial
  begin
    $dumpfile("tb_insertion_sort.vcd");
    $dumpvars(0, tb_insertion_sort);
  end

  task reset_dut;
    begin
      @(negedge clk);
      rst      = 1'b1;
      din      = {DATA_WIDTH{1'b0}};
      valid_in = 1'b0;

      repeat (2) @(negedge clk);

      rst = 1'b0;
      @(posedge clk);
      #1;
    end
  endtask

  task send_clean;
    input [DATA_WIDTH-1:0] value;
    begin
      @(negedge clk);
      din      = value;
      valid_in = 1'b1;

      @(posedge clk);
      #1;
    end
  endtask

  task send_with_data_glitch;
    input [DATA_WIDTH-1:0] value;
    input [DATA_WIDTH-1:0] noise1;
    input [DATA_WIDTH-1:0] noise2;
    begin
      @(negedge clk);

      valid_in = 1'b1;
      din      = value;

      #1 din = noise1;
      #1 din = {DATA_WIDTH{1'bx}};
      #1 din = noise2;
      #1 din = value;

      @(posedge clk);
      #1;
    end
  endtask

  task send_with_valid_glitch;
    input [DATA_WIDTH-1:0] value;
    begin
      @(negedge clk);

      din      = value;
      valid_in = 1'b1;

      #1 valid_in = 1'b0;
      #1 valid_in = 1'bx;
      #1 valid_in = 1'b0;
      #1 valid_in = 1'b1;

      @(posedge clk);
      #1;
    end
  endtask

  task idle_cycles;
    input integer n;
    integer k;
    begin
      for (k = 0; k < n; k = k + 1)
      begin
        @(negedge clk);

        valid_in = 1'b0;

        case (k % 4)
          0:
            din = 4'd15;
          1:
            din = 4'd0;
          2:
            din = {DATA_WIDTH{1'bx}};
          3:
            din = 4'd9;
        endcase

        @(posedge clk);
        #1;
      end
    end
  endtask

  task wait_done;
    input [255:0] case_name;
    integer k;
    reg found;
    begin
      found = 1'b0;

      for (k = 0; k < 30; k = k + 1)
      begin
        @(posedge clk);
        #1;

        if (done === 1'b1)
        begin
          found = 1'b1;
          k = 30;
        end
      end

      if (!found)
      begin
        $display("FAIL: %0s | done khong len 1", case_name);
        error_count = error_count + 1;
      end
    end
  endtask

  task check_result;
    input [1023:0] case_name;
    input [DATA_WIDTH-1:0] exp0;
    input [DATA_WIDTH-1:0] exp1;
    input [DATA_WIDTH-1:0] exp2;
    input [DATA_WIDTH-1:0] exp3;

    reg [DATA_WIDTH-1:0] out0;
    reg [DATA_WIDTH-1:0] out1;
    reg [DATA_WIDTH-1:0] out2;
    reg [DATA_WIDTH-1:0] out3;
    begin
      test_count = test_count + 1;

      out0 = sorted_out[0*DATA_WIDTH +: DATA_WIDTH];
      out1 = sorted_out[1*DATA_WIDTH +: DATA_WIDTH];
      out2 = sorted_out[2*DATA_WIDTH +: DATA_WIDTH];
      out3 = sorted_out[3*DATA_WIDTH +: DATA_WIDTH];

      if (done !== 1'b1)
      begin
        $display("FAIL: %0s | done = %b, expected done = 1", case_name, done);
        error_count = error_count + 1;
      end
      else if ((^sorted_out) === 1'bx)
      begin
        $display("FAIL: %0s | sorted_out co X/Z = %b", case_name, sorted_out);
        error_count = error_count + 1;
      end
      else if (out0 !== exp0 ||
               out1 !== exp1 ||
               out2 !== exp2 ||
               out3 !== exp3)
      begin

        $display("FAIL: %0s", case_name);
        $display("      result   = [%0d %0d %0d %0d]", out0, out1, out2, out3);
        $display("      expected = [%0d %0d %0d %0d]", exp0, exp1, exp2, exp3);

        error_count = error_count + 1;
      end
      else
      begin
        $display("PASS: %0s | result = [%0d %0d %0d %0d]",
                 case_name, out0, out1, out2, out3);
      end
    end
  endtask
  initial
  begin
    error_count = 0;
    test_count  = 0;

    rst      = 1'b0;
    din      = {DATA_WIDTH{1'b0}};
    valid_in = 1'b0;

    // CASE 1:
    // valid_in = 1, din bi nhieu giua chu ky clock
    reset_dut();

    send_with_data_glitch(4'd5, 4'd12, 4'd3);
    send_with_data_glitch(4'd2, 4'd15, 4'd7);
    send_with_data_glitch(4'd4, 4'd0,  4'd9);
    send_with_data_glitch(4'd1, 4'd8,  4'd6);

    @(negedge clk);
    valid_in = 1'b0;
    din      = {DATA_WIDTH{1'b0}};

    wait_done("CASE 1: valid=1, din bi nhieu giua chu ky");
    check_result("CASE 1: valid=1, din bi nhieu giua chu ky",
                 4'd1, 4'd2, 4'd4, 4'd5);


    // CASE 2:
    // valid_in bi nhieu giua chu ky clock nhung on dinh = 1 tai posedge
    reset_dut();

    send_with_valid_glitch(4'd9);
    send_with_valid_glitch(4'd3);
    send_with_valid_glitch(4'd7);
    send_with_valid_glitch(4'd1);

    @(negedge clk);
    valid_in = 1'b0;
    din      = {DATA_WIDTH{1'b0}};

    wait_done("CASE 2: valid_in bi nhieu giua chu ky");
    check_result("CASE 2: valid_in bi nhieu giua chu ky",
                 4'd1, 4'd3, 4'd7, 4'd9);


    // CASE 3:
    // Dang dich du lieu vao thi dung mot khoang, sau do dich tiep
    reset_dut();

    send_clean(4'd9);
    send_clean(4'd3);

    idle_cycles(4);

    send_clean(4'd7);
    send_clean(4'd1);

    @(negedge clk);
    valid_in = 1'b0;
    din      = {DATA_WIDTH{1'b0}};

    wait_done("CASE 3: dung giua chung roi dich tiep");
    check_result("CASE 3: dung giua chung roi dich tiep",
                 4'd1, 4'd3, 4'd7, 4'd9);


    // CASE 4:
    // Du lieu co cac so giong nhau
    reset_dut();

    send_clean(4'd4);
    send_clean(4'd4);
    send_clean(4'd2);
    send_clean(4'd2);

    @(negedge clk);
    valid_in = 1'b0;

    wait_done("CASE 4: co so giong nhau");
    check_result("CASE 4: co so giong nhau",
                 4'd2, 4'd2, 4'd4, 4'd4);


    // CASE 5:
    // Du lieu da sap xep san
    reset_dut();

    send_clean(4'd1);
    send_clean(4'd2);
    send_clean(4'd3);
    send_clean(4'd4);

    @(negedge clk);
    valid_in = 1'b0;

    wait_done("CASE 5: da sap xep san");
    check_result("CASE 5: da sap xep san",
                 4'd1, 4'd2, 4'd3, 4'd4);


    // CASE 6:
    // Du lieu dao nguoc
    reset_dut();

    send_clean(4'd15);
    send_clean(4'd8);
    send_clean(4'd7);
    send_clean(4'd0);

    @(negedge clk);
    valid_in = 1'b0;

    wait_done("CASE 6: dao nguoc");
    check_result("CASE 6: dao nguoc",
                 4'd0, 4'd7, 4'd8, 4'd15);


    // CASE 7:
    // Tat ca phan tu bang nhau
    reset_dut();

    send_clean(4'd6);
    send_clean(4'd6);
    send_clean(4'd6);
    send_clean(4'd6);

    @(negedge clk);
    valid_in = 1'b0;

    wait_done("CASE 7: tat ca bang nhau");
    check_result("CASE 7: tat ca bang nhau",
                 4'd6, 4'd6, 4'd6, 4'd6);


    // CASE 8:
    // Gia tri bien min/max
    reset_dut();

    send_clean(4'd0);
    send_clean(4'd15);
    send_clean(4'd15);
    send_clean(4'd0);

    @(negedge clk);
    valid_in = 1'b0;

    wait_done("CASE 8: min max duplicate");
    check_result("CASE 8: min max duplicate",
                 4'd0, 4'd0, 4'd15, 4'd15);


    // CASE 9:
    // Reset giua chung, sau reset chi tinh block moi
    reset_dut();

    send_clean(4'd8);
    send_clean(4'd1);

    reset_dut();

    send_clean(4'd3);
    send_clean(4'd0);
    send_clean(4'd15);
    send_clean(4'd2);

    @(negedge clk);
    valid_in = 1'b0;

    wait_done("CASE 9: reset giua chung");
    check_result("CASE 9: reset giua chung",
                 4'd0, 4'd2, 4'd3, 4'd15);


    $display("----------------------------------------");
    $display("TOTAL TESTS = %0d", test_count);
    $display("TOTAL ERRORS = %0d", error_count);
    $display("----------------------------------------");

    if (error_count == 0)
    begin
      $display("ALL TESTS PASSED");
    end
    else
    begin
      $display("SOME TESTS FAILED");
    end

    $finish;
  end

endmodule
