class ConvertAttachmentToPaperclip < ActiveRecord::Migration
  def self.up
    change_table :attachments do |attachment|
      attachment.rename :filename, :attachment_file_name
      attachment.rename :size, :attachment_file_size
      attachment.rename :content_type, :attachment_content_type
      attachment.datetime :attachment_updated_at 

      # Removing child thumbnails as its not required for paperclip 
      Attachment.delete_all("parent_id is not null")

      attachment.remove :parent_id, :thumbnail, :width, :height, :is_default
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, "Cannot recover deleted data"
  end
end
