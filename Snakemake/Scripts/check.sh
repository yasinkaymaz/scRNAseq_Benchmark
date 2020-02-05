#!/bin/bash

echo "" |cat - tools.txt > table.txt
for d in `cat datasets.txt`;
do
  echo $d > tmp.txt;
  for i in `cat tools.txt`;
  do
    if [ -f $d/BMoutput/$i/"$i"_pred.csv ]; then echo "yes"; else echo "no"; fi
  done >> tmp.txt
  paste -d "\t" table.txt tmp.txt > table2.txt;
  rm table.txt && mv table2.txt table.txt;
done

rm tmp.txt


for m in MedF1 Acc PercUnl;
do
  echo $m;

  echo "" |cat - tools.txt > "$m"_table.txt
  for d in `cat datasets.txt`;
  do
    echo $d > tmp.txt;
    for i in `cat tools.txt`;
    do
      if [ -f $d/BMoutput/$i/"$i"_pred.csv ]; then Rscript rfile.R $d/BMoutput/$i/"$i"_true.csv $d/BMoutput/$i/"$i"_pred.csv $m; else echo "NA"; fi
    done >> tmp.txt
    paste -d "\t" "$m"_table.txt tmp.txt > table2.txt;
    rm "$m"_table.txt && mv table2.txt "$m"_table.txt;
  done
  rm tmp.txt

done

for i in `cat datasets.txt`;
do
  datafile=`grep datafile $i/config.yml|cut -d " " -f2`;
  labelfile=`grep labfile $i/config.yml|cut -d " " -f2`;
  col=`grep column $i/config.yml|cut -d " " -f2`;
  Comp=`Rscript complex.R $datafile $labelfile $col`;
  echo -e "$i\t$Comp ";
done >> dataComplexities_UQ.txt

for d in `cat datasets.txt`;
do
  labelfile=`grep labfile $d/config.yml|cut -d " " -f2`;
  col=`grep column $d/config.yml|cut -d " " -f2`;
  cut -d, -f $col $labelfile > "$d"_cellType_labels.txt;
done

for d in `cat datasets.txt`;
do
  echo "" > "$d"_F1_table.txt;
  Rscript rfile.R $d/BMoutput/ACTINN/ACTINN_true.csv $d/BMoutput/ACTINN/ACTINN_pred.csv F1|sed '1d'|awk '{print $1}' >> "$d"_F1_table.txt;
  let cellTypecount=`Rscript rfile.R $d/BMoutput/ACTINN/ACTINN_true.csv $d/BMoutput/ACTINN/ACTINN_pred.csv F1|sed '1d'|wc -l`;
    for i in `cat tools.txt`;
    do
      echo $i > tmp.txt;
      if [ -f $d/BMoutput/$i/"$i"_pred.csv ];
        then Rscript rfile.R $d/BMoutput/$i/"$i"_true.csv $d/BMoutput/$i/"$i"_pred.csv F1|sed '1d'|awk '{print $2}' >> tmp.txt;
      else
        for i in `seq 1 $cellTypecount`;do echo "NA"; done >> tmp.txt;
      fi
      paste -d "\t" "$d"_F1_table.txt tmp.txt > table2.txt;
      rm "$d"_F1_table.txt tmp.txt && mv table2.txt "$d"_F1_table.txt;
    done

  done




#For collecting results from Inter-dataset tests:MedF1 PercUnl Acc
  for m in PercInter;
  do

    for d in `cat datasets.txt`;
    do
      echo "" |cat - "$d"/indices.txt|cut -f1 > "$d"_"$m"_table.txt;

      for i in `cat tools.txt`;
      do
        if [ $i == "HieRFIT" ] || [ $i == "Seurat" ]; then dir="./"; else dir="../";fi
        echo $i > tmp.txt;
        for s in `cut -f1 "$d"/indices.txt`;
        do
          start=`grep $s "$d"/indices.txt|cut -f2`;
          end=`grep $s "$d"/indices.txt|cut -f3`;
          if [ -f $dir/$d/BMoutput/$i/"$i"_pred.csv ]; then Rscript rfile.R $dir/$d/BMoutput/$i/"$i"_true.csv $dir/$d/BMoutput/$i/"$i"_pred.csv $m $start $end NULL; else echo "NA"; fi
        done >> tmp.txt
        paste -d "\t" "$d"_"$m"_table.txt tmp.txt > table2.txt;
        rm "$d"_"$m"_table.txt tmp.txt && mv table2.txt "$d"_"$m"_table.txt;
      done

    done

  done


  m="hPRF";
  dir="./";
  i='HieRFIT';
    for d in `cat datasets.txt`;
    do
      echo "" |cat - hPRF.metrics.txt|cut -f1 > "$d"_"$m"_table.txt;
      for s in `cut -f1 "$d"/indices.txt`;
      do
        echo $s > tmp.txt;
        start=`grep $s "$d"/indices.txt|cut -f2`;
        end=`grep $s "$d"/indices.txt|cut -f3`;
        if [ -f $dir/$d/BMoutput/$i/"$i"_pred.csv ]; then Rscript rfile2.R "$dir"/"$d"/BMoutput/"$i"/"$i"_true.csv "$dir"/"$d"/BMoutput/"$i"/"$i"_pred.csv "$m" "$start" "$end" "$dir"/"$d"/BMoutput/"$i"/1_HieRMod.Rdata.RDS; else for i in `seq 1 12`;do echo "NA"; done; fi  >> tmp.txt

        paste -d "\t" "$d"_"$m"_table.txt tmp.txt > table2.txt;
        rm "$d"_"$m"_table.txt tmp.txt && mv table2.txt "$d"_"$m"_table.txt;
      done
    done





  for i in `cat datasets.txt`;
  do
    echo $i;
    datafile=`grep datafile $i/config.yml|cut -d " " -f2`;
    sed '1d' $datafile |cut -d, -f1-10|head -1;
  done
