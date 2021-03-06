include_class 'org.apache.thrift.TUnion'
include_class 'org.apache.thrift.protocol.TStruct'
include_class 'org.apache.thrift.protocol.TField'

module Thrift
  Union = org.apache.thrift.TUnion
  module Struct
    def initialize(d={}, &block)
      # get a copy of the default values to work on, removing defaults in favor of arguments
      fields_with_defaults = fields_with_default_values.dup
      
      # check if the defaults is empty, or if there are no parameters for this 
      # instantiation, and if so, don't bother overriding defaults.
      unless fields_with_defaults.empty? || d.empty?
        d.each_key do |name|
          fields_with_defaults.delete(name.to_s)
        end
      end
      
      # assign all the user-specified arguments
      unless d.empty?
        d.each do |name, value|
          unless name_to_id(name.to_s)
            raise Exception, "Unknown key given to #{self.class}.new: #{name}"
          end
          Thrift.check_type(value, struct_fields[name_to_id(name.to_s)], name) if Thrift.type_checking
          instance_variable_set("@#{name}", value)
        end
      end
      
      # assign all the default values
      unless fields_with_defaults.empty?
        fields_with_defaults.each do |name, default_value|
          instance_variable_set("@#{name}", (default_value.dup rescue default_value))
        end
      end
      
      yield self if block_given?
    end

    def fields_with_default_values
      fields_with_default_values = self.class.instance_variable_get("@fields_with_default_values")
      unless fields_with_default_values
        fields_with_default_values = {}
        struct_fields.each do |fid, field_def|
          unless field_def[:default].nil?
            fields_with_default_values[field_def[:name]] = field_def[:default]
          end
        end
        self.class.instance_variable_set("@fields_with_default_values", fields_with_default_values)
      end
      fields_with_default_values
    end
    
    def inspect(skip_optional_nulls = true)
      fields = []
      each_field do |fid, field_info|
        name = field_info[:name]
        value = instance_variable_get("@#{name}")
        unless skip_optional_nulls && field_info[:optional] && value.nil?
          fields << "#{name}:#{inspect_field(value, field_info)}"
        end
      end
      "<#{self.class} #{fields.join(", ")}>"
    end

    def read(iprot)
      iprot.read_struct_begin
      loop do
        field = iprot.read_field_begin
        break if (field.type == Types::STOP)
        handle_message(iprot, field.id, field.type)
        iprot.read_field_end
      end
      iprot.read_struct_end
      validate
    end

    def write(oprot)
      validate
      oprot.write_struct_begin(org.apache.thrift.protocol.TStruct.new(self.class.name))
      each_field do |fid, field_info|
        name = field_info[:name]
        type = field_info[:type]
        value = instance_variable_get("@#{name}")
        unless value.nil?
          if is_container? type
            oprot.write_field_begin(org.apache.thrift.protocol.TField.new(name, type, fid))
            write_container(oprot, value, field_info)
            oprot.write_field_end
          else
            oprot.write_field(name, type, fid, value)
          end
        end
      end
      oprot.write_field_stop
      oprot.write_struct_end
    end

    def ==(other)
      each_field do |fid, field_info|
        name = field_info[:name]
        return false unless self.instance_variable_get("@#{name}") == other.instance_variable_get("@#{name}")
      end
      true
    end

    def eql?(other)
      self.class == other.class && self == other
    end

    def hash
      field_values = []
      each_field do |fid, field_info|
        name = field_info[:name]
        field_values << self.instance_variable_get("@#{name}")
      end
      field_values.hash
    end

    def differences(other)
      diffs = []
      unless other.is_a?(self.class)
        diffs << "Different class!"
      else
        each_field do |fid, field_info|
          name = field_info[:name]
          diffs << "#{name} differs!" unless self.instance_variable_get("@#{name}") == other.instance_variable_get("@#{name}")
        end
      end
      diffs
    end

    def self.field_accessor(klass, field_info)
      field_name_sym = field_info[:name].to_sym
      klass.send :attr_reader, field_name_sym
      klass.send :define_method, "#{field_info[:name]}=" do |value|
        Thrift.check_type(value, field_info, field_info[:name]) if Thrift.type_checking
        instance_variable_set("@#{field_name_sym}", value)
      end
    end

    def self.generate_accessors(klass)
      klass::FIELDS.values.each do |field_info|
        field_accessor(klass, field_info)
        qmark_isset_method(klass, field_info)
      end
    end

    def self.qmark_isset_method(klass, field_info)
      klass.send :define_method, "#{field_info[:name]}?" do
        !self.send(field_info[:name].to_sym).nil?
      end
    end

    def <=>(other)
      if self.class == other.class
        each_field do |fid, field_info|
          v1 = self.send(field_info[:name])
          v1_set = !v1.nil?
          v2 = other.send(field_info[:name])
          v2_set = !v2.nil?
          if v1_set && !v2_set
            return -1
          elsif !v1_set && v2_set
            return 1
          elsif v1_set && v2_set
            cmp = v1 <=> v2
            if cmp != 0
              return cmp
            end
          end
        end
        0
      else
        self.class <=> other.class
      end
    end

    protected

    def self.append_features(mod)
      if mod.ancestors.include? ::Exception
        mod.send :class_variable_set, :'@@__thrift_struct_real_initialize', mod.instance_method(:initialize)
        super
        # set up our custom initializer so `raise Xception, 'message'` works
        mod.send :define_method, :struct_initialize, mod.instance_method(:initialize)
        mod.send :define_method, :initialize, mod.instance_method(:exception_initialize)
      else
        super
      end
    end

    def exception_initialize(*args, &block)
      if args.size == 1 and args.first.is_a? Hash
        # looks like it's a regular Struct initialize
        method(:struct_initialize).call(args.first)
      else
        # call the Struct initializer first with no args
        # this will set our field default values
        method(:struct_initialize).call()
        # now give it to the exception
        self.class.send(:class_variable_get, :'@@__thrift_struct_real_initialize').bind(self).call(*args, &block) if args.size > 0
        # self.class.instance_method(:initialize).bind(self).call(*args, &block)
      end
    end

    def handle_message(iprot, fid, ftype)
      field = struct_fields[fid]
      if field and field[:type] == ftype
        value = read_field(iprot, field)
        instance_variable_set("@#{field[:name]}", value)
      else
        iprot.skip(ftype)
      end
    end
  end
  
  module Struct_Union
    def name_to_id(name)
      names_to_ids = self.class.instance_variable_get("@names_to_ids")
      unless names_to_ids
        names_to_ids = {}
        struct_fields.each do |fid, field_def|
          names_to_ids[field_def[:name]] = fid
        end
        self.class.instance_variable_set("@names_to_ids", names_to_ids)
      end
      names_to_ids[name]
    end

    def each_field
      struct_fields.keys.sort.each do |fid|
        data = struct_fields[fid]
        yield fid, data
      end
    end

    def read_field(iprot, field = {})
      case field[:type]
      when Types::STRUCT
        value = field[:class].new
        value.read(iprot)
      when Types::MAP
        key_type, val_type, size = iprot.read_map_begin
        value = {}
        size.times do
          k = read_field(iprot, field_info(field[:key]))
          v = read_field(iprot, field_info(field[:value]))
          value[k] = v
        end
        iprot.read_map_end
      when Types::LIST
        type = iprot.read_list_begin
        puts type
        value = Array.new(type.size) do |n|
          read_field(iprot, field_info(field[:element]))
        end
        iprot.read_list_end
      when Types::SET
        e_type, size = iprot.read_set_begin
        value = Set.new
        size.times do
          element = read_field(iprot, field_info(field[:element]))
          value << element
        end
        iprot.read_set_end
      else
        value = iprot.read_type(field[:type])
      end
      value
    end

    def write_data(oprot, value, field)
      if is_container? field[:type]
        write_container(oprot, value, field)
      else
        oprot.write_type(field[:type], value)
      end
    end

    def write_container(oprot, value, field = {})
      case field[:type]
      when Types::MAP
        oprot.write_map_begin(field[:key][:type], field[:value][:type], value.size)
        value.each do |k, v|
          write_data(oprot, k, field[:key])
          write_data(oprot, v, field[:value])
        end
        oprot.write_map_end
      when Types::LIST
        oprot.write_list_begin(field[:element][:type], value.size)
        value.each do |elem|
          write_data(oprot, elem, field[:element])
        end
        oprot.write_list_end
      when Types::SET
        oprot.write_set_begin(field[:element][:type], value.size)
        value.each do |v,| # the , is to preserve compatibility with the old Hash-style sets
          write_data(oprot, v, field[:element])
        end
        oprot.write_set_end
      else
        raise "Not a container type: #{field[:type]}"
      end
    end

    CONTAINER_TYPES = []
    CONTAINER_TYPES[Types::LIST] = true
    CONTAINER_TYPES[Types::MAP] = true
    CONTAINER_TYPES[Types::SET] = true
    def is_container?(type)
      CONTAINER_TYPES[type]
    end

    def field_info(field)
      { :type => field[:type],
        :class => field[:class],
        :key => field[:key],
        :value => field[:value],
        :element => field[:element] }
    end

    def inspect_field(value, field_info)
      if enum_class = field_info[:enum_class]
        "#{enum_class.const_get(:VALUE_MAP)[value]} (#{value})"
      elsif value.is_a? Hash 
        if field_info[:type] == Types::MAP
          map_buf = []
          value.each do |k, v|
            map_buf << inspect_field(k, field_info[:key]) + ": " + inspect_field(v, field_info[:value])
          end
          "{" + map_buf.join(", ") + "}"
        else
          # old-style set
          inspect_collection(value.keys, field_info)
        end
      elsif value.is_a? Array
        inspect_collection(value, field_info)
      elsif value.is_a? Set
        inspect_collection(value, field_info)
      elsif value.is_a?(String) && field_info[:binary]
        value.unpack("H*").first
      else
        value.inspect
      end
    end
    
    def inspect_collection(collection, field_info)
      buf = []
      collection.each do |k|
        buf << inspect_field(k, field_info[:element])
      end
      "[" + buf.join(", ") + "]"      
    end
  end
end