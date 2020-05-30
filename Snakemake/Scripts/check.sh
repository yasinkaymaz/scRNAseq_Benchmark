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


for m in MedF1 Acc PercUnl MeanF1;
do
  echo $m;

  echo "" |cat - tools.txt > "$m"_table.txt
  for d in `cat datasets.txt`;
  do
    echo $d > tmp.txt;
    for i in `cat tools.txt`;
    do
      if [ -f $d/BMoutput/$i/"$i"_pred.csv ]; then Rscript eval.R $d/BMoutput/$i/"$i"_true.csv $d/BMoutput/$i/"$i"_pred.csv $m; else echo "NA"; fi
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




#For collecting results from Inter-dataset tests:MedF1 MeanF1 PercUnl Acc
  for m in MeanF1;
  do

    for d in `cat datasets.txt`;
    do
      echo "" |cat - "$d"/indices.txt|cut -f1 > "$d"_"$m"_table.txt;

      for i in `cat tools.txt`;
      do
        #if [ $i == "HieRFIT" ] || [ $i == "Seurat" ]; then dir="./"; else dir="../";fi
        dir='./'
        echo $i > tmp.txt;
        for s in `cut -f1 "$d"/indices.txt`;
        do
          start=`grep $s "$d"/indices.txt|cut -f2`;
          end=`grep $s "$d"/indices.txt|cut -f3`;
          if [ -f $dir/$d/BMoutput/$i/"$i"_pred.csv ]; then Rscript alpha/rfile.R $dir/$d/BMoutput/$i/"$i"_true.csv $dir/$d/BMoutput/$i/"$i"_pred.csv $m $start $end NULL; else echo "NA"; fi
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
        if [ -f $dir/$d/BMoutput/$i/"$i"_pred.csv ]; then Rscript alpha/rfile2.R "$dir"/"$d"/BMoutput/"$i"/"$i"_true.csv "$dir"/"$d"/BMoutput/"$i"/"$i"_pred.csv "$m" "$start" "$end" "$dir"/"$d"/BMoutput/"$i"/1_HieRMod.Rdata.RDS.RDS; else for x in `seq 1 12`;do echo "NA"; done; fi  >> tmp.txt

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

######################




for m in MedF1 Acc PercUnl MeanF1;
do
  echo $m;

  echo "" |cat - tools.txt > "$m"_table.txt
  for d in `cat datasets.txt`;
  do
    echo $d > tmp.txt;
    for i in `cat tools.txt`;
    do
      if [ -f $d/BMoutput/$i/"$i"_pred.csv ]; then Rscript ~/codes/EvaluationFullScale.R  $d/BMoutput/$i/"$i"_true.csv $d/BMoutput/$i/"$i"_pred.csv $m; else echo "NA"; fi
    done >> tmp.txt
    paste -d "\t" "$m"_table.txt tmp.txt > table2.txt;
    rm "$m"_table.txt && mv table2.txt "$m"_table.txt;
  done
  rm tmp.txt

done


for m in "hPRF";
do
  if [ -f "$m"_table.txt ];
    then
      rm "$m"_table.txt && touch "$m"_table.txt;
  else
      touch "$m"_table.txt;
  fi

  row_n=12;
  for i in `cat tools.txt`;
  do
    echo -e "$m\t$i";
    echo $i > tmp.txt;
    for d in `cat datasets.txt`;
    do

      if [ -f $d/BMoutput/$i/"$i"_pred.csv ];
      then
        Rscript ~/codes/EvaluationFullScale.R $d/BMoutput/$i/"$i"_true.csv $d/BMoutput/$i/"$i"_pred.csv $m "cat" "$d"/BMoutput/HieRFIT/1_HieRMod.Rdata.RDS.RDS;
      else
        for x in `seq 1 "$row_n"`;do echo "NA"; done;
      fi
    done >> tmp.txt
    paste -d "\t" "$m"_table.txt tmp.txt > table2.txt;
    rm "$m"_table.txt tmp.txt && mv table2.txt "$m"_table.txt;
  done
  echo  -e "Dataset\tMetric" > tmp.rownames.txt;
  for d in `cut -f1 datasets.txt`;
  do
    for i in `cat hPRF.metrics.txt`;
    do
      echo -e "$d\t$i";
    done
  done >> tmp.rownames.txt
  paste tmp.rownames.txt "$m"_table.txt > table2.txt;
  rm "$m"_table.txt tmp.rownames.txt && mv table2.txt "$m"_table.txt;
done



#Rscript ~/codes/EvaluationFullScale.R $d/BMoutput/ACTINN/ACTINN_true.csv $d/BMoutput/ACTINN/ACTINN_pred.csv "F1" print|awk '{print "F1_"$1}'|sed '1d' >> Stats.names.txt;








