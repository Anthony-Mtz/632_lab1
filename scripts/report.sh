for FILE in NIST_data/*.txt
    do
       #../bin/backconer s9234_comb.bench ${flop} | tee backconer/${flop}.backcone
       echo ${FILE}
       python report_parse.py -f ${FILE}
    done