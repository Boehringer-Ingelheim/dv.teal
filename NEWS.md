# dv.teal 2.1.1
- Change checkmate check to be able to deal with the newly introduced transformators argument in {teal.modules.clinical}(version 0.10.0) 

# dv.teal 2.1.0
- GitHub release
- remove deprecated functions

# dv.teal 2.0.1
- bug fix: app crashed after dataset switch with new version of {dv.manager}(version 2.1.4) and {dv.filter}(version 3.0.2)

# dv.teal 2.0.0 
- add generic wrapper function called mod_teal()
- set module specific wrapper functions to deprecated 

# dv.teal 1.1.0

#### New features:

- add wrapper function for teal.osprey::tm_g_butterfly()   

#### Bugfixes:  

- add missing parameter event_type to wrapper function for teal.modules.clinical::tm_t_events()

# dv.teal 1.0.1

- adapt wrapper functions to use `teal_data`

# dv.teal 1.0.0

- initial version of dv.teal
- contains wrapper functions for the teal modules teal.modules.clinical::tm_t_events() and teal.modules.clinical::tm_t_summary()
