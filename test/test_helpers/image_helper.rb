# frozen_string_literal: true

def write_to_file(result_blob, extension = '.jpg')
  result_file = Tempfile.new(['widget', extension])
  File.binwrite(result_file.path, result_blob)
  result_file
end

def compare_images(result_file_path, expected_image_path, allowed_diff = 0.0)
  tempfile = Tempfile.new('compare-results')
  comparision_command = "compare -metric RMSE #{result_file_path} #{expected_image_path} null:"
  # MiniMagick::Tool::Compare does not play well with redirection operator.
  system("#{comparision_command} 2> #{tempfile.path}")
  diff = /\((.+)\)/.match(tempfile.read)[1].to_f
  # Slight font rendering differences are acceptable.
  _(diff < allowed_diff).must_equal true, "Images differed by #{diff} while only #{allowed_diff} allowed"
end
