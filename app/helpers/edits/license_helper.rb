module Edits::LicenseHelper
  private

  def edit_values_license(edit)
    return unless edit.target.is_a?(License)
    edit_values_license_create(edit)
  end

  def edit_values_license_create(edit)
    { new: { text: edit.target.name,
             href: license_url(edit.target) } } if edit.is_a?(CreateEdit)
  end
end
