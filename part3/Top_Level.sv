// CSE140L  
// see Structural Diagram in Lab2 assignment writeup
// fill in missing connections and parameters
module Top_Level #(parameter NS=60, NH=24)(
  input Reset,
        Timeset, 	  // manual buttons
        Alarmset,	  //	(five total)
        Minadv,
        Hrsadv,
        Dayadv,
        Datadv,
        Monadv,
        Alarmon,
        Pulse,		  // digital clock, assume 1 cycle/sec.
// 6 decimal digit display (7 segment)
  output [6:0]  S1disp, S0disp, 	   // 2-digit seconds display
                M1disp, M0disp, 
                H1disp, H0disp,
                D0disp,   // for part 2
                N1disp, N0disp,
                T1disp, T0disp,
  output logic Buzz);	           // alarm sounds
// internal connections (may need more)
  logic[6:0] TSec, TMin, THrs, TDay,     // clock/time 
             AMin, AHrs, ADay;		   // alarm setting
  logic[6:0] TDat, TMon;
  logic[6:0] Min, Hrs;
  logic S_max, M_max, H_max, 	   // "carry out" from sec -> min, min -> hrs, hrs -> days
        D_max,
        TMen, THen, AMen, AHen;
  logic TDen, ADen, TNen, TTen;
  logic buzz;

  logic [4:0] numdays;

  assign TMen = (Timeset && Minadv) ? Pulse :                    S_max;
  assign THen = (Timeset && Hrsadv) ? Pulse : (         M_max && S_max);
  assign TDen = (Timeset && Dayadv) ? Pulse : (H_max && M_max && S_max);
  
  assign TNen = (Timeset && Datadv) ? Pulse : (         H_max && M_max && S_max);
  assign TTen = (Timeset && Monadv) ? Pulse : (D_max && H_max && M_max && S_max);

  assign AMen = Alarmset && Minadv;
  assign AHen = Alarmset && Hrsadv;
  assign ADen = Alarmset && Dayadv;

  assign Buzz = buzz && Alarmon;

  month_days md(
    .month(TMon[3:0]),
    .numdays
  );

// (almost) free-running seconds counter	-- be sure to set modulus inputs on ct_mod_N modules
  ct_mod_N  Sct(
    .clk(Pulse), .rst(Reset), .en(!Timeset), .modulus(7'd60),
    .ct_out(TSec), .ct_max(S_max)
  );

// minutes counter -- runs at either 1/sec while being set or 1/60sec normally
  ct_mod_N Mct(
    .clk(Pulse), .rst(Reset), .en(TMen), .modulus(7'd60),
    .ct_out(TMin), .ct_max(M_max)
  );

// hours counter -- runs at either 1/sec or 1/60min
  ct_mod_N  Hct(
  	.clk(Pulse), .rst(Reset), .en(THen), .modulus(7'd24),
    .ct_out(THrs), .ct_max(H_max)
  );

// days counter
  ct_mod_N Dct(
    .clk(Pulse), .rst(Reset), .en(TDen), .modulus(7'd7),
    .ct_out(TDay), .ct_max()
  );
  
// date counter
  ct_mod_N Datct(
    .clk(Pulse), .rst(Reset), .en(TNen), .modulus({2'b0,numdays}),
    .ct_out(TDat), .ct_max(D_max)
  );
  
// month counter
  ct_mod_N Monct(
    .clk(Pulse), .rst(Reset), .en(TTen), .modulus(7'd12),
    .ct_out(TMon), .ct_max()
  );

// alarm set registers -- either hold or advance 1/sec while being set
  ct_mod_N Mreg(
// input ports
    .clk(Pulse), .rst(Reset), .en(AMen), .modulus(7'd60),
// output ports    
    .ct_out(AMin), .ct_max()  ); 

  ct_mod_N  Hreg(
// input ports
    .clk(Pulse), .rst(Reset), .en(AHen), .modulus(7'd24),
// output ports    
    .ct_out(AHrs), .ct_max() );
    
  ct_mod_N  Dreg(
// input ports
    .clk(Pulse), .rst(Reset), .en(ADen), .modulus(7'd7),
// output ports    
    .ct_out(ADay), .ct_max() );

// display drivers (2 digits each, 6 digits total)
  lcd_int Sdisp(					  // seconds display
    .bin_in    (TSec),
    .Segment1  (S1disp),
    .Segment0  (S0disp)
	);

  lcd_int Mdisp(
    .bin_in    (Alarmset ? AMin : TMin),
    .Segment1  (M1disp),
    .Segment0  (M0disp)
	);

  lcd_int Hdisp(
    .bin_in    (Alarmset ? AHrs : THrs),
    .Segment1  (H1disp),
    .Segment0  (H0disp)
	);

  lcd_int Ddisp(
    .bin_in    (Alarmset ? ADay : TDay),
    .Segment1  (),
    .Segment0  (D0disp)
  );

  lcd_int Ndisp(
    .bin_in    (TDat),
    .Segment1  (N1disp),
    .Segment0  (N0disp)
  );

  lcd_int Tdisp(
    .bin_in    (TMon),
    .Segment1  (T1disp),
    .Segment0  (T0disp)
  );

// buzz off :)	  make the connections
  alarm a1(
    .tmin(TMin), .amin(AMin),
    .thrs(THrs), .ahrs(AHrs),
    .tday(TDay), .aday(ADay),
    .buzz
	);

endmodule
