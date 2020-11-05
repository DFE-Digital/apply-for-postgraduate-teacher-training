### 9th November 2020

New attributes:

- `Course` now has a `start_date` attribute giving the month and year the
  course begins

### 23rd October 2020

New attributes:

- `ApplicationAttributes` now has a `recruited_at` attribute which will contain
  an ISO8601 date for candidates in the `recruited` state.
- `Offer` now has three new date fields: `offer_made_at`, `offer_accepted_at` and
  `offer_declined_at`.
- `Reference` now has two new fields: an enum `referee_type` and a boolean
  `safeguarding_concerns`
- `Qualification` now has a free text field `non_uk_qualification_type` which
  is populated in the event the qualification type is `non_uk`

### 8th October 2020

New attributes:

- `Candidate` now has a `domicile` attribute of type string, returning a two-letter country code (ISO 3166-2). Its value is derived from the candidate's address.
- `Qualification` now includes attributes for HESA qualification codes, if the qualification is degree-level. The attributes are: `hesa_degtype`, `hesa_degsbj`, `hesa_degclss`, `hesa_degest`, `hesa_degctry`, `hesa_degstdt`, `hesa_degenddt`.

Changes to existing attributes:

- The `equivalency_details` attribute of `Qualification` will now contain a NARIC code and its description, if these are avalailable. Example: 'Naric: 4000123456 - Between GCSE and GCSE AS Level - Equivalent to GCSE C'

### 5th October 2020

Changes to existing attributes:

- clarify that `hesa_itt_data` will be populated once an offer has been
  accepted. (Previously it was following enrolment, but enrolment has been
  removed).

### 29th September 2020

New attributes:

- `Reference` now has a unique `id` attribute of type integer to assist with tracking of reference changes.

### 16th September 2020

Changes to existing attributes:

- Increase the limit of elements in the `nationality` array to 5. Nationalities are sorted so British or Irish are first.
- `uk_residency_status` now returns strings indicating candidate's right to work and study in the UK

### 15th September 2020

Changes to existing attributes:

- Maximum length of `address_line1` increased to 200 characters to account for international addresses.

### 9th September 2020

- fix a bug with test data generation where provider names in qualifications
were strings like `#<struct HESA::Institution::InstitutionStruct...>`

### 1st September 2020

- Deprecate the `enrolled` state which will not be part of the Apply service
- Deprecate the `enrol` endpoint which will now simply return the application unchanged
- Remove mentions of enrolment from the API documentation

### 28th August 2020

New attributes:

- `Application` now has a `safeguarding_issues_status` attribute of type string and an optional `safeguarding_issues_details_url` attribute of type string.

### 24th August 2020

- Fix a bug where the study mode of a chosen or offered course appeared as
  "full_or_part_time" instead of "full_time" or "part_time" as appropriate.

### 10th August 2020

- `POST /application/:id/offer` is now idempotent and will continue to return 200
if the same offer details are POSTed repeatedly
- `POST /application/:id/offer` now supports changing the conditions on an offer
while retaining the original offered course. Previously this returned a 422 error
saying it was necessary to offer a different course.
- Deprecate `Withdrawal.reason`, which was supposed to hold a candidate’s reason for
withdrawing their application. The Apply service will not collect this information

### 7th July 2020

Documentation has been amended to emphasise the stability of `/applications` endpoints
in contrast to the `/test-data` endpoints.

Experimental endpoints have also been updated:

- `/test-data/regenerate` endpoint has been deactivated. The response contains an explanatory error message.
- `/experimental/test-data/*` endpoints moved to `/test-data/*` and POST requests to the old paths return 410 status with a message detailing the new location.

### 2nd July 2020

The documentation around the `/offer` endpoint has been clarified to show that:

- it is possible to change the offer by POSTing to that endpoint again
- for the time being, a changed offer must have a changed course, not just changed conditions

### 30th June 2020

New attributes:

- `Rejection` now has a `date` attribute of type string.

### 24th June 2020

Changes to existing attributes:

- `ContactDetails` attributes `address_line1`, `address_line2`, `address_line3` and `postcode` are no longer required attributes.

### 16th June 2020

Sandbox changes:

- Sandbox no longer sends emails to providers about application state changes

### 15th June 2020

New attributes:

- `Qualification` now has a `start_year` attribute of type string.

### 9th June 2020

New attributes:

- `ApplicationAttributes` now has a `support_reference` attribute of type string.

### 20th May 2020

Corrections to documentation

- The Application lifecycle incorrectly stated that candidates have 5 days to respond to offers. This has been amended to 10 days.
- Clarify that we use the two-letter version of ISO 3166, ISO 3166-2, for country codes.

### 11th February 2020

New attributes:

- `Rejection` now includes offer withdrawal reasons

### 10 February 2020

- Add minimum of 1 to `courses_per_application` field for [`test-data/generate`](/experimental/test-data/generate). Stops test application data being generated that have zero courses per application.

### 5th February 2020

Field lengths updated:

- free text coming from inline inputs is standardised to 256 chars
- free text coming from textareas is standardised to 10240 chars (allowing room for over 1000 words)

### 28th January 2020

New attributes:

- `WorkExperience` now has a unique `id` attribute of type integer.
- `Qualification` now has a unique `id` attribute of type integer.

### 14th January 2020

- Introduce `missing_gcses_explanation` field to [`qualifications`](/api-docs/reference#qualifications-object). This contains the candidate’s explanation for any missing GCSE (or equivalent) qualifications.

### 7th January 2020

- Correct size of [`personal_statement`](/api-docs/reference#applicationattributes-object) field to 11624 chars
- Introduce `work_history_break_explanation` field to [`work_experience`](/api-docs/reference#workexperiences-object). This contains the candidate’s explanation for any breaks in work history.

### v1.0 — 18th December 2019

Initial release of the API.

For a log of pre-release changes, [see the alpha release notes](/api-docs/alpha-release-notes).
