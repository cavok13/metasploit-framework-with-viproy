# -*- coding: binary -*-

module Msf::HTTP::Wordpress::Base
  # Checks if the site is online and running wordpress
  #
  # @return [Rex::Proto::Http::Response,nil] Returns the HTTP response if the site is online and running wordpress, nil otherwise
  def wordpress_and_online?
    wordpress_detect_regexes = [
        /["'][^"']*\/#{Regexp.escape(wp_content_dir)}\/[^"']*["']/i,
        /<link rel=["']wlwmanifest["'].*href=["'].*\/wp-includes\/wlwmanifest\.xml["'] \/>/i,
        /<link rel=["']pingback["'].*href=["'].*\/xmlrpc\.php["'](?: \/)*>/i
    ]

    res = send_request_cgi(
        'method' => 'GET',
        'uri' => normalize_uri(target_uri.path)
    )

    # handle one redirect
    if res && res.redirect? && res.redirection
      res = send_request_cgi(
      'method' => 'GET',
      'uri' => path_from_uri(res.redirection)
      )
    end

    return res if res && res.code == 200 && res.body && wordpress_detect_regexes.any? { |r| res.body =~ r }
    return nil
  rescue ::Rex::ConnectionRefused, ::Rex::HostUnreachable, ::Rex::ConnectionTimeout => e
    print_error("#{peer} - Error connecting to #{target_uri}: #{e}")
    return nil
  end
end
