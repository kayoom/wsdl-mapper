module WsdlMapper
  module Runtime
    module SimplerInspect
      def inspect
        vars = instance_variables.map do |iv|
          next if iv.to_s[0, 2] == '@_'

          val = instance_variable_get iv
          "#{iv}: #{val}"
        end
        vars = vars.compact * ', '

        "#<#{self.class.name} #{vars}>"
      end
    end
  end
end
