#!/bin/bash
SCRIPTPATH=$( cd "$(dirname "$0")" && pwd -P )
ROOTDIR=$SCRIPTPATH/..
cd "$ROOTDIR" || exit

ADD_LICENSE=$1
THISYEAR=$(date +"%Y")
if [[ $ADD_LICENSE == true ]]; then
  echo "Check License script is running in ADD_LICENSE mode. It will automatically add any missing licenses for you."
fi

ret=0
for fn in $(find "${ROOTDIR}" -name '*.go' | grep -v vendor | grep -v testdata); do
  if [[ $fn == *.pb.go ]];then
    continue
  fi

  if head -20 "$fn" | grep "auto\\-generated" > /dev/null; then
          continue
  fi

  if head -20 "$fn" | grep "DO NOT EDIT" > /dev/null; then
          continue
  fi

  if ! head -20 "$fn" | grep "Apache License, Version 2" > /dev/null; then
    if [[ $ADD_LICENSE == true ]]; then
      echo "// Copyright ${THISYEAR} Istio Authors
//
// Licensed under the Apache License, Version 2.0 (the \"License\");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an \"AS IS\" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

$(cat "${fn}")" > "${fn}"
    else
      echo "${fn} missing license"
      ret=$((ret+1))
    fi
  fi

  if ! head -20 "$fn" | grep Copyright > /dev/null; then
    echo "${fn} missing Copyright"
    ret=$((ret+1))
  fi
done

exit $ret
