require "hashugar/version"

class Hashugar
  def initialize(hash)
    @table = {}
    @table_with_original_keys = {}
    hash.each_pair do |key, value|
      hashugar = value.to_hashugar
      @table_with_original_keys[key] = hashugar
      @table[stringify(key)] = hashugar
    end
  end

  def method_missing(method, *args, &block)
    method = method.to_s
    if @table.key?(method.gsub('=', ''))
      if method.chomp!('=')
        @table[method] = args.first
      else
        @table[method]
      end
    else
      # Allows Hash methods (like stringify_keys) to still work
      to_hash.send(method, *args, &block)
    end
  end

  def [](key)
    @table[stringify(key)]
  end

  def []=(key, value)
    @table[stringify(key)] = value
  end

  def respond_to?(key, include_all=false)
    super(key) || @table.has_key?(stringify(key))
  end

  def each(&block)
    @table_with_original_keys.each(&block)
  end

  def to_hash
    hash = @table_with_original_keys.to_hash
    hash.each do |key, value|
      hash[key] = value.to_hash if value.is_a?(Hashugar)
    end
  end

  def empty?
    @table.empty?
  end

  private
  def stringify(key)
    key.is_a?(Symbol) ? key.to_s : key
  end
end

class Hash
  def to_hashugar
    Hashugar.new(self)
  end
end

class Array
  def to_hashugar
    map(&:to_hashugar)
  end
end

class Object
  def to_hashugar
    self
  end
end
