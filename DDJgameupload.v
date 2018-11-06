module	DDJgame(freq, RESET, segc, segd, led, key_col, key_row, key_data, GO, test);
//segc-segcom//segd-segdata//
	input	freq, RESET;
	input	[2:0] key_row;
	output	[7:0] segc, led;
	output	[6:0] segd;
	output	[2:0] key_col;
	output	GO;
	output	[5:0] key_data;
	reg	[11:0] DD;//Ddj Data
	reg	[7:0] segc, led;
	reg	[6:0] segd;
	reg	[2:0] key_col;
	reg	CLK1, CLK2;
	reg [14:0] count1_clk;
	reg [8:0] count2_clk;
	reg	[2:0] count_segc;
	reg	[5:0] key_data;
	reg	[6:0] point;
	reg	GO;//for Game Over
	output test;//
	reg	test;//
	
always @(negedge freq or posedge RESET)//CLK1 - 1KHz
	if(RESET) CLK1<=0;
	else if (count1_clk==24_999) begin count1_clk<=0; CLK1<=1; end
	else begin count1_clk <= count1_clk+1; CLK1<=0; end

always @(negedge CLK1 or posedge RESET)//CLK2 - 2Hz
	if(RESET) CLK2<=0;
	else if (count2_clk==499) begin count2_clk<=0; CLK2<=1; end
	else begin count2_clk <= count2_clk+1; CLK2<=0; end
	
	LedClock	L1(CLK2, RESET, led, GO);
	DDJData		Ddj1(CLK1, CLK2, RESET, DD);
//	DispCompare	Dc1(CLK1, RESET, DD, segc, segd);
	keypad_scan	SCAN(CLK1, RESET, key_col, key_row, key_data);
	DDJ_point	DP(CLK1, RESET, key_data, DD, point, test);
	RDisp		RD1 (CLK1, RESET, DD, point, segc, segd);//ddj
//	DYN_SCORE	DS(CLK1, RESET, point, segd2, segc[1:0]);//score

endmodule

//LED CLOCK/////////////////////////////////////////////////////////////////////////

module LedClock(freq, RESET, led, GO);
	input	freq, RESET;
	output	[7:0]led;
	output	GO;
	reg	[7:0]led;
	reg	GO;
	reg [3:0]count;
	
always @(negedge freq or posedge RESET)//7.5s count
	if(RESET) begin led<=8'b11111111; GO<=0; count<=0; end
	else if (count==14) begin count<=0; led<=(led>>1); end
	else if (led==0) GO<=1;
	else count <= count+1;
	
endmodule

//DDJ DATA/////////////////////////////////////////////////////////////////////////

module	DDJData(freq1, freq2, RESET, DD);
	input	freq1, freq2, RESET;
	output	[11:0] DD;
	wire	feedback = random[11]^random[5]^random[3]^random[0];
	reg [11:0] DD;
	reg	[11:0] random;
	
always @ (negedge freq1 or posedge RESET)
	begin 
		if (RESET) random <= 12'hFFF;
		else random = {random[10:0],feedback};
	end

always @ (negedge freq2 or posedge RESET)
	begin
		if (RESET) DD<=12'h0;
		else DD<=random;
	end
	
endmodule

//DispCompare/////////////////////////////////////////////////////////////////////////
module	DispCompare(freq, RESET, DD, segc, segd);
	input	freq, RESET;
	input	[11:0]DD;
	output	[7:0] segc;
	output	[6:0] segd;
	reg [7:0] segc;
	reg	[6:0] segd;
	reg	[3:0] DIGIT;
	
always @(posedge freq or posedge RESET)
	begin
	if(RESET) begin segc<=0; segd<=0; end
	else begin
		//...
	end
endmodule
//******************************************************************************
//RDisp/////////////////////////////////////////////////////////////////////////
module	RDisp(freq, RESET, DD, point, segc, segd);
	input	freq, RESET;
	input	[11:0]DD;
	input	[6:0] point;
	output	[7:0] segc;
	output	[6:0] segd;
	reg 	[7:0] segc;
	reg		[6:0] segd;
	reg		[1:0] DDJ;
	reg		[3:0] DIGIT;
	reg 	[3:0] point_01;   
	reg 	[3:0] point_10;
	reg	switch;
	
SEPARATOR		U0(point, point_10, point_01);
	
always @(posedge freq or posedge RESET)
	begin
	if(RESET)	begin	segc<=8'b11111110;	segd<=0; switch<=0; end
	else begin
		//...
	end
