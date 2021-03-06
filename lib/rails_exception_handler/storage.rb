class RailsExceptionHandler::Storage
  def self.active_record(info)
    if Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR > 0
      error_message = RailsExceptionHandler::ActiveRecord::ErrorMessage.find_or_initialize_by(info, without_protection: true) if RailsExceptionHandler::ActiveRecord::ErrorMessage.respond_to?(:find_or_initialize_by)
    else
      error_message = RailsExceptionHandler::ActiveRecord::ErrorMessage.find_or_initialize_by(info) if RailsExceptionHandler::ActiveRecord::ErrorMessage.respond_to?(:find_or_initialize_by)
    end
    error_message.count += 1
    error_message.save
  end

  def self.mongoid(info)
    if Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR > 0
      error_message = RailsExceptionHandler::Mongoid::ErrorMessage.find_or_initialize_by(info, without_protection: true) if RailsExceptionHandler::Mongoid::ErrorMessage.respond_to?(:find_or_initialize_by)
    else
      error_message = RailsExceptionHandler::Mongoid::ErrorMessage.find_or_initialize_by(info) if RailsExceptionHandler::Mongoid::ErrorMessage.respond_to?(:find_or_initialize_by)
    end
    error_message.count += 1
    error_message.save
  end

  def self.rails_log(info)
    message = ''
    info.each do |key,val|
      message += "#{key.to_s.upcase}: #{val.to_s}\n"
    end
    Rails.logger.fatal(message)
  end

  def self.remote_url(target, info)
    uri = URI.parse(target)
    params = flatten_hash({:error_message => info})
    Net::HTTP::post_form(uri, params)
  end

  private

  # Credit: Hash flattening technique borrowed from Peter Marklund: http://marklunds.com/articles/one/314
  def self.flatten_hash(hash, ancestor_names = [])
    flat_hash = {}
    hash.each do |k, v|
      names = Array.new(ancestor_names)
      names << k
      if v.is_a?(Hash)
        flat_hash.merge!(flatten_hash(v, names))
      else
        key = flat_hash_key(names)
        key += '[]' if v.is_a?(Array)
        flat_hash[key] = v
      end
    end
    flat_hash
  end

  def self.flat_hash_key(names)
    names = Array.new(names)
    name = names.shift.to_s.dup
    names.each do |n|
      name << "[#{n}]"
    end
    name
  end
end
