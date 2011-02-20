include_class 'org.apache.thrift.server.TServer'
include_class 'org.apache.thrift.server.TSimpleServer'
include_class 'org.apache.thrift.server.THsHaServer'
include_class 'org.apache.thrift.server.TThreadPoolServer'
include_class 'org.apache.thrift.server.TNonblockingServer'
module Thrift
  BaseServer = org.apache.thrift.server.TServer
  SimpleServer = org.apache.thrift.server.TSimpleServer
  ThreadedServer = org.apache.thrift.server.THsHaServer
  ThreadPoolServer = org.apache.thrift.server.TThreadPoolServer
  NonblockingServer = org.apache.thrift.server.TNonblockingServer
end