endmodule
///////////////////////////////////////////////////////////////////////
module keypad_scan(freq, RESET, key_col, key_row, key_data);
	input 	freq, RESET;
	input	[1:0] 	key_row;
	output	[2:0]	key_col;
	output	[5:0]	key_data;
	reg	[5:0]	key_data;
	reg	[2:0]	state;
	reg 	[3:0]  counts;
	reg 	key_clk;
	wire	key_stop;
	// define state of FSM
	parameter no_scan = 3'b000;
	parameter column0 = 3'b001;
	parameter column1 = 3'b010;
	parameter column2 = 3'b100; 
	
	assign key_stop = key_row[0] | key_row[1] ;
	assign key_col = state;
	

	// 10분주해서 더 안정적이게
	always @(posedge freq or posedge RESET)  
	begin
	  	if(RESET) key_clk <= 0;
		else if (counts==9) begin counts <= 0; key_clk <= 1; end
		else begin counts <= counts +1; key_clk <= 0; end
	end
	// FSM drive
	always @(posedge key_clk or posedge RESET)
	begin
		if (RESET) state <= no_scan;
		else begin
		  if (!key_stop) begin
		    case (state)
		    no_scan : state <= column0;
		    column0 : state <= column1;
		    column1 : state <= column2;
		    column2 : state <= column0;
		    default : state <= no_scan;
		    endcase
		  end
		end
	end
// key_data
	always @ (posedge key_clk) 
	begin
	case (state)
	  column0 : case (key_row)
	  	2'b01 : key_data <= 6'b000001; // key_1
	  	2'b10 : key_data <= 6'b001000; // key_4 
	  	default : key_data  <= 6'b000000;
	  	endcase
	 
	 column1 : case (key_row)
	  	2'b01 : key_data <= 6'b000010; // key_2
	  	2'b10 : key_data <= 6'b010000; // key_5 
	  	
	  	default : key_data  <= 6'b000000;
	  	endcase
	
	  column2 : case (key_row)
	  	2'b01 : key_data <= 6'b000100; // key_3
	  	2'b10 : key_data <= 6'b100000; // key_6 
	  	default : key_data <= 6'b000000;
	  	endcase	  	
	default : key_data <= 6'b000000;
	endcase
	end
endmodule 

////----------------------------------------------------------------------
module	DDJ_point(freq, RESET, key_data, DD, point, test);
	input	[11:0]DD;
	input	freq, RESET;
	input	[5:0]key_data;
	output	[6:0] point;
	reg	[5:0] plus, minus; 
	reg	[6:0] point;
	output test;//
	reg	test;//
	
	DDJ_comp	C1(CLK1, RESET, key_data[0], DD[11:10], plus[0], minus[0], test);
	DDJ_comp	C2(CLK1, RESET, key_data[1], DD[9:8], plus[1], minus[1]);
	DDJ_comp	C3(CLK1, RESET, key_data[2], DD[7:6], plus[2], minus[2]);
	DDJ_comp	C4(CLK1, RESET, key_data[3], DD[5:4], plus[3], minus[3]);
	DDJ_comp	C5(CLK1, RESET, key_data[4], DD[3:2], plus[4], minus[4]);
	DDJ_comp	C6(CLK1, RESET, key_data[5], DD[1:0], plus[5], minus[5]);
	
always @ (plus or minus or RESET)
begin
if(RESET) point<=0;
begin
	if(plus) point<=point+(|plus);
	else if(minus)
	begin
		if(point !=0) point<=point-(|minus);
	end
end
end
endmodule
////===================================================================
module	DDJ_comp(freq, RESET, key_data, DDJ, plus, minus, test);

	input	freq, RESET;
	input	key_data;
	input	[1:0] DDJ;
	output	plus, minus;
	reg	plus, minus; 
	output test;//
	reg	test;//

always @(negedge freq or posedge RESET)
	if(RESET) begin plus<=0; minus<=0; test<=0; end
	else if({DDJ,key_data}==3'b011)
	begin 
		test<=1;//
		if(DDJ == 1) begin plus<=1; minus<=0; end
		else if(DDJ == 2) begin plus<=0; minus<=1;end
	end
	else begin	plus<=0; minus<=0; end
	
endmodule
///----------------------------------------------------------------------------

module DYN_SCORE(freq, RESET, point, point_segd, segc); //점수출력  

	input	freq, RESET;
	input	[6:0] point; 
	output	[6:0] point_segd;
	output	[1:0] segc;   
	reg	[6:0] point_segd;   
	reg [3:0] point_01;   
	reg [3:0] point_10;   
	reg [1:0] segc;   
	
    SEPARATOR		U0(point, point_10, point_01);     
	DYN_point_DEC	U1(freq, RESET, point_10, point_01, point_segd, segc);

endmodule
 
/////////////////////////////////////////////////////////////////////////