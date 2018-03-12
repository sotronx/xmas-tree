require 'set'

class Expression
  attr_reader :literal
  
  def initialize
    @literal = nil
  end

  def to_javascript

  end
end

class AndExpression < Expression
  # operator node
  attr_accessor :left, :right

  def initialize()
    @literal = '&'
    @left = nil
    @right = nil
  end

  def to_s
    puts "#{@literal}"
  end
  
  def to_javascript(context)
    
    left = @left.to_javascript(context)
    right = @right.to_javascript(context)
    n = left.length
    
    # statements
    stmz = []
    # counter
    i = 0
    
    # collect statements from left-hand node
    while(i < n)
      stmz << left[i]
      i += 1
    end
    n = right.length
    i = 0
     # collect statements from right-hand node
    while(i < n)
      stmz << right[i]
      i += 1
    end
    
    stmz
  end
end

class OrExpression < Expression
  # operator node
  attr_accessor :left, :right
  
  def initialize()
    @literal = '|'
    @left = nil
    @right = nil
  end
  
  def to_s
    puts "#{@literal}"
  end
  
  def to_javascript(context)
    
    # parts
    pz = []
    
    left = @left.to_javascript(context)
    right = @right.to_javascript(context)
    
    # locate the middle of the container
    m = left.length / 2
    middle = left[m]
    
    if middle.include?("{") and middle.include?("}")
      # with curly braces
      pz = middle.partition("}")
    elsif !middle.include?("{") and !middle.include?("}")
      # without curly braces
      pz[0] = middle
      pz[1] = "\n"
    end
    
    # statements
    stmz = []
    i = 0
    # collect first half of statements from left-hand node
    while(i < m)
      stmz << left[i]
      i += 1
    end
    stmz << pz[0]
    i = 0
    # collect statements from right-hand node
    while(i < right.length)
      stmz << "  " + "#{right[i]}"
      i += 1
    end
    stmz << pz[1]
    i = m + 1
    # collect second half of statements from left-hand node
    while(i < left.length)
      stmz << left[i]
      i += 1
    end
    
    stmz
  end
end

class IdeogramExpression < Expression
  attr_accessor :romanizations
  attr_accessor :statements
  
  def initialize(ideograph)
    # hanja, hanji, kanji, or romanized in uppercase
    @literal = ideograph
    # boolean for cast or not
    @iscast = false
    # which romanization is used to cast the ideogram
    @cast_index = -1
    @romanizations = []
    @statements = []
  end

  def cast(romanization)
    # cast the ideogram with one of its romanization
    if has_romanizations?
      @cast_index = romanizations.find_index(romanization)
      if @cast_index
        @iscast = true
      else
        @iscast = false
      end
    end
    
    return @iscast
  end
  
  def original_romanization?
    # check if the ideogram is cast with the first romanization
    return @cast_index == 0
  end
  
  def has_romanizations?
    # are there romanizations for this ideogram
    if romanizations == nil
      puts "romanizations array is nil for #{@literal}"
      return false
    elsif romanizations.length == 0
      puts "There are no romanizations for #{@literal}"
      return false
    end
    # there is at least one romanization
    return true
  end

  def to_s
    puts "literal:#{@literal}"
    puts "romanizations:#{@romanizations}"
    puts "statements:#{@statements}"
  end
  
  def to_javascript(context)
    # other hanjis wants the statements from me
    stmz = []
    
	context.select do |rul|
	  if rul[1] == self
        stmz << rul[1].statements[rul[2]]
	  end
	end
    
    if stmz.size == 0
      stmz << statements[0]
    end
    
    return stmz
  end
end

class HanjaExpression < IdeogramExpression
  # attr_accessor :forms
  # def cast(form)
  # def original_form?
  # def has_forms?
  # puts "forms:#{@forms}"
end

class HanjiExpression < IdeogramExpression
  # attr_accessor :tones
  # def cast(tone)
  # def original_tone?
  # def has_tones?
  # puts "tones:#{@tones}"
end

class KanjiExpression < IdeogramExpression
  # attr_accessor :forms
  # def cast(form)
  # def original_form?
  # def has_forms?
  # puts "forms:#{@forms}"
end

class EnglishExpression < IdeogramExpression
  # attr_accessor :words
  # def cast(word)
  # def original_word?
  # def has_words?
  # puts "words:#{@words}"
end

class ASTWrapper < Expression

  def initialize(ast, sequence)
    # hanji object nodes as context elements
    @hanjis = sequence
    # abstract syntax tree for this series or group
    @ast = ast
    
    l = []
    @hanjis.each do |h| l << h.literal end
    @literal = l
  end
  
  def to_s
    puts "#{@literal}"
  end
end

class Series < ASTWrapper
  
  def to_javascript(context)
    p @literal
    puts '-' * 40
    @ast.to_javascript(context)
  end
end

class Group < ASTWrapper

  def initialize(ast, sequence)
    super
    @localc = Set.new
  end
  
  def to_javascript(context)
    # lookups or selections across group boundaries should be masked
    # we pick up those rules covered by group members
    context.each do |rul|
      if @hanjis.include?(rul[0]) and @hanjis.include?(rul[1])
        @localc.add(rul)
      end
    end
    return @ast.to_javascript(@localc)
  end
end
