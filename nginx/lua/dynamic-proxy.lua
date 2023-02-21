-- Load Memcached, cjson module
local resolver = require "resty.dns.resolver"
local cjson     = require "cjson"
local memcached = require "resty.memcached"
local memc      = memcached:new()

-- Set Memcached timeout(1 sec)
memc:set_timeout(1000)

local r, err = resolver:new{
    host = 127.0.0.1 -- memcachedホストのアドレス
    port = 11211     -- memcachedホストのポート
	nameservers = {{host,port}}, 
	retrans = 5,  -- 5 retransmissions on receive timeout
	timeout = 2000,  -- 2 sec
	no_random = true, -- always start with first nameserver
}

if not r then
	ngx.say("failed to instantiate the resolver: ", err)
	return
end

local answers, err, tries = r:query("memcached", nil, {})
if not answers then
	ngx.say("failed to query the DNS server: ", err)
	return
end

local addr = ""

for i, ans in ipairs(answers) do
	addr = ans.address;
end


-- Connect to Memcached daemon
local client, err = memc:new()
local ok, error = client:connect(addr, 11211)

if not ok then
    ngx.log(ngx.ALERT, "Failed to connect to Memcached: ", err)
end

-- Rewrite HOST and PATH 
local target=ngx.var["token"]
local path=ngx.var.path_dst

if target ~= nil then
    local val, flags, err = client:get(target)

    if val ~= nil then
        ngx.var.dynamic_host = val

    else
        ngx.say("[DynamicProxyError] : failed access to instance")
    end

else
        ngx.say("[DynamicProxyError] : invalid token")
end
