modalId = '#stack-entries-modal'

$(modalId).remove()  # remove any previous modals.

$('body').append("<%=j render('modal') %>")

$(modalId).modal('show')

App.StackEntryCheckboxes.setup $('.stack-checkbox-container input:checkbox')
