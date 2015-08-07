class Slave::Sync
  delegate :run, to: :@slave

  def initialize
    @slave = Slave.local
  end

  def execute
    @slave.logs.create!(message: I18n.t('slaves.syncing_db', dir: @slave.clump_dir), level: SlaveLog::WARNING)

    destroy_clumps_lacking_code_set_directories
    delete_directories_for_clumps_without_code_set_in_db
    create_missing_clumps_for_code_sets_on_disk
  end

  private

  def destroy_clumps_lacking_code_set_directories
    clumps = Clump.where.not(code_set_id: ClumpDirectory.code_set_ids)
    clumps.each do |clump|
      @slave.logs.create!(message: I18n.t('slaves.clump_not_found', path: ClumpDirectory.path(clump.code_set_id)),
                          code_set_id: clump.code_set_id)
    end
    clumps.delete_all
  end

  def delete_directories_for_clumps_without_code_set_in_db
    code_set_ids_in_db = CodeSet.where(id: ClumpDirectory.code_set_ids).pluck(:id)

    code_set_ids = ClumpDirectory.code_set_ids - code_set_ids_in_db
    code_set_ids.each do |id|
      FileUtils.rm_rf ClumpDirectory.path(id)
      @slave.logs.create!(message: I18n.t('slaves.no_code_set_exists', id: id))
    end
  end

  def create_missing_clumps_for_code_sets_on_disk
    CodeSet.includes(:clump).where(id: ClumpDirectory.code_set_ids).where(clumps: { id: nil }).each do |code_set|
      code_set.find_or_create_clump
      @slave.logs.create!(message: I18n.t('slaves.clump_found', path: ClumpDirectory.path(code_set.id)),
                          code_set_id: code_set.id, level: SlaveLog::WARNING)
    end
  end
end
