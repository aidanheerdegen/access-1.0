#!/bin/ksh
#############################################################################
#									    #	
# usage: qsub do_mppncombine.ksh -v sdir=$sdir,tdir=$tdir,idate=$enddate    #
#									    #
#############################################################################
###PBS -q normal
#PBS -q express
#PBS -l mem=2GB
###PBS -q copyq
### --- copyq only allows 1G vmem, not enough for the cmip5 big data! ---
###PBS -l vmem=400MB
#PBS -l walltime=0:10:00
#PBS -l ncpus=1
#PBS -N do-mppncombing
#PBS -l wd
#############################################################################
date
set -e
set -xv

ulimit -s unlimited
ulimit -a

datadir=$sdir
workdir=$tdir
enddate=$idate

echo "datadir $datadir"
echo "workdir $workdir"
echo "enddate $enddate"

cd $workdir

# clean up (in case do_mppncombine failed last time)
badfile=`ls *.nc *.nc.???? | wc -w`
if (( $badfile == 0 )); then
  echo 'Good, no leftover! '
else
  rm *.nc *.nc.????
fi

# there may be some nc files 'ready' (ie, no need for merging), such as scalar.nc
goodncfile=`ls $datadir/*.nc | wc -w`
if (( $goodncfile == 0 )); then
  echo 'No ready nc files!'
else
  mv $datadir/*.nc .
fi
for ncfile in `ls *.nc`; do
  mv $ncfile ${ncfile}-${enddate}
done

mv $datadir/*.nc.???? .

echo "Combining ocean data files with mppnccombine"
# combine netcdf files
for histfile in `ls *.nc.0000`; do
  newfile=${histfile%.*}              #drop the appendix '.0000'!
#  ~dhb599/ACCESS/bin/mppnccombine.XE -v -r $newfile ${newfile}.????
  $mppncombine_exec -v -r $newfile ${newfile}.???? &
done
wait

echo "Moving collated ocean data files to history"
for histfile in `ls ocean*.nc`; do
  mv $histfile ${histfile}-${enddate}
done

#gzip *-${enddate}

#############################################################################
date
${job_account}
exit

