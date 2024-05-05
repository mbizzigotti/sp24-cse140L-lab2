module month_days(
    input        [3:0] month,
    output logic [4:0] numdays
);

always_comb
case (month)
     0: numdays = 31; // January - 31 days
     1: numdays = 29; // February - 28 days in a common year and 29 days in leap years
     2: numdays = 31; // March - 31 days
     3: numdays = 30; // April - 30 days
     4: numdays = 31; // May - 31 days
     5: numdays = 30; // June - 30 days
     6: numdays = 31; // July - 31 days
     7: numdays = 31; // August - 31 days
     8: numdays = 30; // September - 30 days
     9: numdays = 31; // October - 31 days
    10: numdays = 30; // November - 30 days
    11: numdays = 31; // December - 31 days
	 default: numdays = 0;
endcase

endmodule