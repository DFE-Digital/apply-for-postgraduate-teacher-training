require.context("govuk-frontend/govuk/assets");

import { initAll as govUKFrontendInitAll } from "govuk-frontend";
import initApiTokenProviderAutocomplete from "./autocompletes/api-token-autocomplete";
import "../styles/application-support.scss";
import filter from "./components/paginated_filter";
import "accessible-autocomplete/dist/accessible-autocomplete.min.css";

govUKFrontendInitAll();
initApiTokenProviderAutocomplete();
filter();
