
`default_nettype none

module bitmap_rom (
    input wire [4:0] x,
    input wire [4:0] y,
    output wire pixel
  );

  reg [7:0] mem[79:0];
  initial
  begin
    mem[0] = 8'hff;
    mem[1] = 8'hff;
    mem[2] = 8'h0f;
    mem[3] = 8'h00;
    mem[4] = 8'h55;
    mem[5] = 8'hf5;
    mem[6] = 8'h0f;
    mem[7] = 8'h00;
    mem[8] = 8'h51;
    mem[9] = 8'hfb;
    mem[10] = 8'h0f;
    mem[11] = 8'h00;
    mem[12] = 8'h55;
    mem[13] = 8'hfb;
    mem[14] = 8'h0f;
    mem[15] = 8'h00;
    mem[16] = 8'hb5;
    mem[17] = 8'hfb;
    mem[18] = 8'h0f;
    mem[19] = 8'h00;
    mem[20] = 8'hff;
    mem[21] = 8'hff;
    mem[22] = 8'h0f;
    mem[23] = 8'h00;
    mem[24] = 8'h1b;
    mem[25] = 8'hc5;
    mem[26] = 8'h0e;
    mem[27] = 8'h00;
    mem[28] = 8'hb5;
    mem[29] = 8'h65;
    mem[30] = 8'h0d;
    mem[31] = 8'h00;
    mem[32] = 8'hb1;
    mem[33] = 8'h75;
    mem[34] = 8'h0d;
    mem[35] = 8'h00;
    mem[36] = 8'hb5;
    mem[37] = 8'hc5;
    mem[38] = 8'h0e;
    mem[39] = 8'h00;
    mem[40] = 8'hff;
    mem[41] = 8'hff;
    mem[42] = 8'h0f;
    mem[43] = 8'h00;
    mem[44] = 8'hff;
    mem[45] = 8'h07;
    mem[46] = 8'h0e;
    mem[47] = 8'h00;
    mem[48] = 8'hff;
    mem[49] = 8'h03;
    mem[50] = 8'h0c;
    mem[51] = 8'h00;
    mem[52] = 8'h83;
    mem[53] = 8'h21;
    mem[54] = 8'h08;
    mem[55] = 8'h00;
    mem[56] = 8'hbb;
    mem[57] = 8'h61;
    mem[58] = 8'h08;
    mem[59] = 8'h00;
    mem[60] = 8'hab;
    mem[61] = 8'he1;
    mem[62] = 8'h08;
    mem[63] = 8'h00;
    mem[64] = 8'hbb;
    mem[65] = 8'h61;
    mem[66] = 8'h08;
    mem[67] = 8'h00;
    mem[68] = 8'h83;
    mem[69] = 8'h21;
    mem[70] = 8'h08;
    mem[71] = 8'h00;
    mem[72] = 8'hff;
    mem[73] = 8'h03;
    mem[74] = 8'h0c;
    mem[75] = 8'h00;
    mem[76] = 8'hff;
    mem[77] = 8'h07;
    mem[78] = 8'h0e;
    mem[79] = 8'h00;
  end
  // Địa chỉ byte: y * 4 + (x / 8)
  wire [6:0] addr = {y[4:0], x[4:3]};
  // Trích xuất bit
  assign pixel = mem[addr][x[2:0]];

endmodule
