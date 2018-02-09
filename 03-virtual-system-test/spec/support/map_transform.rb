require 'hashformer'


def map_transform( comment:, data: , xSchema: )
  support_debug "map_transform(#{comment}): data=#{data}"
  transformed = Hashformer.transform( data, xSchema )
  support_debug "map_transform(#{comment}): transformed=#{transformed}"
  transformed
end
