module Wbck::Util
  class Amitool

    def initialize(image, geometry, shell_executor)
      @image = image
      @geometry = geometry
      @shell_executor = shell_executor
    end

    def rdbtool(commands)
      c = commands.clone
      c.insert(0, Command.new('open', [], { 'c' => @geometry.cylinders, 'h' => @geometry.heads, 's' => @geometry.sectors }))
      amitool('rdbtool', c)
    end

    def xdftool(partition, commands)
      c = commands.clone
      c.insert(0, Command.new('open', [], { 'c' => @geometry.cylinders, 'h' => @geometry.heads, 's' => @geometry.sectors, 'part' => partition }))
      amitool('xdftool', c)
    end

    def amitool(tool, commands)
      command = [tool, @image]
      commands.each do |c|
        command.push c.name
        command.concat c.arguments
        c.parameters.each_pair do |k,v|
          command.push "#{k}=#{v}"
        end
        command.push '+'
      end
      command.pop if command[-1] == '+'
      @shell_executor.execute(command)
    end

    class Command

      attr_reader :name, :arguments, :parameters

      def initialize(name, arguments, parameters)
        @name = name
        @arguments = arguments
        @parameters = parameters
      end

    end

  end
end