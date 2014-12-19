load 'dtm_to_sat.rb'

dtm_to_sat = DTM_TO_SAT.new
sat = SAT.new(dtm_to_sat.sat_format)
sat.print_cnf_form('cnf_expanded')
sat.variables.each_with_index{|x,i| puts x if [1,5,10,15,19,23,25,32,37,47,53,62,64,67,72,75,76,81,83,85,88,93,96,97,102,104,106,109,114,117,118,123,124,127,130,135,138,139,144,145,148,151,156,159,160,165,166,169,172,177,180,181,186,192,195,197,198,203,207,210,218].index(i+1)}