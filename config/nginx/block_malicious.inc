# These requests are almost always malicious and do not match any content we host.
location ~* (\.php$|\.php/) {}
location ~* \+s\.src\+ {}
