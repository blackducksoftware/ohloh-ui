class RenameStatusToPublishedInCodeLocationEvents < ActiveRecord::Migration
  def change
    change_table :code_location_events do |t|
      t.rename :status, :published
      t.change :published, :boolean, default: false
    end
  end
end
