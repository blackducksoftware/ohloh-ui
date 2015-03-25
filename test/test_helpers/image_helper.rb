def write_to_file(result_blob, extension = '.jpg')
  result_file = Tempfile.new(['widget', extension])
  File.binwrite(result_file.path, result_blob)
  result_file
end

def compare_images(result_file_path, expected_image_path)
  tempfile = Tempfile.new('compare-results')
  comparision_command = "compare -metric RMSE #{ result_file_path } #{ expected_image_path } null:"
  # MiniMagick::Tool::Compare does not play well with redirection operator.
  system("#{ comparision_command } 2> #{ tempfile.path }")
  tempfile.read.must_equal "0 (0)\n"
end
