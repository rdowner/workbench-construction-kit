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
      amitool('rdbtool', @image, c)
    end

    def rdbtool_create(commands)
      c = commands.clone
      c.insert(0, Command.new('create', [], { 'c' => @geometry.cylinders, 'h' => @geometry.heads, 's' => @geometry.sectors }))
      amitool('rdbtool', @image, c)
    end

    def rdbtool_create_or_open(commands)
      c = commands.clone
      cmd = File.exist?(@image) ? 'open' : 'create'
      c.insert(0, Command.new(cmd, [], {'c' => @geometry.cylinders, 'h' => @geometry.heads, 's' => @geometry.sectors }))
      amitool('rdbtool', @image, c)
    end

    def xdftool_raw(xdffile, commands)
      c = commands.clone
      amitool('xdftool', xdffile, c)
    end

    def xdftool(partition, commands)
      c = commands.clone
      c.insert(0, Command.new('open', [], { 'c' => @geometry.cylinders, 'h' => @geometry.heads, 's' => @geometry.sectors, 'part' => partition }))
      amitool('xdftool', @image, c)
    end

    def amitool(tool, xdffile, commands)
      command = [tool, xdffile]
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