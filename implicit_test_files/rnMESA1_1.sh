##!/usr/local/bin/bash
#!/bin/bash

function check_okay {
	if [ $? -ne 0 ]
	then
		exit 1
	fi
}


export MESA_DIR=/home/tjr63/mesa-r9793
export OMP_NUM_THREADS=1
export MESA_BASE=/home/tjr63/implicit_test/impTRUE_c3
# !!! If you change MESA_BASE you must change the file paths in inlist !!!
export MESA_INLIST=$MESA_BASE/inlist
export MESA_RUN=$MESA_BASE/RUNS
#export MESA_RUN=/home/tjr63/sand

declare -A svals=( [SD]=.TRUE. [SI]=.FALSE. )
declare -a sord=( SD )
declare -A cbvals=( [c0]=0.D0 [c1]=1.D1 [c2]=1.D2 [c3]=1.D3 [c4]=1.D4 [c5]=1.D5 [c6]=1.D6 )
declare -a cord=( c3 )
# run the rest of cbvals later
declare -A mvals=( [m1p0]=1.0D0 [m1p1]=1.1D0 [m1p2]=1.2D0 )
declare -a mord=( m1p2 )


for spin in "${sord[@]}"; do
    for cdir in "${cord[@]}"; do
        for mass in "${mord[@]}"; do
#			# TESTING:
#			echo $spin $cdir $mass
            mkdir -pm 777 $MESA_RUN/$spin/$cdir/$mass
                cp $MESA_BASE/implicit_test_files/xinlist_template $MESA_RUN/$spin/$cdir/$mass/inlist_cluster
                check_okay
                cd $MESA_RUN/$spin/$cdir/$mass
                sed -i 's/s_c_m_/'$spin$cdir$mass'/g; s/cboost_/'${cbvals[$cdir]}'/g; s/imass_/'${mvals[$mass]}'/g; s/SD_/'${svals[$spin]}'/g' inlist_cluster
                check_okay

                $MESA_BASE/star
                check_okay

                cd $MESA_RUN
        done
    done
done
