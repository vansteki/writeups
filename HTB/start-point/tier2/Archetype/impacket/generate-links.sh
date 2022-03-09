#!/usr/bin/env bash
cd $(dirname $0)
echo $(pwd)

mkdir /usr/local/sbin/impacket

for file in ./impacket/examples/*.py; do
  echo "generate link: $file -> /usr/local/sbin/impacket-`basename $file`";

  # get the script name
  name_script=$(basename "$file")
  # remove .py extension
  example_name="${name_script%.*}"

  isExists=$(cat $file | grep -c "env python3")
  if [ $isExists -gt 0 ]; then
    echo "$name_script: already using python3 in #!"
  else
      # replace python to python3 of shebang
      sed -i '' 's/env python/env python3/g' $file
  fi

  # make link
  ln -sf $(pwd)/impacket/examples/`basename $file` /usr/local/sbin/impacket/impacket-$example_name
done

# add path to env
isExists=$(grep -c "impacket" ~/.zshrc)
if [ $isExists -gt 0 ]; then
  echo "config already exists"
else
  echo "config path to env"
  echo export PATH=/usr/local/sbin/impacket/:$PATH >> ~/.zshrc
fi

echo 'done!'
echo 'you may need to add export PATH=/usr/local/sbin/impacket/:$PATH to ~/.zshrc or ~/.bashrc'
