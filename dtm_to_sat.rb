load 'dtm.rb'
load 'sat.rb'

class DTM_TO_SAT

  def initialize(dtm = nil)
    dtm = DTM.new() unless dtm
    @dtm = dtm     
    @pn = 5*1 #input length
    @r = dtm.states.length-1
    @v = dtm.symbols.length-1
  end

  def sat_format
    [
      clause_group_one, 
      clause_group_two, 
      clause_group_three,  
      clause_group_four,
      clause_group_five,
      clause_group_six
      ].join(", ")
  end

  def sat_no_start_end
    [
      clause_group_one, 
      clause_group_two, 
      clause_group_three, 
      clause_group_six
      ].join(", ")
  end

  def sat_no_start
    [
      clause_group_one, 
      clause_group_two, 
      clause_group_three,
      clause_group_five,
      clause_group_six
      ].join(", ")
  end

  def clause_group_one    
    result = (0..@pn).map{|i| (0..@r).map{|r| "Q[#{i};#{r}]"}.join(" ")  }.join(", ")
    result + ", " + (0..@pn).map{|i| (0..@r-1).map{|j| (j+1..@r).map{ |j_prime| "!Q[#{i};#{j}] !Q[#{i};#{j_prime}]" }.join(", ") }.join(", ") }.join(", ")
  end

  def clause_group_two #Only non negative tape indexes
    result = (0..@pn).map{|i| (0..@pn).map{|x| "H[#{i};#{x}]"}.join(" ")  }.join(", ")
    result + ", " + (0..@pn).map{|i| (0..@pn-1).map{|j| (j+1..@pn).map{ |j_prime| "!H[#{i};#{j}] !H[#{i};#{j_prime}]" }.join(", ") }.join(", ") }.join(", ")
  end

  def clause_group_three #Only non negative tape indexes
    result = (0..@pn).map{|i| (0..@pn+1).map{|j| (0..@v).map{|k| "S[#{i};#{j};#{k}]"}.join(" ") }.join(", ")  }.join(", ")
    result + ", " + (0..@pn).map{|i| (0..@pn+1).map{|j| (0..@v-1).map{|k| (k+1..@v).map{ |k_prime| "!S[#{i};#{j};#{k}] !S[#{i};#{j};#{k_prime}]"}.join(", ") }.join(", ") }.join(", ") }.join(", ")
  end

  def clause_group_four
    "Q[0;0], H[0;0], S[0;0;1], S[0;1;0]"
  end

  def clause_group_five
    "Q[#{@pn};#{@dtm.states.index @dtm.accept}]"
  end

  def clause_group_six
    result = (0..@pn).map{|i| (0..@pn+1).map{|j| (0..@v).map{|l| "!S[#{i};#{j};#{l}] H[#{i};#{j}] S[#{i+1};#{j};#{l}]"}.join(", ") }.join(", ") }.join(", ")


    result += ', ' + (0..@pn-1).map{|i| (0..@pn+1).map{|j| (0..@r).map{|k| (0..@v).map{|l|
      delta = translate_dtm_step(k,l).last
      "!S[#{i};#{j};#{l}] !H[#{i};#{j}] !Q[#{i};#{k}] H[#{i+1};#{j+delta}]"
      }.join(", ") }.join(", ") }.join(", ") }.join(", ")
    
    result += ', ' + (0..@pn-1).map{|i| (0..@pn+1).map{|j| (0..@r).map{|k| (0..@v).map{|l|
      k_prime = translate_dtm_step(k,l).first
      "!S[#{i};#{j};#{l}] !H[#{i};#{j}] !Q[#{i};#{k}] Q[#{i+1};#{k_prime}]"
      }.join(", ") }.join(", ") }.join(", ") }.join(", ")
    
    result + ', ' + (0..@pn-1).map{|i| (0..@pn+1).map{|j| (0..@r).map{|k| (0..@v).map{|l|
      l_prime = translate_dtm_step(k,l)[1]
      "!S[#{i};#{j};#{l}] !H[#{i};#{j}] !Q[#{i};#{k}] S[#{i+1};#{j};#{l_prime}]"
      }.join(", ") }.join(", ") }.join(", ") }.join(", ")
  end

  def translate_dtm_step(k, l)
    k_prime, l_prime, delta = @dtm.next_step(@dtm.states[k], @dtm.symbols[l])
    k_prime = @dtm.states.index k_prime
    l_prime = @dtm.symbols.index l_prime
    [k_prime, l_prime, delta]
  end


end