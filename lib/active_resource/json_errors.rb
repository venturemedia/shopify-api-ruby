# frozen_string_literal: true
require 'active_resource/base'

module ActiveResource
  class Errors < ActiveModel::Errors
    def from_json(json, save_cache = false)
      data =
        begin
          ActiveSupport::JSON.decode(json)['errors'] || {}
        rescue
          {}
        end
      case data
      when String
        from_string(data, save_cache)
      when Array
        from_array(data, save_cache)
      else
        from_hash(data, save_cache)
      end
    end

    def from_hash(messages, save_cache = false)
      clear unless save_cache

      messages.each do |key, errors|
        errors.each do |error|
          add(key, error)
        end
      end
    end

    def from_array(errors, save_cache = false)
      clear unless save_cache

      raise ActiveResource::ResourceInvalid.new(response_struct(errors))
    end

    def from_string(error, save_cache = false)
      clear unless save_cache

      add(:base, error)
    end

    private

    def response_struct(errors)
      Struct.new(:message, :code).new(errors.join(', '), 422)
    end
  end
end
