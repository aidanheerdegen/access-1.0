
This repository contains modifed versions of the ACCESS-1.0 RCP 85 runscripts to allow multiple model runs per PBS submit. There are no changes to the date handling in this script so the model runs 3 months at a time.

The main difference in the code is in a10_rcp85_hp.fin, which I have modified to use functions (hence it is sourced at the beginning of the main script and the functions called at the end of the main script).

The main script now runs the model(s) inside a never ending loop, that is broken out of if there is not sufficient wall time remaining to keep running.

The criteria for sufficient wall time remaining is if there is RUN_TIME time left. The RUN_TIME variable is defined in a10_rcp85_hp.init just after the initial and final dates. I have set it to 1:20:00, which is quite conservative, as the model seems to run in 1:12:00 pretty consistently.

I have made it so the script does the ocean data collation inside the fin script, instead of submitting a separate PBS job. The collation only takes a minute or so.

In addition I am using a new version of `mppnccombine` which outputs compressed netCDF4 files. This should greatly reduce the size of the ocean outputs. For example, 3 month's worth of ocean output is 30% of the size:

```
$ du -shc archive/a10_rcp85_hp/history/ocn/ocean_*20170630
115M    archive/a10_rcp85_hp/history/ocn/ocean_daily.nc-20170630
2.4G    archive/a10_rcp85_hp/history/ocn/ocean_gfdl.nc-20170630
2.5G    archive/a10_rcp85_hp/history/ocn/ocean_month.nc-20170630
28K     archive/a10_rcp85_hp/history/ocn/ocean_scalar.nc-20170630
5.0G    total
$ du -shc history/ocn/ocean_*20060331 
47M     history/ocn/ocean_daily.nc-20060331
741M    history/ocn/ocean_gfdl.nc-20060331
725M    history/ocn/ocean_month.nc-20060331
28K     history/ocn/ocean_scalar.nc-20060331
1.5G    total
```

The updated `mppnccombine` new executable is available here

```
/short/e14/aph502/ACCESS/bin/mppnccombine.nc4
```

As it is set up this should run about 10 model years in a single 48 hour submission

