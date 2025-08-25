#! /usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/environment'
require 'logger'

class GenerateMissingTinyLogos
  def initialize
    @log = Logger.new('log/missing_tiny_logos.log')
    @options = { bucket: ENV.fetch('OHLOH_S3_BUCKET_NAME', nil), acl: :public_read }
    @tiny_image_count = 0
    @original_image_count = 0
  end

  def execute
    Logo.joins('inner join projects on projects.logo_id = attachments.id').uniq.find_each do |logo|
      unless logo.attachment.exists?(:tiny)
        @log.info "Generating tiny image for Logo #{logo.id}."
        create_original_logo(logo.attachment) if logo.attachment.exists?
        logo.attachment.reprocess!(:tiny)
        @tiny_image_count += 1
      end
    end
    @log.info "Generated #{@tiny_image_count} tiny images and #{@original_image_count} original images."
  end

  private

  def create_original_logo(attachment)
    source_obj = attachment.s3_object
    target_obj = attachment.s3_object(:original)
    source_obj.copy_to(target_obj, @options)
    @original_image_count += 1
  end
end

GenerateMissingTinyLogos.new.execute
