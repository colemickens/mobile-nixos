DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
set -e
set -u

shopt -s extglob

set -x; trap "set +x" EXIT

bdencoder="${DIR}/ath10k-bdencoder"

mkdir bdf
trap "rm -rf bdf" EXIT
cp -vt "bdf/" bdwlan*bin

JSON="bdf/board-2.json"
        
iter=0
echo "[" > "${JSON}"

ls -al bdf/
ls -al bdf/bdwlan*

for file in bdf/bdwlan*; do
  [[ $file == *.txt ]] && continue
                 
  iter=$((iter+1))
  [ $iter -ne 1 ] && echo "  }," >> "${JSON}"
                 
  echo "  {" >> "${JSON}"
  echo "          \"data\": \"$file\"," >> "${JSON}"
  if [[ $file == */bdwlan.bin ]]; then
    file_ext="ff"
  else
    piece="(basename "${file}" | sed -E 's:^.*\.b?([0-9a-f]*)$:0x\1:')"
    echo "$piece"
    file_ext="$(printf '%x\n' "$piece")"
  fi
  echo "          \"names\": [\"bus=snoc,qmi-board-id=${file_ext}\"]" >> "${JSON}"
done
                        
echo "  }" >> "${JSON}"
echo "]" >> "${JSON}"
                        
"${bdencoder}" -c "${JSON}" -o board-2.bin
