# frozen_string_literal: true

require 'ipaddr'
require 'resolv'
require 'uri'

# rubocop:disable Metrics/ModuleLength
module SsrfUrlValidator
  extend ActiveSupport::Concern

  # Major known code-hosting forges (from production data).
  # SCM-prefix subdomains (git.*, svn.*, hg.*, etc.) and domain suffixes
  # (*.googlesource.com, *.sf.net) are handled by pattern matching below.
  ALLOWED_HOSTS = %w[
    github.com
    gitlab.com
    bitbucket.org
    gitee.com
    codeberg.org
    pagure.io
    repo.or.cz
    framagit.org
    gitea.com
    gist.github.com
    gitcode.com
    launchpad.net
    code.launchpad.net
    bazaar.launchpad.net
    gopkg.in
    pkg.re
    edugit.org
    src.fedoraproject.org
    pkgs.fedoraproject.org
    invent.kde.org
    gitlab.gnome.org
    gitlab.freedesktop.org
    salsa.debian.org
    git.eclipse.org
    git.openstack.org
    git.sr.ht
    gerrit.wikimedia.org
    svn.apache.org
    gitbox.apache.org
    plugins.svn.wordpress.org
    hg.tryton.org
    source.sakaiproject.org
    source.puri.sm
    code.ros.org
    gitlab.riscosopen.org
    gitlab.eclipse.org
    gitlab.exherbo.org
    dev.eclipse.org
    subversion.assembla.com
    svn2.assembla.com
  ].to_set.freeze

  # Any subdomain with these prefixes is treated as a legitimate SCM host
  # (e.g. git.company.com, svn.university.edu, gerrit.project.org).
  # Combined with private IP blocking this prevents SSRF to internal hosts
  # while supporting self-hosted instances.
  ALLOWED_SCM_SUBDOMAINS = %w[git svn hg cvs gerrit scm anongit anonsvn bzr src].freeze

  # All subdomains of these hosting platforms are legitimate.
  ALLOWED_HOST_SUFFIXES = %w[
    .googlesource.com
    .sf.net
    .sourceforge.net
    .assembla.com
  ].freeze

  ALLOWED_SCM_SCHEMES = %w[http https git svn bzr].freeze

  PRIVATE_RANGES = [
    IPAddr.new('127.0.0.0/8'),
    IPAddr.new('10.0.0.0/8'),
    IPAddr.new('172.16.0.0/12'),
    IPAddr.new('192.168.0.0/16'),
    IPAddr.new('169.254.0.0/16'),
    IPAddr.new('0.0.0.0/8'),
    IPAddr.new('100.64.0.0/10'),
    IPAddr.new('::1/128'),
    IPAddr.new('fc00::/7'),
    IPAddr.new('fe80::/10')
  ].freeze

  PSERVER_PATTERN = /\A:?pserver:[^@]*@([^:\/]+)/i
  GIT_SCP_PATTERN = /\Agit@([^:]+):/i

  def safe_repo_url?(url_string)
    return false if url_string.blank?

    url = url_string.to_s.strip
    return true if url.start_with?('lp:')

    host = repository_host(url)
    return false if host.blank?

    allowed_host?(host) && !private_host?(host)
  end

  private

  def repository_host(url)
    match = PSERVER_PATTERN.match(url)
    return match[1] if match

    match = GIT_SCP_PATTERN.match(url)
    return match[1] if match

    uri = URI.parse(url)
    return unless ALLOWED_SCM_SCHEMES.include?(uri.scheme&.downcase)

    uri.host
  rescue URI::InvalidURIError
    false
  end

  def allowed_host?(host)
    return false if host.blank?

    h = host.downcase.strip

    return true if ALLOWED_HOSTS.include?(h)
    return true if ALLOWED_HOST_SUFFIXES.any? { |suffix| h.end_with?(suffix) }

    parts = h.split('.')
    parts.length >= 3 && ALLOWED_SCM_SUBDOMAINS.include?(parts.first)
  end

  def private_host?(host)
    begin
      return private_ip?(IPAddr.new(host))
    rescue IPAddr::InvalidAddressError
      # hostname, not a raw IP — fall through to DNS resolution
    end

    addrs = Resolv.getaddresses(host)
    return true if addrs.empty?

    addrs.any? { |a| private_ip?(IPAddr.new(a)) }
  rescue Resolv::ResolvTimeout, Resolv::ResolvError
    true # fail closed on DNS errors
  end

  def private_ip?(ip)
    PRIVATE_RANGES.any? { |range| range.include?(ip) }
  end
end
# rubocop:enable Metrics/ModuleLength
