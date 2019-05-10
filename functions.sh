curl_request () {
  local _curl_args=("${!1}")
  local _response=$(curl "${_curl_args[@]}" | tr -d "\n")

  if [[ $(printf "%b" "$_response" | grep "${expect_grep_expr[@]}") != "" ]]; then
    echo "${_curl_args[@]}"
  fi
}

attack () {
  local _curl_args=("${!1}")
  local _curr_field_num="$2"
  local _next_field_num=$(( "$_curr_field_num" + 2 ))
  local _num_children=0

  local _curr_field_name="${dict_fields[$_curr_field_num]}"
  local _curr_field_file="${dict_fields[$_curr_field_num+1]}"

  while read line; do
    if [[ "$do_urlencode" -eq 1 ]]; then
      line=$(urlencode "$line")
    fi

    line=$(printf "%q" "$line")

    local _tmp_curl_args=()
    for arg in "${_curl_args[@]}"; do
      _tmp_curl_args+=($(printf "%s" "$arg" | sed "s/{$_curr_field_name}/$line/g"))
    done

    _num_children=$(( $(ps --no-headers -o pid --ppid=$$ | wc -w) - 1 ))

    if [[ "$_num_children" -eq "$max_threads" ]]; then
      while [[ "$_num_children" -gt $(( "$max_threads" / 2 )) ]]; do
        _num_children=$(( $(ps --no-headers -o pid --ppid=$$ | wc -w) - 1 ))
        sleep 1
      done
    fi

    if [[ "$_curr_field_num" -eq $(( "$total_field_num" - 2 )) ]]; then
      curl_request _tmp_curl_args[@]&
    else
      attack _tmp_curl_args[@] "$_next_field_num"
    fi
  done < "$_curr_field_file"
}

# from https://gist.github.com/cdown/1163649
urlencode() {
  local result=""

  old_lc_collate=$LC_COLLATE
  LC_COLLATE=C

  local length="${#1}"
  for (( i = 0; i < length; i++ )); do
    local c="${1:i:1}"
    case $c in
      [a-zA-Z0-9.~_-]) result+="$c" ;;
      *) result+=$(printf '%%%02X' "'$c") ;;
    esac
  done

  LC_COLLATE=$old_lc_collate

  printf '%b' "$result"
}

# from https://gist.github.com/cdown/1163649
urldecode() {
  local url_encoded="${1//+/ }"
  printf '%b' "${url_encoded//%/\\x}"
}
