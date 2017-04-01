require 'yaml'
require 'pp'
require 'csv'
require 'active_support/core_ext/hash/indifferent_access'
require 'faraday/detailed_logger'
require 'logger'
require 'erb'

require_relative 'importer'
require_relative 'osdi'

public

class Object
  def presence
    self if present?
  end

  def present?
    !blank?
  end

  def blank?
    respond_to?(:empty?) ? !!empty? : !self
  end
  def try(*a, &b)
    if a.empty? && block_given?
      yield self
    else
      __send__(*a, &b)
    end
  end
end

class Mixer
  def self._phone_simplify(in_num)
    return nil if in_num.nil?
    out_num=in_num.gsub(/[^0-9]/, '')
    out_num.sub!(/^1/, '')
    out_num
  end

  def self.osdi_info(osdi_obj)
    [
        osdi_obj.dig(:person,:given_name),
        osdi_obj.dig(:person,:family_name),
        osdi_obj.dig(:person,:email_addresses,0,:address),
        'with tags',
        osdi_obj.dig(:add_tags)

    ].join ' '
  end


  def self.clean(obj)

    case
      when (['Hash', 'ActiveSupport::HashWithIndifferentAccess'].include? (obj.class.to_s))
        #Rails.logger.debug("Hash")
        result=obj.each_with_object({}) do |o, stub|
          k=o[0]
          v=o[1]

          #Rails.logger.debug("Hash o=#{o} k=#{k} v=#{v}, stub #{stub}")

          stub[k]=clean(v) unless v.blank?


        end
      when obj.class == Array
        #Rails.logger.debug("Array")
        result=obj.each_with_object([]) do |k, stub|
          #Rails.logger.debug("Array=#{k} stub #{stub}")
          stub << clean(k) unless k.blank?

        end
      else

        result = obj unless obj.blank?
      #Rails.logger.debug("Else obj #{obj} class #{obj.class} result #{result}")
    end
    return result

  end



end

class MultiIO
  def initialize(*targets)
    @targets = targets
  end

  def write(*args)
    @targets.each {|t| t.write(*args)}
  end

  def close
    @targets.each(&:close)
  end
end