for d in `cat datasets.txt`;
do
  echo "" > "$d"_F1_table.txt;
  Rscript ~/codes/EvaluationFullScale.R $d/BMoutput/ACTINN/ACTINN_true.csv $d/BMoutput/ACTINN/ACTINN_pred.csv F1 "print"|sed '1d'|awk '{print $1}' >> "$d"_F1_table.txt;
  let cellTypecount=`Rscript ~/codes/EvaluationFullScale.R $d/BMoutput/ACTINN/ACTINN_true.csv $d/BMoutput/ACTINN/ACTINN_pred.csv F1 "print"|sed '1d'|wc -l`;
    for i in `cat tools.txt`;
    do
      echo $i > tmp.txt;
      if [ -f $d/BMoutput/$i/"$i"_pred.csv ];
        then
        Rscript ~/codes/EvaluationFullScale.R  $d/BMoutput/$i/"$i"_true.csv $d/BMoutput/$i/"$i"_pred.csv F1 "print"|sed '1d'|awk '{print $2}' >> tmp.txt;
      else
        for i in `seq 1 $cellTypecount`;do echo "NA"; done >> tmp.txt;
      fi
      paste -d "\t" "$d"_F1_table.txt tmp.txt > table2.txt;
      rm "$d"_F1_table.txt tmp.txt && mv table2.txt "$d"_F1_table.txt;
    done

  done




#Interdataset all together:
#"MeanF1" "hPRF" "MedF1" "F1" "Acc" "PercInter" "PercUnl" "PopSize"
for m in "MeanF1" "MedF1" "F1" "Acc" "PercInter" "PercUnl" "PopSize";
do
  for d in `cat datasets.txt`;
  do
    echo "" |cat - "$d"/indices.txt|cut -f1 > "$d"_"$m"_table.txt;
    row_n=1;

    for i in `cat tools.txt`;
    do
      echo $i > tmp.txt;

      for s in `cut -f1 "$d"/indices.txt`;
      do
        start=`grep $s "$d"/indices.txt|cut -f2`;
        end=`grep $s "$d"/indices.txt|cut -f3`;

        if [ -f $d/BMoutput/$i/"$i"_pred.csv ];
          then
          Rscript ~/codes/EvaluationFullScale.R "$d"/BMoutput/"$i"/"$i"_true.csv "$d"/BMoutput/"$i"/"$i"_pred.csv "$m" "cat" "$d"/BMoutput/HieRFIT/1_HieRMod.Rdata.RDS.RDS "$start" "$end";
        else
          for x in `seq 1 "$row_n"`;do echo "NA"; done;
        fi

        done >> tmp.txt

        paste -d "\t" "$d"_"$m"_table.txt tmp.txt > table2.txt;
        rm "$d"_"$m"_table.txt tmp.txt && mv table2.txt "$d"_"$m"_table.txt;
    done
  done
done

for m in "hPRF";
do
  for d in `cat datasets.txt`;
  do

    if [ -f "$d"_"$m"_table.txt ];
      then
        #echo "" |cat - hPRF.metrics.txt|cut -f1 > "$d"_"$m"_table.txt;
        rm "$d"_"$m"_table.txt && touch "$d"_"$m"_table.txt;
    else
        touch "$d"_"$m"_table.txt;
    fi

    row_n=12;

    for i in `cat tools.txt`;
    do
      echo $i > tmp.txt;

      for s in `cut -f1 "$d"/indices.txt`;
      do
        start=`grep $s "$d"/indices.txt|cut -f2`;
        end=`grep $s "$d"/indices.txt|cut -f3`;

        if [ -f $d/BMoutput/$i/"$i"_pred.csv ];
          then
          Rscript ~/codes/EvaluationFullScale.R "$d"/BMoutput/"$i"/"$i"_true.csv "$d"/BMoutput/"$i"/"$i"_pred.csv "$m" "cat" "$d"/BMoutput/HieRFIT/1_HieRMod.Rdata.RDS.RDS "$start" "$end";
        else
          for x in `seq 1 "$row_n"`;do echo "NA"; done;
        fi

        done >> tmp.txt

        paste -d "\t" "$d"_"$m"_table.txt tmp.txt > table2.txt;
        rm "$d"_"$m"_table.txt tmp.txt && mv table2.txt "$d"_"$m"_table.txt;
    done

    echo  -e "Dataset\tMetric" > tmp.rownames.txt;

    for s in `cut -f1 "$d"/indices.txt`;
    do
      for i in `cat hPRF.metrics.txt`;
      do
        echo -e "$s\t$i";
      done
    done >> tmp.rownames.txt

    paste tmp.rownames.txt "$d"_"$m"_table.txt > table2.txt;
    rm "$d"_"$m"_table.txt tmp.rownames.txt && mv table2.txt "$d"_"$m"_table.txt;

  done
done
