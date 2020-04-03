##!/usr/local/bin/bash
#!/bin/bash

function check_okay {
	if [ $? -ne 0 ]
	then
		exit 1
	fi
}


export MESA_DIR=/home/tjr63/mesa-r10398
export OMP_NUM_THREADS=12
export MESA_BASE=/home/tjr63/mesaruns
# !!! If you change MESA_BASE you must change the file paths in inlist and condor_wrapper !!!
export MESA_INLIST=$MESA_BASE/inlist
rnmesa=rnMESA_extraC0
export MESA_RUN=$MESA_BASE/RUNS_dmEmoment_condor/${rnmesa}
# logfile=$MESA_BASE/batch_run/logs/${rnmesa}.out
logfile=$MESA_BASE/RUNS_dmEmoment_condor/${rnmesa}.out
cp $MESA_BASE/batch_run/${rnmesa}.sh $MESA_BASE/RUNS_dmEmoment_condor/.

declare -A svals=( [SD]=.TRUE. [SI]=.FALSE. )
declare -a sord=( SD )
declare -A cbvals=( [c0]=0.D0 [c1]=1.D1 [c2]=1.D2 [c3]=1.D3 [c4]=1.D4 [c5]=1.D5 [c6]=1.D6 )
declare -a cord=( c0 )
declare -A mvals=( [m0p83]=0.83D0 [m0p87]=0.87D0 [m0p92]=0.92D0 [m0p94]=0.94D0 [m0p96]=0.96D0 [m0p98]=0.98D0 )
declare -A mints=( [m0p83]=83 [m0p87]=87 [m0p92]=92 [m0p94]=94 [m0p96]=96 [m0p98]=98 )
declare -a mord=( m0p83 m0p87 m0p92 m0p94 m0p96 m0p98 )
# declare -A mvals=( [m4p0]=4.0D0 [m4p1]=4.1D0 [m4p2]=4.2D0 [m4p3]=4.3D0 [m4p4]=4.4D0 [m4p5]=4.5D0 [m4p6]=4.6D0 [m4p7]=4.7D0 [m4p8]=4.8D0 [m4p9]=4.9D0 )
# declare -a mord=( m4p0 m4p1 m4p2 m4p3 m4p4 m4p5 m4p6 m4p7 m4p8 m4p9 )

for spin in "${sord[@]}"; do
    for cdir in "${cord[@]}"; do
		oe=$([ $cdir = c0 ] && echo ".false." || echo ".true.") # use_other_energy_implicit=.false. if c0 else .true.
        for mass in "${mord[@]}"; do
			if [ ${mints[$mass]} -lt  90 ]; then # set max_age depending on mass
				ma=22.D9
			elif [ ${mints[$mass]} -ge  90 ]; then
				ma=15.D9
			else
				ma=13.D9
			fi

            mkdir -pm 777 $MESA_RUN/$spin/$cdir/$mass
            cp $MESA_BASE/batch_run/xinlist_template $MESA_RUN/$spin/$cdir/$mass/inlist_cluster
            check_okay
            cd $MESA_RUN/$spin/$cdir/$mass

            sed -i 's/imass_/'${mvals[$mass]}'/g; s/maxage_/'$ma'/g; s/oenergy_/'$oe'/g; s/cboost_/'${cbvals[$cdir]}'/g; s/SD_/'${svals[$spin]}'/g' inlist_cluster
            check_okay

            $MESA_BASE/star &>> $logfile
            check_okay
			$MESA_BASE/bash_scripts/del_dup_mods.sh $(pwd) &>> $logfile # delete duplicate models
			check_okay

            cd $MESA_RUN
        done
    done
done