xml.instruct!
xml.response do
  xml.status 'failed'
  xml.error t('.message', name: @project.name)
end
