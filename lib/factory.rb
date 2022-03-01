# frozen_string_literal: true

# * Here you must define your `Factory` class.
# * Each instance of Factory could be stored into variable. The name of this variable is the name of created Class
# * Arguments of creatable Factory instance are fields/attributes of created class
# * The ability to add some methods to this class must be provided while creating a Factory
# * We must have an ability to get/set the value of attribute like [0], ['attribute_name'], [:attribute_name]
#
# * Instance of creatable Factory class should correctly respond to main methods of Struct
# - each
# - each_pair
# - dig
# - size/length
# - members
# - select
# - to_a
# - values_at
# - ==, eql?

# /factory/ruby-factory-master/lib/factory.rb
class Factory
  class << self
    def new(*args, &block)
      const_set(args.shift.capitalize, new(*args, &block)) if args.first.is_a? String
      create_class(*args, &block)
    end

    def create_class(*args, &block)
      Class.new do
        attr_accessor(*args)

        define_method :initialize do |*arg_value|
          raise ArgumentError unless arg_value.length == args.length

          args.zip(arg_value).each do |instance_key, instance_value|
            instance_variable_set("@#{instance_key}", instance_value)
          end
        end

        define_method :values do
          instance_variables.map { |arg| instance_variable_get(arg) }
        end

        define_method :eql? do |other|
          instance_of?(other.class) && values == other.values
        end

        define_method :[] do |arg|
          return instance_variable_get("@#{arg}") if [String, Symbol].include? arg.class
          return instance_variable_get(instance_variables[arg]) if arg.is_a? Integer
        end

        define_method :[]= do |arg, value|
          return instance_variable_set("@#{arg}", value) if [String, Symbol].include? arg.class
          return instance_variable_set(instance_variables[arg], value) if arg.is_a? Integer
        end

        define_method :members do
          args
        end

        define_method :to_h do
          members.zip(values).to_h
        end

        define_method :dig do |*arg|
          arg.reduce(to_h) do |hash, key|
            break unless hash[key]

            hash[key]
          end
        end

        define_method :each do |&bloc|
          values.each(&bloc)
        end

        define_method :each_pair do |&bloc|
          to_h.each_pair(&bloc)
        end

        define_method :length do
          instance_variables.length
        end

        define_method :select do |&bloc|
          values.select(&bloc)
        end

        define_method :values_at do |*index|
          instance_variables.values_at(*index).map { |arg| instance_variable_get(arg) }
        end

        class_eval(&block) if block
        alias_method :==, :eql?
        alias_method :size, :length
        alias_method :to_a, :values
      end
    end
  end
end
