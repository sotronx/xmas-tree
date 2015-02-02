require_relative './expression'

class Parser

  def initialize(matchdata)
    # an array of expression nodes, including combination operators and hanji operands
    @nodes = matchdata
  end
  
  def join(operators, operands)
    # left-hanji-node and right-hanji-node join together with operator-node
    o = operators.pop
    o.right = operands.pop
    o.left = operands.pop
    operands.push(o)
  end
  
  def to_ast
    return shunt
  end
  
  def shunt
    # shunt the expression nodes
    # operator stack and operand stack for Shunting Yard Algorithm
    # operator stack for combination operator nodes
    operators = []
    # operand stack for hanji operand nodes
    operands = []
    # if grouping a couple of hanji nodes
    grouping = false
    # if the previous hanji is in original romanization
    previous_original_romanization = true
    # counter for operators in a group
    count = 0
    # series array holds member hanjis and groups
    sarray = []
    # group array holds member hanjis
    garray = []

    @nodes.each do |node|
      
      if node.literal == "&" or node.literal == "|"
        # combination operator nodes
        if grouping
          count += 1
        end
        
        # push the operator into operator stack
        operators.push(node)
      else
        # hanji operand nodes
        
        if !node.original_romanization?
          puts "non-original romazination: #{node.literal}"
        end
        
        operands.push(node)
        
        if !node.original_romanization? && previous_original_romanization == true && grouping == false
          # we start grouping hanjis one by one to form a lengthened hanji
          # each group must start with a hanji node
          previous_original_romanization = false
          grouping = true
          garray = []
          # accumulate a hanji operand
          garray << node
        elsif node.original_romanization? && previous_original_romanization == false && grouping == true
          # we end grouping hanjis
          previous_original_romanization = true
          grouping = false
          
          while count > 0 do
            # build an ast for the group
            join(operators, operands)
            # operator counter
            count -= 1
          end

          # the last member hanji for this group
          garray << node

          # pop out the group ast, add members to a group
          gnode = Group.new(operands.pop, garray)
          
          # add the member group to series
          sarray << gnode
          
          # push the group back to operand stack
          operands.push(gnode)
        elsif !node.original_romanization? && previous_original_romanization == false && grouping == true
          # accumulate the hanji operands for the group
          # grouping
          garray << node
        elsif node.original_romanization? && previous_original_romanization == true && grouping == false
          # accumulate the hanjis. no grouping for this state.
          sarray << node
        end
      end
    end
    
    # process the remaining operators and operands
    until operators.empty?
      join(operators, operands)
    end
    
    s = Series.new(operands.last, sarray)
    
    # check the length of operands, should be only one left
    if operands.length != 1
      puts "parsing error!"
    end
    
    return s
  end
end
