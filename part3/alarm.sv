// CSE140 lab 2  
// How does this work? How long does the alarm stay on? 
// (buzz is the alarm itself)
module alarm(
  input[6:0]  tmin,
              amin,
              thrs,
              ahrs,
              tday,
              aday,					 
  output logic buzz
);

  logic min_match, hrs_match, day_match;
  logic [2:0] next_alarm_day;
  logic [2:0] aday2;

  assign min_match = tmin == amin;
  assign hrs_match = thrs == ahrs;

  assign next_alarm_day = aday[2:0] + 1;
  assign aday2 = (next_alarm_day >= 3'd7) ? '0 : next_alarm_day;

  // Want to match to alarm day and (alarm day + 1) mod 7
  assign day_match = !( (tday == aday) || (tday[2:0] == aday2) );

  assign buzz = min_match && hrs_match && day_match;

endmodule