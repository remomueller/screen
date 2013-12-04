## 0.9.7 (December 4, 2013)

### Enhancements
- **Gem Changes**
  - Updated to rails 4.0.2
  - Updated to contour 2.2.0.rc2
  - Updated to kaminari 0.15.0
  - Updated to coffee-rails 4.0.1
  - Updated to sass-rails 4.0.1
  - Updated to simplecov 0.8.2
  - Updated to mysql 0.3.14
- Removed support for Ruby 1.9.3

## 0.9.6 (September 3, 2013)

### Enhancements
- **General Changes**
  - The interface now uses [Bootstrap 3](http://getbootstrap.com/)
  - Gravatars added for users
  - Reorganized Menu
  - Reward modified for completing 150 baseline visits
  - Simplified patient search typeahead
- **Gem Changes**
  - Updated to contour 2.1.0.rc
  - Updated to mysql 0.3.13

## 0.9.5 (July 9, 2013)

### Enhancements
- Use of Ruby 2.0.0-p247 is now recommended
- **Gem Changes**
  - Updated to rails 4.0.0

## 0.9.4 (June 24, 2013)

### Bug Fix
- Fixed another reference to image files

## 0.9.3 (June 24, 2013)

### Bug Fix
- Fixed reference to image files

## 0.9.2 (June 24, 2013)

### Enhancements
- Added reward for completing 150 baseline visits
- **Gem Changes**
  - Updated to rails 4.0.0.rc2

## 0.9.1 (June 7, 2013)

### Enhancements
- Use of Ruby 2.0.0-p195 is now recommended
- **Gem Changes**
  - Updated to rails 4.0.0.rc1
  - Updated to contour 2.0.0.beta.8

## 0.9.0 (April 10, 2013)

### Enhancements
- MRN organization added to patients
- Prescreens inline editing has been removed
- **Gem Changes**
  - Updated to Rails 4.0.0.beta1
  - Updated to Contour 2.0.0.beta.4

## 0.8.9 (March 20, 2013)

### Enhancements
- Use of Ruby 2.0.0-p0 is now recommended

## 0.8.8 (February 14, 2013)

### Security Fix
- Updated Rails to 3.2.12
- Updated Contour to 1.1.3

### Enhancements
- ActionMailer can now be configured to use the NTLM protocol used by Microsoft Exchange Server

## 0.8.7 (February 7, 2013)

### Enhancements
- Number of total Baseline Visits reduced to 150, down from 180
- Mailing index now automatically filters to "potentially eligible" patients
- Contact list can now be generated from patients who have had visits
- Contact information now includes an email
- Acceptable Use Policy added

### Bug Fix
- Switching Administration Type should no longer cause an IE7 JavaScript error

## 0.8.6 (January 8, 2013)

### Security Fix
- Updated Rails to 3.2.11

## 0.8.5 (January 4, 2013)

### Enhancements
- Updated to Contour 1.1.2, using Contour as pagination theme

### Bug Fix
- Evaluations with AHI now accept two digits after the decimal

## 0.8.4 (January 3, 2013)

### Security Fix
- Updated Rails to 3.2.10

### Enhancements
- Use new Task Tracker 0.24.0 API when creating new groups

### Bug Fix
- User activation emails are no longer sent out when a user's status is changed from pending to inactive

## 0.8.3 (November 27, 2012)

### Enhancements
- Gem updates including Rails 3.2.9 and Ruby 1.9.3-p327
- Patient search now uses Select2 JavaScript plugin
- Updated to Contour 1.1.1 and replaced inline JavaScript with Unobtrusive JavaScript

## 0.8.2 (August 13, 2012)

### Enhancements
- Updated to Rails 3.2.8

## 0.8.1 (July 31, 2012)

### Enhancements
- Using unassigned => 1 for JSON request for stickies from Task Tracker
- Simplified labels for doctor type on bulk mailing import page
- Updated to Rails 3.2.7
  - Removed deprecated use of update_attribute for Rails 4.0 compatibility

### Testing
- Use ActionDispatch for Integration tests instead of ActionController

## 0.8.0 (July 17, 2012)

### Enhancements
- Mailing Changes:
  - Imports using Subject Codes instead of MRNs available
  - Imports now require the doctor type to be specified
- Email Changes:
  - Default application name is now added to the from: field for emails
  - Email subjects no longer include the application name
- Patients can now be filtered using comma-separated subject codes
- About page reformatted to include links to github and contact information

### Refactoring
- Mass-assignment attr_accessible and params slicing implemented to leverage Rails 3.2.6 configuration defaults
- Consistent sorting and display of model counts used across all objects, (calls, clinics, doctors, mailings, users, etc)

### Bug Fix
- Sticky requests from Task Tracker now correctly include stickies for Phone Calls and Visits that are unassigned

## 0.7.10 (July 2, 2012)

### Bug Fix
- Removed quiet_assets code as it was causing issues with Rails 3.2.6

## 0.7.9 (June 26, 2012)

### Enhancements
- CSV Exports added for:
  - Calls: Patient ID, Subject Code, Call Time, Call Type, Response, Participation, Exclusion, Berlin, ESS, Eligibility, Direction, Comments
  - Mailings: Patient ID, Subject Code, Sent Date, Response Date, Berlin, ESS, Eligibility, Participation, Exclusion, Comments
  - Evaluations: Patient ID, Subject Code, Administration Type, Evaluation Type, Source, Administration Date, Receipt Date, Scored Date, AHI, Eligibility, Exclusion, Status, Comments
  - Visits: Patient ID, Subject Code, Visit Type, Visit Date, Outcome, Comments
- Mailings can be filtered by response date
- Evaluations can be filtered by receipt date, scored date, administration type, and evaluation type
- Data dictionary export updated to include majority of models

## 0.7.8 (June 21, 2012)

### Enhancements
- Update to Rails 3.2.6 and Contour 1.0.2
- Links with confirm: now use data: { confirm: } to account for deprecations in Rails 4.0

## 0.7.7 (June 11, 2012)

### Enhancements
- Visits can be filtered by visit type
- Searching by phone number now returns results for patients, prescreens, mailings, calls, evaluations, and visits
- Mailing comments are now displayed in the participant timeline, consistent with other event types
- Creator of an event is now displayed on the participant timeline in the event details
- PHI Access role added to grant de-identified access to retrieve aggregate counts

### Bug Fix
- User is now a required field for clinics, doctors, choices, patients, prescreens, mailings, calls, evaluations, and visits

## 0.7.6 (June 6, 2012)

### Enhancements
- Update to Rails 3.2.5 and Contour 1.0.1
- Use Ruby 1.9.3-p194

## 0.7.5 (May 24, 2012)

### Bug Fix
- Timeouts no longer cause an error when trying to login again

## 0.7.4 (May 21, 2012)

### Enhancements
- Prescreen and Mailing Bulk Imports will now automatically preprend leading zeros to MRNs under the 8-digit length

### Bug Fix
- MRNs are now required to have 8 digits, and be zero-padded

## 0.7.3 (May 9, 2012)

### Enhancements
- Call Creator is now listed in the participant timeline and on the call show page
- Calls can now be filtered and sorted by response

## 0.7.2 (May 8, 2012)

### Bug Fix
- Prescreens, Mailings, Calls, Evaluations, and Visits no longer display if the associated patient has been deleted

## 0.7.1 (May 4, 2012)

### Bug Fix
- Fix Registration page to use new Contour login attributes

## 0.7.0 (April 30, 2012)

### Enhancements
- Using Contour 1.0.0 with Twitter-Bootstrap CSS and JS

### Bug Fix
- Spinning icon no longer shows indefinitely on participants without subject code

## 0.6.1 (April 19, 2012)

### Enhancements
- Calls can now be filtered by the user making the call
- Mailings can be filtered to exclude any mailings that have participants ineligibile from a call, evaluation, or prescreen
- Dates can now be entered in either mm/dd/yy or mm/dd/yyyy format

### Bug Fix
- Prescreens now require a visit date and time in order to display correctly on the participant timeline

## 0.6.0 (April 13, 2012)

### Enhancements
- Call comments are now also added to a Task Tracker group description
- Choices can now be set to only show specific fields for different call types
- Choices can now be set to only show specific fields for different evaluation administration types
- Task Tracker stickies are now integrated on the Patient Timeline
- Update to Rails 3.2.3

### Bug Fix
- Fixed minor graphical menu bug for subject handlers

## 0.5.0 (March 30, 2012)

### Enhancements
- Call creation integration with Task Tracker Templates
  - Selecting templates displays the stickies that will be generated
- Mailings
  - Bulk Import from spreadsheet now available
- Prescreens
  - Bulk Import moved to its own page, now availabe as a submenu item under Prescreens
  - Can be filtered by patients who have not had a call
- Date filters added for Prescreens, Mailings, Calls, Evaluations, and Visits
- Doctors, Clinics, and Choices GUI Updated
- Patient Demographics displays aggregated ESS and Berlin scores from Calls and Mailings
- Patients index filterable by priority message
- Update to Rails 3.2.3.rc2

## 0.4.0 (March 23, 2012)

### Enhancements
- Searching on index pages now uses autocomplete
- Patient events now displayed as a timeline

## 0.3.0 (March 20, 2012)

### Enhancements
- Subject Handler Role Added:
  - Can View, Create, Update, and Delete: Prescreens, Mailings, Calls, Evaluations, and Visits for Patients with Subject Codes
- Patients list cleaned up
- Mailings now include Risk Factors
- Visits and Evaluations lists are now sortable
- Overall visit progress bar added to dashboard
- Patient events now display only the date for certain events (Mailings, Evaluations, and Visits)
- Priority Followup added to allow filtering by patients who require immediate followup based on event criteria

## 0.2.1 (March 9, 2012)

### Bug Fix
- Changed AHI to a decimal instead of an integer

## 0.2.0 (March 9, 2012)

### Enhancements
- Evaluations have been added to track:
  - Administration Types:
    - Emblettas
    - Lab PSGs
    - Run-Ins
  - Evaluation Type:
    - Screening
    - Final Visit
- Visits have been added
  - Visit Type
  - Visit Outcome
  - Visit Date
- Patients can now be identified using study codes or MRNs
- Phone Calls Updated
  - Phone Call Type
    - Screening
    - [2,4,6,8,10,12]-month
    - Unscheduled
  - Phone Direction
    - Incoming, Outgoing
  - Call Response now based on preset choices

## 0.1.0 (March 2, 2012)

### Enhancements
- Prescreen management
  - Inline editing of eligibility, risk factors, and exclusion criteria
  - Bulk import from tab-delimited spreadsheets automatically filtered
    - By customized age range
    - By white- or black-listed doctors and clinics
- Patient Study Management
  - Calls made to ascertain study eligibility
  - Mailings sent and received
- Reporting
  - Patient-Event model stored as star schema for easier reporting and extensibility
  - Simple Site Overview with basic statistics on number of prescreens, calls, and mailings
- Security
  - PHI separated from study management data and accessible only by screeners entering the data
  - Patient list is masked and only accessible by the screener
  - Patient-Event joins use internal ID, references to patient model use de-identified and scrambled id

## 0.0.0 (February 22, 2012)

- Skeleton files to initialize Rails application with testing framework and continuous integration
