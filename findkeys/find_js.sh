#/bin/sh

findKeyFile="to_find.json"
findPath="/.../.../"
findCount=`cat $findKeyFile | ./jq -r '. | length'`
hasThings=()

echo $findCount

index=0
while [ "$index" -lt "$findCount" ]; do
   
    some="keys[""$index""]"

	findKey=`cat to_find.json | ./jq -r $some`
	findKey="\"""$findKey""\""

	result=`find $findPath -type f -name "*" | xargs grep -i -s $findKey`

	if [ -n "$result" ];then
		hasThings+=($findKey)
		echo "----------------"
		echo "$findKey""   ->"
		echo $result
		echo "----------------\n\n"
	else
		echo "----------------"
		echo "$findKey""   ->"
		echo "Nothing"
		echo "----------------\n\n"
	fi

	index=`expr $index + 1`
done

echo "Count ="" ${#hasThings[@]}"
echo ${hasThings[@]}

