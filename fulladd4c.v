module	fulladd4c	(sum, co, a, b, ci);

	output	[3:0]sum;
	output	co;
	input	[3:0]a,b;
	input	ci;
	
	wire	p0,g0,p1,g1,p2,g2,p3,g3;
	wire	c4,c3,c2,c1;
	
	assign	p0 =a[0]^b[0],p1	=a[1]^b[1],p2	=a[2]^b[2],p3	=a[3]^b[3];
	
	assign	g0 =a[0]&b[0],g1 =a[1]&b[1],g2 =a[2]&b[2],g3 =a[3]&b[3];
	
	assign	c1 =g0|(p0&ci),
		c2 =g1|(p1&g0)|(p1&p0&ci),
		c3 =g2|(p2&g1)|(p2&p1&g0)|(p2&p1&p0&ci),
		c4 =g3|(p3&g2)|(p3&p2&g1)|(p3&p2&p1&g0)|(p3&p2&p1&p0&ci);
		
	assign	sum[0] =p0^ci,sum[1] =p1^c1,sum[2] =p2^c2,sum[3] =p3^c3;
	
	assign	co = c4;
endmodule

