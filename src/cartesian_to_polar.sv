/*
 * Copyright 2019 Brett Witherspoon
 */

module cartesian_to_polar #(
  parameter int WIDTH = 32,
  parameter int DEPTH = 16
)(
  input  logic               clk,
  input  logic               reset,

  input  logic               s_valid,
  output logic               s_ready = 1,
  input  logic [2*WIDTH-1:0] s_data,

  output logic               m_valid = 0,
  input  logic               m_ready,
  output logic [2*WIDTH-1:0] m_data
);
  typedef logic signed [WIDTH-1:0] data_t;
  typedef logic signed [WIDTH+1:0] wide_t;

  localparam MIN = wide_t'(-2 ** ($bits(data_t) - 1));
  localparam MAX = wide_t'(+2 ** ($bits(data_t) - 1) - 1);

  localparam PI_3_4 = data_t'(3) << WIDTH - 3;
  localparam PI_4 = data_t'(1) << WIDTH - 3;

  data_t lut [DEPTH];

  initial begin
    for (int n = 0; n < $size(lut); n++) begin
      lut[n] = data_t'($atan($pow(2, $itor(-(n + 1)))) * $pow(2, $bits(data_t) - 1) / 3.1415926);
    end
  end

  logic [DEPTH-1:0] en = '0;

  always_ff @(posedge clk) begin
    if (reset) begin
      m_valid <= 0;
      en <= '0;
    end else if (!m_valid || m_ready) begin
      {m_valid, en} <= {en[$bits(en)-1:0], s_valid};
    end
  end

  wide_t re [DEPTH + 1];
  wide_t im [DEPTH + 1];
  data_t ph [DEPTH + 1];

  // Work around for iverilog where constant selects not supported in always_*
  wire signed [WIDTH-1:0] i = s_data[WIDTH-1:0];
  wire signed [WIDTH-1:0] q = s_data[2*WIDTH-1-:WIDTH];

  always_ff @(posedge clk) begin
    if (s_valid && s_ready) begin
      unique case ({q[$bits(q) - 1], i[$bits(i) - 1]})
        2'b00: begin
          re[0] <= +wide_t'(q) + wide_t'(i);
          im[0] <= -wide_t'(i) + wide_t'(q);
          ph[0] <= +PI_4;
        end
        2'b01: begin
          re[0] <= +wide_t'(q) - wide_t'(i);
          im[0] <= -wide_t'(i) - wide_t'(q);
          ph[0] <= +PI_3_4;
        end
        2'b10: begin
          re[0] <= -wide_t'(q) + wide_t'(i);
          im[0] <= +wide_t'(i) + wide_t'(q);
          ph[0] <= -PI_4;
        end
        2'b11: begin
          re[0] <= -wide_t'(q) - wide_t'(i);
          im[0] <= +wide_t'(i) - wide_t'(q);
          ph[0] <= -PI_3_4;
        end
      endcase
    end
  end

  genvar n;
  for (n = 1; n < DEPTH + 1; n = n + 1) begin
    always_ff @(posedge clk) begin
      if (!m_valid || m_ready) begin
        if (im[n - 1][$bits(im[n - 1]) - 1]) begin
          re[n] <= re[n - 1] - (im[n - 1] >>> n);
          im[n] <= im[n - 1] + (re[n - 1] >>> n);
          ph[n] <= ph[n - 1] - lut[n - 1];
        end else begin
          re[n] <= re[n - 1] + (im[n - 1] >>> n);
          im[n] <= im[n - 1] - (re[n - 1] >>> n);
          ph[n] <= ph[n - 1] + lut[n - 1];
        end
      end
    end
  end

  assign m_data = {re[$size(re) - 1][WIDTH-1:0], ph[$size(ph) - 1]};

  always_comb s_ready = m_ready;

  assert property (@(posedge clk) re[$size(re) - 1] === 'x ||
                                  re[$size(re) - 1] <= MAX) else begin
    $error("Overflow: %0d > %0d", re[$size(re) - 1], MAX);
  end
  assert property (@(posedge clk) re[$size(re) - 1] === 'x ||
                                  re[$size(re) - 1] >= MIN) else begin
    $error("Underflow: %0d < %0d", re[$size(re) - 1], MIN);
  end

`ifdef FORMAL
  assume property (@(posedge clk) disable iff (reset)
    s_valid && !s_ready |=> s_valid && $stable(s_data));

  assert property (@(posedge clk) disable iff (reset)
    m_valid && !m_ready |=> m_valid && $stable(m_data));
`endif

endmodule
