package disallowdeletewithlabels

get_message(parameters, _default) = msg {
  not parameters.message
  msg := _default
}

get_message(parameters, _default) = msg {
  msg := parameters.message
}

match_label_value(input_original) {
  value := input_original.review.object.metadata.labels[key]
  expected := input_original.parameters.labels[_]
  expected.key == key
  # do not match if allowedRegex is not defined, or is an empty string
  expected.allowedRegex != ""
  re_match(expected.allowedRegex, value)
}

violation[{"msg": msg, "details": {"cannot be deleted having label": required}}] {
  provided := {label | input.review.object.metadata.labels[label]}
  required := {label | label := input.parameters.labels[_].key}
  intersect := required & provided
  
  number := count(intersect)
  number2 := count(required)

  msg2 :=sprintf("%d --- %d,  required:%v----provided:%v", [number,number2, required, provided])
  trace(msg2)

  number!=0
  number2!=0
  number == number2 

  match_label_value(input)

  def_msg := sprintf("cannot be deleted with label: %v", [required])
  msg := get_message(input.parameters, def_msg)

}
