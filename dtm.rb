class DTM

  NEW_STATE = 0
  WRITE_SYMBOL = 1
  MOVE_HEAD = 2

  attr_reader :transition_function, :symbols, :alphabet, :blank, :states, :accept, :reject

  def initialize(config = {})
    @symbols = config[:symbols] || ['b', '0', '1']
    @alphabet = config[:alphabet] || ['0', '1']
    @blank = (@symbols - @alphabet).first

    @states = config[:states] || ['q0','q1','qy','qn']
    @accept = config[:accept] || 'qy'
    @reject = config[:reject] || 'qn'
    
    @transition_function = config[:transition] || {
      'q0-0'=>['q0','0',1], 'q0-1'=>['q0','1',1], 'q0-b'=>['q1','b',-1],
      'q1-0'=>['qy','b',-1], 'q1-1'=>['qn','b',-1], 'q1-b'=>['qn','b',-1],
      'qy-0'=>['qy','0',0], 'qy-1'=>['qy','1',0], 'qy-b'=>['qy','b',0],
      'qn-0'=>['qn','0',0], 'qn-1'=>['qn','1',0], 'qn-b'=>['qn','b',0]  
       }    
  end

  #['1']
  def compute(input_tape)
    @zero_offset = 0;   
    @index = 0; 
    @state = @states.first
    wrap_tape input_tape
    print_state input_tape
    transition(input_tape)
  end

  def transition(tape)    
    rel_index = @index+@zero_offset
    outcome = next_step(@state, tape[rel_index])
    tape[rel_index] = outcome[WRITE_SYMBOL]
    @index += outcome[MOVE_HEAD]
    @state = outcome[NEW_STATE]
    print_state tape    
    transition(tape) unless @state == @accept || @state == @reject
  end

  def next_step(state, symbol)
    @transition_function["#{state}-#{symbol}"]
  end

  def wrap_tape(tape)
    @zero_offset += 1
    tape.unshift @blank
    tape.push @blank
  end

  def print_state(tape)
    print " "*(@state.length + 2 + (2*@index) + (2*@zero_offset))
    puts "\u25BC".encode('utf-8')
    puts "#{@state}:|#{tape.join('|')}|" 
  end

end