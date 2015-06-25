require 'uri'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
      @params = {}
      if req.query_string
        @params.merge!(parse_www_encoded_form(req.query_string))
      end
      # parsing the request body
      if req.body
        @params.merge!(parse_www_encoded_form(req.body))
      end
      @params.merge!(route_params)
    end

    def [](key)
      @params[key.to_s]
    end

    def to_s
      @params.to_json.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      params = {}
      key_val_pairs = URI::decode_www_form(www_encoded_form)
      key_val_pairs.each do |key, val|
          # assign current level to an empty hash
          current_level = params
          # parse the key values
          parse_key(key).each_with_index do |nested_key, i|
              # if you are at the last key
              if i == (parse_key(key).length-1)
                  # set this key to the value
                  current_level[nested_key] = val
              else
                  # create a new (hash) level, establishing the
                  # nested_key as the key of an empty hash.
                  current_level[nested_key] = {}
                  # set current_level down one: so you are at the level of
                  # the hash that you just set
                  current_level = current_level[nested_key]
              end
          end
      end
      params
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      key.split(/\]\[|\[|\]/)
    end
  end
end
