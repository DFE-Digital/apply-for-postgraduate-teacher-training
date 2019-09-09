@candidate @provider @referee
Feature: successful application states

  References pending/Application complete
  =======================================
  Applicants will be able to submit their applications to providers without
  references already being present (the 'references pending' status). Once at least
  one reference has been submitted, the application goes into 'application complete'
  status.

  Offer made & meeting conditions
  ===============================
  A provider makes an offer to the candidate (be it conditional and unconditional).
  The candidate then has to accept the offer, which sets the application status
  to 'meeting conditions'.

  Recruited
  =========
  If the candidate has met all conditions of their offer, the provider marks
  their application as 'recruited'.

  Enrolment
  =========
  Once a candidate has completed the enrolment process, the provider confirms
  their enrolment onto the training programme. Since this status would be used
  to claim bursaries/grants from DfE, the provider may delay enrolling the trainee
  until a few weeks after the start of the training, since trainees can still
  not show up on the first day or drop out within the first couple of weeks.
  This reduces the risk that DfE over-pays that provider for training they didn't
  deliver and having to reconcile or claw back that money later on.

  Background:
    Given the following rules around “reject by default” decision timeframes:
      | application submitted after | application submitted before | # of working days until rejection |
      | 1 Oct 2018 0:00:00          | 15 Sept 2025 23:59:59        | 3                                 |

  Scenario Outline: A successful application changes state depending on candidate, referee and provider actions.
    Given an application in "<original state>" state
    When a <actor> <action>
    Then the new application state is "<new state>"

    Examples:
      | original state        | actor     | action                   | new state                |
      | unsubmitted           | candidate | submit                   | references pending       |
      | references pending    | referee   | submit reference         | application complete     |
      | application complete  | provider  | make unconditional offer | conditional offer        |
      | application complete  | provider  | make unconditional offer | unconditional offer      |
      | conditional offer     | candidate | accept offer             | meeting conditions       |
      | meeting conditions    | provider  | confirm conditions met   | recruited                |
      | unconditional offer   | candidate | accept offer             | recruited                |
      | recruited             | provider  | confirm onboarding       | enrolled                 |
