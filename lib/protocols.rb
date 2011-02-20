include_class 'org.apache.thrift.protocol.TProtocol'
include_class 'org.apache.thrift.protocol.TBinaryProtocol'
include_class 'org.apache.thrift.protocol.TCompactProtocol'
include_class 'org.apache.thrift.protocol.TField'

module Thrift
  BaseProtocol = org.apache.thrift.protocol.TProtocol
  
  class BaseProtocol
    def write_field(name, type, fid, value)
      write_field_begin(org.apache.thrift.protocol.TField.new(name, type, fid))
      write_type(type, value)
      write_field_end
    end

    def write_type(type, value)
      case type
      when Types::BOOL
        write_bool(value)
      when Types::BYTE
        write_byte(value)
      when Types::DOUBLE
        write_double(value)
      when Types::I16
        write_i16(value)
      when Types::I32
        write_i32(value)
      when Types::I64
        write_i64(value)
      when Types::STRING
        write_string(value)
      when Types::STRUCT
        value.write(self)
      else
        raise NotImplementedError
      end
    end
    
    def skip(type)
      case type
      when Types::STOP
        nil
      when Types::BOOL
        read_bool
      when Types::BYTE
        read_byte
      when Types::I16
        read_i16
      when Types::I32
        read_i32
      when Types::I64
        read_i64
      when Types::DOUBLE
        read_double
      when Types::STRING
        read_string
      when Types::STRUCT
        read_struct_begin
        while true
          name, type, id = read_field_begin
          break if type == Types::STOP
          skip(type)
          read_field_end
        end
        read_struct_end
      when Types::MAP
        ktype, vtype, size = read_map_begin
        size.times do
          skip(ktype)
          skip(vtype)
        end
        read_map_end
      when Types::SET
        etype, size = read_set_begin
        size.times do
          skip(etype)
        end
        read_set_end
      when Types::LIST
        etype, size = read_list_begin
        size.times do
          skip(etype)
        end
        read_list_end
      end
    end
    
  end
  
  BinaryProtocol = org.apache.thrift.protocol.TBinaryProtocol
  BinaryProtocolAccelerated = BinaryProtocol
  CompactProtocol = org.apache.thrift.protocol.TCompactProtocol
end