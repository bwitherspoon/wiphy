/*
 * Copyright 2019-2020 Brett Witherspoon
 */

module control (
    input  logic        s_axi_aclk,
    input  logic        s_axi_aresetn,

    input  logic        s_axi_awvalid,
    input  logic [15:0] s_axi_awaddr,
    input  logic [ 2:0] s_axi_awprot,
    output logic        s_axi_awready = 1,

    input  logic        s_axi_wvalid,
    input  logic [31:0] s_axi_wdata,
    input  logic [ 3:0] s_axi_wstrb,
    output logic        s_axi_wready = 1,

    output logic        s_axi_bvalid = 0,
    output logic [ 1:0] s_axi_bresp,
    input  logic        s_axi_bready,

    input  logic        s_axi_arvalid,
    input  logic [15:0] s_axi_araddr,
    input  logic [ 2:0] s_axi_arprot,
    output logic        s_axi_arready = 1,

    output logic        s_axi_rvalid = 0,
    output logic [31:0] s_axi_rdata,
    output logic [ 1:0] s_axi_rresp,
    input  logic        s_axi_rready
);
    localparam OKAY = 2'd0;
    localparam DEPTH = 16;

    typedef logic [$clog2(DEPTH)-1:0] addr_t;
    typedef logic [31:0] data_t;
    typedef logic [3:0] strb_t;

    wire read_addr_valid = s_axi_arvalid | ~s_axi_arready;
    wire read_data_stall = s_axi_rvalid & ~s_axi_rready;

    wire write_addr_valid = s_axi_awvalid | ~s_axi_awready;
    wire write_data_valid = s_axi_wvalid | ~s_axi_wready;
    wire write_resp_stall = s_axi_bvalid & ~s_axi_bready;

    addr_t raddr;
    addr_t waddr;

    addr_t raddr_buf;
    addr_t waddr_buf;

    data_t wdata;
    strb_t wstrb;

    data_t wdata_buf;
    strb_t wstrb_buf;

    data_t data [DEPTH];

    assign s_axi_bresp = OKAY;
    assign s_axi_rresp = OKAY;

    always_ff @ (posedge s_axi_aclk) begin
        if (!s_axi_aresetn) begin
            s_axi_rvalid <= 0;
        end else if (read_data_stall || read_addr_valid) begin
            s_axi_rvalid <= 1;
        end else begin
            s_axi_rvalid <= 0;
        end
    end

    always_ff @ (posedge s_axi_aclk) begin
        if (s_axi_arready) begin
            raddr_buf <= addr_t'(s_axi_araddr);
        end
    end

    always_comb begin
        if (s_axi_arready) begin
            raddr = addr_t'(s_axi_araddr);
        end else begin
            raddr = raddr_buf;
        end
    end

    always_ff @ (posedge s_axi_aclk) begin
        if (!read_data_stall) begin
            s_axi_rdata <= data[raddr];
        end
    end

    always_ff @ (posedge s_axi_aclk) begin
        if (!s_axi_aresetn) begin
            s_axi_arready <= 1;
        end else if (read_data_stall) begin
            s_axi_arready <= ~read_addr_valid;
        end else begin
            s_axi_arready <= 1;
        end
    end

    always_ff @ (posedge s_axi_aclk) begin
        if (!s_axi_aresetn) begin
            s_axi_awready <= 1;
        end else if (write_resp_stall) begin
            s_axi_awready <= ~write_addr_valid;
        end else if (write_data_valid) begin
            s_axi_awready <= 1;
        end else begin
            s_axi_awready <= ~write_addr_valid;
        end
    end

    always_ff @ (posedge s_axi_aclk) begin
        if (!s_axi_aresetn) begin
            s_axi_wready <= 1;
        end else if (write_resp_stall) begin
            s_axi_wready <= ~write_data_valid;
        end else if (write_addr_valid) begin
            s_axi_wready <= 1;
        end else begin
            s_axi_wready <= ~write_data_valid;
        end
    end

    always_ff @ (posedge s_axi_aclk) begin
        if (s_axi_awready) begin
            waddr_buf <= addr_t'(s_axi_awaddr);
        end
    end

    always_comb begin
        if (s_axi_awready) begin
            waddr = addr_t'(s_axi_awaddr);
        end else begin
            waddr = waddr_buf;
        end
    end

    always_ff @ (posedge s_axi_aclk) begin
        if (s_axi_wready) begin
            wdata_buf <= s_axi_wdata;
            wstrb_buf <= s_axi_wstrb;
        end
    end

    always_comb begin
        if (s_axi_wready) begin
            wdata = s_axi_wdata;
            wstrb = s_axi_wstrb;
        end begin
            wdata = wdata_buf;
            wstrb = wstrb_buf;
        end
    end

    // FIXME $bits(wstrb) does not work correctly with iverilog in generate loop
    genvar i;
    for (i = 0; i < 4; i = i + 1) begin
        always_ff @ (posedge s_axi_aclk) begin
            if (!write_resp_stall && write_data_valid && write_addr_valid) begin
                if (wstrb[i]) begin
                    data[waddr][8*i+:8] <= wdata[8*i+:8];
                end
            end
        end
    end

    always_ff @ (posedge s_axi_aclk) begin
        if (!s_axi_aresetn) begin
            s_axi_bvalid <= 0;
        end else if (write_data_valid && write_addr_valid) begin
            s_axi_bvalid <= 1;
        end else if (s_axi_bready) begin
            s_axi_bvalid <= 0;
        end
    end

    wire unused = &{1'b0,
                    s_axi_awaddr[$bits(s_axi_awaddr)-1:8],
                    s_axi_awprot,
                    s_axi_araddr[$bits(s_axi_araddr)-1:8],
                    s_axi_arprot,
                    1'b0};

endmodule
