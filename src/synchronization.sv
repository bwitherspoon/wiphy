/*
 * Copyright 2019-2020 Brett Witherspoon
 */

module synchronization (
  input  logic        clk,
  input  logic        reset,

  input  logic        adc_valid,
  input  logic [31:0] adc_data,

  output logic        m_valid,
  input  logic        m_ready,
  output logic [31:0] m_data,
  output logic [31:0] m_user,
  output logic        m_last = 0
);
  function logic [31:0] conj(input logic [31:0] z);
    return {-$signed(z[31:16]), z[15:0]};
  endfunction

  logic sample_valid;
  logic [2:0] sample_ready;
  logic [31:0] sample_data;

  assign sample_valid = adc_valid & &sample_ready;
  assign sample_data = adc_data;

  assert property (@(posedge clk) sample_valid || !adc_valid);

  logic sample_mem_valid;
  logic sample_mem_ready;
  logic [31:0] sample_mem_data;

  // Memories to account for latency and backpressure
  shift_register_memory #(.WIDTH(32), .DEPTH(32)) sample_mem (
    .clk,
    .reset,
    .s_valid(sample_valid),
    .s_ready(sample_ready[2]),
    .s_data(sample_data),
    .m_valid(sample_mem_valid),
    .m_ready(sample_mem_ready),
    .m_data(sample_mem_data)
  );

  logic energy_mem_valid;
  logic energy_mem_ready;
  logic [31:0] energy_mem_data;

  shift_register_memory #(.WIDTH(32), .DEPTH(32)) energy_mem (
    .clk,
    .reset,
    .s_valid(sample_valid),
    .s_ready(sample_ready[1]),
    .s_data(sample_data),
    .m_valid(energy_mem_valid),
    .m_ready(energy_mem_ready),
    .m_data(energy_mem_data)
  );

  logic energy_valid;
  logic energy_ready;
  logic [31:0] energy_data;

  window_energy #(.WIDTH(16), .LENGTH(16)) win_energy (
    .clk,
    .reset,
    .s_valid(energy_mem_valid),
    .s_ready(energy_mem_ready),
    .s_data(energy_mem_data),
    .m_valid(energy_valid),
    .m_ready(energy_ready),
    .m_data(energy_data)
  );

  logic autocorr_valid;
  logic autocorr_ready;
  logic [63:0] autocorr_data;

  autocorrelation #(.WIDTH(16), .DELAY(16), .LENGTH(16)) autocorr (
    .clk,
    .reset,
    .s_valid(sample_valid),
    .s_ready(sample_ready[0]),
    .s_data(sample_data),
    .m_valid(autocorr_valid),
    .m_ready(autocorr_ready),
    .m_data(autocorr_data)
  );

  logic polar_valid;
  logic polar_ready;
  logic [63:0] polar_data;

  cartesian_to_polar #(.WIDTH(32), .DEPTH(16)) rect_to_polar (
    .clk,
    .reset,
    .s_valid(autocorr_valid),
    .s_ready(autocorr_ready),
    .s_data(autocorr_data),
    .m_valid(polar_valid),
    .m_ready(polar_ready),
    .m_data(polar_data)
  );

  logic inphase_valid;
  logic inphase_ready;
  logic [31:0] inphase_data;

  logic phase_valid;
  logic phase_ready;
  logic [31:0] phase_data;

  broadcast #(.WIDTH(64), .COUNT(2)) mag_phase_bcast (
    .clk,
    .reset,
    .s_valid(polar_valid),
    .s_ready(polar_ready),
    .s_data(polar_data),
    .m_valid({inphase_valid, phase_valid}),
    .m_ready({inphase_ready, phase_ready}),
    .m_data({inphase_data, phase_data})
  );

  logic magnitude_valid;
  logic magnitude_ready;
  logic [31:0] magnitude_data;

  shift_register_memory #(.WIDTH(32), .DEPTH(16)) mag_shift (
    .clk,
    .reset,
    .s_valid(inphase_valid),
    .s_ready(inphase_ready),
    .s_data(inphase_data),
    .m_valid(magnitude_valid),
    .m_ready(magnitude_ready),
    .m_data(magnitude_data)
  );

  logic frequency_valid;
  logic frequency_ready;
  logic [31:0] frequency_data;

  shift_register_memory #(.WIDTH(32), .DEPTH(48), .DELAY(32)) phase_delay (
    .clk,
    .reset,
    .s_valid(phase_valid),
    .s_ready(phase_ready),
    .s_data(phase_data),
    .m_valid(frequency_valid),
    .m_ready(frequency_ready),
    .m_data(frequency_data)
  );

  logic combined_valid;
  logic [127:0] combined_data;

  // Combine and align signals
  combine #(.WIDTH(32), .COUNT(4)) signal_combo (
    .clk,
    .reset,
    .s_valid({energy_valid, magnitude_valid, frequency_valid, sample_mem_valid}),
    .s_ready({energy_ready, magnitude_ready, frequency_ready, sample_mem_ready}),
    .s_data({energy_data, magnitude_data, frequency_data, sample_mem_data}),
    .m_valid(combined_valid),
    .m_ready,
    .m_data(combined_data)
  );

  wire signed [31:0] energy = $signed(combined_data[127-:32]);

  logic signals_valid;
  logic [95:0] signals;

  logic baseband_valid;

  logic trigger;
  logic signed [31:0] threshold;
  logic signed [15:0] inphase;
  logic signed [15:0] quadrature;
  logic signed [31:0] magnitude;
  logic signed [31:0] frequency;

  always_ff @ (posedge clk) begin
    if (!m_valid || m_ready) begin
      signals_valid <= combined_valid;
      baseband_valid <= signals_valid;
      signals <= combined_data[95:0];
      // Trigger threshold of 75% of signal energy within window
      threshold <= (energy >>> 1) + (energy >>> 2);
      inphase <= $signed(signals[15:0]);
      quadrature <= $signed(signals[31:16]);
      magnitude <= $signed(signals[95-:32]);
      // Divide by sixteen to get average estimated frequency offset
      frequency <= $signed(signals[63-:32]) >>> 4;
      trigger <= magnitude > threshold;
    end
  end

  logic [4:0] counter = '0;

  logic previous = 0;

  logic detected = 0;

  wire bounce = previous ^ trigger;

  wire falling = detected & ~trigger;

  wire timeout = counter == 5'd28;

  always_ff @(posedge clk) begin
    if (reset) begin
      counter <= '0;
      previous <= 0;
      detected <= 0;
    end else if (m_valid && m_ready) begin
      previous <= trigger;
      if (bounce) begin
        counter <= '0;
      end else if (timeout) begin
        counter <= '0;
        detected <= trigger;
      end else begin
        counter <= counter + 5'd1;
      end
    end
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      m_last <= 0;
    end else if (m_valid && m_ready) begin
      m_last <= !bounce && timeout ? falling : 0;
    end
  end

  assign m_valid = baseband_valid;

  assign m_user = frequency;

  assign m_data = {quadrature, inphase};

endmodule
