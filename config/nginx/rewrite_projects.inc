rewrite "^/projects/(.*)/widgets(.+)$" $scheme://$http_host/p/$1/widgets$2 last;
rewrite "^/projects/(.*)/badge_js$" $scheme://$http_host/p/$1/badge_js last;
rewrite "^/projects(.*)\.atom(.*)" $scheme://$http_host/p$1.atom$2 last;
rewrite "^/projects(.*)\.rss(.*)" $scheme://$http_host/p$1.rss$2 last;
rewrite "^/projects(.*)\.csv(.*)" $scheme://$http_host/p$1.csv$2 last;
rewrite "^/projects(.*)\.xml" $scheme://$http_host/p$1.xml last;
rewrite "^/projects/(.*)" $scheme://$http_host/p/$1 permanent;
rewrite "^/projects$" $scheme://$http_host/p permanent;

# rewrite project stack urls.
rewrite "^/p/(.*)/stacks$" $scheme://$http_host/p/$1/users redirect;

# rewrite account/:account_id/positions/total to Commits by Language page
rewrite "^/accounts/(.*)/positions/total" $scheme://$http_host/accounts/$1/languages permanent;

#rewrite /anon80.gif to the respective image path -- for Twitter Cards
rewrite "^/anon(.*)$" $scheme://$http_host/images/anon/anon$1 permanent;

rewrite "^/licenses/Ms-PL/(.*)" $scheme://$http_host/licenses/Microsoft_Public_License/$1 permanent;
rewrite "^/licenses/Ms-PL$" $scheme://$http_host/licenses/Microsoft_Public_License permanent;
rewrite "^/licenses/Microsoft_Public_License_/(.*)" $scheme://$http_host/licenses/Microsoft_Public_License/$1 permanent;
rewrite "^/licenses/Microsoft_Public_License_$" $scheme://$http_host/licenses/Microsoft_Public_License permanent;

rewrite "^/licenses/gpl_v3/(.*)" $scheme://$http_host/licenses/gpl3/$1 permanent;
rewrite "^/licenses/gpl_v3$" $scheme://$http_host/licenses/gpl3 permanent;

rewrite "^/licenses/GPL-3/(.*)" $scheme://$http_host/licenses/gpl3/$1 permanent;
rewrite "^/licenses/GPL-3$" $scheme://$http_host/licenses/gpl3 permanent;

rewrite "^/licenses/GPL_3/(.*)" $scheme://$http_host/licenses/gpl3/$1 permanent;
rewrite "^/licenses/GPL_3$" $scheme://$http_host/licenses/gpl3 permanent;

rewrite "^/licenses/GPLv3/(.*)" $scheme://$http_host/licenses/gpl3/$1 permanent;
rewrite "^/licenses/GPLv3$" $scheme://$http_host/licenses/gpl3 permanent;

rewrite "^/licenses/GPLv3plus/(.*)" $scheme://$http_host/licenses/gpl3/$1 permanent;
rewrite "^/licenses/GPLv3plus$" $scheme://$http_host/licenses/gpl3 permanent;

location ~ ^/blog$ {
    if ($args ~ "^format=rss$") {
        set $args "";
        rewrite ^.*$  http://feeds.feedburner.com/OhlohMeta permanent;
    }
    if ($args = '') {
        rewrite ^.*$  https://community.synopsys.com/s/black-duck-open-hub permanent;
    }
}
