module DYN_SEC_CLOCK(CLK, CLR, SEG_DEC, COM);//*FREQ-CLK*
	input CLK, CLR;//*FREQ-CLK*
	output [6:0] SEG_DEC;
	output [7:0] COM;
	reg FREQ;//**
	reg [6:0] SEG_DEC;
	reg [3:0] SEC_01;
	reg [2:0] SEC_10;
	reg [7:0] COM;//**
	reg SEC_CLK;
	reg [15:0] CLK_COUNT;//**
	
always @(negedge CLK or posedge CLR) //25MHz->1kHz**
	if(CLR) FREQ<=0;
	else if (CLK_COUNT==25_000) begin CLK_COUNT<=0; FREQ<=1; end
	else begin CLK_COUNT <= CLK_COUNT+1; FREQ<=0; end//**
	
	SEPARATOR U0(CLR, FREQ, SEC_10, SEC_01);
	DYN_SEG_DEC U1(CLR, FREQ, SEC_10, SEC_01, SEG_DEC, COM);

endmodule

module SEPARATOR(CLR, FREQ, SEC_10, SEC_01);
	input CLR, FREQ;
	output [3:0] SEC_01;
	output [2:0] SEC_10;
	reg [8:0] COUNTS;
	reg [5:0] SEC;
	reg [3:0] SEC_01;
	reg [2:0] SEC_10;
	reg SEC_CLK,MIN_CLK;

always @(posedge FREQ or posedge CLR) begin // CLK
	if(CLR) begin COUNTS <= 0; SEC_CLK <= 1; end
	else if (COUNTS >= 499) begin COUNTS <= 0; SEC_CLK <= ~SEC_CLK; end
	else COUNTS <= COUNTS + 1; end

always @(posedge SEC_CLK or posedge CLR) begin // SEC_COUNT
	if(CLR) SEC <= 0;
	else if(SEC>=59) SEC <= 0;
	else SEC <= SEC + 1; end

always @(SEC) begin // SEPA_SEC
	if (SEC <= 9) begin SEC_10 <= 0; SEC_01 <= SEC; end
	else if (SEC <= 19) begin SEC_10 <= 1; SEC_01 <= SEC - 10; end
	else if (SEC <= 29) begin SEC_10 <= 2; SEC_01 <= SEC - 20; end
	else if (SEC <= 39) begin SEC_10 <= 3; SEC_01 <= SEC - 30; end
	else if (SEC <= 49) begin SEC_10 <= 4; SEC_01 <= SEC - 40; end
	else if (SEC <= 59) begin SEC_10 <= 5; SEC_01 <= SEC-50; end
	else begin SEC_10 <= 0; SEC_01 <= 0; end end
endmodule

module DYN_SEG_DEC(CLR,CLK, SEC_10, SEC_01, SEG_DEC, COM);
	input [3:0] SEC_10, SEC_01;
	input CLR,CLK;
	output [6:0] SEG_DEC;
	output [7:0] COM;
	reg [6:0] SEG_DEC;
	reg [3:0] DIGIT;
	reg [7:0]COM;

always @(posedge CLK or posedge CLR)
	begin
		if(CLR) begin COM<=0; SEG_DEC<=2; end
	else begin
		if(COM==8'b11111110) begin  COM<=8'b11111101;DIGIT <=SEC_01; end
		else begin COM<=8'b11111110;DIGIT<=SEC_10;  end
		case (DIGIT) // gfe_dcba
			0 : SEG_DEC <= 7'h3f; // 011_1111
			1 : SEG_DEC <= 7'h06; // 000_0110
			2 : SEG_DEC <= 7'h5b; // 101_1011
			3 : SEG_DEC <= 7'h4f; // 100_1111
			4 : SEG_DEC <= 7'h66; // 010_0110
			5 : SEG_DEC <= 7'h6d; // 110_1101
			6 : SEG_DEC <= 7'h7c; // 111_1100
			7 : SEG_DEC <= 7'h07; // 000_0111
			8 : SEG_DEC <= 7'h7f; // 111_1111
			9 : SEG_DEC <= 7'h67; // 110_0111
		endcase
		end
	end
endmodule