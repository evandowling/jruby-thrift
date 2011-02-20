require 'java'
require File.dirname(__FILE__) + '/libthrift.jar'
require File.dirname(__FILE__) + '/slf4j-simple-1.6.1.jar'
require File.dirname(__FILE__) + '/slf4j-api-1.6.1.jar'

require File.dirname(__FILE__) + '/core_ext'
require File.dirname(__FILE__) + '/exceptions'
require File.dirname(__FILE__) + '/types'
require File.dirname(__FILE__) + '/processor'
require File.dirname(__FILE__) + '/client'
require File.dirname(__FILE__) + '/data_structures'

require File.dirname(__FILE__) + '/serializer'
require File.dirname(__FILE__) + '/deserializer'

require File.dirname(__FILE__) + '/protocols'
require File.dirname(__FILE__) + '/transports'
require File.dirname(__FILE__) + '/servers'