class SplattRepository

def initialize(client, user)
    @client = client
    @bucket = user.email
end

def save(splatt)
    splatts = @client.bucket(@bucket)
    key = splatt.id

    unless splatts.exists?(key)
        riak_obj = splatts.new(key)
        riak_obj.data = splatt
        riak_obj.content_type = 'application/json'
        riak_obj.store
        splatt
    end
end
