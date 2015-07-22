class SvnClump < Clump

	def scm_class
		OhlohScm::Adapters::SvnChainAdapter
	end

	def url
		if self.slave.local?
			"file://#{self.path}"
		else
			"svn+ssh://#{self.slave.hostname}#{self.path}"
		end
	end
end
