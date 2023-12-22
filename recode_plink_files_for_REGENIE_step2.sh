pgenfile_prefix=$1
output_prefix=$1

plink2 \
--pfile ${pgenfile_prefix} \
--memory 8000 \
--make-pgen \
--maj-ref force \
--out ${output_prefix}