# frozen_string_literal: true

require 'test_helper'

class SsrfUrlValidatorTest < ActiveSupport::TestCase
  # Minimal host that includes the concern under test
  class DummyHost
    include SsrfUrlValidator
    public :safe_repo_url?
  end

  setup do
    @v = DummyHost.new
    # Default: all hostnames resolve to a public IP unless stubbed otherwise
    Resolv.stubs(:getaddresses).returns(['140.82.121.4']) # github.com-like
  end

  # --- blank / nil ---

  it 'rejects nil' do
    _(@v.safe_repo_url?(nil)).must_equal false
  end

  it 'rejects blank string' do
    _(@v.safe_repo_url?('')).must_equal false
  end

  # --- lp: shorthand ---

  it 'allows lp: shorthand (no hostname; FIS resolves against launchpad.net)' do
    _(@v.safe_repo_url?('lp:busybox')).must_equal true
  end

  # --- allowed schemes ---

  it 'allows https://github.com repo' do
    _(@v.safe_repo_url?('https://github.com/rails/rails.git')).must_equal true
  end

  it 'allows http:// repo on known forge' do
    _(@v.safe_repo_url?('http://github.com/user/repo')).must_equal true
  end

  it 'allows git:// on known forge' do
    _(@v.safe_repo_url?('git://github.com/user/repo.git')).must_equal true
  end

  it 'allows svn:// on allowed host' do
    _(@v.safe_repo_url?('svn://svn.apache.org/repos/asf/project')).must_equal true
  end

  it 'allows bzr:// on known forge' do
    _(@v.safe_repo_url?('bzr://bazaar.launchpad.net/project')).must_equal true
  end

  # --- blocked schemes ---

  it 'blocks file:// scheme' do
    _(@v.safe_repo_url?('file:///etc/passwd')).must_equal false
  end

  it 'blocks gopher:// scheme' do
    _(@v.safe_repo_url?('gopher://attacker.com/')).must_equal false
  end

  it 'blocks ftp:// scheme' do
    _(@v.safe_repo_url?('ftp://github.com/repo')).must_equal false
  end

  it 'blocks dict:// scheme' do
    _(@v.safe_repo_url?('dict://attacker.com/d:word')).must_equal false
  end

  # --- private IP blocking ---

  it 'blocks http://127.0.0.1' do
    _(@v.safe_repo_url?('http://127.0.0.1/repo')).must_equal false
  end

  it 'blocks http://localhost' do
    Resolv.stubs(:getaddresses).returns(['127.0.0.1'])
    _(@v.safe_repo_url?('http://localhost/repo')).must_equal false
  end

  it 'blocks http://10.0.0.1' do
    _(@v.safe_repo_url?('http://10.0.0.1/admin')).must_equal false
  end

  it 'blocks http://192.168.1.1' do
    _(@v.safe_repo_url?('http://192.168.1.1/')).must_equal false
  end

  it 'blocks AWS metadata endpoint 169.254.169.254' do
    _(@v.safe_repo_url?('http://169.254.169.254/latest/meta-data/')).must_equal false
  end

  it 'blocks http://172.16.0.1 (RFC1918)' do
    _(@v.safe_repo_url?('http://172.16.0.1/')).must_equal false
  end

  it 'blocks hostname resolving to private IP' do
    Resolv.stubs(:getaddresses).with('internal.corp').returns(['10.0.0.50'])
    _(@v.safe_repo_url?('https://internal.corp/repo')).must_equal false
  end

  it 'fails closed when DNS resolution fails' do
    Resolv.stubs(:getaddresses).raises(Resolv::ResolvError)
    _(@v.safe_repo_url?('http://git.unknown-host.example/repo')).must_equal false
  end

  # --- hostname allowlist ---

  it 'allows gitlab.com' do
    _(@v.safe_repo_url?('https://gitlab.com/user/project')).must_equal true
  end

  it 'allows bitbucket.org' do
    _(@v.safe_repo_url?('https://bitbucket.org/user/project')).must_equal true
  end

  it 'allows *.googlesource.com (domain suffix pattern)' do
    _(@v.safe_repo_url?('https://android.googlesource.com/platform/build')).must_equal true
  end

  it 'allows *.sf.net (SourceForge subdomain)' do
    _(@v.safe_repo_url?('https://svn.code.sf.net/p/project/code')).must_equal true
  end

  it 'blocks random unknown host' do
    _(@v.safe_repo_url?('https://randomsite.example.com/repo')).must_equal false
  end

  it 'blocks attacker.com even though scheme is https' do
    _(@v.safe_repo_url?('https://attacker-burp-collaborator.com/payload')).must_equal false
  end

  # --- SCM subdomain prefix pattern ---

  it 'allows git.company.com (SCM subdomain prefix, public IP)' do
    Resolv.stubs(:getaddresses).with('git.company.com').returns(['1.2.3.4'])
    _(@v.safe_repo_url?('https://git.company.com/repo.git')).must_equal true
  end

  it 'allows svn.university.edu (SCM subdomain prefix, public IP)' do
    Resolv.stubs(:getaddresses).with('svn.university.edu').returns(['203.0.113.5'])
    _(@v.safe_repo_url?('svn://svn.university.edu/project')).must_equal true
  end

  it 'blocks git.internal.corp (SCM prefix but resolves to private IP)' do
    Resolv.stubs(:getaddresses).with('git.internal.corp').returns(['10.0.0.10'])
    _(@v.safe_repo_url?('https://git.internal.corp/repo')).must_equal false
  end

  it 'blocks git.evil.internal (SCM prefix, private IP)' do
    Resolv.stubs(:getaddresses).with('git.evil.internal').returns(['192.168.0.1'])
    _(@v.safe_repo_url?('http://git.evil.internal/repo')).must_equal false
  end

  # --- CVS pserver format ---

  it 'allows valid pserver URL with public host' do
    Resolv.stubs(:getaddresses).with('cvs.savannah.gnu.org').returns(['209.51.188.20'])
    _(@v.safe_repo_url?(':pserver:anonymous:@cvs.savannah.gnu.org:/sources/gv')).must_equal true
  end

  it 'blocks pserver URL with private host IP' do
    _(@v.safe_repo_url?(':pserver:anonymous:@10.0.0.5:/cvsroot/project')).must_equal false
  end

  it 'blocks pserver URL with hostname resolving to private IP' do
    Resolv.stubs(:getaddresses).with('internal-cvs.corp').returns(['172.20.0.5'])
    _(@v.safe_repo_url?(':pserver:user:pass@internal-cvs.corp:/cvsroot/repo')).must_equal false
  end

  # --- git SCP-style SSH ---

  it 'allows git@github.com:user/repo.git' do
    Resolv.stubs(:getaddresses).with('github.com').returns(['140.82.121.4'])
    _(@v.safe_repo_url?('git@github.com:user/repo.git')).must_equal true
  end

  it 'blocks git@10.0.0.1:repo.git (raw private IP)' do
    _(@v.safe_repo_url?('git@10.0.0.1:repo.git')).must_equal false
  end

  it 'blocks git@internal.server:repo.git (resolves to private IP)' do
    Resolv.stubs(:getaddresses).with('internal.server').returns(['192.168.1.5'])
    _(@v.safe_repo_url?('git@internal.server:repo.git')).must_equal false
  end
end
