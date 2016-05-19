require_relative 'signup'

module RestoreStrategies
  # Objectification of the API's opportunity
  class Opportunity
    include ActiveModel::Model
    include ActiveModel::Validations
    include ActiveModel::Conversion

    @@client = nil

    attr_reader :raw, :client, :id, :name, :type, :featured, :description,
                :location, :items_committed, :items_given, :max_items_needed,
                :ongoing, :organization, :instructions, :gift_question, :days,
                :group_type, :issues, :region, :supplies, :skills

    def initialize(json_obj, json_str, client)
      @raw = json_str
      @client = client
      # TODO: Find a better way of capturing the ID
      @id = json_obj['href'][%r{[^(\/api\/opportunities\/)].}].to_i

      json_obj['data'].each do |datum|
        instance_variable_set("@#{datum['name'].underscore}", datum['value'])
      end

      json_obj['links'].each do |link|
        @signup_href = link['href'] if link['rel'] == 'signup'
      end
    end

    def self.client=(client)
      @@client
    end

    def self.client
      @@client
    end

    def get_signup
      signup_str = client.get_signup id
      RestoreStrategies::Signup.new(signup_str, self, client, id)
    end

    def submit_signup(signup)
      raise TypeError unless signup.is_a? Signup
      raise SignupValidationError,
            'Signup does not contain valid data' unless signup.valid?

      client.submit_signup(id, signup.to_payload)
    end
  end
end