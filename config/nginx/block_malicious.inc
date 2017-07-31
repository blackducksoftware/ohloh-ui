# These requests are almost always malicious and do not match any content we host.

location ~* /trackback {
    limit_except GET {
    deny all;
  }
}

location ~* /similar_by_tags {
    limit_except GET {
    deny all;
  }
}

location ~* /download_notice {
    limit_except GET {
    deny all;
  }
}

location ~* \.(php|exe|src|aspx)$ {
  deny all;
}
