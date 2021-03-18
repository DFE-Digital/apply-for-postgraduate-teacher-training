require.context("govuk-frontend/govuk/assets");

import { initAll as govUKFrontendInitAll } from "govuk-frontend";
import initWarnOnUnsavedChanges from "./warn-on-unsaved-changes";
import {initAutocomplete} from "./autocompletes/init-autocomplete";
import {initAutosuggest} from "./autosuggests/init-autosuggest";
import {candidateAutocompleteInputs} from "./autocompletes/candidate/candidate-autocomplete-inputs";
import {candidateAutosuggestInputs} from "./autosuggests/candidate/candidate-autosuggest-inputs";
import nationalitiesComponent from "./nationalities-component";
import initBackLinks from "./app-back-link";
import "accessible-autocomplete/dist/accessible-autocomplete.min.css";
import "../styles/application-candidate.scss";

govUKFrontendInitAll();

candidateAutocompleteInputs.forEach((autocompleteInput) => {
  initAutocomplete(autocompleteInput)
});

candidateAutosuggestInputs.forEach((autoSuggestInput) => {
  initAutosuggest(autoSuggestInput)
})

initWarnOnUnsavedChanges();
nationalitiesComponent();
initBackLinks();
