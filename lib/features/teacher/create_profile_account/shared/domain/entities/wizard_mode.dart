/// Why the wizard is open.
///
/// [create] is onboarding: five steps in order, each save advancing to the
/// next, finishing at the dashboard. [edit] is a return visit from the profile
/// screen to change one section: a single step, no timeline, and a save that
/// stays put and pops back.
enum WizardMode { create, edit }
