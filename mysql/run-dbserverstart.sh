#!/bin/bash

function show_case_detail() {
    echo "case config           =${cfg}"
    echo "mysql_cnf             =${mysql_cnf}"
    echo "create_tbl_opt        =${create_tbl_opt}"
    echo "table_data_src_file   =${table_data_src_file}"
    echo "case_id               =${case_id}"
    echo "output_dir            =${output_dir}"
    echo -e "\n"
}

# cfg_list=${cfg_list-"sb/csd-300g-awoff sb/csd-300g-awon sb/csd-2t-awoff sb/csd-2t-awon"}
cfg_list=${cfg_list-"tpcc/csd-500-awoff tpcc/csd-500-awon tpcc/csd-2000-awoff tpcc/csd-2000-awon"}

if [[ "${WORKSPACE}" != "" ]] && [[ -d ${WORKSPACE} ]];
then
        if [ ! -d ${WORKSPACE}/test_output ]; then mkdir -p ${WORKSPACE}/test_output; fi
fi

fail_count=0

for cfg in ${cfg_list}
do

    cfg=${cfg}.cfg
    echo ${run_script} ${cfg}
    
    source ${cfg}; 
    if [ $? -ne 0 ]; 
    then 
        echo "source [${cfg}] failed, try next cfg"
        fail_count=$((${fail_count}+1))
        continue
    fi
    timestamp=`date +%Y%m%d_%H%M%S`
    export output_dir=${result_dir}sb-${timestamp}${case_id}
    show_case_detail
    
    if [ ! -e ${output_dir} ]; then mkdir -p ${output_dir}; fi
    touch ${output_dir}/time_${timestamp}
    mkdir ${output_dir}/scripts
    cp -r ./* ${output_dir}/scripts

    if [ "${prep_dev}" == "yes" ];
    then 
        ./1_prep_dev.sh  ${cfg}
    fi

    if [ "${init_db}" == "yes" ];
    then
        ./2_initdb.sh   ${cfg}
    else
        ./stop.sh
        export MYSQL_PWD=${mysql_pwd}
        disk_mnt="`lsblk -o mountpoint ${disk} | tail -n1`"
        if [[ "${disk_mnt}" != "${mnt_point_data}" ]]
        then
            sudo mount ${mnt_opt} ${disk} ${mnt_point_data}
        fi
        ./start.sh ${cfg}
    fi

    ps -ef  |grep bin/mysqld
    if [ $? -eq 0 ];
    then
       echo "Mysql server started successfully, will exit now"
       exit 0
    fi
done

