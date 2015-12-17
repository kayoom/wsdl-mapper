module WsdlMapper
  module Runtime
    # This module contains a non-recursive implementation of {#inspect} to prevent
    # pollution of an `irb` console with 20000 lines of inspect
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
