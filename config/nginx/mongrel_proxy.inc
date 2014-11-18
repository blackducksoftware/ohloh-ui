#
# shared configuration for nginx "locations" that are passed to a mongrel
# this file is shared by production and staging configs
#

proxy_pass  http://mongrel;
proxy_next_upstream error;
proxy_set_header   Host             $host;
proxy_set_header   X-Real-IP        $remote_addr;
proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
proxy_redirect     off;
