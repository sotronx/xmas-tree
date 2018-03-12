class Matcher

  def initialize(expression)
    # the expression will be broken down into tokens - hanji operand tokens and 
    # combination operator tokens.
    p expression
    @lexer = expression.scan(/[[:alnum:]]+|\&|\|/)
  end
  
  def getToken
    return @lexer.shift
  end
  
  def getHanji
    return @hanjis.shift
  end
  
  def match(sequence)
    # hanji operand tokens are used to match hanji sequence
    @hanjis = sequence
    
    # an empty array for expression nodes - hanji operand nodes and combination operator nodes
    nodes = []
    
    h = getHanji
    while h
      t = getToken
      
      if /[[:alnum:]]+/.match(t)
        # token is matched with alphanumeric. it is a form/tone/word
        # cast the hanja/hanji/kanji with form/tone/word
        b = h.cast(t)
        if b == false
          puts "casting error for #{h.literal}"
        end
        
        nodes << h
        h = getHanji
      elsif t == '&'
        # a token matched with and-expression (and operator)
        nodes << AndExpression.new()
      elsif t == '|'
        # a token matched with or-expression (or operator)
        nodes << OrExpression.new()
      end
    end

    # return an array of expression nodes ready to be shunted.
    # in this match method, we turn hanji objects into expression nodes.
    # expression nodes are returned as match data
    return nodes
  end
end
