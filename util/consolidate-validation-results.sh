
OUTFILE="test.csv"
echo "type,trial,measure"

for tputtype in "dl" "ul"; do
  for file in tmp/"$tputtype"rate-*; do
    lines=$(cat "$file" | grep "SUM" | head -12 | tail -10 )
    mBytes=$(echo -e "$lines" | grep "MBytes" |  awk '{sum+=$4} END {print sum}')
    kBytes=$(echo -e "$lines" | grep "KBytes" |  awk '{sum+=$4} END {print sum}')
    Bytes=$(echo $lines | grep " Bytes" |  awk '{sum+=$4} END {print sum}')
    [[  -z  $mBytes  ]] && mBytes=0
    [[  -z  $kBytes  ]] && kBytes=0
    [[  -z  $Bytes  ]] && Bytes=0
    begintime=$(cat "$file" | grep "SUM" | head -3 | tail -1 | awk '{print $2}' | cut -f1 -d'-')
    endtime=$(cat "$file" | grep "SUM" | head -12 | tail -1 | awk '{print $2}' | cut -f2 -d'-')
    throughput=$(bc <<< "scale=5; 8*($mBytes*1000 + $kBytes + $Bytes/1000)/($endtime - $begintime)" )
    mtype="$tputtype"rate
    trial=$(echo $file | awk -F'[-.]' '{print $2}')

    echo "$mtype,$trial,$throughput"
  done
done

for file in tmp/ping*; do

  mtype="latency"
  latency=$(cat $file | tail -1 | cut -d'/' -f5)
  trial=$(echo $file | awk -F'[-.]' '{print $2}')
  echo "$mtype,$trial,$latency"
done

for file in tmp/udp*; do

    mtype="loss"
    loss=$(cat $file | grep '%' | tail -1 | cut -d'(' -f2 | cut -d'%' -f1 )
    trial=$(echo $file | awk -F'[-.]' '{print $2}')
    echo "$mtype,$trial,$loss"
done

for file in tmp/udp*; do

    mtype="dljitter"
    dljitter=$(cat $file | grep '%' | tail -1 | awk '{print $9}')
    trial=$(echo $file | awk -F'[-.]' '{print $2}')
    echo "$mtype,$trial,$dljitter"
done

for file in tmp/udp*; do

    mtype="uljitter"
    uljitter=$(cat $file | grep '%' | head -1 | awk '{print $9}')
    trial=$(echo $file | awk -F'[-.]' '{print $2}')
    echo "$mtype,$trial,$uljitter"
done

