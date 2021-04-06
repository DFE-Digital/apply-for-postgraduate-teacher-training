import { initAll as govUKFrontendInitAll } from 'govuk-frontend'
import initWarnOnUnsavedChanges from './warn-on-unsaved-changes'
import filter from './components/paginated_filter'
import checkbox_filter from './components/checkbox_filter'
import '../styles/application-provider.scss'

require.context('govuk-frontend/govuk/assets')

govUKFrontendInitAll()
initWarnOnUnsavedChanges()
filter()
checkbox_filter('#subject', 'Search for subject')
