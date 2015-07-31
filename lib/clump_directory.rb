module ClumpDirectory
  module_function

  def path(code_set_id)
    return unless code_set_id
    j = code_set_id.to_s.rjust(12, "0")
    "#{ DIRECTORY }/#{ j[0..2] }/#{ j[3..5] }/#{ j[6..8] }/#{ j[9..-1] }"
  end

  def code_set_ids
    return [] unless File.exist?(Clump::DIRECTORY + '/000')
    run_on_clump_machine("find #{ Clump::DIRECTORY }/000 -maxdepth 3 -mindepth 3")
      .split.map { |path| find_code_set_id(path) }.compact
  end

  private

  module_function

  def find_code_set_id(path)
    return unless path =~ /\/(\d\d\d)\/(\d\d\d)\/(\d\d\d)\/?$/
    $3.to_i + $2.to_i * 1000 + $1.to_i * 1000000
  end
end
