/*
 * Copyright 2019 Brett Witherspoon
 */

module rotate #(
  parameter int WIDTH = 16,
  parameter int STAGES = 16
)(
  input  logic               clk,
  input  logic               reset,

  input  logic               s_valid,
  output logic               s_ready = 1,
  input  logic [4*WIDTH-1:0] s_data,
  input  logic               s_last,

  output logic               m_valid,
  input  logic               m_ready,
  output logic [2*WIDTH-1:0] m_data,
  output logic               m_last
);
  typedef logic signed [WIDTH-1:0] amp_t;
  typedef logic signed [WIDTH+1:0] acc_t;
  typedef logic signed [2*WIDTH-1:0] arg_t;

  localparam MIN = acc_t'(-2 ** ($bits(amp_t) - 1));
  localparam MAX = acc_t'(+2 ** ($bits(amp_t) - 1) - 1);

  localparam PI = arg_t'(1) << (2 * WIDTH - 1);
  localparam PI_2 = PI >> 1;
  localparam PI_R = 3.1415926;

  arg_t phi [STAGES];

  initial begin
    for (int n = 0; n < $size(phi); n++) begin
      phi[n] = arg_t'($atan($pow(2, real'(-(n + 1)))) * $pow(2, $bits(arg_t) - 1) / PI_R);
    end
  end

  logic [STAGES:0] valid = '0;

  always_ff @(posedge clk) begin
    if (reset) begin
      valid <= '0;
    end else if (!m_valid || m_ready) begin
      valid <= {valid[$bits(valid)-2:0], s_valid};
    end
  end

  assign m_valid = valid[$bits(valid)-1];

  logic [STAGES:0] last = '0;

  always_ff @(posedge clk) begin
    if (!m_valid || m_ready) begin
      last <= {last[$bits(last)-2:0], s_last};
    end
  end

  assign m_last = last[$bits(last)-1];

  acc_t re [STAGES + 1];
  acc_t im [STAGES + 1];
  arg_t ph [STAGES + 1];

  wire signed [WIDTH-1:0] i = s_data[WIDTH-1:0];
  wire signed [WIDTH-1:0] q = s_data[2*WIDTH-1-:WIDTH];
  wire signed [2*WIDTH-1:0] p = s_data[4*WIDTH-1-:2*WIDTH];

  always_ff @(posedge clk) begin
    if (s_valid && s_ready) begin
      unique case (p[$bits(p)-1-:3])
        3'b001, 3'b010: begin
          re[0] <= -acc_t'(q);
          im[0] <= +acc_t'(i);
          ph[0] <= p - PI_2;
        end
        3'b011, 3'b100: begin
          re[0] <= -acc_t'(i);
          im[0] <= -acc_t'(q);
          ph[0] <= p - PI;
        end
        3'b101, 3'b110: begin
          re[0] <= +acc_t'(q);
          im[0] <= -acc_t'(i);
          ph[0] <= p + PI_2;
        end
        default: begin
          re[0] <= acc_t'(i);
          im[0] <= acc_t'(q);
          ph[0] <= p;
        end
      endcase
    end
  end

  genvar n;
  for (n = 1; n < STAGES + 1; n = n + 1) begin
    always_ff @(posedge clk) begin
      if (m_ready) begin
        if (ph[n - 1][$bits(ph[n - 1]) - 1]) begin
          re[n] <= re[n - 1] + (im[n - 1] >>> n);
          im[n] <= im[n - 1] - (re[n - 1] >>> n);
          ph[n] <= ph[n - 1] + phi[n - 1];
        end else begin
          re[n] <= re[n - 1] - (im[n - 1] >>> n);
          im[n] <= im[n - 1] + (re[n - 1] >>> n);
          ph[n] <= ph[n - 1] - phi[n - 1];
        end
      end
    end
  end

  assign m_data = {im[$size(im) - 1][WIDTH:1], re[$size(re) - 1][WIDTH:1]};

  always_comb s_ready = m_ready;

  assert property (@(posedge clk) re[$size(re) - 1] === 'x ||
                                  re[$size(re) - 1] <= MAX) else begin
    $error("Overflow: %0d > %0d", re[$size(re) - 1], MAX);
  end
  assert property (@(posedge clk) re[$size(re) - 1] === 'x ||
                                  re[$size(re) - 1] >= MIN) else begin
    $error("Underflow: %0d < %0d", re[$size(re) - 1], MIN);
  end

  assert property (@(posedge clk) im[$size(im) - 1] === 'x ||
                                  im[$size(im) - 1] <= MAX) else begin
    $error("Overflow: %0d > %0d", im[$size(im) - 1], MAX);
  end
  assert property (@(posedge clk) im[$size(im) - 1] === 'x ||
                                  im[$size(im) - 1] >= MIN) else begin
    $error("Underflow: %0d < %0d", im[$size(im) - 1], MIN);
  end

`ifdef FORMAL
  assume property (@(posedge clk) disable iff (reset)
    s_valid && !s_ready |=> s_valid && $stable(s_data));

  assert property (@(posedge clk) disable iff (reset)
    m_valid && !m_ready |=> m_valid && $stable(m_data));
`endif

endmodule
